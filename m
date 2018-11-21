Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 499BB6B231E
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 20:56:22 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 80so5399496qkd.0
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 17:56:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d19si10033712qvd.218.2018.11.20.17.56.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 17:56:21 -0800 (PST)
Date: Tue, 20 Nov 2018 20:56:14 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH v1 1/8] mm: balloon: update comment about
 isolation/migration/compaction
Message-ID: <20181120204655-mutt-send-email-mst@kernel.org>
References: <20181119101616.8901-1-david@redhat.com>
 <20181119101616.8901-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119101616.8901-2-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>

On Mon, Nov 19, 2018 at 11:16:09AM +0100, David Hildenbrand wrote:
> Commit b1123ea6d3b3 ("mm: balloon: use general non-lru movable page
> feature") reworked balloon handling to make use of the general
> non-lru movable page feature. The big comment block in
> balloon_compaction.h contains quite some outdated information. Let's fix
> this.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  include/linux/balloon_compaction.h | 26 +++++++++-----------------
>  1 file changed, 9 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> index 53051f3d8f25..cbe50da5a59d 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -4,15 +4,18 @@
>   *
>   * Common interface definitions for making balloon pages movable by compaction.
>   *
> - * Despite being perfectly possible to perform ballooned pages migration, they
> - * make a special corner case to compaction scans because balloon pages are not
> - * enlisted at any LRU list like the other pages we do compact / migrate.
> + * Balloon page migration makes use of the general non-lru movable page
> + * feature.
> + *
> + * page->private is used to reference the responsible balloon device.
> + * page->mapping is used in context of non-lru page migration to reference
> + * the address space operations for page isolation/migration/compaction.
>   *
>   * As the page isolation scanning step a compaction thread does is a lockless
>   * procedure (from a page standpoint), it might bring some racy situations while
>   * performing balloon page compaction. In order to sort out these racy scenarios
>   * and safely perform balloon's page compaction and migration we must, always,
> - * ensure following these three simple rules:
> + * ensure following these simple rules:
>   *
>   *   i. when updating a balloon's page ->mapping element, strictly do it under
>   *      the following lock order, independently of the far superior
> @@ -21,19 +24,8 @@
>   *	      +--spin_lock_irq(&b_dev_info->pages_lock);
>   *	            ... page->mapping updates here ...
>   *
> - *  ii. before isolating or dequeueing a balloon page from the balloon device
> - *      pages list, the page reference counter must be raised by one and the
> - *      extra refcount must be dropped when the page is enqueued back into
> - *      the balloon device page list, thus a balloon page keeps its reference
> - *      counter raised only while it is under our special handling;
> - *
> - * iii. after the lockless scan step have selected a potential balloon page for
> - *      isolation, re-test the PageBalloon mark and the PagePrivate flag
> - *      under the proper page lock, to ensure isolating a valid balloon page
> - *      (not yet isolated, nor under release procedure)
> - *
> - *  iv. isolation or dequeueing procedure must clear PagePrivate flag under
> - *      page lock together with removing page from balloon device page list.
> + *  ii. isolation or dequeueing procedure must remove the page from balloon
> + *      device page list under b_dev_info->pages_lock.
>   *
>   * The functions provided by this interface are placed to help on coping with
>   * the aforementioned balloon page corner case, as well as to ensure the simple
> -- 
> 2.17.2
