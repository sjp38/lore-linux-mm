From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH, RFC 0/9] Introduce huge zero page
Date: Fri, 10 Aug 2012 11:49:12 +0800
Message-ID: <19243.3085096583$1344570580@news.gmane.org>
References: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1SzgEC-0003dn-MX
	for glkm-linux-mm-2@m.gmane.org; Fri, 10 Aug 2012 05:49:36 +0200
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id A6EE16B002B
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 23:49:32 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 10 Aug 2012 13:49:14 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7A3ebKa21496024
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 13:40:47 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7A3nEhH006343
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 13:49:14 +1000
Content-Disposition: inline
In-Reply-To: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Gavin Shan <shangw@linux.vnet.ibm.com>

On Thu, Aug 09, 2012 at 12:08:11PM +0300, Kirill A. Shutemov wrote:
>From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
>During testing I noticed big (up to 2.5 times) memory consumption overhead
>on some workloads (e.g. ft.A from NPB) if THP is enabled.
>
>The main reason for that big difference is lacking zero page in THP case.
>We have to allocate a real page on read page fault.
>
>A program to demonstrate the issue:
>#include <assert.h>
>#include <stdlib.h>
>#include <unistd.h>
>
>#define MB 1024*1024
>
>int main(int argc, char **argv)
>{
>        char *p;
>        int i;
>
>        posix_memalign((void **)&p, 2 * MB, 200 * MB);
>        for (i = 0; i < 200 * MB; i+= 4096)
>                assert(p[i] == 0);
>        pause();
>        return 0;
>}
>
>With thp-never RSS is about 400k, but with thp-always it's 200M.
>After the patcheset thp-always RSS is 400k too.
>
Hi Kirill, 

Thank you for your patchset, I have some questions to ask.

1. In your patchset, if read page fault, the pmd will be populated by huge
zero page, IIUC, assert(p[i] == 0) is a read operation, so why thp-always
RSS is 400K ? You allocate 100 pages, why each cost 4K? I think the
right overhead should be 2MB for the huge zero page instead of 400K, where
I missing ?

2. If the user hope to allocate 200MB, total 100 pages needed. The codes 
will allocate one 2MB huge zero page and populate to all associated pmd
in your patchset logic. When the user attempt to write pages, wp will be 
triggered, and if allocate huge page failed will fallback to
do_huge_pmd_wp_zero_page_fallback in your patch logic, but you just
create a new table and set pte around fault address to the newly
allocated page, all other ptes set to normal zero page. In this scene 
user only get one 4K page and all other zero pages, how the codes can
cotinue to work? Why not fallback to allocate normal page even if not 
physical continuous.

3. In your patchset logic:
"In fallback path we create a new table and set pte around fault address
to the newly allocated page. All other ptes set to normal zero page."
When these zero pages will be replaced by real pages and add memcg charge?

Look forward to your detail response, thank you! :)

Regards,
Wanpeng Li


>H. Peter Anvin proposed to use a "virtual huge zero page" -- a pmd table
>with all pte set to 4k zero page. I haven't tried that approach and I'm
>not sure if it's good idea (cache vs. tlb trashing). And I guess it will
>require more code to handle.
>For now, I just allocate 2M page and use it.
>
>Kirill A. Shutemov (9):
>  thp: huge zero page: basic preparation
>  thp: zap_huge_pmd(): zap huge zero pmd
>  thp: copy_huge_pmd(): copy huge zero page
>  thp: do_huge_pmd_wp_page(): handle huge zero page
>  thp: change_huge_pmd(): keep huge zero page write-protected
>  thp: add address parameter to split_huge_page_pmd()
>  thp: implement splitting pmd for huge zero page
>  thp: setup huge zero page on non-write page fault
>  thp: lazy huge zero page allocation
>
> Documentation/vm/transhuge.txt |    4 +-
> arch/x86/kernel/vm86_32.c      |    2 +-
> fs/proc/task_mmu.c             |    2 +-
> include/linux/huge_mm.h        |   10 +-
> include/linux/mm.h             |    8 ++
> mm/huge_memory.c               |  228 +++++++++++++++++++++++++++++++++++-----
> mm/memory.c                    |   11 +--
> mm/mempolicy.c                 |    2 +-
> mm/mprotect.c                  |    2 +-
> mm/mremap.c                    |    3 +-
> mm/pagewalk.c                  |    2 +-
> 11 files changed, 226 insertions(+), 48 deletions(-)
>
>-- 
>1.7.7.6
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
