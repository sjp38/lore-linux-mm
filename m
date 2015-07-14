Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id CA45C6B026C
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 12:16:00 -0400 (EDT)
Received: by pacan13 with SMTP id an13so8055759pac.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 09:16:00 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id lv5si2527220pab.220.2015.07.14.09.15.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 09:16:00 -0700 (PDT)
Date: Tue, 14 Jul 2015 09:15:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 4.2-rc2: hitting "file-max limit 8192 reached"
Message-Id: <20150714091554.3d653316.akpm@linux-foundation.org>
In-Reply-To: <55A530A3.2080301@intel.com>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
	<1430231830-7702-8-git-send-email-mgorman@suse.de>
	<55A530A3.2080301@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Mel Gorman <mgorman@suse.de>, Nathan Zimmer <nzimmer@sgi.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, 14 Jul 2015 08:54:11 -0700 Dave Hansen <dave.hansen@intel.com> wrote:

> My laptop has been behaving strangely with 4.2-rc2.  Once I log in to my
> X session, I start getting all kinds of strange errors from applications
> and see this in my dmesg:
> 
> 	VFS: file-max limit 8192 reached
> 
> Could this be from CONFIG_DEFERRED_STRUCT_PAGE_INIT=y?  files_init()
> seems top be sizing files_stat.max_files from memory sizes.

argh.

> vfs_caches_init() uses nr_free_pages() to figure out what the "current
> kernel size" is in early boot.  *But* since we have not freed most of
> our memory, nr_free_pages() is low and makes us calculate the reserve as
> if the kernel we huge.
> 
> Adding some printk's confirms this.  Broken kernel:
> 
> 	vfs_caches_init() mempages: 4026972
> 	vfs_caches_init() reserve: 4021629
> 	vfs_caches_init() mempages (after reserve minus): 5343
> 	files_init() n: 2137
> 	files_init() files_stat.max_files: 8192
> 
> Working kernel:
> 
> 	vfs_caches_init() mempages: 4026972
> 	vfs_caches_init() reserve: 375
> 	vfs_caches_init() mempages2: 4026597
> 	files_init() n: 1610638
> 	files_init() files_stat.max_files: 1610638
> 
> Do we have an alternative to call instead of nr_free_pages() in
> vfs_caches_init()?
> 
> I guess we could save off 'nr_initialized' in memmap_init_zone() and
> then use "nr_initialized - nr_free_pages()", but that seems a bit hackish.

There are a lot of things that might be affected this way.  Callers of
nr_free_buffer_pages(), nr_free_pagecache_pages(), etc.

If we'd fully used the memory hotplug infrastructure then everything
would work - all those knobs which are sized off free-memory would get
themselves resized as more memory comes on line.  But quite a few
things have been missed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
