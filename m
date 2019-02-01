Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F0D8C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 09:04:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5655E20855
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 09:04:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5655E20855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E660F8E0002; Fri,  1 Feb 2019 04:04:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E16E38E0001; Fri,  1 Feb 2019 04:04:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D04FC8E0002; Fri,  1 Feb 2019 04:04:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7224E8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 04:04:26 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id f17so2528471edm.20
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 01:04:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=hLcwXMz+8ZUB0n9zYz82/38boLtXumuez0AG78bRcf8=;
        b=tpu823uS76pcrCrjebpyGLXhNP0OKnADzESNlZyLluePqxB0W2yyx5feLJ0FH8HNVm
         ID2jR6u+jAR5DP0A0nSOPDx73DWhMkyntusUVu6NGZT8xifp0o2EDUwUL0Pl+MBQTxCk
         qy3fB79uLtCLUvNfY1axuFH0dk0bWVOMQALPHi06eFFgkIxC4bYYzrLDqG9HL665Q9Qa
         328CMKDdyqNLzoaKUYMo7wAdGQpq3phx/pj7fKzZ0ifBlZ3dth9mJNwd6cqMEzdu1WXv
         MyI8XsbLfIDDcE0anQFILwljSYyTx+BWGg1Sfd+TThH6w17hwUrxH2lr5jNjn+8uqQwc
         D7JA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUuke7pq0xhqbTR+2plMlGLWabj5pkojPd82Ac2CsNR1XAdJwoheMt
	liJyy9gs2knSzI0nJqfHM04pLvZMnV7M8tGYdo4QCCYFPvs9NAUXkUFqEYg2wYL5Egc842ItUdr
	vupmQAqeqfZOzKm4vDWBJATnJPjNrEIJbeeZTFt1bMxQPOI+ntCF8Yy+Cu/6P0KhCpQ==
X-Received: by 2002:a50:ad97:: with SMTP id a23mr36358844edd.128.1549011865931;
        Fri, 01 Feb 2019 01:04:25 -0800 (PST)
X-Google-Smtp-Source: ALg8bN59zzG8kYcuoPnbztHhtaZG+JNdVDPaqDCIdOppX7VoqP1XFj5qa0CejQ0R1c2cNAGPbwgD
X-Received: by 2002:a50:ad97:: with SMTP id a23mr36358784edd.128.1549011864836;
        Fri, 01 Feb 2019 01:04:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549011864; cv=none;
        d=google.com; s=arc-20160816;
        b=hmlHfbAm34UgwxdeEBF0sGV8A2YQV2CxKsXgKKcdc0NOXf+EJ2R3x2XkngPw3t+KdP
         r17KTe38OQkzrRfz1GuGNRP8Bue2oUuKwej1xZ7WY8tm9sIXA/V4uKGWXgX0DfwjEj4C
         gznU+PQD2TncPiLkHmVAjNdJqV8BvbLygqSCrR9LJ4Nh+0+5u7Koc7LFoNRYFN1g0QV8
         sL9lIQOF6ot8kZ4m8gaRfcGwjfR5ZRBrW73RtSYV32awEP1b2PgzXG0QsZTV1+1qh6vu
         erAFp59tfR7GATgdX5To8KQWgN2lHX571CGtymPz4NPn3VfksfhWdU8lzXuelC3URmyP
         LRug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=hLcwXMz+8ZUB0n9zYz82/38boLtXumuez0AG78bRcf8=;
        b=ga6UMp8pOuSH+xn4CEtjcBPnI7s6hBBklO4XVchOjHuAaZFjrDPa4eGM5mumGMH/4x
         lAoAzOHXSSw9oOzISlKkoE/EXe/vLL32d8a5s6mMMmhj4Z6f6z8y4JbYjeqwtX4b+FpX
         Y44zMfJiEtPWqw6aTr9RFg6mhTHM1tEk2+KW4LIZNjZeCyq7pA5zCNXFVM+ij9CR+gEy
         O2SeakYWHqTBou2nATR4CSIGWIREgiP5mp/nseqBTK6y0j31UZN+2Hncgl46YID1varW
         yJB6rfN9Fd8q4BM/evh5l1DlJ0etH0s+Yyh/JyjebhP+DYMpe2s7wQXocID+KhEHmb+k
         3EqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 95si3598727edq.82.2019.02.01.01.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 01:04:24 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F389EB029;
	Fri,  1 Feb 2019 09:04:23 +0000 (UTC)
Subject: Re: [PATCH 3/3] mm/mincore: provide mapped status when cached status
 is not allowed
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org,
 Peter Zijlstra <peterz@infradead.org>, Greg KH <gregkh@linuxfoundation.org>,
 Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>,
 Dominique Martinet <asmadeus@codewreck.org>,
 Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>,
 Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>,
 Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>, Daniel Gruss
 <daniel@gruss.cc>, Jiri Kosina <jkosina@suse.cz>,
 Josh Snyder <joshs@netflix.com>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-4-vbabka@suse.cz>
 <20190131100907.GS18811@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <99ee4d3e-aeb2-0104-22be-b028938e7f88@suse.cz>
Date: Fri, 1 Feb 2019 10:04:23 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190131100907.GS18811@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 1/31/19 11:09 AM, Michal Hocko wrote:
> On Wed 30-01-19 13:44:20, Vlastimil Babka wrote:
>> After "mm/mincore: make mincore() more conservative" we sometimes restrict the
>> information about page cache residency, which we have to do without breaking
>> existing userspace, if possible. We thus fake the resulting values as 1, which
>> should be safer than faking them as 0, as there might theoretically exist code
>> that would try to fault in the page(s) until mincore() returns 1.
>>
>> Faking 1 however means that such code would not fault in a page even if it was
>> not in page cache, with unwanted performance implications. We can improve the
>> situation by revisting the approach of 574823bfab82 ("Change mincore() to count
>> "mapped" pages rather than "cached" pages") but only applying it to cases where
>> page cache residency check is restricted. Thus mincore() will return 0 for an
>> unmapped page (which may or may not be resident in a pagecache), and 1 after
>> the process faults it in.
>>
>> One potential downside is that mincore() will be again able to recognize when a
>> previously mapped page was reclaimed. While that might be useful for some
>> attack scenarios, it's not as crucial as recognizing that somebody else faulted
>> the page in, and there are also other ways to recognize reclaimed pages anyway.
> 
> Is this really worth it? Do we know about any specific usecase that
> would benefit from this change? TBH I would rather wait for the report
> than add a hard to evaluate side channel.

Well it's not that complicated IMHO. Linus said it's worth trying, so
let's see how he likes the result. The side channel exists anyway as
long as process can e.g. check if its rss shrinked, and I doubt we are
going to remove that possibility.

Also CC Josh Snyder since I forgot originally, and keeping rest of mail
for reference.

>> Cc: Jiri Kosina <jikos@kernel.org>
>> Cc: Dominique Martinet <asmadeus@codewreck.org>
>> Cc: Andy Lutomirski <luto@amacapital.net>
>> Cc: Dave Chinner <david@fromorbit.com>
>> Cc: Kevin Easton <kevin@guarana.org>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Cyril Hrubis <chrubis@suse.cz>
>> Cc: Tejun Heo <tj@kernel.org>
>> Cc: Kirill A. Shutemov <kirill@shutemov.name>
>> Cc: Daniel Gruss <daniel@gruss.cc>
>> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
>> ---
>>  mm/mincore.c | 49 +++++++++++++++++++++++++++++++++----------------
>>  1 file changed, 33 insertions(+), 16 deletions(-)
>>
>> diff --git a/mm/mincore.c b/mm/mincore.c
>> index 747a4907a3ac..d6784a803ae7 100644
>> --- a/mm/mincore.c
>> +++ b/mm/mincore.c
>> @@ -21,12 +21,18 @@
>>  #include <linux/uaccess.h>
>>  #include <asm/pgtable.h>
>>  
>> +struct mincore_walk_private {
>> +	unsigned char *vec;
>> +	bool can_check_pagecache;
>> +};
>> +
>>  static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
>>  			unsigned long end, struct mm_walk *walk)
>>  {
>>  #ifdef CONFIG_HUGETLB_PAGE
>>  	unsigned char present;
>> -	unsigned char *vec = walk->private;
>> +	struct mincore_walk_private *walk_private = walk->private;
>> +	unsigned char *vec = walk_private->vec;
>>  
>>  	/*
>>  	 * Hugepages under user process are always in RAM and never
>> @@ -35,7 +41,7 @@ static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
>>  	present = pte && !huge_pte_none(huge_ptep_get(pte));
>>  	for (; addr != end; vec++, addr += PAGE_SIZE)
>>  		*vec = present;
>> -	walk->private = vec;
>> +	walk_private->vec = vec;
>>  #else
>>  	BUG();
>>  #endif
>> @@ -85,7 +91,8 @@ static unsigned char mincore_page(struct address_space *mapping, pgoff_t pgoff)
>>  }
>>  
>>  static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
>> -				struct vm_area_struct *vma, unsigned char *vec)
>> +				struct vm_area_struct *vma, unsigned char *vec,
>> +				bool can_check_pagecache)
>>  {
>>  	unsigned long nr = (end - addr) >> PAGE_SHIFT;
>>  	int i;
>> @@ -95,7 +102,9 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
>>  
>>  		pgoff = linear_page_index(vma, addr);
>>  		for (i = 0; i < nr; i++, pgoff++)
>> -			vec[i] = mincore_page(vma->vm_file->f_mapping, pgoff);
>> +			vec[i] = can_check_pagecache ?
>> +				 mincore_page(vma->vm_file->f_mapping, pgoff)
>> +				 : 0;
>>  	} else {
>>  		for (i = 0; i < nr; i++)
>>  			vec[i] = 0;
>> @@ -106,8 +115,11 @@ static int __mincore_unmapped_range(unsigned long addr, unsigned long end,
>>  static int mincore_unmapped_range(unsigned long addr, unsigned long end,
>>  				   struct mm_walk *walk)
>>  {
>> -	walk->private += __mincore_unmapped_range(addr, end,
>> -						  walk->vma, walk->private);
>> +	struct mincore_walk_private *walk_private = walk->private;
>> +	unsigned char *vec = walk_private->vec;
>> +
>> +	walk_private->vec += __mincore_unmapped_range(addr, end, walk->vma,
>> +				vec, walk_private->can_check_pagecache);
>>  	return 0;
>>  }
>>  
>> @@ -117,7 +129,8 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>>  	spinlock_t *ptl;
>>  	struct vm_area_struct *vma = walk->vma;
>>  	pte_t *ptep;
>> -	unsigned char *vec = walk->private;
>> +	struct mincore_walk_private *walk_private = walk->private;
>> +	unsigned char *vec = walk_private->vec;
>>  	int nr = (end - addr) >> PAGE_SHIFT;
>>  
>>  	ptl = pmd_trans_huge_lock(pmd, vma);
>> @@ -128,7 +141,8 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>>  	}
>>  
>>  	if (pmd_trans_unstable(pmd)) {
>> -		__mincore_unmapped_range(addr, end, vma, vec);
>> +		__mincore_unmapped_range(addr, end, vma, vec,
>> +					walk_private->can_check_pagecache);
>>  		goto out;
>>  	}
>>  
>> @@ -138,7 +152,7 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>>  
>>  		if (pte_none(pte))
>>  			__mincore_unmapped_range(addr, addr + PAGE_SIZE,
>> -						 vma, vec);
>> +				 vma, vec, walk_private->can_check_pagecache);
>>  		else if (pte_present(pte))
>>  			*vec = 1;
>>  		else { /* pte is a swap entry */
>> @@ -152,8 +166,12 @@ static int mincore_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
>>  				*vec = 1;
>>  			} else {
>>  #ifdef CONFIG_SWAP
>> -				*vec = mincore_page(swap_address_space(entry),
>> +				if (walk_private->can_check_pagecache)
>> +					*vec = mincore_page(
>> +						    swap_address_space(entry),
>>  						    swp_offset(entry));
>> +				else
>> +					*vec = 0;
>>  #else
>>  				WARN_ON(1);
>>  				*vec = 1;
>> @@ -187,22 +205,21 @@ static long do_mincore(unsigned long addr, unsigned long pages, unsigned char *v
>>  	struct vm_area_struct *vma;
>>  	unsigned long end;
>>  	int err;
>> +	struct mincore_walk_private walk_private = {
>> +		.vec = vec
>> +	};
>>  	struct mm_walk mincore_walk = {
>>  		.pmd_entry = mincore_pte_range,
>>  		.pte_hole = mincore_unmapped_range,
>>  		.hugetlb_entry = mincore_hugetlb,
>> -		.private = vec,
>> +		.private = &walk_private
>>  	};
>>  
>>  	vma = find_vma(current->mm, addr);
>>  	if (!vma || addr < vma->vm_start)
>>  		return -ENOMEM;
>>  	end = min(vma->vm_end, addr + (pages << PAGE_SHIFT));
>> -	if (!can_do_mincore(vma)) {
>> -		unsigned long pages = (end - addr) >> PAGE_SHIFT;
>> -		memset(vec, 1, pages);
>> -		return pages;
>> -	}
>> +	walk_private.can_check_pagecache = can_do_mincore(vma);
>>  	mincore_walk.mm = vma->vm_mm;
>>  	err = walk_page_range(addr, end, &mincore_walk);
>>  	if (err < 0)
>> -- 
>> 2.20.1
> 

