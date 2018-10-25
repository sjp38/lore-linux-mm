Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 40B406B0007
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 03:24:36 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id n5-v6so4044237plp.16
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 00:24:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e2-v6sor6721578pfb.55.2018.10.25.00.24.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 00:24:35 -0700 (PDT)
Date: Thu, 25 Oct 2018 10:24:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/2] x86/mm: Move LDT remap out of KASLR region on
 5-level paging
Message-ID: <20181025072429.k54aem37sefqonqy@kshutemo-mobl1>
References: <20181024125112.55999-1-kirill.shutemov@linux.intel.com>
 <20181024125112.55999-2-kirill.shutemov@linux.intel.com>
 <20181025021809.GB2120@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181025021809.GB2120@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, boris.ostrovsky@oracle.com, jgross@suse.com, willy@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 25, 2018 at 10:18:09AM +0800, Baoquan He wrote:
> > We don't touch 4 pgd slot gap just before the direct mapping reserved
> > for a hypervisor, but move direct mapping by one slot instead.
> > 
> > The LDT mapping is per-mm, so we cannot move it into P4D page table next
> > to CPU_ENTRY_AREA without complicating PGD table allocation for 5-level
> > paging.
> 
> Here as discussed in private thread, at the first place you also agreed
> to put it in p4d entry next to CPU_ENTRY_AREA, but finally you changd
> mind, there must be some reasons when you implemented and investigated
> further to find out. Could you please say more about how it will
> complicating PGD table allocation for 5-level paging? Or give an use
> case where it will complicate?

On 5-level machine all memory starting from CPU_ENTRY_AREA (and part of
KASAN memory) is in the same P4D page table. All this memory is shared
across all processes, we just copy PGD entry -- all proceses point to the
same P4D page table. (I leave out PTI from the picture for simplicity.)

LDT is per-mm. If we would place it next to CPU_ENTRY_AREA we would need
to unshare P4D page table and create a new one on each fork and copy P4D
entries.

It's considerably more complex and would affect processes that never use
modify_ldt() at all.

Other option would be to move LDT remap *to* KASLR region for both paging
modes and make KALSR code aware about it: randomize it as we do for page
offset, vmalloc, vmap. It's probably better long term, but it's more
complex and I wanted to get backportable fix.

-- 
 Kirill A. Shutemov
