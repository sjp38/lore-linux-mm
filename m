Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4AFCF6B00D2
	for <linux-mm@kvack.org>; Tue, 22 Oct 2013 13:52:45 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so8958436pbc.35
        for <linux-mm@kvack.org>; Tue, 22 Oct 2013 10:52:44 -0700 (PDT)
Received: from psmtp.com ([74.125.245.168])
        by mx.google.com with SMTP id gj2si12860912pac.341.2013.10.22.10.52.43
        for <linux-mm@kvack.org>;
        Tue, 22 Oct 2013 10:52:44 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <526697F5.7040800@intel.com>
References: <1382449940-24357-1-git-send-email-kirill.shutemov@linux.intel.com>
 <526697F5.7040800@intel.com>
Subject: Re: [PATCH] x86, mm: get ASLR work for hugetlb mappings
Content-Transfer-Encoding: 7bit
Message-Id: <20131022175219.BB0E3E0090@blue.fi.intel.com>
Date: Tue, 22 Oct 2013 20:52:19 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>

Dave Hansen wrote:
> On 10/22/2013 06:52 AM, Kirill A. Shutemov wrote:
> > Matthew noticed that hugetlb doesn't participate in ASLR on x86-64.
> > The reason is genereic hugetlb_get_unmapped_area() which is used on
> > x86-64. It doesn't support randomization and use bottom-up unmapped area
> > lookup, instead of usual top-down on x86-64.
> 
> I have to wonder if this was on purpose in order to keep the large and
> small mappings separate.  We don't *have* to keep them separate this, of
> course, but it makes me wonder.

I haven't seen any evidence that it's on purpose, but who knows...

In x86-specific hugetlb_get_unmapped_area() there's explicit check what is
mm->get_unmapped_area top-down or bottom-up, and doing the same.

> > x86 has arch-specific hugetlb_get_unmapped_area(), but it's used only on
> > x86-32.
> > 
> > Let's use arch-specific hugetlb_get_unmapped_area() on x86-64 too.
> > It fixes the issue and make hugetlb use top-down unmapped area lookup.
> 
> Shouldn't we fix the generic code instead of further specializing the
> x86 stuff?

For that we need to modify info.low_limit to mm->mmap_legacy_base (which
is x86 specific, no-go) or switch to top-down and set info.high_limit to
mm->mmap_base.

I don't know how it can affect other architectures.

> In any case, you probably also want to run this through: the
> libhugetlbfs tests:
> 
> http://sourceforge.net/p/libhugetlbfs/code/ci/master/tree/tests/

I've got the same fail list for upstream and patched kernel, so no
regression was found.

********** TEST SUMMARY  
*                      2M            
*                      32-bit 64-bit 
*     Total testcases:   107    110   
*             Skipped:     0      0   
*                PASS:    98    108   
*                FAIL:     2      2   
*    Killed by signal:     7      0   
*   Bad configuration:     0      0   
*       Expected FAIL:     0      0   
*     Unexpected PASS:     0      0   
* Strange test result:     0      0   
**********

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
