Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id C02516B0187
	for <linux-mm@kvack.org>; Wed,  1 May 2013 10:43:48 -0400 (EDT)
Received: by mail-oa0-f70.google.com with SMTP id n9so9807701oag.5
        for <linux-mm@kvack.org>; Wed, 01 May 2013 07:43:47 -0700 (PDT)
Date: Wed, 1 May 2013 09:43:41 -0500
From: Shawn Bohrer <sbohrer@rgmadvisors.com>
Subject: deadlock on vmap_area_lock
Message-ID: <20130501144341.GA2404@BohrerMBP.rgmadvisors.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: xfs@oss.sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I've got two compute clusters with around 350 machines each which are
running kernels based off of 3.1.9 (Yes I realize this is ancient by
todays standards).  All of the machines run a 'find' command once an
hour on one of the mounted XFS filesystems.  Occasionally these find
commands get stuck requiring a reboot of the system.  I took a peek
today and see this with perf:

    72.22%          find  [kernel.kallsyms]          [k] _raw_spin_lock
                    |
                    --- _raw_spin_lock
                       |          
                       |--98.84%-- vm_map_ram
                       |          _xfs_buf_map_pages
                       |          xfs_buf_get
                       |          xfs_buf_read
                       |          xfs_trans_read_buf
                       |          xfs_da_do_buf
                       |          xfs_da_read_buf
                       |          xfs_dir2_block_getdents
                       |          xfs_readdir
                       |          xfs_file_readdir
                       |          vfs_readdir
                       |          sys_getdents
                       |          system_call_fastpath
                       |          __getdents64
                       |          
                       |--1.12%-- _xfs_buf_map_pages
                       |          xfs_buf_get
                       |          xfs_buf_read
                       |          xfs_trans_read_buf
                       |          xfs_da_do_buf
                       |          xfs_da_read_buf
                       |          xfs_dir2_block_getdents
                       |          xfs_readdir
                       |          xfs_file_readdir
                       |          vfs_readdir
                       |          sys_getdents
                       |          system_call_fastpath
                       |          __getdents64
                        --0.04%-- [...]

Looking at the code my best guess is that we are spinning on
vmap_area_lock, but I could be wrong.  This is the only process
spinning on the machine so I'm assuming either another process has
blocked while holding the lock, or perhaps this find process has tried
to acquire the vmap_area_lock twice?

I've skimmed through the change logs between 3.1 and 3.9 but nothing
stood out as fix for this bug.  Does this ring a bell with anyone?  If
I have a machine that is currently in one of these stuck states does
anyone have any tips to identifying the processes currently holding
the lock?

Additionally as I mentioned before I have two clusters of roughly
equal size though one cluster hits this issue more frequently.  On
that cluster with approximately 350 machines we get about 10 stuck
machines a month.  The other cluster has about 450 machines but we
only get about 1 or 2 stuck machines a month.  Both clusters run the
same find command every hour, but the workloads on the machines are
different.  The cluster that hits the issue more frequently tends to
run more memory intensive jobs.

I'm open to building some debug kernels to help track this down,
though I can't upgrade all of the machines in one shot so it may take
a while to reproduce.  I'm happy to provide any other information if
people have questions.

Thanks,
Shawn

-- 

---------------------------------------------------------------
This email, along with any attachments, is confidential. If you 
believe you received this message in error, please contact the 
sender immediately and delete all copies of the message.  
Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
