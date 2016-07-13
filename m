Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2DFAC6B0260
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 09:19:07 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x83so34890763wma.2
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 06:19:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t83si11856284wmg.97.2016.07.13.06.19.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 06:19:06 -0700 (PDT)
Date: Wed, 13 Jul 2016 15:19:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Unexpected growth of the LRU inactive list
Message-ID: <20160713131905.GA28731@dhcp22.suse.cz>
References: <d8e2130c-5a1c-bd6c-0f79-6b17bb6da645@polymtl.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d8e2130c-5a1c-bd6c-0f79-6b17bb6da645@polymtl.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Houssem Daoud <houssem.daoud@polymtl.ca>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>

[CC ext/jbd experts]

On Wed 13-07-16 01:48:57, Houssem Daoud wrote:
> Hi,
> 
> I was testing the filesystem performance of my system using the following
> script:
> 
> #!/bin/bash
> while true;
> do
> dd if=/dev/zero of=output.dat  bs=100M count=1
> done
> 
> I noticed that after some time, all the physical memory is consumed by the
> LRU inactive list and only 120 MB are left to the system.
> /proc/meminfo shows the following information:
> MemTotal: 4021820 Kb
> MemFree: 121912 Kb
> Active: 1304396 Kb
> Inactive: 2377124 Kb
> 
> The evolution of memory utilization over time is available in this link:
> http://secretaire.dorsal.polymtl.ca/~hdaoud/ext4_journal_meminfo.png
> 
> With the help of a kernel tracer, I found that most of the pages in the
> inactive list are created by the ext4 journal during a truncate operation.
> The call stack of the allocation is:
> [
> __alloc_pages_nodemask
> alloc_pages_current
> __page_cache_alloc
> find_or_create_page
> __getblk
> jbd2_journal_get_descriptor_buffer
> jbd2_journal_commit_transaction
> kjournald2
> kthread
> ]
> 
> I can't find an explanation why the LRU is growing while we are just writing
> to the same file again and again. I know that the philosophy of memory
> management in Linux is to use the available memory as much as possible, but
> what is the need of keeping truncated pages in the LRU if we know that they
> are not even accessible ?
> 
> Thanks !
> 
> ps: My system is running kernel 4.3 with ext4 filesystem (journal mode)
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
