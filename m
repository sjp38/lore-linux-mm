Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 663E7C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 18:27:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E7C12173C
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 18:27:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmwopensource.org header.i=@vmwopensource.org header.b="vl6XdSWY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E7C12173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=vmwopensource.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13ECD6B0006; Tue, 11 Jun 2019 14:27:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F06F6B0008; Tue, 11 Jun 2019 14:27:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED2A86B000A; Tue, 11 Jun 2019 14:27:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8498C6B0006
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 14:27:15 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id m8so2149222lfl.23
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 11:27:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=1aarXh6g8RLhn1IEvcQGEpxO7kP680xnN7pdWsO0Y2s=;
        b=PkqXiHv1UfsSRekfRo0Qk8Vp+je0ScqmuDYtl81cmgHlGCDG9pvMjwnHOZD0GMODAG
         +V+BvJBGCg5RujRWp1ZD/1vY1uXYzUxbBT32AClFxJ/F33xBlxixTOqrOSS2RdH+naHI
         /ep43XkExrpWuNWnVp4ZWyO3qqr4soM8QhuSKbS/Sv4Fx23rvuRre9lbriJnlGVB+Sp4
         6KmpkfioAaX2gUB32aTJLBB9tSMvzaGwK/z60ENQ/BhxKOg/iyOso7PUoUoaoheL/B4l
         7TJHH9p4aijaS2y8NnkxHpJ83WOKzl6Vu0qoyyFAgw7IcbbbXFod6gwxPSARHJaWpSh2
         k7xg==
X-Gm-Message-State: APjAAAUYIadpOSzwlyKmIGfqrzQsbdlGJ1G0F7BJeLDeXvnITRbgnLlD
	rSIlseLCnLbuEGU1qsxgFrG36tA6Qepi46/+DV/HRTAqexFr2fXFlGAqeTOzafTH8NSb0TCJ7bO
	ZIQjkfIqG5YAXDze3HKwrKp4s2/DTiVj0Ztzmo7xHomqhJtefGZGkSSyUmoC85piPxg==
X-Received: by 2002:a2e:8195:: with SMTP id e21mr19446357ljg.62.1560277634645;
        Tue, 11 Jun 2019 11:27:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVT+1MDQZEeM/5N5SxOperqHoPg4WFVnxBSZSyRJ42EJ9s+/w4mE4ZJLFr64NYQBlHEZDo
X-Received: by 2002:a2e:8195:: with SMTP id e21mr19446319ljg.62.1560277633553;
        Tue, 11 Jun 2019 11:27:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560277633; cv=none;
        d=google.com; s=arc-20160816;
        b=HwIhGP/uxbWosnxemqCO+DID4rLlKuY5KLZQdVFilMCcAvLRZWBriE8OakqI4ts15D
         HT3r4SbkAOo8EcQKg7u2VnnTO6zWKID0cfg7FwAeZSVC2mh1WwYb3Vk8QFMht2nw6V/y
         4ycOLK1yUHuzCjHdNXNOEX/tmeBIyNS7q14+2l/ljINPO/6C1jm+7vDOJMR+uc8p9ln1
         UdQG1YfwOXL3qMqcKQH5H7ITSSP6XeXS53ekMGPJUoBaUlhQBnyqMLDAPz4bk6hQRX4y
         zg64jb20hUFI9HXcVhORoGnVtHk0/WxbWEBbo+gREO/HKy1QC908pByVJ5YrDuQ+Sxbq
         /Ahg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=1aarXh6g8RLhn1IEvcQGEpxO7kP680xnN7pdWsO0Y2s=;
        b=MeW8DnLGJCI14yiTweBoMoUU9Fkfx7ViMbic9i2yOhoYDVOpkFDy/hRTzwHQ51AfRg
         5JxKlrP9d19MaDIbkwTFS7lkV0DTi7264XABQciR308sNvRtOUI3pC0MRRVTU+Q/pYR+
         lx4AP5jiORT/F57NazUuPyTDHxknpv/ZkaIAiVRVv0s89bPl+wUkyxvCOi4EYXijhrKQ
         IOFyojteBUjbTYa08dTEB8anPDsjtgQJ5+Sl9e3b47E/BhjN83yaXwuiDpWBMWfr/rKj
         H0F2aKWDmpXYZPjlBJXJwKOEMLyIqpcZvNF2UPObyLwYziu2BULhYmOl4IQVyIsob+O+
         B0zw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=vl6XdSWY;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.70 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from ste-pvt-msa1.bahnhof.se (ste-pvt-msa1.bahnhof.se. [213.80.101.70])
        by mx.google.com with ESMTPS id 69si12084719ljc.178.2019.06.11.11.27.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 11:27:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.70 as permitted sender) client-ip=213.80.101.70;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmwopensource.org header.s=mail header.b=vl6XdSWY;
       spf=pass (google.com: domain of thellstrom@vmwopensource.org designates 213.80.101.70 as permitted sender) smtp.mailfrom=thellstrom@vmwopensource.org
Received: from localhost (localhost [127.0.0.1])
	by ste-pvt-msa1.bahnhof.se (Postfix) with ESMTP id B3A2940D6F;
	Tue, 11 Jun 2019 20:27:07 +0200 (CEST)
Authentication-Results: ste-pvt-msa1.bahnhof.se;
	dkim=pass (1024-bit key; unprotected) header.d=vmwopensource.org header.i=@vmwopensource.org header.b=vl6XdSWY;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at bahnhof.se
Received: from ste-pvt-msa1.bahnhof.se ([127.0.0.1])
	by localhost (ste-pvt-msa1.bahnhof.se [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id smfTGIN7o__R; Tue, 11 Jun 2019 20:26:58 +0200 (CEST)
Received: from mail1.shipmail.org (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	(Authenticated sender: mb878879)
	by ste-pvt-msa1.bahnhof.se (Postfix) with ESMTPA id B2F543F86C;
	Tue, 11 Jun 2019 20:26:57 +0200 (CEST)
Received: from localhost.localdomain (h-205-35.A357.priv.bahnhof.se [155.4.205.35])
	by mail1.shipmail.org (Postfix) with ESMTPSA id 198C3361A96;
	Tue, 11 Jun 2019 20:26:57 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=vmwopensource.org;
	s=mail; t=1560277617;
	bh=l3W/AqRf84wNp6P4sWXjTRud8TI0AhrSO/bC0PKM5fg=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=vl6XdSWYGKdFQN7iy2I6478NTemupw3IjgYmmFrjGfarW9AUCkwCHczkOJHx4UA/2
	 L1Dz4hmwgBEYT3Z08isg+RMbIw9Oui5bwMskWFMMLeuhAIytZWixxGvFKerujCko3C
	 0o5dD+7XGLhFoCpoAA3Z0Lw4LMccKlNHHMGaNQt0=
Subject: Re: [PATCH v4 3/9] mm: Add write-protect and clean utilities for
 address space ranges
To: Nadav Amit <nadav.amit@gmail.com>
Cc: dri-devel@lists.freedesktop.org, linux-graphics-maintainer@vmware.com,
 "VMware, Inc." <pv-drivers@vmware.com>, LKML <linux-kernel@vger.kernel.org>,
 Thomas Hellstrom <thellstrom@vmware.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Matthew Wilcox <willy@infradead.org>, Will Deacon <will.deacon@arm.com>,
 Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@surriel.com>,
 Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>,
 Huang Ying <ying.huang@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, linux-mm@kvack.org,
 Ralph Campbell <rcampbell@nvidia.com>
References: <20190611122454.3075-1-thellstrom@vmwopensource.org>
 <20190611122454.3075-4-thellstrom@vmwopensource.org>
 <1CDAE797-4686-4041-938F-DE0456FFF451@gmail.com>
From: =?UTF-8?Q?Thomas_Hellstr=c3=b6m_=28VMware=29?=
 <thellstrom@vmwopensource.org>
Organization: VMware Inc.
Message-ID: <ac0b0ef5-8f76-5e55-2be2-f1860878841a@vmwopensource.org>
Date: Tue, 11 Jun 2019 20:26:56 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1CDAE797-4686-4041-938F-DE0456FFF451@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Nadav,

On 6/11/19 7:21 PM, Nadav Amit wrote:
>> On Jun 11, 2019, at 5:24 AM, Thomas Hellström (VMware) <thellstrom@vmwopensource.org> wrote:
>>
>> From: Thomas Hellstrom <thellstrom@vmware.com>
>>
> [ snip ]
>
>> +/**
>> + * apply_pt_wrprotect - Leaf pte callback to write-protect a pte
>> + * @pte: Pointer to the pte
>> + * @token: Page table token, see apply_to_pfn_range()
>> + * @addr: The virtual page address
>> + * @closure: Pointer to a struct pfn_range_apply embedded in a
>> + * struct apply_as
>> + *
>> + * The function write-protects a pte and records the range in
>> + * virtual address space of touched ptes for efficient range TLB flushes.
>> + *
>> + * Return: Always zero.
>> + */
>> +static int apply_pt_wrprotect(pte_t *pte, pgtable_t token,
>> +			      unsigned long addr,
>> +			      struct pfn_range_apply *closure)
>> +{
>> +	struct apply_as *aas = container_of(closure, typeof(*aas), base);
>> +	pte_t ptent = *pte;
>> +
>> +	if (pte_write(ptent)) {
>> +		pte_t old_pte = ptep_modify_prot_start(aas->vma, addr, pte);
>> +
>> +		ptent = pte_wrprotect(old_pte);
>> +		ptep_modify_prot_commit(aas->vma, addr, pte, old_pte, ptent);
>> +		aas->total++;
>> +		aas->start = min(aas->start, addr);
>> +		aas->end = max(aas->end, addr + PAGE_SIZE);
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>> +/**
>> + * struct apply_as_clean - Closure structure for apply_as_clean
>> + * @base: struct apply_as we derive from
>> + * @bitmap_pgoff: Address_space Page offset of the first bit in @bitmap
>> + * @bitmap: Bitmap with one bit for each page offset in the address_space range
>> + * covered.
>> + * @start: Address_space page offset of first modified pte relative
>> + * to @bitmap_pgoff
>> + * @end: Address_space page offset of last modified pte relative
>> + * to @bitmap_pgoff
>> + */
>> +struct apply_as_clean {
>> +	struct apply_as base;
>> +	pgoff_t bitmap_pgoff;
>> +	unsigned long *bitmap;
>> +	pgoff_t start;
>> +	pgoff_t end;
>> +};
>> +
>> +/**
>> + * apply_pt_clean - Leaf pte callback to clean a pte
>> + * @pte: Pointer to the pte
>> + * @token: Page table token, see apply_to_pfn_range()
>> + * @addr: The virtual page address
>> + * @closure: Pointer to a struct pfn_range_apply embedded in a
>> + * struct apply_as_clean
>> + *
>> + * The function cleans a pte and records the range in
>> + * virtual address space of touched ptes for efficient TLB flushes.
>> + * It also records dirty ptes in a bitmap representing page offsets
>> + * in the address_space, as well as the first and last of the bits
>> + * touched.
>> + *
>> + * Return: Always zero.
>> + */
>> +static int apply_pt_clean(pte_t *pte, pgtable_t token,
>> +			  unsigned long addr,
>> +			  struct pfn_range_apply *closure)
>> +{
>> +	struct apply_as *aas = container_of(closure, typeof(*aas), base);
>> +	struct apply_as_clean *clean = container_of(aas, typeof(*clean), base);
>> +	pte_t ptent = *pte;
>> +
>> +	if (pte_dirty(ptent)) {
>> +		pgoff_t pgoff = ((addr - aas->vma->vm_start) >> PAGE_SHIFT) +
>> +			aas->vma->vm_pgoff - clean->bitmap_pgoff;
>> +		pte_t old_pte = ptep_modify_prot_start(aas->vma, addr, pte);
>> +
>> +		ptent = pte_mkclean(old_pte);
>> +		ptep_modify_prot_commit(aas->vma, addr, pte, old_pte, ptent);
>> +
>> +		aas->total++;
>> +		aas->start = min(aas->start, addr);
>> +		aas->end = max(aas->end, addr + PAGE_SIZE);
>> +
>> +		__set_bit(pgoff, clean->bitmap);
>> +		clean->start = min(clean->start, pgoff);
>> +		clean->end = max(clean->end, pgoff + 1);
>> +	}
>> +
>> +	return 0;
> Usually, when a PTE is write-protected, or when a dirty-bit is cleared, the
> TLB flush must be done while the page-table lock for that specific table is
> taken (i.e., within apply_pt_clean() and apply_pt_wrprotect() in this case).
>
> Otherwise, in the case of apply_pt_clean() for example, another core might
> shortly after (before the TLB flush) write to the same page whose PTE was
> changed. The dirty-bit in such case might not be set, and the change get
> lost.

Hmm. Let's assume that was the case, we have two possible situations:

A: pt_clean

1. That core's TLB entry is invalid. It will set the PTE dirty bit and 
continue. The dirty bit will probably remain set after the TLB flush.
2. That core's TLB entry is valid. It will just continue. The dirty bit 
will remain clear after the TLB flush.

But I fail to see how having the TLB flush within the page table lock 
would help in this case. Since the writing core will never attempt to 
take it? In any case, if such a race occurs, the corresponding bit in 
the bitmap would have been set and we've recorded that the page is dirty.

B: wrprotect situation, the situation is a bit different:

1. That core's TLB entry is invalid. It will read the PTE, cause a fault 
and block in mkwrite() on an external address space lock which is held 
over this operation. (Is it this situation that is your main concern?)
2. That core's TLB entry is valid. It will just continue regardless of 
any locks.

For both mkwrite() and dirty() if we act on the recorded pages *after* 
the TLB flush, we're OK. The difference is that just after the TLB flush 
there should be no write-enabled PTEs in the write-protect case, but 
there may be dirty PTEs in the pt_clean case. Something that is 
mentioned in the docs already.

>
> Does this function regards a certain use-case in which deferring the TLB
> flushes is fine? If so, assertions and documentation of the related
> assumption would be useful.

If I understand your comment correctly, the page table lock is sometimes 
used as the lock in B1, blocking a possible software fault until the TLB 
flush has happened.  Here we assume an external address space lock taken 
both around the wrprotect operation and in mkwrite(). Would it be OK if 
I add comments about the necessity of an external lock to the doc? Ok 
with a follow-up patch?

Thanks,
Thomas


