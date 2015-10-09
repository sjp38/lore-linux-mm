Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id AE6E26B0253
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 05:26:02 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so59871784wic.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 02:26:02 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id yp6si792462wjc.166.2015.10.09.02.26.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 02:26:01 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so59871190wic.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 02:26:01 -0700 (PDT)
Date: Fri, 9 Oct 2015 12:25:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv12 25/37] mm, thp: remove infrastructure for handling
 splitting PMDs
Message-ID: <20151009092559.GA7346@node>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1444145044-72349-26-git-send-email-kirill.shutemov@linux.intel.com>
 <56162EC9.8030803@synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56162EC9.8030803@synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 08, 2015 at 02:22:25PM +0530, Vineet Gupta wrote:
> On Tuesday 06 October 2015 08:53 PM, Kirill A. Shutemov wrote:
> > With new refcounting we don't need to mark PMDs splitting. Let's drop code
> > to handle this.
> > 
> ....
> >  
> > diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> > index 29c57b2cb344..010a7e3f6ad1 100644
> > --- a/include/asm-generic/pgtable.h
> > +++ b/include/asm-generic/pgtable.h
> > @@ -184,11 +184,6 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
> >  #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> >  #endif
> >  
> > -#ifndef __HAVE_ARCH_PMDP_SPLITTING_FLUSH
> > -extern void pmdp_splitting_flush(struct vm_area_struct *vma,
> > -				 unsigned long address, pmd_t *pmdp);
> > -#endif
> 
> 
> Hi Kirill,
> 
> While at it - you would also want to nuke
> 
> Documentation/features/vm/pmdp_splitting_flush/

Sure.

The patch below can be folded into this one.

diff --git a/Documentation/features/vm/pmdp_splitting_flush/arch-support.txt b/Documentation/features/vm/pmdp_splitting_flush/arch-support.txt
deleted file mode 100644
index 26f74b457e0b..000000000000
--- a/Documentation/features/vm/pmdp_splitting_flush/arch-support.txt
+++ /dev/null
@@ -1,40 +0,0 @@
-#
-# Feature name:          pmdp_splitting_flush
-#         Kconfig:       __HAVE_ARCH_PMDP_SPLITTING_FLUSH
-#         description:   arch supports the pmdp_splitting_flush() VM API
-#
-    -----------------------
-    |         arch |status|
-    -----------------------
-    |       alpha: | TODO |
-    |         arc: | TODO |
-    |         arm: |  ok  |
-    |       arm64: |  ok  |
-    |       avr32: | TODO |
-    |    blackfin: | TODO |
-    |         c6x: | TODO |
-    |        cris: | TODO |
-    |         frv: | TODO |
-    |       h8300: | TODO |
-    |     hexagon: | TODO |
-    |        ia64: | TODO |
-    |        m32r: | TODO |
-    |        m68k: | TODO |
-    |       metag: | TODO |
-    |  microblaze: | TODO |
-    |        mips: |  ok  |
-    |     mn10300: | TODO |
-    |       nios2: | TODO |
-    |    openrisc: | TODO |
-    |      parisc: | TODO |
-    |     powerpc: |  ok  |
-    |        s390: |  ok  |
-    |       score: | TODO |
-    |          sh: | TODO |
-    |       sparc: | TODO |
-    |        tile: | TODO |
-    |          um: | TODO |
-    |   unicore32: | TODO |
-    |         x86: |  ok  |
-    |      xtensa: | TODO |
-    -----------------------
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
