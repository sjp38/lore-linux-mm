Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8ABC26B56EF
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 08:28:33 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v21-v6so8528096wrc.2
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 05:28:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a7-v6sor6970968wrc.9.2018.08.31.05.28.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 Aug 2018 05:28:32 -0700 (PDT)
Subject: Re: [PATCH v1] mm: relax deferred struct page requirements
References: <20171117014601.31606-1-pasha.tatashin@oracle.com>
 <20171121072416.v77vu4osm2s4o5sq@dhcp22.suse.cz>
 <b16029f0-ada0-df25-071b-cd5dba0ab756@suse.cz>
 <CAGM2rea=_VJJ26tohWQWgfwcFVkp0gb6j1edH1kVLjtxfugf5Q@mail.gmail.com>
 <CAGM2reYcwyOcKrO=WhB3Cf0FNL3ZearC=KvxmTNUU6rkWviQOg@mail.gmail.com>
 <83d035f1-40b4-bed8-6113-f4c5a0c4d22f@suse.cz>
 <c4d46b63-5237-d002-faf5-4e0749d825d7@suse.cz>
 <7aee9274-9e8e-4a40-a9e5-3c9ef28511b7@microsoft.com>
 <87516e50-a17c-6c80-e9b5-ba68eda9ce33@microsoft.com>
 <597f3f35-6aad-6ca1-ba03-b93444b1cb5f@suse.cz>
 <0acf1c74-1bd3-e425-f92b-5d084ff954a4@suse.cz>
 <5070bde7-d20e-a464-a566-e97a13264b94@microsoft.com>
From: Jiri Slaby <jslaby@suse.cz>
Message-ID: <31c12066-ae77-6a86-6238-2a55bde4f8e4@suse.cz>
Date: Fri, 31 Aug 2018 14:28:28 +0200
MIME-Version: 1.0
In-Reply-To: <5070bde7-d20e-a464-a566-e97a13264b94@microsoft.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>
Cc: "mhocko@kernel.org" <mhocko@kernel.org>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "paulus@samba.org" <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, "schwidefsky@de.ibm.com" <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, "mgorman@techsingularity.net" <mgorman@techsingularity.net>

On 08/31/2018, 02:10 PM, Pasha Tatashin wrote:
> Thanks Jiri, I am now able to reproduce it with your new config.
> 
> I have tried yesterday to enable sparsemem and deferred_struct_init on
> x86_32, and that kernel booted fine, there must be something else in
> your config that helps to trigger this problem. I am studying it now.
> 
> [    0.051245] Initializing CPU#0
> [    0.051682] Initializing HighMem for node 0 (000367fe:0007ffe0)
> [    0.067499] BUG: unable to handle kernel NULL pointer dereference at
> 00000028
> [    0.068452] *pdpt = 0000000000000000 *pde = f000ff53f000ff53
> [    0.069105] Oops: 0000 [#1] PREEMPT SMP PTI
> [    0.069595] CPU: 0 PID: 0 Comm: swapper Not tainted
> 4.19.0-rc1-pae_pt_jiri #1
> [    0.070382] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
> BIOS 1.11.0-20171110_100015-anatol 04/01/2014
> [    0.071545] EIP: free_unref_page_prepare.part.70+0x2c/0x50
> [    0.072178] Code: 19 e9 ff 89 d1 55 c1 ea 11 c1 e9 07 8b 14 d5 44 52
> fd d6 81 e1 fc 03 00 00 89 e5 56 53 89 cb be 1d 00 00 00 c1 eb 05 83 e1
> 1f <8b> 14 9a 29 ce 89 f1 d3 ea 83 e2 07 89 50 10 b8 01 00 00 00 5b 5e
> [    0.074296] EAX: f4cfa000 EBX: 0000000a ECX: 00000010 EDX: 00000000
> [    0.075005] ESI: 0000001d EDI: 0007ffe0 EBP: d6d41ed0 ESP: d6d41ec8
> [    0.075714] DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068 EFLAGS: 00210002
> [    0.076508] CR0: 80050033 CR2: 00000028 CR3: 16f20000 CR4: 000406b0
> [    0.077242] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> [    0.077934] DR6: fffe0ff0 DR7: 00000400
> [    0.078380] Call Trace:
> [    0.078670]  free_unref_page+0x3a/0x90
> [    0.079136]  __free_pages+0x25/0x30
> [    0.079533]  free_highmem_page+0x1e/0x50
> [    0.079978]  add_highpages_with_active_regions+0xd1/0x11f
> [    0.080592]  set_highmem_pages_init+0x67/0x7d
> [    0.081076]  mem_init+0x30/0x1fc

page_to_pfn(pfn_to_page(pfn)) != pfn with my .config on pfns >= 0x60000:

[    0.157667] add_highpages_with_active_regions: pfn=5fffb pg=f55f9f4c
pfn(pg(pfn)=5fffb sec=2
[    0.159231] add_highpages_with_active_regions: pfn=5fffc pg=f55f9f70
pfn(pg(pfn)=5fffc sec=2
[    0.161020] add_highpages_with_active_regions: pfn=5fffd pg=f55f9f94
pfn(pg(pfn)=5fffd sec=2
[    0.163149] add_highpages_with_active_regions: pfn=5fffe pg=f55f9fb8
pfn(pg(pfn)=5fffe sec=2
[    0.165204] add_highpages_with_active_regions: pfn=5ffff pg=f55f9fdc
pfn(pg(pfn)=5ffff sec=2
[    0.167216] add_highpages_with_active_regions: pfn=60000 pg=f4cfa000
pfn(pg(pfn)=c716a800 sec=3

So add_highpages_with_active_regions passes down page to
free_highmem_page and later, free_unref_page does page_to_pfn(page) and
__get_pfnblock_flags_mask operates on this modified pfn leading to crash
a?? __pfn_to_section(pfn)->pageblock_flags is NULL!

Note that __pfn_to_section(pfn)->pageblock_flags on the original pfn
returns a valid bitmap.

thanks,
-- 
js
suse labs
