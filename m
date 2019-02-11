Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1BDFC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:14:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B4E8214DA
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:14:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="F2wnBIUI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B4E8214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 022738E0166; Mon, 11 Feb 2019 16:14:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F10E58E0165; Mon, 11 Feb 2019 16:13:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD8918E0166; Mon, 11 Feb 2019 16:13:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id A68938E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:13:59 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id k69so226265ywa.12
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:13:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=jCNJwm22GIJyJ9ioZIwP6IZZLdb+CRCGAEh9x8vIK40=;
        b=F/xJS533R8wW373ldkHAZTNNzfj5z9b3L/GGPl56BjDgwEjgrJ4Rer8BfQB9z1TBSG
         dUOKrZJVi+fWcjeogJuF9qqd4Dx9HtoFijmuOjdhKw6jLbFYR6kXtVkBN4lboTiaP/2i
         VkLFleJziK01Txi5RV/SvnTQlb2dTeDI8ip2FFVWY7cwPGVOY1lOx5j9LpaxUm7RuiU3
         47gKONIYfqTCasvMlblEgIw27LkBIS3v4dq+EJwvL2iDs4zBTwlfSWqAQkdbENRO8Dht
         huWXhRkUfO9Bh9WKZP06y3zP3AQQRy9qrE7l+ylvf3GUFAP0imaizIAdmzJc6bfGvn0K
         zcTA==
X-Gm-Message-State: AHQUAuaONUi4t6zXR/HpfOeC9dPPzzf5XZ67GgrmPlhiPxGUIRUjgDLo
	hwos3z44ooNH12Pm77PcT65EFeLSmrLkZKyfbFZtsF0EoOJQ559yniO/BME0jQ/VZWg3m9+DEdm
	ODAAyPD4MvYynKsZvnBEh0oSTk70cxg8ZFMPKBkX2t03NaB8AtdXniTTP464nEWbWug==
X-Received: by 2002:a81:a355:: with SMTP id a82mr148889ywh.445.1549919639395;
        Mon, 11 Feb 2019 13:13:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYmyRLl0CBgpCi3zvtYEHgBWkyxCMnbikj7To2/Kj3+Ks1Bgxg6+QdACOPD5V5TJNltSxQ/
X-Received: by 2002:a81:a355:: with SMTP id a82mr148851ywh.445.1549919638733;
        Mon, 11 Feb 2019 13:13:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549919638; cv=none;
        d=google.com; s=arc-20160816;
        b=Uvt5Ts0YwGK7w4Ciat/nV5QPCAyiar9B7EcK7J62M7KX4+lWk1IlSQpKLQF5PqvtAv
         7G5BWZTfJDdvXFGs3jviAhtkUK94Wwv7I/6X1GTQETk1j7oE3Ada3SuKkxEpkQzZwNWo
         ygWvKUrCOTzz8x6uZx8+LLtHAu2i6Ku/YXFoX3g+H4lhXlNmi2UqmEywYcsABCl9XU4g
         3Q5JYO+TncJLVlVBDuIaKGUbzps8RNhvuwd5/AX/Tzq3uCy7nVQByV9ExIzYxWm+bq5i
         inzyUsG9nKaPQYWO9a4fMwUpszQ2AK8Iuc/Vs2s6YxcZ+MMGZ4SrzI96VFlrF1eF7Eaw
         a55w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=jCNJwm22GIJyJ9ioZIwP6IZZLdb+CRCGAEh9x8vIK40=;
        b=SHNN67RACrviItJ+Fd4i8nTXz2wy1y9RAE0oeayU5ueeq/QBF9LGad5xdyixhHPHFX
         TH+Gc03pcf1mtNkPG2g8zePVjblGT61j6RHMFwQ2wVS3uRDPusjSkMXuL0yMmq/xEoHT
         fv9ZKdr28kytDkaZlkvW8gML7nOtiHPg7nsW72lAktLfbr9QC/9bUATuDE62p1MDQGD8
         WtR2sbaOEfvYw27Ugy30sab39wUTiJQykfCqMqqBls0Oy5yh26+lohjSDdM1Gw18Htq5
         0OEtUNgscQiRPYj8fzWCCl1C1qsQf56IcebLfv8AQXiQMCDzLzw/r9ISCUAgmgF4S6vA
         +YAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=F2wnBIUI;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id z6si6497326ywa.245.2019.02.11.13.13.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 13:13:58 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=F2wnBIUI;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c61e5960000>; Mon, 11 Feb 2019 13:13:58 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Mon, 11 Feb 2019 13:13:57 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Mon, 11 Feb 2019 13:13:57 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Mon, 11 Feb
 2019 21:13:57 +0000
Subject: Re: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
To: Jason Gunthorpe <jgg@ziepe.ca>, <ira.weiny@intel.com>
CC: <linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, Daniel Borkmann <daniel@iogearbox.net>, Davidlohr Bueso
	<dave@stgolabs.net>, <netdev@vger.kernel.org>, Mike Marciniszyn
	<mike.marciniszyn@intel.com>, Dennis Dalessandro
	<dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Andrew
 Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov"
	<kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211201643.7599-3-ira.weiny@intel.com> <20190211203916.GA2771@ziepe.ca>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <bcc03ee1-4c42-48c3-bc67-942c0f04875e@nvidia.com>
Date: Mon, 11 Feb 2019 13:13:56 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190211203916.GA2771@ziepe.ca>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL108.nvidia.com (172.18.146.13) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1549919638; bh=jCNJwm22GIJyJ9ioZIwP6IZZLdb+CRCGAEh9x8vIK40=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=F2wnBIUIyRcBk9XPZBwpp+6XeprxUtoGbDdGoNtn6k9OQQtZ9hMy5XhGDUFmFyQvs
	 Cu4YHNkIG9qjaEMUQRhkvvSf6cPgpUW2gmtvWNL+JD0qKEsXO1dtgAKkGacgp3a61z
	 hDrnGMFtLb6t8+segCjn0hgTBqZawFIRjqtd2pbLIpINclPAYE7V/jLZ3XWY+1RIYS
	 Wb23jh/Eent8W8fBllFt3+5gBhmFuUN1816D0bLEeGbozqN0PoFUTf21suiDx53cUq
	 mbkf2aV9MvY/0qnZtPfLUUi7+mmxWEN7SRwLDUmyfCOq+aEEkWj1a6xvxBd0MgIHbx
	 odNPsrr5kqBmg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/11/19 12:39 PM, Jason Gunthorpe wrote:
> On Mon, Feb 11, 2019 at 12:16:42PM -0800, ira.weiny@intel.com wrote:
>> From: Ira Weiny <ira.weiny@intel.com>
[...]
>> +static inline int get_user_pages_fast_longterm(unsigned long start, int nr_pages,
>> +					       bool write, struct page **pages)
>> +{
>> +	return get_user_pages_fast(start, nr_pages, write, pages);
>> +}
>>  #endif /* CONFIG_FS_DAX */
>>  
>>  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
>> @@ -2615,6 +2622,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
>>  #define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
>>  #define FOLL_COW	0x4000	/* internal GUP flag */
>>  #define FOLL_ANON	0x8000	/* don't do file mappings */
>> +#define FOLL_LONGTERM	0x10000	/* mapping is intended for a long term pin */
> 
> If we are adding a new flag, maybe we should get rid of the 'longterm'
> entry points and just rely on the callers to pass the flag?
> 
> Jason
> 

+1, I agree that the overall get_user_pages*() API family will be cleaner
*without* get_user_pages_longterm*() calls. And this new flag makes that possible.
So I'd like to see the "longerm" call replaced with just passing this flag. Maybe
even as part of this patchset, but either way.

Taking a moment to reflect on where I think this might go eventually (the notes
below do not need to affect your patchset here, but this seems like a good place
to mention this):

It seems to me that the longterm vs. short-term is of questionable value.
It's actually better to just call get_user_pages(), and then if it really is
long-term enough to matter internally, we'll see the pages marked as gup-pinned.
If the gup pages are released before anyone (filesystem, that is) notices, then
it must have been short term.

Doing it that way is self-maintaining. Of course, this assumes that we end up with
a design that doesn't require being told, by the call sites, that a given gup
call is intended for "long term" use. So I could be wrong about this direction, but
let's please consider the possibility.

thanks,
-- 
John Hubbard
NVIDIA

