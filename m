Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id DBB4F6B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 07:09:56 -0500 (EST)
Received: by wghn12 with SMTP id n12so46289506wgh.1
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 04:09:56 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id xx1si1164180wjc.205.2015.03.04.04.09.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 04:09:55 -0800 (PST)
Message-ID: <54F6F60F.4070705@suse.cz>
Date: Wed, 04 Mar 2015 13:09:51 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCHv3 04/24] rmap: add argument to charge compound page
References: <1423757918-197669-1-git-send-email-kirill.shutemov@linux.intel.com> <1423757918-197669-5-git-send-email-kirill.shutemov@linux.intel.com> <54EB538B.7040308@suse.cz> <20150304115244.GA16452@node.dhcp.inet.fi>
In-Reply-To: <20150304115244.GA16452@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/04/2015 12:52 PM, Kirill A. Shutemov wrote:
> On Mon, Feb 23, 2015 at 05:21:31PM +0100, Vlastimil Babka wrote:
>> On 02/12/2015 05:18 PM, Kirill A. Shutemov wrote:
>>> @@ -1052,21 +1052,24 @@ void page_add_anon_rmap(struct page *page,
>>>    * Everybody else should continue to use page_add_anon_rmap above.
>>>    */
>>>   void do_page_add_anon_rmap(struct page *page,
>>> -	struct vm_area_struct *vma, unsigned long address, int exclusive)
>>> +	struct vm_area_struct *vma, unsigned long address, int flags)
>>>   {
>>>   	int first = atomic_inc_and_test(&page->_mapcount);
>>>   	if (first) {
>>> +		bool compound = flags & RMAP_COMPOUND;
>>> +		int nr = compound ? hpage_nr_pages(page) : 1;
>>
>> hpage_nr_pages(page) is:
>>
>> static inline int hpage_nr_pages(struct page *page)
>> {
>>          if (unlikely(PageTransHuge(page)))
>>                  return HPAGE_PMD_NR;
>>          return 1;
>> }
>>
>> and later...
>>
>>>   		/*
>>>   		 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
>>>   		 * these counters are not modified in interrupt context, and
>>>   		 * pte lock(a spinlock) is held, which implies preemption
>>>   		 * disabled.
>>>   		 */
>>> -		if (PageTransHuge(page))
>>> +		if (compound) {
>>> +			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
>>
>> this means that we could assume that
>> (compound == true) => (PageTransHuge(page) == true)
>>
>> and simplify above to:
>>
>> int nr = compound ? HPAGE_PMD_NR : 1;
>>
>> Right?
>
> No. HPAGE_PMD_NR is defined based on HPAGE_PMD_SHIFT which is BUILD_BUG()
> without CONFIG_TRANSPARENT_HUGEPAGE. We will get compiler error without
> the helper.

Oh, OK. But that doesn't mean there couldn't be another helper that 
would work in this case, or even open-coded #ifdefs in these functions. 
Apparently "compound" has to be always false for 
!CONFIG_TRANSPARENT_HUGEPAGE, as in that case PageTransHuge is defined 
as 0 and the VM_BUG_ON would trigger if compound was true. So without 
such ifdefs or wrappers, you are also adding dead code and pointless 
tests for !CONFIG_TRANSPARENT_HUGEPAGE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
