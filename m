Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 12ECD6B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 11:08:28 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f126so58552640wma.3
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:08:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i130si2621450lfg.324.2016.07.14.08.08.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 08:08:26 -0700 (PDT)
Date: Thu, 14 Jul 2016 17:08:24 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Unexpected growth of the LRU inactive list
Message-ID: <20160714150824.GI13151@quack2.suse.cz>
References: <d8e2130c-5a1c-bd6c-0f79-6b17bb6da645@polymtl.ca>
 <20160713131905.GA28731@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160713131905.GA28731@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Houssem Daoud <houssem.daoud@polymtl.ca>, linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>

On Wed 13-07-16 15:19:05, Michal Hocko wrote:
> [CC ext/jbd experts]

Thanks.

> On Wed 13-07-16 01:48:57, Houssem Daoud wrote:
> > Hi,
> > 
> > I was testing the filesystem performance of my system using the following
> > script:
> > 
> > #!/bin/bash
> > while true;
> > do
> > dd if=/dev/zero of=output.dat  bs=100M count=1
> > done
> > 
> > I noticed that after some time, all the physical memory is consumed by the
> > LRU inactive list and only 120 MB are left to the system.
> > /proc/meminfo shows the following information:
> > MemTotal: 4021820 Kb
> > MemFree: 121912 Kb
> > Active: 1304396 Kb
> > Inactive: 2377124 Kb
> > 
> > The evolution of memory utilization over time is available in this link:
> > http://secretaire.dorsal.polymtl.ca/~hdaoud/ext4_journal_meminfo.png
> > 
> > With the help of a kernel tracer, I found that most of the pages in the
> > inactive list are created by the ext4 journal during a truncate operation.
> > The call stack of the allocation is:
> > [
> > __alloc_pages_nodemask
> > alloc_pages_current
> > __page_cache_alloc
> > find_or_create_page
> > __getblk
> > jbd2_journal_get_descriptor_buffer
> > jbd2_journal_commit_transaction
> > kjournald2
> > kthread
> > ]
> > 
> > I can't find an explanation why the LRU is growing while we are just writing
> > to the same file again and again. I know that the philosophy of memory
> > management in Linux is to use the available memory as much as possible, but
> > what is the need of keeping truncated pages in the LRU if we know that they
> > are not even accessible ?
> > 
> > Thanks !
> > 
> > ps: My system is running kernel 4.3 with ext4 filesystem (journal mode)

This problem should be fixed by commit bc23f0c8d7cc "jbd2: Fix unreclaimed
pages after truncate in data=journal mode" which was merged into 4.4.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
