Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77C44C32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:04:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3686A2166E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 18:04:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Lm48/h4n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3686A2166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D06E86B0292; Fri,  9 Aug 2019 14:04:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB7E26B02A2; Fri,  9 Aug 2019 14:04:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA7AA6B02B9; Fri,  9 Aug 2019 14:04:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 879736B0292
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 14:04:49 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id l12so13478742pgt.9
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 11:04:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=g0FmRWOVSQw+ovYa/Gu5Q2BPMATNeZLwtOFaVN9ZPw0=;
        b=s/uKi5stqWGOOlyO5zeeqpg8fgBzr59vsJ0Tv28Xs6JK7ZqqHy6uhDRMTupxbcdgMj
         jZ2gcqimDqy1zoLNQfW/YoOKBTpFT7+OLyoug4ABvCn1SAX3fp81n4NVzbqBOL34ZWci
         +4qg8olucOHTFulI0Om2Tl0Rq7TfaQ8Tn3/ydoAGgQBh/m4E2N3/K/q/WhOfR5EzDayq
         WecFG0IdAG0icuHAlzcZLOxavOw5tkJD0/Fk/mmKuUnltzRD75cf6KyRcb6L2ta7z0SS
         oGXdT3QCcNArIMlKUB9xRH4U0TWzcruYtq2fiefRj4z0bQ7G7pW8709PW5cMetvOKetx
         B8PQ==
X-Gm-Message-State: APjAAAVdNW/cQiK8fc0TAu53RLXfJLEurqVHpZ7ps0fwmVbKefROTk6h
	+iD/lHohONHpGriV/vQvijfE0BLrgdzZbewlG6wPYlgxUjuev6vVMmWMJ4/K4vtYkOzB43SluOv
	UvUie/gtJQU7GAHB6BFQW0I1utn0Hv2qTrQ8dRB+1SfoCE3O6LfXzJd7VBVhTppa4FA==
X-Received: by 2002:a17:90a:2343:: with SMTP id f61mr10788437pje.130.1565373889153;
        Fri, 09 Aug 2019 11:04:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRg1++uc2ZwbjaP2qWvls3qOoHS2zTF3TbyG5RrEWHAGLVpQOrKktip71OCv39bKzlqcu+
X-Received: by 2002:a17:90a:2343:: with SMTP id f61mr10788369pje.130.1565373888175;
        Fri, 09 Aug 2019 11:04:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565373888; cv=none;
        d=google.com; s=arc-20160816;
        b=fVah7Q07SZwXyH9S8JSthLsplqQ641G4vhkLQVwPCRG0KTOpBv7ivQliS7Q0fuJ1ML
         nBPche6AzVpPMnOfzAxixr66gEZQT3aVgsK397MR0VJBM0uAqWZyzQ9UGj6ZtUJdQqg7
         gURRj7nEDLVOtuBwjRCLXaoPt6Q0uMiE+Sfw2/P3tr/b3osxmqSoZ1FimIJZtMIj0cgZ
         2o+3dVnY2OwtnX7nwCj9rIM+cl1uX0Lm6eBkejV8jSbnZgPqriy7bzBa/ComD3inNCG9
         Qzys4263k0sQNSw7MveKRnC/9nC7LUvFa2fvd4Kj/8E6syDPhaC52SHa2/7Pspm2Picd
         YeaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=g0FmRWOVSQw+ovYa/Gu5Q2BPMATNeZLwtOFaVN9ZPw0=;
        b=Wd6WXvwbgENqswv1Ap7WLoMWc6zpr0L4LlluiZXosRhhfeHr2wVaFp+aNd168WIGZR
         0VJKH4WUkkTXC4N47C48bvWS+vf347C7ph8J1LVA4assFAUjLgGgxC+m2zBsiMLrr+po
         TpTY4Er2WLrUBc5PTBsZKx4kn4AEu9jAFNXQGj52/wUZXAaY69ZV03gG+cudK0OTpmTG
         JVBzZUrG1ZdaDyC9m6QJdFBO1mKcS+Lob02DX5P1LFTiIGXSxAAPztxM00C75Hf6Lu0Q
         Qh2r0N6UbFyqgo+qhNvXHF2PcBbBe+Ccs3qTkz63xNfpOXO9TkLs8o87FqlbO4nBDva0
         MRaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="Lm48/h4n";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id d1si6442318pln.120.2019.08.09.11.04.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 11:04:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="Lm48/h4n";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4db5c00001>; Fri, 09 Aug 2019 11:04:48 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 09 Aug 2019 11:04:47 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 09 Aug 2019 11:04:47 -0700
Received: from [10.2.165.207] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 9 Aug
 2019 18:04:46 +0000
Subject: Re: [Linux-kernel-mentees][PATCH v4 1/1] sgi-gru: Remove *pte_lookup
 functions
To: Bharath Vedartham <linux.bhar@gmail.com>
CC: <arnd@arndb.de>, <gregkh@linuxfoundation.org>, <sivanich@sgi.com>,
	<ira.weiny@intel.com>, <jglisse@redhat.com>, <william.kucharski@oracle.com>,
	<hch@lst.de>, <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-kernel-mentees@lists.linuxfoundation.org>
References: <1565290555-14126-1-git-send-email-linux.bhar@gmail.com>
 <1565290555-14126-2-git-send-email-linux.bhar@gmail.com>
 <b659042a-f2c3-df3c-4182-bb7dd5156bc1@nvidia.com>
 <20190809094406.GA22457@bharath12345-Inspiron-5559>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <f2f928f1-2747-e693-1a7f-14ad5f57fef5@nvidia.com>
Date: Fri, 9 Aug 2019 11:03:14 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809094406.GA22457@bharath12345-Inspiron-5559>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565373888; bh=g0FmRWOVSQw+ovYa/Gu5Q2BPMATNeZLwtOFaVN9ZPw0=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Lm48/h4n/E5d/oO1iuhNqiTdYfI3bWD99pXlSulIAVr+7+NFRBRx04unypjYa1LXI
	 Qu4NX+U659GBezGwaMcDXMJU0olVDQx+bBlgV+unRtfatA4yS2dWJxVAXe/iowCU4x
	 0GAz9g4BgSU+xFpBfQVrsgoJPYC5iS30AC3Opk/9+2XoJDfHTPY12Ub/9+JxFl6irE
	 KcsFlVYTcES6cGUQKT3HWrC/e0R6pQqwaF3SLlUyeXHHoS6q3AkNvxCzBgk8SbSyTj
	 pO7Z0ED/1Dy0mBD1w54rbULkdwFKXtgUu6IGkQ7U0H1qrJd68vPLFJvdGloq1H30oh
	 sfUnjNFy9oqKA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/9/19 2:44 AM, Bharath Vedartham wrote:
> On Thu, Aug 08, 2019 at 04:21:44PM -0700, John Hubbard wrote:
>> On 8/8/19 11:55 AM, Bharath Vedartham wrote:
>> ...
>>>   static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
>>>   		    int write, int atomic, unsigned long *gpa, int *pageshift)
>>>   {
>>>   	struct mm_struct *mm = gts->ts_mm;
>>>   	struct vm_area_struct *vma;
>>>   	unsigned long paddr;
>>> -	int ret, ps;
>>> +	int ret;
>>> +	struct page *page;
>>>   
>>>   	vma = find_vma(mm, vaddr);
>>>   	if (!vma)
>>> @@ -263,21 +187,33 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
>>>   
>>>   	/*
>>>   	 * Atomic lookup is faster & usually works even if called in non-atomic
>>> -	 * context.
>>> +	 * context. get_user_pages_fast does atomic lookup before falling back to
>>> +	 * slow gup.
>>>   	 */
>>>   	rmb();	/* Must/check ms_range_active before loading PTEs */
>>> -	ret = atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
>>> -	if (ret) {
>>> -		if (atomic)
>>> +	if (atomic) {
>>> +		ret = __get_user_pages_fast(vaddr, 1, write, &page);
>>> +		if (!ret)
>>>   			goto upm;
>>> -		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))
>>> +	} else {
>>> +		ret = get_user_pages_fast(vaddr, 1, write ? FOLL_WRITE : 0, &page);
>>> +		if (!ret)
>>>   			goto inval;
>>>   	}
>>> +
>>> +	paddr = page_to_phys(page);
>>> +	put_user_page(page);
>>> +
>>> +	if (unlikely(is_vm_hugetlb_page(vma)))
>>> +		*pageshift = HPAGE_SHIFT;
>>> +	else
>>> +		*pageshift = PAGE_SHIFT;
>>> +
>>>   	if (is_gru_paddr(paddr))
>>>   		goto inval;
>>> -	paddr = paddr & ~((1UL << ps) - 1);
>>> +	paddr = paddr & ~((1UL << *pageshift) - 1);
>>>   	*gpa = uv_soc_phys_ram_to_gpa(paddr);
>>> -	*pageshift = ps;
>>
>> Why are you no longer setting *pageshift? There are a couple of callers
>> that both use this variable.
> Hi John,
> 
> I did set *pageshift. The if statement above sets *pageshift. ps was
> used to retrive the pageshift value when the pte_lookup functions were
> present. ps was passed by reference to those functions and set by them.
> But here since we are trying to remove those functions, we don't need ps
> and we directly set *pageshift to HPAGE_SHIFT or PAGE_SHIFT based on the
> type of vma.
> 
> Hope this clears things up?
> 

Right you are, sorry for overlooking that. Looks good.

thanks,
-- 
John Hubbard
NVIDIA

