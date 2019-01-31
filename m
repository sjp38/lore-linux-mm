Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D3C9C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 05:07:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57A24218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 05:07:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57A24218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF4818E0002; Thu, 31 Jan 2019 00:07:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA6148E0001; Thu, 31 Jan 2019 00:07:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6B548E0002; Thu, 31 Jan 2019 00:07:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 994468E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:07:24 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id u197so2064141qka.8
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 21:07:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=+Rx0lCwvgYA0q29RRKXZqS/8ldEG2Ksq2KlKUkLtTf8=;
        b=TSYU61AJYYE1oES7+3bcstpPn21zqJkbPzEJYYokDtFLae8cwDkUCjqzbEPRJMzY5V
         O3wQgmUnljimav2yqKxY5xSwzYmY/ZqqOAHA37qisD5jdrvlxTq/bN5iJBeSlWmfvi9b
         FX19XuGQSUloKlSuKlABGZ5EqLIQlbfi/RwrEz7IEX7mJiXptvWB+9LuFXQRPL/D0UDd
         IWPCzYnFqf9XW4HWYZkQARZNMvFBtYttSvXBoHiIOmVCEeB4LGvHQBdAAhRt2tg8G4EG
         dCMSmTd7P4HpdQYId8oGj80LgccA3Osvk+FlqB22z1pe0CLW1BSkFo80iCCDlEC6DcnK
         +/gg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AJcUukeEYF3DlpuxTjs4tD22OhOQRo3347zl0q1GehSjvoigWROD8UMb
	R4HryQVvvFLVqELXFU73RxTqjJSqRvEGjOZg9f8zFmXu0hePjdcQkYx1tYWYa7Z0S88TcNbJKa/
	OY+mKc8mZZYb3R87M080BQhOX/6ia3oGz4x2mE4fAayuQJFv1sRngt4/6/AgUT70d5w==
X-Received: by 2002:a37:a7c3:: with SMTP id q186mr31270858qke.244.1548911244362;
        Wed, 30 Jan 2019 21:07:24 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6a/cgg2TubkDELpQIAkGov84bxE3XP/z0NoWS6l4aENf/IJVQdvaMHwNySrZj91iXlCHaQ
X-Received: by 2002:a37:a7c3:: with SMTP id q186mr31270832qke.244.1548911243656;
        Wed, 30 Jan 2019 21:07:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548911243; cv=none;
        d=google.com; s=arc-20160816;
        b=0Ee41j4jpLnJKAPQ0XfclIeoR448AqZGQGRhOLAirvbvBM8DSHeOK5HP6vSfmYjJqU
         hp9lNytSZrv4fmsU1PpJ0YFUgA0SPN88MMER/zZnD1DIETKHY1uQlnIjjmvFU4oIHhX0
         Pg8VSWWhnnxCIhi1T4U5bg0Hbm9tPJ/Iacz4ldxwlMGRd06Yo4Gf9tPAyWkyqtCXa6Lx
         1TWR3tr22OjUv5KYZk1VhPPG/5mCQHhKMpQdaTe+cdnjTix/cAPBSPc348XW2r8V5ye9
         u/AszTeggcht1mSXAefEHsGBd3FTZkjgZZ3Da5oaSrgi2mCXyj2zS/xcWVfX7N1MSw9R
         Opkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=+Rx0lCwvgYA0q29RRKXZqS/8ldEG2Ksq2KlKUkLtTf8=;
        b=Y8rCEc1nFr6rumM9+5oGuq+k7xXgsVNwXM2tY5BWhpC5RaSqZhuHTZQgcHSvE/P8W4
         WNaYfW9w9GWnKHLlFM6tl75OOESQDXaxZ8lNnvQFliqA8Os2420UjrJoqvtNbEg+ZnT1
         1SsU3HUspPpyOdf00imNK6KckOJ6pvC13GEE9VbW2v1tzBGsuK4RrXLVYUsEXM8jXU1S
         vvvpApv7A/mYNzR9CE3oEKOmxPf7ZYyY8ZdjkKJ5G95Vxxbxc1Zhq788YA2iVfuYoKE8
         qPNrvXkuBkN/WC7YbYrSjtorxFFfwRlLxO1zvFsBUl8gSRTu5qUAXWAI3pJuU7O8PZnZ
         J2SA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g13si2858692qkg.240.2019.01.30.21.07.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 21:07:23 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x0V4xJiV029185
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:07:23 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qbrqrmewa-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:07:23 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 31 Jan 2019 05:07:21 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 31 Jan 2019 05:07:17 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x0V57GjZ8651114
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 31 Jan 2019 05:07:16 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B9D9A11C052;
	Thu, 31 Jan 2019 05:07:16 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AD27C11C04A;
	Thu, 31 Jan 2019 05:07:14 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.38.122])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 31 Jan 2019 05:07:14 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Michael Ellerman <mpe@ellerman.id.au>, npiggin@gmail.com,
        benh@kernel.crashing.org, paulus@samba.org, akpm@linux-foundation.org,
        x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org
Subject: Re: [PATCH V5 3/5] arch/powerpc/mm: Nest MMU workaround for mprotect RW upgrade.
In-Reply-To: <87fttaqux5.fsf@concordia.ellerman.id.au>
References: <20190116085035.29729-1-aneesh.kumar@linux.ibm.com> <20190116085035.29729-4-aneesh.kumar@linux.ibm.com> <87fttaqux5.fsf@concordia.ellerman.id.au>
Date: Thu, 31 Jan 2019 10:37:13 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19013105-4275-0000-0000-0000030821E8
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19013105-4276-0000-0000-0000381629CB
Message-Id: <87k1ilo1oe.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-01-31_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=944 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1901310039
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michael Ellerman <mpe@ellerman.id.au> writes:

> "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
>> NestMMU requires us to mark the pte invalid and flush the tlb when we do a
>> RW upgrade of pte. We fixed a variant of this in the fault path in commit
>> Fixes: bd5050e38aec ("powerpc/mm/radix: Change pte relax sequence to handle nest MMU hang")
>
> You don't want the "Fixes:" there.
>
>>
>> Do the same for mprotect upgrades.
>>
>> Hugetlb is handled in the next patch.
>>
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> ---
>>  arch/powerpc/include/asm/book3s/64/pgtable.h | 18 ++++++++++++++
>>  arch/powerpc/include/asm/book3s/64/radix.h   |  4 ++++
>>  arch/powerpc/mm/pgtable-book3s64.c           | 25 ++++++++++++++++++++
>>  arch/powerpc/mm/pgtable-radix.c              | 18 ++++++++++++++
>>  4 files changed, 65 insertions(+)
>>
>> diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> index 2e6ada28da64..92eaea164700 100644
>> --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
>> +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> @@ -1314,6 +1314,24 @@ static inline int pud_pfn(pud_t pud)
>>  	BUILD_BUG();
>>  	return 0;
>>  }
>
> Can we get a blank line here?
>
>> +#define __HAVE_ARCH_PTEP_MODIFY_PROT_TRANSACTION
>> +pte_t ptep_modify_prot_start(struct vm_area_struct *, unsigned long, pte_t *);
>> +void ptep_modify_prot_commit(struct vm_area_struct *, unsigned long,
>> +			     pte_t *, pte_t, pte_t);
>
> So these are not inline ...
>
>> +/*
>> + * Returns true for a R -> RW upgrade of pte
>> + */
>> +static inline bool is_pte_rw_upgrade(unsigned long old_val, unsigned long new_val)
>> +{
>> +	if (!(old_val & _PAGE_READ))
>> +		return false;
>> +
>> +	if ((!(old_val & _PAGE_WRITE)) && (new_val & _PAGE_WRITE))
>> +		return true;
>> +
>> +	return false;
>> +}
>>  
>>  #endif /* __ASSEMBLY__ */
>>  #endif /* _ASM_POWERPC_BOOK3S_64_PGTABLE_H_ */
>> diff --git a/arch/powerpc/mm/pgtable-book3s64.c b/arch/powerpc/mm/pgtable-book3s64.c
>> index f3c31f5e1026..47c742f002ea 100644
>> --- a/arch/powerpc/mm/pgtable-book3s64.c
>> +++ b/arch/powerpc/mm/pgtable-book3s64.c
>> @@ -400,3 +400,28 @@ void arch_report_meminfo(struct seq_file *m)
>>  		   atomic_long_read(&direct_pages_count[MMU_PAGE_1G]) << 20);
>>  }
>>  #endif /* CONFIG_PROC_FS */
>> +
>> +pte_t ptep_modify_prot_start(struct vm_area_struct *vma, unsigned long addr,
>> +			     pte_t *ptep)
>> +{
>> +	unsigned long pte_val;
>> +
>> +	/*
>> +	 * Clear the _PAGE_PRESENT so that no hardware parallel update is
>> +	 * possible. Also keep the pte_present true so that we don't take
>> +	 * wrong fault.
>> +	 */
>> +	pte_val = pte_update(vma->vm_mm, addr, ptep, _PAGE_PRESENT, _PAGE_INVALID, 0);
>> +
>> +	return __pte(pte_val);
>> +
>> +}
>> +
>> +void ptep_modify_prot_commit(struct vm_area_struct *vma, unsigned long addr,
>> +			     pte_t *ptep, pte_t old_pte, pte_t pte)
>> +{
>
> Which means we're going to be doing a function call to get to here ...
>
>> +	if (radix_enabled())
>> +		return radix__ptep_modify_prot_commit(vma, addr,
>> +						      ptep, old_pte, pte);
>
> And then another function call to get to the radix version ...
>
>> +	set_pte_at(vma->vm_mm, addr, ptep, pte);
>> +}
>> diff --git a/arch/powerpc/mm/pgtable-radix.c b/arch/powerpc/mm/pgtable-radix.c
>> index 931156069a81..dced3cd241c2 100644
>> --- a/arch/powerpc/mm/pgtable-radix.c
>> +++ b/arch/powerpc/mm/pgtable-radix.c
>> @@ -1063,3 +1063,21 @@ void radix__ptep_set_access_flags(struct vm_area_struct *vma, pte_t *ptep,
>>  	}
>>  	/* See ptesync comment in radix__set_pte_at */
>>  }
>> +
>> +void radix__ptep_modify_prot_commit(struct vm_area_struct *vma,
>> +				    unsigned long addr, pte_t *ptep,
>> +				    pte_t old_pte, pte_t pte)
>> +{
>> +	struct mm_struct *mm = vma->vm_mm;
>> +
>> +	/*
>> +	 * To avoid NMMU hang while relaxing access we need to flush the tlb before
>> +	 * we set the new value. We need to do this only for radix, because hash
>> +	 * translation does flush when updating the linux pte.
>> +	 */
>> +	if (is_pte_rw_upgrade(pte_val(old_pte), pte_val(pte)) &&
>> +	    (atomic_read(&mm->context.copros) > 0))
>> +		radix__flush_tlb_page(vma, addr);
>
> To finally get here, where we'll realise that 99.99% of processes don't
> use copros and so we have nothing to do except set the PTE.
>
>> +
>> +	set_pte_at(mm, addr, ptep, pte);
>> +}
>
> So can we just make it all inline in the header? Or do we think it's not
> a hot enough path to worry about it?
>

I did try that earlier, But IIRC that didn't work due to header
inclusion issue. I can try that again in an addon patch. That would
require moving things around so that we find different struct
definitions correctly.

-aneesh

