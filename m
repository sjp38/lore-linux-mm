Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f45.google.com (mail-vn0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 000A3900016
	for <linux-mm@kvack.org>; Fri,  5 Jun 2015 10:43:22 -0400 (EDT)
Received: by vnbg7 with SMTP id g7so3204721vnb.1
        for <linux-mm@kvack.org>; Fri, 05 Jun 2015 07:43:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id da8si13749262vdb.7.2015.06.05.07.43.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jun 2015 07:43:22 -0700 (PDT)
Date: Fri, 5 Jun 2015 10:43:13 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [RFC 0/4] enable migration of non-LRU pages
Message-ID: <20150605144313.GD18087@t510.redhat.com>
References: <1433230065-3573-1-git-send-email-gioh.kim@lge.com>
 <20150605135350.GE10661@t510.redhat.com>
 <5571B3C5.1000004@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5571B3C5.1000004@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: jlayton@poochiereds.net, bfields@fieldses.org, akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mst@redhat.com, kirill@shutemov.name, minchan@kernel.org, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, gunho.lee@lge.com

On Fri, Jun 05, 2015 at 11:35:49PM +0900, Gioh Kim wrote:
> >On Tue, Jun 02, 2015 at 04:27:40PM +0900, Gioh Kim wrote:
> >>Hello,
> >>
> >>This series try to enable migration of non-LRU pages, such as driver's page.
> >>
> >>My ARM-based platform occured severe fragmentation problem after long-term
> >>(several days) test. Sometimes even order-3 page allocation failed. It has
> >>memory size 512MB ~ 1024MB. 30% ~ 40% memory is consumed for graphic processing
> >>and 20~30 memory is reserved for zram.
> >>
> >>I found that many pages of GPU driver and zram are non-movable pages. So I
> >>reported Minchan Kim, the maintainer of zram, and he made the internal
> >>compaction logic of zram. And I made the internal compaction of GPU driver.
> >>
> >>They reduced some fragmentation but they are not enough effective.
> >>They are activated by its own interface, /sys, so they are not cooperative
> >>with kernel compaction. If there is too much fragmentation and kernel starts
> >>to compaction, zram and GPU driver cannot work with the kernel compaction.
> >>
> >>The first this patch adds a generic isolate/migrate/putback callbacks for page
> >>address-space. The zram and GPU, and any other modules can register
> >>its own migration method. The kernel compaction can call the registered
> >>migration when it works. Therefore all page in the system can be migrated
> >>at once.
> >>
> >>The 2nd the generic migration callbacks are applied into balloon driver.
> >>My gpu driver code is not open so I apply generic migration into balloon
> >>to show how it works. I've tested it with qemu enabled by kvm like followings:
> >>- turn on Ubuntu 14.04 with 1G memory on qemu.
> >>- do kernel building
> >>- after several seconds check more than 512MB is used with free command
> >>- command "balloon 512" in qemu monitor
> >>- check hundreds MB of pages are migrated
> >>
> >>Next kernel compaction code can call generic migration callbacks instead of
> >>balloon driver interface.
> >>Finally calling migration of balloon driver is removed.
> >>
> >
> >In a glance, ss Konstantin pointed out this set, while it twists chunks around,
> >brings back code we got rid of a while ago because it was messy and racy.
> 
> Yes, your point is right.
> 
> >I'll take a closer look into your work next week, but for now, I'd say
> >we should not follow this patch of reintroducing long-dead code.
> 
> BUT as I replied to Konstantin, the code for balloon driver is to show
> how the generic callbacks can be applied.
> 
> My point is there are some pages to be migrated which are not LRU pages,
> but there is no interface for them to migrate.
> 
> For example gpu driver has many, not mapped to kernel space, pages.
> Those pages can be migrated when GPU is not working, screen is not refreshed.
> And zram pages can be migrated also.
> 
> I'm very sorry that I'm not familiar to balloon driver.
> If you give me some hints, I might be able to refine code of patch 2~3 in the next spin.
>

NP at all. Thanks for bringing this discussion of migrating non-LRU
pages back to the table, actually. As I mentioned earlier, I'll take a
closer look into your work as soon as I get time next week, so I can try
to help with more qualified feedback.
 
Have a nice weekend!
-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
