Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 221FA6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 19:37:50 -0500 (EST)
Received: by iecat20 with SMTP id at20so52897310iec.12
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 16:37:49 -0800 (PST)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id tf17si10367icb.103.2015.03.02.16.37.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Mar 2015 16:37:49 -0800 (PST)
Message-ID: <1425343031.17007.177.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2 5/7] x86, mm: Support huge KVA mappings on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 02 Mar 2015 17:37:11 -0700
In-Reply-To: <1423609825.1128.24.camel@misato.fc.hp.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
	 <1423521935-17454-6-git-send-email-toshi.kani@hp.com>
	 <54DA54FA.7010707@intel.com> <1423600952.1128.9.camel@misato.fc.hp.com>
	 <54DA6F38.4050902@intel.com> <1423606397.1128.20.camel@misato.fc.hp.com>
	 <1423609825.1128.24.camel@misato.fc.hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com

On Tue, 2015-02-10 at 16:10 -0700, Toshi Kani wrote:
> On Tue, 2015-02-10 at 15:13 -0700, Toshi Kani wrote:
> > On Tue, 2015-02-10 at 12:51 -0800, Dave Hansen wrote:
> > > On 02/10/2015 12:42 PM, Toshi Kani wrote:
> > > > On Tue, 2015-02-10 at 10:59 -0800, Dave Hansen wrote:
> > > >> On 02/09/2015 02:45 PM, Toshi Kani wrote:
> > > >>> Implement huge KVA mapping interfaces on x86.  Select
> > > >>> HAVE_ARCH_HUGE_VMAP when X86_64 or X86_32 with X86_PAE is set.
> > > >>> Without X86_PAE set, the X86_32 kernel has the 2-level page
> > > >>> tables and cannot provide the huge KVA mappings.
> > > >>
> > > >> Not that it's a big deal, but what's the limitation with the 2-level
> > > >> page tables on 32-bit?  We have a 4MB large page size available there
> > > >> and we already use it for the kernel linear mapping.
> > > > 
> > > > ioremap() calls arch-neutral ioremap_page_range() to set up I/O mappings
> > > > with PTEs.  This patch-set enables ioremap_page_range() to set up PUD &
> > > > PMD mappings.  With 2-level page table, I do not think this PUD/PMD
> > > > mapping code works unless we add some special code.
> > > 
> > > What actually breaks, though?
> > > 
> > > Can't you just disable the pud code via ioremap_pud_enabled()?
> > 
> > That's what v1 did, and I found in testing that the PMD mapping code did
> > not work when PAE was unset.  I think we need special handling similar
> > to one_md_table_init(), which returns pgd as pmd in case of non-PAE.
> > ioremap_page_range() does not have such handling and I thought it would
> > not be worth adding it.
> 
> Actually pud_alloc() and pmd_alloc() should carry pgd in this case...  I
> will look into the problem to see why it did not work when PAE was
> unset.

I have looked at this case, 32bit without PAE, and confirmed that it set
pgd properly.  crash can translate an address with the mapping as well.
However, there is something missing in the code that the kernel cannot
access to a page with the mapping (page fault).  I tried TLB flush, but
it did not help, either.  Since this config can unlikely be benefited by
this feature, I will have to continue to disable this case.  I hope that
is OK.  

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
