Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 301B36B0070
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 20:08:49 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so24777297pdb.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 17:08:48 -0700 (PDT)
Received: from mail-pd0-x229.google.com (mail-pd0-x229.google.com. [2607:f8b0:400e:c02::229])
        by mx.google.com with ESMTPS id cc3si10948910pdb.128.2015.06.09.17.08.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 17:08:48 -0700 (PDT)
Received: by pdbnf5 with SMTP id nf5so24776279pdb.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 17:08:44 -0700 (PDT)
Date: Wed, 10 Jun 2015 09:08:51 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/4] enable migration of non-LRU pages
Message-ID: <20150610000850.GC13376@bgram>
References: <1433230065-3573-1-git-send-email-gioh.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433230065-3573-1-git-send-email-gioh.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>
Cc: jlayton@poochiereds.net, bfields@fieldses.org, akpm@linux-foundation.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, mst@redhat.com, kirill@shutemov.name, mgorman@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtualization@lists.linux-foundation.org, gunho.lee@lge.com

Hello Gioh,

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

I didn't hava a time to review but it surely will help using zram with
CMA as well as fragmentation of the system memory via making zram objects
movable.

If it lands on mainline, I will work for zram object migration.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
