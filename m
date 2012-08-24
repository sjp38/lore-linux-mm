Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 5EAEF6B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 20:39:08 -0400 (EDT)
Date: Thu, 23 Aug 2012 21:38:48 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v8 1/5] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20120824003848.GH10777@t510.redhat.com>
References: <20120823021903.GA23660@x61.redhat.com>
 <20120823100107.GA17409@redhat.com>
 <20120823121338.GA3062@t510.redhat.com>
 <20120823123432.GA25659@redhat.com>
 <20120823130606.GB3746@t510.redhat.com>
 <20120823135328.GB25709@redhat.com>
 <20120823162504.GA1522@redhat.com>
 <20120823172844.GC10777@t510.redhat.com>
 <20120823233616.GB2775@redhat.com>
 <20120824003353.GG10777@t510.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120824003353.GG10777@t510.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Thu, Aug 23, 2012 at 09:33:53PM -0300, Rafael Aquini wrote:
> On Fri, Aug 24, 2012 at 02:36:16AM +0300, Michael S. Tsirkin wrote:
> > I would wake it each time after adding a page, then it
> > can stop waiting when it leaks enough.
> > But again, it's cleaner to just keep tracking all
> > pages, let mm hang on to them by keeping a reference.
> > 

Btw, it's also late here, and there still some work to be done around those
bits, but I guess that has potential to get this issue nailed.

> Here is a rough idea on how it's getting:
> 
> Basically, I'm have introducing an atomic counter to track isolated pages, I
> also have changed vb->num_pages into an atomic conter. All inc/dec operations
> take place under pages_lock spinlock, and we only perform work under page lock.
> 
> It's still missing the wait-part (I'll write it during the weekend) and your
> concerns (and mine) will be addressed, IMHO.
> 
> ---8<---
> +/*
> + *
> + */
> +static inline void __wait_on_isolated_pages(struct virtio_balloon *vb,
> +                                           size_t num)
> +{
> +       /* There are no isolated pages for this balloon device */
> +       if (!atomic_read(&vb->num_isolated_pages))
> +               return;
> +
> +       /* the leak target is smaller than # of pages on vb->pages list */
> +       if (num < (atomic_read(&vb->num_pages) -
> +           atomic_read(&vb->num_isolated_pages)))
> +               return;
> +       else {
> +               spin_unlock(&vb->pages_lock);
> +               /* wait stuff goes here */
> +               spin_lock(&vb->pages_lock);
> +       }
> +}
> +
>  static void leak_balloon(struct virtio_balloon *vb, size_t num)
>  {
> -       struct page *page;
> +       /* The array of pfns we tell the Host about. */
> +       unsigned int num_pfns;
> +       u32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
> 
>         /* We can only do one array worth at a time. */
> -       num = min(num, ARRAY_SIZE(vb->pfns));
> +       num = min(num, ARRAY_SIZE(pfns));
> 
> -       for (vb->num_pfns = 0; vb->num_pfns < num;
> -            vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> -               page = list_first_entry(&vb->pages, struct page, lru);
> -               list_del(&page->lru);
> -               set_page_pfns(vb->pfns + vb->num_pfns, page);
> -               vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
> +       for (num_pfns = 0; num_pfns < num;
> +            num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
> +               struct page *page = NULL;
> +               spin_lock(&vb->pages_lock);
> +               __wait_on_isolated_pages(vb, num);
> +
> +               if (!list_empty(&vb->pages))
> +                       page = list_first_entry(&vb->pages, struct page, lru);
> +               /*
> +                * Grab the page lock to avoid racing against threads isolating
> +                * pages from, or migrating pages back to vb->pages list.
> +                * (both tasks are done under page lock protection)
> +                *
> +                * Failing to grab the page lock here means this page is being
> +                * isolated already, or its migration has not finished yet.
> +                */
> +               if (page && trylock_page(page)) {
> +                       clear_balloon_mapping(page);
> +                       list_del(&page->lru);
> +                       set_page_pfns(pfns + num_pfns, page);
> +                       atomic_sub(VIRTIO_BALLOON_PAGES_PER_PAGE,
> +                                  &vb->num_pages);
> +                       unlock_page(page);
> +               }
> +               spin_unlock(&vb->pages_lock);
>         }
> 
>         /*
> @@ -182,8 +251,10 @@ static void leak_balloon(struct virtio_balloon *vb, size_t
> num)
>          * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
>          * is true, we *have* to do it in this order
>          */
> +       mutex_lock(&vb->balloon_lock);
>         tell_host(vb, vb->deflate_vq);
> -       release_pages_by_pfn(vb->pfns, vb->num_pfns);
> +       mutex_unlock(&vb->balloon_lock);
> +       release_pages_by_pfn(pfns, num_pfns);
>  }
> ---8<---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
