Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2236B028B
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 03:45:27 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l51-v6so2675119edc.14
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 00:45:27 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gq13-v6si1001794ejb.174.2018.10.10.00.45.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 00:45:25 -0700 (PDT)
Date: Wed, 10 Oct 2018 09:45:23 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Preserve _PAGE_DEVMAP across mprotect() calls
Message-ID: <20181010074523.GA11507@quack2.suse.cz>
References: <20181009101917.32497-1-jack@suse.cz>
 <CAPcyv4jExSvW8xSe_LYAYvjgBd=gfKdvrqtojybK0wfu9GFNLA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jExSvW8xSe_LYAYvjgBd=gfKdvrqtojybK0wfu9GFNLA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, stable <stable@vger.kernel.org>

On Tue 09-10-18 10:55:14, Dan Williams wrote:
> On Tue, Oct 9, 2018 at 3:19 AM Jan Kara <jack@suse.cz> wrote:
> >
> > Currently _PAGE_DEVMAP bit is not preserved in mprotect(2) calls. As a
> > result we will see warnings such as:
> >
> > BUG: Bad page map in process JobWrk0013  pte:800001803875ea25 pmd:7624381067
> > addr:00007f0930720000 vm_flags:280000f9 anon_vma:          (null) mapping:ffff97f2384056f0 index:0
> > file:457-000000fe00000030-00000009-000000ca-00000001_2001.fileblock fault:xfs_filemap_fault [xfs] mmap:xfs_file_mmap [xfs] readpage:          (null)
> > CPU: 3 PID: 15848 Comm: JobWrk0013 Tainted: G        W          4.12.14-2.g7573215-default #1 SLE12-SP4 (unreleased)
> > Hardware name: Intel Corporation S2600WFD/S2600WFD, BIOS SE5C620.86B.01.00.0833.051120182255 05/11/2018
> > Call Trace:
> >  dump_stack+0x5a/0x75
> >  print_bad_pte+0x217/0x2c0
> >  ? enqueue_task_fair+0x76/0x9f0
> >  _vm_normal_page+0xe5/0x100
> >  zap_pte_range+0x148/0x740
> >  unmap_page_range+0x39a/0x4b0
> >  unmap_vmas+0x42/0x90
> >  unmap_region+0x99/0xf0
> >  ? vma_gap_callbacks_rotate+0x1a/0x20
> >  do_munmap+0x255/0x3a0
> >  vm_munmap+0x54/0x80
> >  SyS_munmap+0x1d/0x30
> >  do_syscall_64+0x74/0x150
> >  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
> > ...
> >
> > when mprotect(2) gets used on DAX mappings. Also there is a wide variety
> > of other failures that can result from the missing _PAGE_DEVMAP flag
> > when the area gets used by get_user_pages() later.
> >
> > Fix the problem by including _PAGE_DEVMAP in a set of flags that get
> > preserved by mprotect(2).
> >
> > Fixes: 69660fd797c3 ("x86, mm: introduce _PAGE_DEVMAP")
> > Fixes: ebd31197931d ("powerpc/mm: Add devmap support for ppc64")
> > CC: stable@vger.kernel.org
> > Signed-off-by: Jan Kara <jack@suse.cz>
> 
> Looks good, do you want me to take this upstream along with the livelock fix?

Yes, I think that would be best. Thanks!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
