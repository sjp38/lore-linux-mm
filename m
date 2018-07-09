Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE236B0329
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 14:33:00 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id n18-v6so16996301iog.10
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 11:33:00 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id e21-v6si11061401jae.55.2018.07.09.11.32.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 11:32:59 -0700 (PDT)
Date: Mon, 9 Jul 2018 14:32:50 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCHv4 15/18] x86/mm: Calculate direct mapping size
Message-ID: <20180709183250.GJ6873@char.US.ORACLE.com>
References: <20180626142245.82850-1-kirill.shutemov@linux.intel.com>
 <20180626142245.82850-16-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180626142245.82850-16-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Jun 26, 2018 at 05:22:42PM +0300, Kirill A. Shutemov wrote:
> The kernel needs to have a way to access encrypted memory. We have two
> option on how approach it:
> 
>  - Create temporary mappings every time kernel needs access to encrypted
>    memory. That's basically brings highmem and its overhead back.
> 
>  - Create multiple direct mappings, one per-KeyID. In this setup we
>    don't need to create temporary mappings on the fly -- encrypted
>    memory is permanently available in kernel address space.
> 
> We take the second approach as it has lower overhead.
> 
> It's worth noting that with per-KeyID direct mappings compromised kernel
> would give access to decrypted data right away without additional tricks
> to get memory mapped with the correct KeyID.
> 
> Per-KeyID mappings require a lot more virtual address space. On 4-level
> machine with 64 KeyIDs we max out 46-bit virtual address space dedicated
> for direct mapping with 1TiB of RAM. Given that we round up any
> calculation on direct mapping size to 1TiB, we effectively claim all
> 46-bit address space for direct mapping on such machine regardless of
> RAM size.
> 
> Increased usage of virtual address space has implications for KASLR:
> we have less space for randomization. With 64 TiB claimed for direct
> mapping with 4-level we left with 27 TiB of entropy to place
> page_offset_base, vmalloc_base and vmemmap_base.
> 
> 5-level paging provides much wider virtual address space and KASLR
> doesn't suffer significantly from per-KeyID direct mappings.
> 
> It's preferred to run MKTME with 5-level paging.


Why not make this a config dependency then?
