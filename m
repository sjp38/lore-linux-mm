Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 725546B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 19:05:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e74so16825420pfd.12
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 16:05:10 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n3si5905718pld.998.2017.08.07.16.05.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 16:05:09 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm: Clear to access sub-page last when clearing huge page
References: <20170807072131.8343-1-ying.huang@intel.com>
	<alpine.DEB.2.20.1708071343030.19915@nuc-kabylake>
Date: Tue, 08 Aug 2017 07:05:03 +0800
In-Reply-To: <alpine.DEB.2.20.1708071343030.19915@nuc-kabylake> (Christopher
	Lameter's message of "Mon, 7 Aug 2017 13:46:37 -0500")
Message-ID: <87a83bgesg.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>

Christopher Lameter <cl@linux.com> writes:

> On Mon, 7 Aug 2017, Huang, Ying wrote:
>
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -4374,9 +4374,31 @@ void clear_huge_page(struct page *page,
>>  	}
>>
>>  	might_sleep();
>> -	for (i = 0; i < pages_per_huge_page; i++) {
>> +	VM_BUG_ON(clamp(addr_hint, addr, addr +
>> +			(pages_per_huge_page << PAGE_SHIFT)) != addr_hint);
>> +	n = (addr_hint - addr) / PAGE_SIZE;
>> +	if (2 * n <= pages_per_huge_page) {
>> +		base = 0;
>> +		l = n;
>> +		for (i = pages_per_huge_page - 1; i >= 2 * n; i--) {
>> +			cond_resched();
>> +			clear_user_highpage(page + i, addr + i * PAGE_SIZE);
>> +		}
>
> I really like the idea behind the patch but this is not clearing from last
> to first byte of the huge page.
>
> What seems to be happening here is clearing from the last page to the
> first page and I would think that within each page the clearing is from
> first byte to last byte. Maybe more gains can be had by really clearing
> from last to first byte of the huge page instead of this jumping over 4k
> addresses?

Yes.  That is a good idea.  I will experiment it via changing the
direction to clear in clear_user_highpage().

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
