Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f46.google.com (mail-vn0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 75F27900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 09:54:03 -0400 (EDT)
Received: by vnbf7 with SMTP id f7so9069135vnb.13
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 06:54:03 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x5si13542104vdx.36.2015.06.05.06.54.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 06:54:01 -0700 (PDT)
Date: Fri, 5 Jun 2015 09:53:51 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [RFC 0/4] enable migration of non-LRU pages
Message-ID: <20150605135350.GE10661@t510.redhat.com>
References: <1433230065-3573-1-git-send-email-gioh.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433230065-3573-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: jlayton@poochiereds.net, bfields@fieldses.org, akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mst@redhat.com, kirill@shutemov.name, minchan@kernel.org, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, gunho.lee@lge.com

On Tue, Jun 02, 2015 at 04:27:40PM +0900, Gioh Kim wrote:
> Hello,
> 
> This series try to enable migration of non-LRU pages, such as driver's page.
> 
> My ARM-based platform occured severe fragmentation problem after long-term
> (several days) test. Sometimes even order-3 page allocation failed. It has
> memory size 512MB ~ 1024MB. 30% ~ 40% memory is consumed for graphic processing
> and 20~30 memory is reserved for zram.
> 
> I found that many pages of GPU driver and zram are non-movable pages. So I
> reported Minchan Kim, the maintainer of zram, and he made the internal 
> compaction logic of zram. And I made the internal compaction of GPU driver.
> 
> They reduced some fragmentation but they are not enough effective.
> They are activated by its own interface, /sys, so they are not cooperative
> with kernel compaction. If there is too much fragmentation and kernel starts
> to compaction, zram and GPU driver cannot work with the kernel compaction.
> 
> The first this patch adds a generic isolate/migrate/putback callbacks for page
> address-space. The zram and GPU, and any other modules can register
> its own migration method. The kernel compaction can call the registered
> migration when it works. Therefore all page in the system can be migrated
> at once.
> 
> The 2nd the generic migration callbacks are applied into balloon driver.
> My gpu driver code is not open so I apply generic migration into balloon
> to show how it works. I've tested it with qemu enabled by kvm like followings:
> - turn on Ubuntu 14.04 with 1G memory on qemu.
> - do kernel building
> - after several seconds check more than 512MB is used with free command
> - command "balloon 512" in qemu monitor
> - check hundreds MB of pages are migrated
> 
> Next kernel compaction code can call generic migration callbacks instead of
> balloon driver interface.
> Finally calling migration of balloon driver is removed.
>

In a glance, ss Konstantin pointed out this set, while it twists chunks around, 
brings back code we got rid of a while ago because it was messy and racy. 
I'll take a closer look into your work next week, but for now, I'd say
we should not follow this patch of reintroducing long-dead code.

Cheers!
-- Rafael
 
> 
> Gioh Kim (4):
>   mm/compaction: enable driver page migration
>   mm/balloon: apply migratable-page into balloon driver
>   mm/compaction: apply migratable-page into compaction
>   mm: remove direct migration of migratable-page
> 
>  drivers/virtio/virtio_balloon.c        |  2 +
>  fs/proc/page.c                         |  4 +-
>  include/linux/balloon_compaction.h     | 42 +++++++++++++++------
>  include/linux/compaction.h             | 13 +++++++
>  include/linux/fs.h                     |  2 +
>  include/linux/mm.h                     | 14 +++----
>  include/linux/pagemap.h                | 27 ++++++++++++++
>  include/uapi/linux/kernel-page-flags.h |  2 +-
>  mm/balloon_compaction.c                | 67 +++++++++++++++++++++++++++++-----
>  mm/compaction.c                        |  9 +++--
>  mm/migrate.c                           | 25 ++++---------
>  11 files changed, 154 insertions(+), 53 deletions(-)
> 
> -- 
> 1.9.1
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
