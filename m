Received: by wx-out-0506.google.com with SMTP id h31so16056wxd.11
        for <linux-mm@kvack.org>; Thu, 21 Feb 2008 04:29:31 -0800 (PST)
Message-ID: <44c63dc40802210429y24757a34p2cc8093a2db6181a@mail.gmail.com>
Date: Thu, 21 Feb 2008 21:29:30 +0900
From: "minchan Kim" <barrioskmc@gmail.com>
Subject: Re: [RFC][PATCH] the proposal of improve page reclaim by throttle
In-Reply-To: <2f11576a0802210255k1e3acad7n87814e916fd24509@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080220181447.6444.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <44c63dc40802200149r6b03d970g2fbde74b85ad5443@mail.gmail.com>
	 <20080220185648.6447.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <44c63dc40802210138s100e921ekde01b30bae13beb1@mail.gmail.com>
	 <2f11576a0802210255k1e3acad7n87814e916fd24509@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2008 at 7:55 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> Hi Kim-san,
>
>  Thank you very much.
>  btw, what different between <test 1> and <test 2>?

<test 1> have no swap device with 200 tasks by hackbench.
But <test 2> have swap device(32M) with 240 tasks by hackbench.
If <test2> have no swap device without your patch, <test2> is killed by OOM.

<test 1> - NO SWAP
Running with 5*40 (== 200) tasks.
...
<test 2> - SWAP
Running with 6*40 (== 240) tasks.
...

>
>  >  It was a very interesting result.
>  >  In embedded system, your patch improve performance a little in case
>  >  without noswap(normal case in embedded system).
>  >  But, more important thing is OOM occured when I made 240 process
>  >  without swap device and vanilla kernel.
>  >  Then, I applied your patch, it worked very well without OOM.
>
>  Wow, it is very interesting result!
>  I am very happy.
>
>
>  >  I think that's why zone's page_scanned was six times greater than
>  >  number of lru pages.
>  >  At result, OOM happened.
>
>  please repost question with change subject.
>  i don't know reason of vanilla kernel behavior, sorry.

Normally, embedded linux have only one zone(DMA).

If your patch isn't applied, several processes can reclaim memory in parallel.
then, DMA zone's pages_scanned is suddenly increased largely. Because
embedded linux have no swap device,  kernel can't stop to scan lru
list until meeting page cache page. so if zone->pages_scanned is
greater six time than lru list pages, kernel make the zone with
unreclaimable state, As a result, OOM will kill it, too.

-- 
Thanks,
barrios

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
