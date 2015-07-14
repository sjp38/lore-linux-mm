Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id E1C76280255
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 11:54:12 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so15454119igb.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 08:54:12 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id z10si2471229pbt.122.2015.07.14.08.54.12
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 08:54:12 -0700 (PDT)
Message-ID: <55A530A3.2080301@intel.com>
Date: Tue, 14 Jul 2015 08:54:11 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: 4.2-rc2: hitting "file-max limit 8192 reached"
References: <1430231830-7702-1-git-send-email-mgorman@suse.de> <1430231830-7702-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1430231830-7702-8-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>

My laptop has been behaving strangely with 4.2-rc2.  Once I log in to my
X session, I start getting all kinds of strange errors from applications
and see this in my dmesg:

	VFS: file-max limit 8192 reached

Could this be from CONFIG_DEFERRED_STRUCT_PAGE_INIT=y?  files_init()
seems top be sizing files_stat.max_files from memory sizes.

vfs_caches_init() uses nr_free_pages() to figure out what the "current
kernel size" is in early boot.  *But* since we have not freed most of
our memory, nr_free_pages() is low and makes us calculate the reserve as
if the kernel we huge.

Adding some printk's confirms this.  Broken kernel:

	vfs_caches_init() mempages: 4026972
	vfs_caches_init() reserve: 4021629
	vfs_caches_init() mempages (after reserve minus): 5343
	files_init() n: 2137
	files_init() files_stat.max_files: 8192

Working kernel:

	vfs_caches_init() mempages: 4026972
	vfs_caches_init() reserve: 375
	vfs_caches_init() mempages2: 4026597
	files_init() n: 1610638
	files_init() files_stat.max_files: 1610638

Do we have an alternative to call instead of nr_free_pages() in
vfs_caches_init()?

I guess we could save off 'nr_initialized' in memmap_init_zone() and
then use "nr_initialized - nr_free_pages()", but that seems a bit hackish.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
