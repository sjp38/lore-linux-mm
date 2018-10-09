Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD0386B000A
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 13:55:26 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id t68-v6so1642847oih.4
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 10:55:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n97sor1150645ota.162.2018.10.09.10.55.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 10:55:25 -0700 (PDT)
MIME-Version: 1.0
References: <20181009101917.32497-1-jack@suse.cz>
In-Reply-To: <20181009101917.32497-1-jack@suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 9 Oct 2018 10:55:14 -0700
Message-ID: <CAPcyv4jExSvW8xSe_LYAYvjgBd=gfKdvrqtojybK0wfu9GFNLA@mail.gmail.com>
Subject: Re: [PATCH] mm: Preserve _PAGE_DEVMAP across mprotect() calls
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, stable <stable@vger.kernel.org>

On Tue, Oct 9, 2018 at 3:19 AM Jan Kara <jack@suse.cz> wrote:
>
> Currently _PAGE_DEVMAP bit is not preserved in mprotect(2) calls. As a
> result we will see warnings such as:
>
> BUG: Bad page map in process JobWrk0013  pte:800001803875ea25 pmd:7624381067
> addr:00007f0930720000 vm_flags:280000f9 anon_vma:          (null) mapping:ffff97f2384056f0 index:0
> file:457-000000fe00000030-00000009-000000ca-00000001_2001.fileblock fault:xfs_filemap_fault [xfs] mmap:xfs_file_mmap [xfs] readpage:          (null)
> CPU: 3 PID: 15848 Comm: JobWrk0013 Tainted: G        W          4.12.14-2.g7573215-default #1 SLE12-SP4 (unreleased)
> Hardware name: Intel Corporation S2600WFD/S2600WFD, BIOS SE5C620.86B.01.00.0833.051120182255 05/11/2018
> Call Trace:
>  dump_stack+0x5a/0x75
>  print_bad_pte+0x217/0x2c0
>  ? enqueue_task_fair+0x76/0x9f0
>  _vm_normal_page+0xe5/0x100
>  zap_pte_range+0x148/0x740
>  unmap_page_range+0x39a/0x4b0
>  unmap_vmas+0x42/0x90
>  unmap_region+0x99/0xf0
>  ? vma_gap_callbacks_rotate+0x1a/0x20
>  do_munmap+0x255/0x3a0
>  vm_munmap+0x54/0x80
>  SyS_munmap+0x1d/0x30
>  do_syscall_64+0x74/0x150
>  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
> ...
>
> when mprotect(2) gets used on DAX mappings. Also there is a wide variety
> of other failures that can result from the missing _PAGE_DEVMAP flag
> when the area gets used by get_user_pages() later.
>
> Fix the problem by including _PAGE_DEVMAP in a set of flags that get
> preserved by mprotect(2).
>
> Fixes: 69660fd797c3 ("x86, mm: introduce _PAGE_DEVMAP")
> Fixes: ebd31197931d ("powerpc/mm: Add devmap support for ppc64")
> CC: stable@vger.kernel.org
> Signed-off-by: Jan Kara <jack@suse.cz>

Looks good, do you want me to take this upstream along with the livelock fix?
