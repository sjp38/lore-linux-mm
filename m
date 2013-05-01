Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id A1A6A6B0191
	for <linux-mm@kvack.org>; Wed,  1 May 2013 11:57:40 -0400 (EDT)
Received: by mail-da0-f44.google.com with SMTP id z20so714597dae.31
        for <linux-mm@kvack.org>; Wed, 01 May 2013 08:57:39 -0700 (PDT)
Date: Wed, 1 May 2013 08:57:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: deadlock on vmap_area_lock
In-Reply-To: <20130501144341.GA2404@BohrerMBP.rgmadvisors.com>
Message-ID: <alpine.DEB.2.02.1305010855440.4547@chino.kir.corp.google.com>
References: <20130501144341.GA2404@BohrerMBP.rgmadvisors.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Cc: xfs@oss.sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 1 May 2013, Shawn Bohrer wrote:

> I've got two compute clusters with around 350 machines each which are
> running kernels based off of 3.1.9 (Yes I realize this is ancient by
> todays standards).  All of the machines run a 'find' command once an
> hour on one of the mounted XFS filesystems.  Occasionally these find
> commands get stuck requiring a reboot of the system.  I took a peek
> today and see this with perf:
> 
>     72.22%          find  [kernel.kallsyms]          [k] _raw_spin_lock
>                     |
>                     --- _raw_spin_lock
>                        |          
>                        |--98.84%-- vm_map_ram
>                        |          _xfs_buf_map_pages
>                        |          xfs_buf_get
>                        |          xfs_buf_read
>                        |          xfs_trans_read_buf
>                        |          xfs_da_do_buf
>                        |          xfs_da_read_buf
>                        |          xfs_dir2_block_getdents
>                        |          xfs_readdir
>                        |          xfs_file_readdir
>                        |          vfs_readdir
>                        |          sys_getdents
>                        |          system_call_fastpath
>                        |          __getdents64
>                        |          
>                        |--1.12%-- _xfs_buf_map_pages
>                        |          xfs_buf_get
>                        |          xfs_buf_read
>                        |          xfs_trans_read_buf
>                        |          xfs_da_do_buf
>                        |          xfs_da_read_buf
>                        |          xfs_dir2_block_getdents
>                        |          xfs_readdir
>                        |          xfs_file_readdir
>                        |          vfs_readdir
>                        |          sys_getdents
>                        |          system_call_fastpath
>                        |          __getdents64
>                         --0.04%-- [...]
> 
> Looking at the code my best guess is that we are spinning on
> vmap_area_lock, but I could be wrong.  This is the only process
> spinning on the machine so I'm assuming either another process has
> blocked while holding the lock, or perhaps this find process has tried
> to acquire the vmap_area_lock twice?
> 

Significant spinlock contention doesn't necessarily mean that there's a 
deadlock, but it also doesn't mean the opposite.  Depending on your 
definition of "occassionally", would it be possible to run with 
CONFIG_PROVE_LOCKING and CONFIG_LOCKDEP to see if it uncovers any real 
deadlock potential?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
