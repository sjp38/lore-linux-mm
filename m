Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id BF6686B0027
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 05:30:37 -0400 (EDT)
Date: Fri, 5 Apr 2013 11:30:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 0/9] extend hugepage migration
Message-ID: <20130405093034.GB31132@dhcp22.suse.cz>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5148F830.3070601@gmail.com>
 <1363815326-urchkyxr-mutt-n-horiguchi@ah.jp.nec.com>
 <514A4B1C.6020201@gmail.com>
 <20130321125628.GB6051@dhcp22.suse.cz>
 <514B9BD8.9050207@gmail.com>
 <20130322081532.GC31457@dhcp22.suse.cz>
 <515E2592.7020607@gmail.com>
 <20130405080828.GA14882@dhcp22.suse.cz>
 <515E92CA.4000507@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515E92CA.4000507@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Linux kernel Mailing List <linux-kernel@vger.kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>

On Fri 05-04-13 17:00:58, Simon Jeons wrote:
> Hi Michal,
> On 04/05/2013 04:08 PM, Michal Hocko wrote:
> >On Fri 05-04-13 09:14:58, Simon Jeons wrote:
> >>Hi Michal,
> >>On 03/22/2013 04:15 PM, Michal Hocko wrote:
> >>>[getting off-list]
> >>>
> >>>On Fri 22-03-13 07:46:32, Simon Jeons wrote:
> >>>>Hi Michal,
> >>>>On 03/21/2013 08:56 PM, Michal Hocko wrote:
> >>>>>On Thu 21-03-13 07:49:48, Simon Jeons wrote:
> >>>>>[...]
> >>>>>>When I hacking arch/x86/mm/hugetlbpage.c like this,
> >>>>>>diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
> >>>>>>index ae1aa71..87f34ee 100644
> >>>>>>--- a/arch/x86/mm/hugetlbpage.c
> >>>>>>+++ b/arch/x86/mm/hugetlbpage.c
> >>>>>>@@ -354,14 +354,13 @@ hugetlb_get_unmapped_area(struct file *file,
> >>>>>>unsigned long addr,
> >>>>>>
> >>>>>>#endif /*HAVE_ARCH_HUGETLB_UNMAPPED_AREA*/
> >>>>>>
> >>>>>>-#ifdef CONFIG_X86_64
> >>>>>>static __init int setup_hugepagesz(char *opt)
> >>>>>>{
> >>>>>>unsigned long ps = memparse(opt, &opt);
> >>>>>>if (ps == PMD_SIZE) {
> >>>>>>hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT);
> >>>>>>- } else if (ps == PUD_SIZE && cpu_has_gbpages) {
> >>>>>>- hugetlb_add_hstate(PUD_SHIFT - PAGE_SHIFT);
> >>>>>>+ } else if (ps == PUD_SIZE) {
> >>>>>>+ hugetlb_add_hstate(PMD_SHIFT - PAGE_SHIFT+4);
> >>>>>>} else {
> >>>>>>printk(KERN_ERR "hugepagesz: Unsupported page size %lu M\n",
> >>>>>>ps >> 20);
> >>>>>>
> >>>>>>I set boot=hugepagesz=1G hugepages=10, then I got 10 32MB huge pages.
> >>>>>>What's the difference between these pages which I hacking and normal
> >>>>>>huge pages?
> >>>>>How is this related to the patch set?
> >>>>>Please _stop_ distracting discussion to unrelated topics!
> >>>>>
> >>>>>Nothing personal but this is just wasting our time.
> >>>>Sorry kindly Michal, my bad.
> >>>>Btw, could you explain this question for me? very sorry waste your time.
> >>>Your CPU has to support GB pages. You have removed cpu_has_gbpages test
> >>>and added a hstate for order 13 pages which is a weird number on its
> >>>own (32MB) because there is no page table level to support them.
> >>But after hacking, there is /sys/kernel/mm/hugepages/hugepages-*,
> >>and have equal number of 32MB huge pages which I set up in boot
> >>parameter.
> >because hugetlb_add_hstate creates hstate for those pages and
> >hugetlb_init_hstates allocates them later on.
> >
> >>If there is no page table level to support them, how can
> >>them present?
> >Because hugetlb hstate handling code doesn't care about page tables and
> >the way how those pages are going to be mapped _at all_. Or put it in
> >another way. Nobody prevents you to allocate order-5 page for a single
> >pte but that would be a pure waste. Page fault code expects that pages
> >with a proper size are allocated.
> Do you mean 32MB pages will map to one pmd which should map 2MB pages?
> 

Please refer to hugetlb_fault for more information.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
