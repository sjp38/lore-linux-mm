Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8831D6B038A
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 04:49:17 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u199so14317683wmd.4
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 01:49:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g68si6296234wme.88.2017.03.01.01.49.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Mar 2017 01:49:16 -0800 (PST)
Date: Wed, 1 Mar 2017 10:49:13 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Ext4 stack trace with savedwrite patches
Message-ID: <20170301094913.GB20512@quack2.suse.cz>
References: <87innzu233.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87innzu233.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, linux-mm@kvack.org

Hi,

On Fri 24-02-17 19:23:52, Aneesh Kumar K.V wrote:
> I am hitting this while running stress test with the saved write patch
> series. I guess we are missing a set page dirty some where. I will
> continue to debug this, but if you have any suggestion let me know.
<snip>

So this warning can happen when page got dirtied but ->page_mkwrite() was
not called. I don't know details of how autonuma works but a quick look
suggests that autonuma can also do numa hinting faults for file pages.
So the following seems to be possible:

Autonuma decides to check for accesses to a mapped shared file page that is
dirty. pte_present gets cleared, pte_write stays set (due to logic
introduced in commit b191f9b106 "mm: numa: preserve PTE write permissions
across a NUMA hinting fault"). Then page writeback happens, page_mkclean()
is called to write-protect the page. However page_check_address() returns
NULL for the PTE (__page_check_address() returns NULL for !pte_present
PTEs) so we don't clear pte_write bit in page_mkclean_one(). Sometime later
a process looks at the page through mmap, takes NUMA fault and
do_numa_page() reestablishes a writeable mapping of the page although the
filesystem does not expect there to be one and funny things happen
afterwards...

I'll defer to more mm-savvy people to decide how this should be fixed. My
naive understanding is that page_mkclean_one() should clear the pte_write
bit even for pages that are undergoing NUMA probation but I'm not sure
about a preferred way to achieve that...

								Honza

> [ 3177.528954] ------------[ cut here ]------------
> [ 3177.528968] WARNING: CPU: 155 PID: 84480 at fs/ext4/inode.c:3711 ext4_set_page_dirty+0x9c/0xe0
> [ 3177.528969] Modules linked in: powernv_op_panel
> [ 3177.528977] CPU: 155 PID: 84480 Comm: stress-ng-mmap Not tainted 4.10.0-rc8-00038-g528b408-dirty #6
> [ 3177.528979] task: c000000bbbda7d00 task.stack: c000001d777c0000
> [ 3177.528981] NIP: c00000000043322c LR: c00000000027f460 CTR: c000000000433190
> [ 3177.528983] REGS: c000001d777c3850 TRAP: 0700   Not tainted  (4.10.0-rc8-00038-g528b408-dirty)
> [ 3177.528984] MSR: 9000000000029033 <SF,HV,EE,ME,IR,DR,RI,LE>
> [ 3177.528994]   CR: 22082442  XER: 00000000
> [ 3177.528995] CFAR: c0000000004331dc SOFTE: 1 
>                GPR00: c00000000027f460 c000001d777c3ad0 c000000000fb9c00 f0000000063ac880 
>                GPR04: 0000000000000010 00000000c0000018 0000000000000000 f0000000073dbf20 
>                GPR08: c000000000f39c00 0000000000000001 c000000000f39c00 0000000000000018 
>                GPR12: c000000000433190 c00000000fb9c080 c0000018eb220386 0008000000000000 
>                GPR16: f0000000063ac880 c000001e44c76f90 c000001e180c6ca0 00007fffa20f0000 
>                GPR20: c000001bfc672d48 0000000000000000 c000001d777c3b40 00007fffa20e0000 
>                GPR24: 0000000000000000 c1ffffffffffe7ff ffffffffffffffff 860322eb180000c0 
>                GPR28: c000001e180c6900 c000001d777c3cc0 00007fffa20f0000 f0000000063ac880 
> [ 3177.529032] NIP [c00000000043322c] ext4_set_page_dirty+0x9c/0xe0
> [ 3177.529035] LR [c00000000027f460] set_page_dirty+0xb0/0x190
> [ 3177.529036] Call Trace:
> [ 3177.529039] [c000001d777c3ad0] [00007fffa20f0000] 0x7fffa20f0000 (unreliable)
> [ 3177.529043] [c000001d777c3af0] [c00000000027f460] set_page_dirty+0xb0/0x190
> [ 3177.529047] [c000001d777c3b20] [c0000000002c0abc] unmap_page_range+0xf1c/0x1040
> [ 3177.529050] [c000001d777c3c50] [c0000000002c10f4] unmap_vmas+0x84/0x120
> [ 3177.529053] [c000001d777c3ca0] [c0000000002cbe80] unmap_region+0xd0/0x1a0
> [ 3177.529057] [c000001d777c3d80] [c0000000002ce7cc] do_munmap+0x2dc/0x4a0
> [ 3177.529061] [c000001d777c3df0] [c0000000002cea94] SyS_munmap+0x64/0xb0
> [ 3177.529065] [c000001d777c3e30] [c00000000000b96c] system_call+0x38/0xfc
> [ 3177.529066] Instruction dump:
> [ 3177.529068] 7c0803a6 4e800020 60000000 60000000 60420000 3d42fff8 892a6416 2f890000 
> [ 3177.529076] 409effc4 39200001 3d02fff8 99286416 <0fe00000> 4bffffb0 60000000 60000000 
> [ 3177.529083] ---[ end trace 50350faad3b7b385 ]---
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
