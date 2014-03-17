Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 386116B0069
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 00:39:35 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so5076377pdj.17
        for <linux-mm@kvack.org>; Sun, 16 Mar 2014 21:39:34 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2402:b800:7003:1:1::1])
        by mx.google.com with ESMTPS id j4si8983843pad.104.2014.03.16.21.39.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Mar 2014 21:39:34 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: mmotm 2014-03-10-15-35 uploaded (virtio_balloon)
In-Reply-To: <20140311214014.GA18708@leaf>
References: <20140310223701.0969C31C2AA@corp2gmr1-1.hot.corp.google.com> <531F43F2.1030504@infradead.org> <20140311110338.333e1ee691cadb0f20dbb083@linux-foundation.org> <20140311192046.GA2686@leaf> <20140311123133.f40adf3154452e82aecb61ca@linux-foundation.org> <20140311214014.GA18708@leaf>
Date: Mon, 17 Mar 2014 14:02:31 +1030
Message-ID: <877g7tts8g.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Randy Dunlap <rdunlap@infradead.org>, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, virtio-dev@lists.oasis-open.org, "Michael S. Tsirkin" <mst@redhat.com>

Josh Triplett <josh@joshtriplett.org> writes:
> On Tue, Mar 11, 2014 at 12:31:33PM -0700, Andrew Morton wrote:
> I'd love to do that, but as far as I can tell, VIRTIO_BALLOON has gone
> out of its way to support !CONFIG_BALLOON_COMPACTION.
>
> Could someone who works on VIRTIO_BALLOON provide some details here
> about the distinction?

Balloon gives pages back to the host.  If you want to do compaction,
we'll try to help you, but it's independent.

The normal way to do this would be to put a dummy inline version of
balloon_page_enqueue etc in the header.  If you look at how the virtio
balloon code looked before e22504296d4f64fbbbd741602ab47ee874649c18
you'll see what it should do, eg:

#ifndef CONFIG_BALLOON_COMPACTION
struct balloon_dev_info {
	struct list_head pages;		/* Pages enqueued & handled to Host */
};

static inline struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
{
        struct page *page = alloc_page(GFP_HIGHUSER | __GFP_NORETRY |
                                       __GFP_NOMEMALLOC | __GFP_NOWARN)
        if (page)
                list_add(&page->lru, &b_dev_info->pages);

        return page;
}

static inline struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
{
        struct page *page;
        page = list_first_entry(&b_dev_info->pages, struct page, lru);
        list_del(&page->lru);
        return page;
}

static inline void balloon_page_free(struct page *page)
{
        __free_page(page);
}
#else
...

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
