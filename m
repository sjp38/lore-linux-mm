Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id A61626B0032
	for <linux-mm@kvack.org>; Wed, 25 Feb 2015 16:58:05 -0500 (EST)
Received: by wghk14 with SMTP id k14so6456363wgh.4
        for <linux-mm@kvack.org>; Wed, 25 Feb 2015 13:58:05 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id lx9si75474742wjb.182.2015.02.25.13.58.03
        for <linux-mm@kvack.org>;
        Wed, 25 Feb 2015 13:58:03 -0800 (PST)
Date: Wed, 25 Feb 2015 23:57:57 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: 4.0-rc1/PARISC: BUG: non-zero nr_pmds on freeing mm
Message-ID: <20150225215757.GA23672@node.dhcp.inet.fi>
References: <20150224225454.GA14117@fuloong-minipc.musicnaut.iki.fi>
 <20150225202130.GA31491@node.dhcp.inet.fi>
 <20150225123048.a9c97ea726f747e029b4688a@linux-foundation.org>
 <20150225204743.GA31668@node.dhcp.inet.fi>
 <20150225133140.56cfb479cd2f4461ed4fa6d5@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150225133140.56cfb479cd2f4461ed4fa6d5@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-parisc@vger.kernel.org, linux-mm@kvack.org

On Wed, Feb 25, 2015 at 01:31:40PM -0800, Andrew Morton wrote:
> On Wed, 25 Feb 2015 22:47:43 +0200 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > > > If not, I can prepare a patchset which only adds missing
> > > > __PAGETABLE_PUD_FOLDED and __PAGETABLE_PMD_FOLDED.
> > > 
> > > Something simple would be preferred, but I don't know how much simpler
> > > the above would be?
> > 
> > Not much simplier: __PAGETABLE_PMD_FOLDED is missing in frv, m32r, m68k,
> > mn10300, parisc and s390.
> 
> I don't really know what's going on here.  Let's rewind a bit, please. 
> What is the bug, what causes it, which commit caused it and why the
> heck does it require a massive patchset to fix 4.0?

PMD accounting happens in __pmd_alloc() and free_pmd_range(). PMD
accounting only makes sense on architectures with 3 or more page tables
levels. We use __PAGETABLE_PMD_FOLDED to check whether the PMD page table
level exists.

Unfortunately, some architectures don't use <asm-generic/pgtable-nopmd.h>
to indicate that PMD level doesn't exists and fold it in a custom way.
Some of them don't define __PAGETABLE_PMD_FOLDED as pgtable-nopmd.h does.

Missing __PAGETABLE_PMD_FOLDED causes undeflow of mm->nr_pmds:
__pmd_alloc() is never called, but we decrement mm->nr_pmds in
free_pmd_range().

These architecures need to be fixed to define __PAGETABLE_PMD_FOLDED too.

I can do in one patch if you want. Or split per-arch. After that
CONFIG_PGTABLE_LEVELS patchset will require rebasing.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
