Subject: Re: [PATCH 6/9] clockpro-clockpro.patch
From: Peter Zijlstra <peter@programming.kicks-ass.net>
In-Reply-To: <20060208100505.247D874034@sv1.valinux.co.jp>
References: <20051230223952.765.21096.sendpatchset@twins.localnet>
	 <20051230224312.765.58575.sendpatchset@twins.localnet>
	 <20051231002417.GA4913@dmt.cnet> <1136028546.17853.69.camel@twins>
	 <20060105094722.897C574030@sv1.valinux.co.jp>
	 <Pine.LNX.4.63.0601050830530.18976@cuia.boston.redhat.com>
	 <20060106090135.3525D74031@sv1.valinux.co.jp>
	 <20060124063010.B85C77402D@sv1.valinux.co.jp>
	 <20060124072503.BAF6A7402F@sv1.valinux.co.jp>
	 <1138958705.5450.9.camel@localhost.localdomain>
	 <20060208100505.247D874034@sv1.valinux.co.jp>
Content-Type: text/plain
Date: Wed, 08 Feb 2006 21:00:10 +0100
Message-Id: <1139428810.4668.20.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: IWAMOTO Toshihiro <iwamoto@valinux.co.jp>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Christoph Lameter <christoph@lameter.com>, Wu Fengguang <wfg@mail.ustc.edu.cn>, Nick Piggin <npiggin@suse.de>, Marijn Meijles <marijn@bitpit.net>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-02-08 at 19:05 +0900, IWAMOTO Toshihiro wrote:
> I've noticed the way page_replace_reinsert puts pages to a list is
> different from what the paper (TR-05-3.pdf) says.

I reread the paper, and you seem to have found a detail I had not
noticed before. Thanks!

It concerns section 4.3 paragraph 2 and the use of list head as defined
in section 4.2 paragraph 2.

The way I read it is that pages that have their reference bit set are
moved to the list head, which according to 4.2.2 is the page right in
front of hand hot (which would correspond to the tail of the HAND_HOT
list).

So I agree the current code is wrong. However I read it differently.

In your patch you move all Hot pages to the head of the hot list, which
effectively leaves them in place. The other pages are moved to the head
of the cold list, which is right behind hand hot.

So I don't see your condition nor the placement. Could you explain your
reasoning?

Kind regards,

Peter Zijlstra


> I wonder if this divergence is intended or not, but the attached patch
> gave a major improvement.
> Also, I think there's no reason to call __select_list_hand in those
> functions.
> 
>  n   unpatched   patched
> ========================
> 100   392283     595229
> 200   393087	 584397
> 300   309595	 521259
> 400   283340	 400243
> 500   132298	 303189
> 
> --- linux-2.6.16-rc1-git3-clockpro/mm/clockpro.c.save	2006-02-08 17:20:40.000000000 +0900
> +++ linux-2.6.16-rc1-git3-clockpro/mm/clockpro.c	2006-02-08 17:21:16.000000000 +0900
> @@ -446,7 +446,10 @@ void page_replace_reinsert(struct list_h
>  			spin_lock_irq(&zone->lru_lock);
>  			__select_list_hand(zone, &zone->policy.list_hand[HAND_HOT]);
>  		}
> -		list_move(&page->lru, &zone->policy.list_hand[HAND_HOT]);
> +		if (!PageHot(page))
> +			list_move(&page->lru, &zone->policy.list_hand[HAND_COLD]);
> +		else
> +			list_move(&page->lru, &zone->policy.list_hand[HAND_HOT]);
>  		__page_release(zone, page, &pvec);
>  	}
>  	if (zone)
> @@ -520,7 +523,10 @@ void page_replace_reinsert_zone(struct z
>  			++dct;
>  		}
>  
> -		list_move(&page->lru, &zone->policy.list_hand[HAND_HOT]);
> +		if (!PageHot(page))
> +			list_move(&page->lru, &zone->policy.list_hand[HAND_COLD]);
> +		else
> +			list_move(&page->lru, &zone->policy.list_hand[HAND_HOT]);
>  		__page_release(zone, page, &pvec);
>  	}
>  	__cold_target_inc(zone, dct);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
