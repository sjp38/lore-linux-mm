Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 869636B000D
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 22:18:27 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id m63-v6so7944307qkb.9
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 19:18:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z50-v6si586848qth.129.2018.10.24.19.18.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Oct 2018 19:18:26 -0700 (PDT)
Date: Thu, 25 Oct 2018 10:18:09 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCHv2 1/2] x86/mm: Move LDT remap out of KASLR region on
 5-level paging
Message-ID: <20181025021809.GB2120@MiWiFi-R3L-srv>
References: <20181024125112.55999-1-kirill.shutemov@linux.intel.com>
 <20181024125112.55999-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181024125112.55999-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org, boris.ostrovsky@oracle.com, jgross@suse.com, willy@infradead.org, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Kirill,

Thanks for making this patchset. I have small concerns, please see the
inline comments.

On 10/24/18 at 03:51pm, Kirill A. Shutemov wrote:
> On 5-level paging LDT remap area is placed in the middle of
> KASLR randomization region and it can overlap with direct mapping,
> vmalloc or vmap area.
> 
> Let's move LDT just before direct mapping which makes it safe for KASLR.
> This also allows us to unify layout between 4- and 5-level paging.

In crash utility and makedumpfile which are used to analyze system
memory content, PAGE_OFFSET is hardcoded as below in non-KASLR case:

#define PAGE_OFFSET_2_6_27         0xffff880000000000

Seems this time they need add another value for them. For 4-level and
5-level, since 5-level code also exist in stable kernel. Surely this
doesn't matter much.

> 
> We don't touch 4 pgd slot gap just before the direct mapping reserved
> for a hypervisor, but move direct mapping by one slot instead.
> 
> The LDT mapping is per-mm, so we cannot move it into P4D page table next
> to CPU_ENTRY_AREA without complicating PGD table allocation for 5-level
> paging.

Here as discussed in private thread, at the first place you also agreed
to put it in p4d entry next to CPU_ENTRY_AREA, but finally you changd
mind, there must be some reasons when you implemented and investigated
further to find out. Could you please say more about how it will
complicating PGD table allocation for 5-level paging? Or give an use
case where it will complicate?

Very sorry I am stupid, still don't get what's the point. Really
appreciate it.

Thanks
Baoquan
