Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 457516B0062
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 03:41:12 -0500 (EST)
Date: Wed, 16 Jan 2013 17:41:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 1/3] slub: correct to calculate num of acquired objects
 in get_partial_node()
Message-ID: <20130116084114.GA13446@lge.com>
References: <1358234402-2615-1-git-send-email-iamjoonsoo.kim@lge.com>
 <0000013c3ee3b69a-80cfdc68-a753-44e0-ba68-511060864128-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013c3ee3b69a-80cfdc68-a753-44e0-ba68-511060864128-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 15, 2013 at 03:46:17PM +0000, Christoph Lameter wrote:
> On Tue, 15 Jan 2013, Joonsoo Kim wrote:
> 
> > There is a subtle bug when calculating a number of acquired objects.
> > After acquire_slab() is executed at first, page->inuse is same as
> > page->objects, then, available is always 0. So, we always go next
> > iteration.
> 
> page->inuse is always < page->objects because the partial list is not used
> for slabs that are fully allocated. page->inuse == page->objects means
> that no objects are available on the slab and therefore the slab would
> have been removed from the partial list.

Currently, we calculate "available = page->objects - page->inuse",
after acquire_slab() is called in get_partial_node().

In acquire_slab() with mode = 1, we always set new.inuse = page->objects.
So

		acquire_slab(s, n, page, object == NULL);

                if (!object) {
                        c->page = page;
                        stat(s, ALLOC_FROM_PARTIAL);
                        object = t; 
                        available =  page->objects - page->inuse;

			!!!!!! available is always 0 !!!!!!


                } else {
                        available = put_cpu_partial(s, page, 0);
                        stat(s, CPU_PARTIAL_NODE);
                }

Therefore, "available > s->cpu_partial / 2" is always false and
we always go to second iteration.
This patch correct this problem.

> > After that, we don't need return value of put_cpu_partial().
> > So remove it.
> 
> Hmmm... The code looks a bit easier to understand than what we have right now.
> 
> Could you try to explain it better?
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
