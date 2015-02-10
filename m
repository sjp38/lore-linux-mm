Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9630B6B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 17:13:34 -0500 (EST)
Received: by mail-ob0-f181.google.com with SMTP id vb8so34851693obc.12
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 14:13:34 -0800 (PST)
Received: from g5t1627.atlanta.hp.com (g5t1627.atlanta.hp.com. [15.192.137.10])
        by mx.google.com with ESMTPS id lj10si8243175oeb.23.2015.02.10.14.13.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 14:13:33 -0800 (PST)
Message-ID: <1423606397.1128.20.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 5/7] x86, mm: Support huge KVA mappings on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Tue, 10 Feb 2015 15:13:17 -0700
In-Reply-To: <54DA6F38.4050902@intel.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
		 <1423521935-17454-6-git-send-email-toshi.kani@hp.com>
		 <54DA54FA.7010707@intel.com> <1423600952.1128.9.camel@misato.fc.hp.com>
	 <54DA6F38.4050902@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com

On Tue, 2015-02-10 at 12:51 -0800, Dave Hansen wrote:
> On 02/10/2015 12:42 PM, Toshi Kani wrote:
> > On Tue, 2015-02-10 at 10:59 -0800, Dave Hansen wrote:
> >> On 02/09/2015 02:45 PM, Toshi Kani wrote:
> >>> Implement huge KVA mapping interfaces on x86.  Select
> >>> HAVE_ARCH_HUGE_VMAP when X86_64 or X86_32 with X86_PAE is set.
> >>> Without X86_PAE set, the X86_32 kernel has the 2-level page
> >>> tables and cannot provide the huge KVA mappings.
> >>
> >> Not that it's a big deal, but what's the limitation with the 2-level
> >> page tables on 32-bit?  We have a 4MB large page size available there
> >> and we already use it for the kernel linear mapping.
> > 
> > ioremap() calls arch-neutral ioremap_page_range() to set up I/O mappings
> > with PTEs.  This patch-set enables ioremap_page_range() to set up PUD &
> > PMD mappings.  With 2-level page table, I do not think this PUD/PMD
> > mapping code works unless we add some special code.
> 
> What actually breaks, though?
> 
> Can't you just disable the pud code via ioremap_pud_enabled()?

That's what v1 did, and I found in testing that the PMD mapping code did
not work when PAE was unset.  I think we need special handling similar
to one_md_table_init(), which returns pgd as pmd in case of non-PAE.
ioremap_page_range() does not have such handling and I thought it would
be worth adding it.

Thanks,
-Toshi


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
