Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 61B566B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 18:07:34 -0500 (EST)
Received: by pablf10 with SMTP id lf10so11384389pab.12
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 15:07:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t4si932811pdp.6.2015.02.20.15.07.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 15:07:33 -0800 (PST)
Date: Fri, 20 Feb 2015 15:07:31 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fs: avoid locking sb_lock in grab_super_passive()
Message-Id: <20150220150731.e79cd30dc6ecf3c7a3f5caa3@linux-foundation.org>
In-Reply-To: <20150219171934.20458.30175.stgit@buzz>
References: <20150219171934.20458.30175.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Dave Chinner <david@fromorbit.com>

On Thu, 19 Feb 2015 20:19:35 +0300 Konstantin Khlebnikov <khlebnikov@yandex-team.ru> wrote:
>

Please cc Dave Chinner on this.

> I've noticed significant locking contention in memory reclaimer around
> sb_lock inside grab_super_passive(). Grab_super_passive() is called from
> two places: in icache/dcache shrinkers (function super_cache_scan) and
> from writeback (function __writeback_inodes_wb). Both are required for
> progress in memory reclaimer.
> 
> Also this lock isn't irq-safe. And I've seen suspicious livelock under
> serious memory pressure where reclaimer was called from interrupt which
> have happened right in place where sb_lock is held in normal context,
> so all other cpus were stuck on that lock too.

You mean someone is calling grab_super_passive() (ie: fs writeback)
from interrupt context?  What's the call path?

> Grab_super_passive() acquires sb_lock to increment sb->s_count and check
> sb->s_instances. It seems sb->s_umount locked for read is enough here:
> super-block deactivation always runs under sb->s_umount locked for write.
> Protecting super-block itself isn't a problem: in super_cache_scan() sb
> is protected by shrinker_rwsem: it cannot be freed if its slab shrinkers
> are still active. Inside writeback super-block comes from inode from bdi
> writeback list under wb->list_lock.
> 
> This patch removes locking sb_lock and checks s_instances under s_umount:
> generic_shutdown_super() unlinks it under sb->s_umount locked for write.
> Now successful grab_super_passive() only locks semaphore, callers must
> call up_read(&sb->s_umount) instead of drop_super(sb) when they're done.
> 

The patch looks reasonable to me, but the grab_super_passive()
documentation needs further updating, please.

- It no longer "acquires a reference".  All it does is to acquire an rwsem.

- What the heck is a "passive reference" anyway?  It appears to be
  the situation where we increment s_count without incrementing s_active.

  After your patch, this superblock state no longer exists(?), so
  perhaps the entire "passive reference" concept and any references to
  it can be expunged from the kernel.

  And grab_super_passive() should be renamed anyway.  It no longer
  "grabs" anything - it attempts to acquire ->s_umount. 
  "super_trylock", maybe?

- While we're dicking with the grab_super_passive() documentation,
  let's turn it into kerneldoc by adding the /**.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
