Subject: Re: [PATCH]: VM 5/8 async-writepage
From: Nick Piggin <nickpiggin@yahoo.com.au>
In-Reply-To: <17006.4715.211258.938496@gargle.gargle.HOWL>
References: <16994.40662.865338.484778@gargle.gargle.HOWL>
	 <20050425205706.55fe9833.akpm@osdl.org>
	 <17005.64094.860824.34597@gargle.gargle.HOWL>
	 <20050426013632.55e958c8.akpm@osdl.org>
	 <17006.4715.211258.938496@gargle.gargle.HOWL>
Content-Type: text/plain
Date: Tue, 26 Apr 2005 20:22:55 +1000
Message-Id: <1114510975.5097.10.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2005-04-26 at 14:05 +0400, Nikita Danilov wrote:
> Andrew Morton writes:
>  > Seems a bit pointless then?
> 
> Err.. why? With this patch, if there is small memory shortage, and dirty
> pages on the end of the inactive list are rare (usual case),
> alloc_pages() will return quickly after reclaiming clean pages, allowing
> memory consuming operation to complete faster. If there is severe memory
> shortage (priority < KPGOUT_PRIORITY), ->writepage() calls are done
> synchronously, so there is no risk of deadlock.
> 

It is adding a lot of state/behavioural complexity, which is
unfortunate considering we barely manage to keep page reclaim
doing the right thing at the best of times :(

I agree with Andrew. kswapd provides one layer of asynchronous
reclaim, and in the rare case of direct reclaim, ->writepage is
usually asynchronous as well.

We'll never be able to eliminate all stalls. And under really
heavy memory pressure most of the stalls are probably going to
be coming from actually waiting for a page to be cleaned and
freed, or *reading* in the working set.

>  > 
>  > Have you quantified this?
> 
> Yes, (copied from original message that introduced patches):
> 
> before after
>   45.4  45.8
>  214.4 204.3
>  199.1 194.8
>  208.3 194.9
>  199.5 197.7
>  206.8 195.0
>  200.8 199.4
>  204.7 196.3
> 
> In that micro-benchmark memory pressure is high, so not a lot of
> asynchronous pageout is done. More testing will be a good thing of
> course, isn't this what -mm is for? :)
> 

I'd rather see a real benefit *first*, even for -mm :)


-- 
SUSE Labs, Novell Inc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
