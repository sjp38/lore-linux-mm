Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E9CF46B006C
	for <linux-mm@kvack.org>; Mon, 31 Oct 2011 13:56:11 -0400 (EDT)
Date: Mon, 31 Oct 2011 18:14:41 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: kernel 3.0: BUG: soft lockup: find_get_pages+0x51/0x110
Message-ID: <20111031171441.GD3466@redhat.com>
References: <201110122012.33767.pluto@agmk.net>
 <20111021174120.GJ608@redhat.com>
 <20111021225008.GK608@redhat.com>
 <201110221352.22741.nai.xia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201110221352.22741.nai.xia@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Pawel Sikora <pluto@agmk.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, jpiszcz@lucidpixels.com, arekm@pld-linux.org, linux-kernel@vger.kernel.org

On Sat, Oct 22, 2011 at 01:52:22PM +0800, Nai Xia wrote:
> BTW, I am curious about what benchmark did you run and " x10 boost"
> meaning compared to Hugh's anon_vma_locking fix?

I was referring to the mremap optimizations I pushed in -mm.

> This patch and together with the reasoning looks good to me. 
> But I wondering this patch can make the anon_vma chain ordering game more 
> complex and harder to play in the future.

Well we don't know yet what future will bring... at least this adds
some documentation on the fact the order matters for
fork/mremap/migrate/split_huge_page. As far as I can tell they're the
4 pieces of the VM where the rmap_walk order matters. And
split_huge_page and migrate are the only two where if the rmap_walk
fails we can't safely continue and have to BUG_ON.

> However, if it does bring much perfomance benefit, I vote for this patch 
> because it balances all three requirements here: bug free, performance &
> no two VMAs stay not merged for no good reason.

I suppose it should bring an SMP performance benefit as the critical
section is reduced but we'll have to do some more list_del/add_tail
than if we take the global lock...

> Our situation again makes me have the strong feeling that we are really
> in bad need of a computer aided way to travel all possible state space.
> There are some guys around me who do automatic software testing research.
> But I am afraid our problem is too much "real world" for them... sigh...  

Also the code changes too fast for that...

I'll send the patch again with signoff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
