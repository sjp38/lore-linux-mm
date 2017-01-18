Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D2F66B0261
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:16:05 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y143so20201949pfb.6
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 07:16:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i19si507087pgk.91.2017.01.18.07.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 07:16:04 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0IFDuGY011409
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:16:03 -0500
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
	by mx0a-001b2d01.pphosted.com with ESMTP id 281ubbsv65-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 10:16:03 -0500
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <imbrenda@linux.vnet.ibm.com>;
	Wed, 18 Jan 2017 15:16:00 -0000
Subject: Re: [PATCH v1 1/1] mm/ksm: improve deduplication of zero pages with
 colouring
References: <1484237834-15803-1-git-send-email-imbrenda@linux.vnet.ibm.com>
 <20170112172132.GM4947@redhat.com>
From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Date: Wed, 18 Jan 2017 16:15:56 +0100
MIME-Version: 1.0
In-Reply-To: <20170112172132.GM4947@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <1e1e7589-9713-e6a4-f57c-bfd94eb3e1e9@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, borntraeger@de.ibm.com, hughd@google.com, izik.eidus@ravellosystems.com, chrisw@sous-sol.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Hi Andrea,

On 12/01/17 18:21, Andrea Arcangeli wrote:
> Hello Claudio,
> 
> On Thu, Jan 12, 2017 at 05:17:14PM +0100, Claudio Imbrenda wrote:
>> +#ifdef __HAVE_COLOR_ZERO_PAGE
>> +	/*
>> +	 * Same checksum as an empty page. We attempt to merge it with the
>> +	 * appropriate zero page.
>> +	 */
>> +	if (checksum == zero_checksum) {
>> +		struct vm_area_struct *vma;
>> +
>> +		vma = find_mergeable_vma(rmap_item->mm, rmap_item->address);
>> +		err = try_to_merge_one_page(vma, page,
>> +					    ZERO_PAGE(rmap_item->address));
> 
> So the objective is not to add the zero pages to the stable tree but
> just convert them to readonly zerpages?

Yes. I thought that would be the easiest and cleanest way to do it.

> Maybe this could be a standard option for all archs to disable
> enable/disable with a new sysfs control similarly to the NUMA aware
> deduplication. The question is if it should be enabled by default in
> those archs where page coloring matters a lot. Probably yes.

I'm not sure it would make sense to have this for archs that don't have
page coloring. Merging empty pages together instead of with the
ZERO_PAGE() would save exactly one page and it would bring no speed
advantages (or rather: not using the ZERO_PAGE() would not bring any
speed penalty).
That's why I have #ifdef'd it to have it only when page coloring is
present. Also, for what I could see, only MIPS and s390 have page
coloring; I don't like the idea of imposing any overhead to all the
other archs.

I agree that this should be toggleable with a sysfs control, since it's
a change that can potentially negatively affect the performance in some
cases. I'm adding it in the next iteration.

> There are guest OS creating lots of zero pages, not linux though, for
> linux guests this is just overhead. Also those guests creating zero

Unless the userspace in the guests is creating lots of pages full of
zeroes :)

> pages wouldn't constantly read from them so again for KVM usage this
> is unlikely to help. For certain guest OS it'll create less KSM
> metadata with this approach, but it's debatable if it's worth one more

Honestly I don't think this patch will bring any benefits regarding
metadata -- one page more or less in the metadata won't change much. Our
issue is just the reading speed of the deduplicated empty pages.

> memcpy for every merge-candidate page to save some metadata, it's very

I'm confused, why memcpy? did you mean memcmp? We are not doing any
additional memops except in the case when a candidate non-empty page
happens to have the same checksum as an empty page, in which case we
have an extra memcmp compared to the normal operation.

> guest-workload dependent too. Of course your usage is not KVM but
> number crunching with uninitialized tables, it's different and the
> zero page read speed matters.
> 
> On the implementation side I think the above is going to call
> page_add_anon_rmap(kpage, vma, addr, false) and get_page by mistake,
> and it should use pte_mkspecial not mk_pte. I think you need to pass
> up a zeropage bool into replace_page and change replace_page to create
> a proper zeropage in place of the old page or it'll eventually
> overflow the page count crashing etc...

Maybe an even less intrusive change could be to check in replace_page if
is_zero_pfn(page_to_pfn(kpage)). And of course I would #ifdef that too,
to avoid the overhead for archs without page coloring.
So if the replacement page is a ZERO_PAGE() no get_page() and no
page_add_anon_rmap() would be performed, and the set_pte_at_notify()
would have pte_mkspecial(pfn_pte(page_to_pfn(kpage))) instead of mk_pte() .


thanks,
Claudio

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
