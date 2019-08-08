Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86F77C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:21:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B4442173E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:21:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="l5IhY/V8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B4442173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D91AE6B0003; Thu,  8 Aug 2019 19:21:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D41D56B0006; Thu,  8 Aug 2019 19:21:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C572D6B0007; Thu,  8 Aug 2019 19:21:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 942746B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:21:47 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y66so60100430pfb.21
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:21:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=+5ClyXF4/+matB7j6ropEiCrm63pptXnzihc56YYTPY=;
        b=puFKMbtP19zLgs222GSURbUR1JpptjKRMI98O4Vufk6VcpJKERvmpKOI+YAHb6OIEI
         Q2S5t2elIcjMpcPwV/wtlb22USbq1Z4qR7CsWWrvVJS5XAKsYfa2W3IVxaNL1de6d2JF
         yJiloEmD0vAcXZcFDKVZTDVlhVrW2OysWS0R3KJCH/mPNdbtDxImzPYfMTSYpR3SALM+
         LfEJdTFA7WEeDbsEfiCaXtLc/CILy8GpMvgB3ZljC1AKkiVTtpCykr730xQFJoOendZY
         uIGh8hWc0czq4KIuyMw95iUmxwk3sgwp/88fZT20OjzUFJ9zAgp1fut7s98/xcjBjVn2
         SSxw==
X-Gm-Message-State: APjAAAUcj6yAfWo0KwY0M5BQ4+f3TlKRLtuJ9hsO5lcYMh9dWuqr5i4/
	5F33qBL9emgEh6TUKi+6GSVoz+VFzH0+Sz+CoAfx0vkZdDGTvXQ5gaCt6rDtgstuMv5y86w7SI+
	p7CV0fQenfX9pE5qs4IXwMrjhLEVDuVwMQMnziRdHTkAAHH5mYYXsTNXV/qP6oZu0PQ==
X-Received: by 2002:a63:e84a:: with SMTP id a10mr15490765pgk.274.1565306507036;
        Thu, 08 Aug 2019 16:21:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3cl8erteqLRNq9RXWssagxGv0Orq0UZHQWQxgZuHF8yshyzuEUg9MhNRFk6Qtix2kd1gQ
X-Received: by 2002:a63:e84a:: with SMTP id a10mr15490723pgk.274.1565306506289;
        Thu, 08 Aug 2019 16:21:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565306506; cv=none;
        d=google.com; s=arc-20160816;
        b=04n1ULKdn5px8h4qqms/LUvukLX7bOk+XtMEx+h23kmAGNn1BlYRi4ReOBQXnrN049
         EcU5LvM4+oTrm1JJ8M8iokYBI4kCQBp6v8tjhm5n3FvXQ503HPDvR3ez6rWZx7VTgg0o
         rgjTnNiefhRR9yqBxobNZj3n9n6sPfZ0+KIjL2QayBVhi6kUOHy5FQaVeSwIvPcRxJvP
         jBEDiiYtcDhd+yvvWJm7lHHXtfhaTWI3kLd6H48Q7oCLLEzB89HXvT/IG63WgudLfK23
         vopKJS3CO24XMxRcyiB1Fp6Fcc0OvFDN8Alg/LHbs+hQhHa8jHCm0PzaK1Iaet59zr8Q
         a0zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=+5ClyXF4/+matB7j6ropEiCrm63pptXnzihc56YYTPY=;
        b=hsGHWMIpfl+4HE84UQmQ/czFbtm1XT5o/LZqBGNR3Bm/Bk7oDbp5WqKR5ZDgDM1VwL
         /u8EqVMnq77k9MMe+3OedVMG/Nsvx85XdQ4DSeq8lspvQ+zJ6wM04mRRJliA4RjmjH29
         GzQ+wXdjOESAIOoARV7NpQfa8qbhY4f/ovM0DlRq0ajWu3n+4I8Z47WdQCc4Q9PVCEhT
         ZD0nSLOVH98q418QjrQkeSpdWPKcUxuOlUS3qdQagurzvYqdFu+396esrYOhpKK3CcCT
         TIIppVDNlt1f65vn8HRKG+UalQeJXt7vZgWOOmOFuNXwd2ZPDaj9EmbCmIRWF1BLAdUl
         YNXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="l5IhY/V8";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id z61si48225647plb.19.2019.08.08.16.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 16:21:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="l5IhY/V8";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4cae8b0000>; Thu, 08 Aug 2019 16:21:47 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 08 Aug 2019 16:21:45 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 08 Aug 2019 16:21:45 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 8 Aug
 2019 23:21:45 +0000
Subject: Re: [Linux-kernel-mentees][PATCH v4 1/1] sgi-gru: Remove *pte_lookup
 functions
To: Bharath Vedartham <linux.bhar@gmail.com>, <arnd@arndb.de>,
	<gregkh@linuxfoundation.org>, <sivanich@sgi.com>
CC: <ira.weiny@intel.com>, <jglisse@redhat.com>,
	<william.kucharski@oracle.com>, <hch@lst.de>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-kernel-mentees@lists.linuxfoundation.org>
References: <1565290555-14126-1-git-send-email-linux.bhar@gmail.com>
 <1565290555-14126-2-git-send-email-linux.bhar@gmail.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <b659042a-f2c3-df3c-4182-bb7dd5156bc1@nvidia.com>
Date: Thu, 8 Aug 2019 16:21:44 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <1565290555-14126-2-git-send-email-linux.bhar@gmail.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565306507; bh=+5ClyXF4/+matB7j6ropEiCrm63pptXnzihc56YYTPY=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=l5IhY/V8wKpl1V8ijQzYcYptStoxXGnVHOhdeyz+62DluKzAguhVGZiCGRezc95/U
	 U8C6lT2MUtBedJD6kwr7Jr7y0OfIyp3vjjn8DI1jErn0J4NJeZs9lx6UF3OsV+59PF
	 l9qKdPDJk9lnGXFf/ud/g8F09AgJn0qSM+zmSFnnYPTfYywdwSxcSAhkZRvLOWY1fO
	 GdRjyB+IPWpS5D+ip+y8DKkG89yqpP1f/za6Lv89SZGgGtFsR+oiXNE6uljc1cMMJ1
	 vMRXg4Fs1Odywn1ugGiScfNOrclLqL0LzNz6i4WqKlB6fPKlo6RISUsFSt4Ex1WFaP
	 DGa3Uuu+Ljl7w==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 11:55 AM, Bharath Vedartham wrote:
...
>  static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
>  		    int write, int atomic, unsigned long *gpa, int *pageshift)
>  {
>  	struct mm_struct *mm = gts->ts_mm;
>  	struct vm_area_struct *vma;
>  	unsigned long paddr;
> -	int ret, ps;
> +	int ret;
> +	struct page *page;
>  
>  	vma = find_vma(mm, vaddr);
>  	if (!vma)
> @@ -263,21 +187,33 @@ static int gru_vtop(struct gru_thread_state *gts, unsigned long vaddr,
>  
>  	/*
>  	 * Atomic lookup is faster & usually works even if called in non-atomic
> -	 * context.
> +	 * context. get_user_pages_fast does atomic lookup before falling back to
> +	 * slow gup.
>  	 */
>  	rmb();	/* Must/check ms_range_active before loading PTEs */
> -	ret = atomic_pte_lookup(vma, vaddr, write, &paddr, &ps);
> -	if (ret) {
> -		if (atomic)
> +	if (atomic) {
> +		ret = __get_user_pages_fast(vaddr, 1, write, &page);
> +		if (!ret)
>  			goto upm;
> -		if (non_atomic_pte_lookup(vma, vaddr, write, &paddr, &ps))
> +	} else {
> +		ret = get_user_pages_fast(vaddr, 1, write ? FOLL_WRITE : 0, &page);
> +		if (!ret)
>  			goto inval;
>  	}
> +
> +	paddr = page_to_phys(page);
> +	put_user_page(page);
> +
> +	if (unlikely(is_vm_hugetlb_page(vma)))
> +		*pageshift = HPAGE_SHIFT;
> +	else
> +		*pageshift = PAGE_SHIFT;
> +
>  	if (is_gru_paddr(paddr))
>  		goto inval;
> -	paddr = paddr & ~((1UL << ps) - 1);
> +	paddr = paddr & ~((1UL << *pageshift) - 1);
>  	*gpa = uv_soc_phys_ram_to_gpa(paddr);
> -	*pageshift = ps;

Why are you no longer setting *pageshift? There are a couple of callers
that both use this variable.


thanks,
-- 
John Hubbard
NVIDIA

