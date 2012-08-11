From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH, RFC 0/9] Introduce huge zero page
Date: Sat, 11 Aug 2012 09:10:06 +0800
Message-ID: <36800.0020309866$1344647431@news.gmane.org>
References: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120810034912.GA31071@hacker.(null)>
 <20120810103304.GA3915@otc-wbsnb-06>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1T00Dj-0000F1-7E
	for glkm-linux-mm-2@m.gmane.org; Sat, 11 Aug 2012 03:10:27 +0200
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id B962A6B0044
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 21:10:23 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 11 Aug 2012 11:10:03 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7B1A7gT19398678
	for <linux-mm@kvack.org>; Sat, 11 Aug 2012 11:10:12 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7B1A79J004263
	for <linux-mm@kvack.org>; Sat, 11 Aug 2012 11:10:07 +1000
Content-Disposition: inline
In-Reply-To: <20120810103304.GA3915@otc-wbsnb-06>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Gavin Shan <shangw@linux.vnet.ibm.com>

On Fri, Aug 10, 2012 at 01:33:04PM +0300, Kirill A. Shutemov wrote:
>On Fri, Aug 10, 2012 at 11:49:12AM +0800, Wanpeng Li wrote:
>> On Thu, Aug 09, 2012 at 12:08:11PM +0300, Kirill A. Shutemov wrote:
>> >From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> >
>> >During testing I noticed big (up to 2.5 times) memory consumption overhead
>> >on some workloads (e.g. ft.A from NPB) if THP is enabled.
>> >
>> >The main reason for that big difference is lacking zero page in THP case.
>> >We have to allocate a real page on read page fault.
>> >
>> >A program to demonstrate the issue:
>> >#include <assert.h>
>> >#include <stdlib.h>
>> >#include <unistd.h>
>> >
>> >#define MB 1024*1024
>> >
>> >int main(int argc, char **argv)
>> >{
>> >        char *p;
>> >        int i;
>> >
>> >        posix_memalign((void **)&p, 2 * MB, 200 * MB);
>> >        for (i = 0; i < 200 * MB; i+= 4096)
>> >                assert(p[i] == 0);
>> >        pause();
>> >        return 0;
>> >}
>> >
>> >With thp-never RSS is about 400k, but with thp-always it's 200M.
>> >After the patcheset thp-always RSS is 400k too.
>> >
>> Hi Kirill, 
>> 
>> Thank you for your patchset, I have some questions to ask.
>> 
>> 1. In your patchset, if read page fault, the pmd will be populated by huge
>> zero page, IIUC, assert(p[i] == 0) is a read operation, so why thp-always
>> RSS is 400K ? You allocate 100 pages, why each cost 4K? I think the
>> right overhead should be 2MB for the huge zero page instead of 400K, where
>> I missing ?
>
>400k comes not from the allocation, but from libc runtime. The test
>program consumes about the same without any allocation at all.
>
>Zero page is a global resource. System owns it. It's not accounted to any
>process.
>
>> 
>> 2. If the user hope to allocate 200MB, total 100 pages needed. The codes 
>> will allocate one 2MB huge zero page and populate to all associated pmd
>> in your patchset logic. When the user attempt to write pages, wp will be 
>> triggered, and if allocate huge page failed will fallback to
>> do_huge_pmd_wp_zero_page_fallback in your patch logic, but you just
>> create a new table and set pte around fault address to the newly
>> allocated page, all other ptes set to normal zero page. In this scene 
>> user only get one 4K page and all other zero pages, how the codes can
>> cotinue to work? Why not fallback to allocate normal page even if not 
>> physical continuous.
>
>Since we allocate 4k page around the fault address the fault is handled.
>Userspace can use it.
>
>If the process will try to write to any other 4k page of this area a new
>fault will be triggered and do_wp_page() will allocate a real page.
>
>It's not reasonable to allocate all 4k pages in the fallback path. We can
>postpone it until userspace will really want to use them. This way we reduce
>memory pressure in fallback path.

Oh, I see. Thanks for your response and your good work. :)

Regards,
Wanpeng Li

>
>> 3. In your patchset logic:
>> "In fallback path we create a new table and set pte around fault address
>> to the newly allocated page. All other ptes set to normal zero page."
>> When these zero pages will be replaced by real pages and add memcg charge?
>
>I guess I've answered the question above.
>
>> Look forward to your detail response, thank you! :)
>
>Thanks for your questions.
>
>-- 
> Kirill A. Shutemov


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
