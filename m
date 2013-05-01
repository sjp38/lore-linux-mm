Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 3F7DB6B01A1
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:03:09 -0400 (EDT)
Date: Thu, 2 May 2013 08:03:04 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: deadlock on vmap_area_lock
Message-ID: <20130501220303.GO10481@dastard>
References: <20130501144341.GA2404@BohrerMBP.rgmadvisors.com>
 <alpine.DEB.2.02.1305010855440.4547@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1305010855440.4547@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

On Wed, May 01, 2013 at 08:57:38AM -0700, David Rientjes wrote:
> On Wed, 1 May 2013, Shawn Bohrer wrote:
> 
> > I've got two compute clusters with around 350 machines each which are
> > running kernels based off of 3.1.9 (Yes I realize this is ancient by
> > todays standards).

xfs_info output of one of those filesystems? What platform are you
running (32 or 64 bit)?

> > All of the machines run a 'find' command once an
> > hour on one of the mounted XFS filesystems.  Occasionally these find
> > commands get stuck requiring a reboot of the system.  I took a peek
> > today and see this with perf:
> > 
> >     72.22%          find  [kernel.kallsyms]          [k] _raw_spin_lock
> >                     |
> >                     --- _raw_spin_lock
> >                        |          
> >                        |--98.84%-- vm_map_ram
> >                        |          _xfs_buf_map_pages
> >                        |          xfs_buf_get
> >                        |          xfs_buf_read
> >                        |          xfs_trans_read_buf
> >                        |          xfs_da_do_buf
> >                        |          xfs_da_read_buf
> >                        |          xfs_dir2_block_getdents
> >                        |          xfs_readdir
> >                        |          xfs_file_readdir
> >                        |          vfs_readdir
> >                        |          sys_getdents
> >                        |          system_call_fastpath
> >                        |          __getdents64
> >                        |          
> >                        |--1.12%-- _xfs_buf_map_pages
> >                        |          xfs_buf_get
> >                        |          xfs_buf_read
> >                        |          xfs_trans_read_buf
> >                        |          xfs_da_do_buf
> >                        |          xfs_da_read_buf
> >                        |          xfs_dir2_block_getdents
> >                        |          xfs_readdir
> >                        |          xfs_file_readdir
> >                        |          vfs_readdir
> >                        |          sys_getdents
> >                        |          system_call_fastpath
> >                        |          __getdents64
> >                         --0.04%-- [...]
> > 
> > Looking at the code my best guess is that we are spinning on
> > vmap_area_lock, but I could be wrong.  This is the only process
> > spinning on the machine so I'm assuming either another process has
> > blocked while holding the lock, or perhaps this find process has tried
> > to acquire the vmap_area_lock twice?
> > 
> 
> Significant spinlock contention doesn't necessarily mean that there's a 
> deadlock, but it also doesn't mean the opposite.  Depending on your 
> definition of "occassionally", would it be possible to run with 
> CONFIG_PROVE_LOCKING and CONFIG_LOCKDEP to see if it uncovers any real 
> deadlock potential?

It sure will. We've been reporting that vm_map_ram is doing
GFP_KERNEL allocations from GFP_NOFS context for years, and have
reported plenty of lockdep dumps as a result of it.

But that's not the problem that is occurring above - lockstat is
probably a good thing to look at here to determine exactly what
locks are being contended on....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
