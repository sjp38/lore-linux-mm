Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDB3EC10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 03:45:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CD872085A
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 03:45:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CD872085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E95048E0003; Wed, 13 Mar 2019 23:45:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E45DC8E0001; Wed, 13 Mar 2019 23:45:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D33E98E0003; Wed, 13 Mar 2019 23:45:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 92E4B8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 23:45:17 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u19so4701981pfn.1
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 20:45:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=T6/JUSi77vGmH/hzPfQoFRmvfp6hqh9ce5Sl8KkBRWE=;
        b=U5HNY7vwNSXZg4Ek1xYHUM12D94+v7lzb6W+tYeXgCF8p279v/7tc3gXcujEgwrgeI
         9PvDk516bz6p08fGqzQa5/P9sG6R8B6y7HPkqeTJmTYDB4yEj0tpa5fkpSNBwijJGOR9
         hQkekTCNaburPeiwvNMHbtslqNKyacCvuwbwy0FiN290spLpQynNN2btTOL778pG507y
         k1k6p+NcgZoCrx0MWu/z6QNXhLgjPpZGd647JSwG8qNNoAezJH5POCCatKywV2sUS/Jh
         nd1wdvcYXzMmjr+wUZpLiLK7DyZ3vIE7Ta8wCa1Zg/Tr18XnHUcNe6RI1FYWMJI8pDTB
         YadQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUstbmiqH8K6kaCyq0uB0BHU3fQOam/hwsjUTvPKtull/AcR5Hr
	/UQc05+F4ZErGfSyGJSTooTfg5S+kxN1qnfEp/s0X++y7TM96SYl97i1qjBsq/BqTjwv+jbu/Jv
	iBrLoFIpAGEHhtcaA3L3h8GGauT4ooFBh4m72gEpNLENcCoK4VOfg7reC7ux+HbO+lw==
X-Received: by 2002:a17:902:9341:: with SMTP id g1mr49674189plp.80.1552535117112;
        Wed, 13 Mar 2019 20:45:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxU+BM3iaU/DXO1bjjRAutTGNoACHegli/EG8L0tvKuOYpUUvKp776UPB6AyxSgNYe/EPL
X-Received: by 2002:a17:902:9341:: with SMTP id g1mr49674112plp.80.1552535115758;
        Wed, 13 Mar 2019 20:45:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552535115; cv=none;
        d=google.com; s=arc-20160816;
        b=nUdPUyOiv2LH4MDBVwUEd9z/oVjWfpuz8EpRBl9/GdJjETM5Oe+qgL8MDXKcShTPx1
         r6c+pUE5Ce5OeaEveemw2QDFe6WJphjCu63cFvBOXRh95WYXqpVbrwmCDWH+tiCZqy/K
         hXOVIlHOkcZE82cupG4g2i/4Qscm2sfx/I0sxQguY7hKq9Z9o5kXopui43W63Hy7jYfQ
         dhN/ZMXzM5dwilYzQKNIE5xOsW6uxBa8CMNK2xjDUplwJ8OQOvChIIizEDWR8NAGcUJn
         BUj3+WmVUXvYGFZdBDWSDqKAAW3JUDJyyuiZ+nrcSzzHdlryXNXV/CK4CRyMnBBmGPn9
         liKQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=T6/JUSi77vGmH/hzPfQoFRmvfp6hqh9ce5Sl8KkBRWE=;
        b=AnIra/DTTyg97WPsVVgithssNEkh1H8xm6iRS3amkiuNY7pbxAwKrTS8hNvIsreA1F
         XWE2krYOjJUaSaE6TDJdXyCWCOoRncPKG6xlP+g1JTn1yclMoMIQe8BXyppaMYFboKfz
         r//P55jkdokQ8ZaMANZopAxiOXOuHk+pCo2AkXh5oAgkIQpNqqEWZZ0u3BmHZo6jPLl0
         WSjbzNGlNlesueDqQls1VwpdF0b549oCm3+Q+MXGDdjN7p55EdQZ2evmGrzjVjT+nS9n
         eckKKuOVH3gzPkyx3XeTKQV6Ne/gVQetoDU6LIRGfZIEpd7EV7znW50Hzlhg85XCMFgK
         dtKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 1si12841430plj.313.2019.03.13.20.45.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 20:45:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2E3cmLt064996
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 23:45:15 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2r7c2jy0q8-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 23:45:14 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Thu, 14 Mar 2019 03:45:12 -0000
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 14 Mar 2019 03:45:08 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2E3j7Wo20906200
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Thu, 14 Mar 2019 03:45:07 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 7388F11C050;
	Thu, 14 Mar 2019 03:45:07 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9704311C04A;
	Thu, 14 Mar 2019 03:45:04 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.45.189])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 14 Mar 2019 03:45:04 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux MM <linux-mm@kvack.org>, Ross Zwisler <zwisler@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
In-Reply-To: <CAPcyv4ir4irASBQrZD_a6kMkEUt=XPUCuKajF75O7wDCgeG=7Q@mail.gmail.com>
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com> <20190228083522.8189-2-aneesh.kumar@linux.ibm.com> <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com> <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com> <87k1hc8iqa.fsf@linux.ibm.com> <CAPcyv4ir4irASBQrZD_a6kMkEUt=XPUCuKajF75O7wDCgeG=7Q@mail.gmail.com>
Date: Thu, 14 Mar 2019 09:15:02 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19031403-0008-0000-0000-000002CD0D89
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031403-0009-0000-0000-000022390DF9
Message-Id: <871s3aqfup.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-14_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903140023
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

> On Wed, Mar 6, 2019 at 1:18 AM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
>>
>> Dan Williams <dan.j.williams@intel.com> writes:
>>
>> > On Thu, Feb 28, 2019 at 1:40 AM Oliver <oohall@gmail.com> wrote:
>> >>
>> >> On Thu, Feb 28, 2019 at 7:35 PM Aneesh Kumar K.V
>> >> <aneesh.kumar@linux.ibm.com> wrote:
>> >> >
>> >> > Add a flag to indicate the ability to do huge page dax mapping. On architecture
>> >> > like ppc64, the hypervisor can disable huge page support in the guest. In
>> >> > such a case, we should not enable huge page dax mapping. This patch adds
>> >> > a flag which the architecture code will update to indicate huge page
>> >> > dax mapping support.
>> >>
>> >> *groan*
>> >>
>> >> > Architectures mostly do transparent_hugepage_flag = 0; if they can't
>> >> > do hugepages. That also takes care of disabling dax hugepage mapping
>> >> > with this change.
>> >> >
>> >> > Without this patch we get the below error with kvm on ppc64.
>> >> >
>> >> > [  118.849975] lpar: Failed hash pte insert with error -4
>> >> >
>> >> > NOTE: The patch also use
>> >> >
>> >> > echo never > /sys/kernel/mm/transparent_hugepage/enabled
>> >> > to disable dax huge page mapping.
>> >> >
>> >> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> >> > ---
>> >> > TODO:
>> >> > * Add Fixes: tag
>> >> >
>> >> >  include/linux/huge_mm.h | 4 +++-
>> >> >  mm/huge_memory.c        | 4 ++++
>> >> >  2 files changed, 7 insertions(+), 1 deletion(-)
>> >> >
>> >> > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> >> > index 381e872bfde0..01ad5258545e 100644
>> >> > --- a/include/linux/huge_mm.h
>> >> > +++ b/include/linux/huge_mm.h
>> >> > @@ -53,6 +53,7 @@ vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>> >> >                         pud_t *pud, pfn_t pfn, bool write);
>> >> >  enum transparent_hugepage_flag {
>> >> >         TRANSPARENT_HUGEPAGE_FLAG,
>> >> > +       TRANSPARENT_HUGEPAGE_DAX_FLAG,
>> >> >         TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
>> >> >         TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
>> >> >         TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
>> >> > @@ -111,7 +112,8 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
>> >> >         if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
>> >> >                 return true;
>> >> >
>> >> > -       if (vma_is_dax(vma))
>> >> > +       if (vma_is_dax(vma) &&
>> >> > +           (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_DAX_FLAG)))
>> >> >                 return true;
>> >>
>> >> Forcing PTE sized faults should be fine for fsdax, but it'll break
>> >> devdax. The devdax driver requires the fault size be >= the namespace
>> >> alignment since devdax tries to guarantee hugepage mappings will be
>> >> used and PMD alignment is the default. We can probably have devdax
>> >> fall back to the largest size the hypervisor has made available, but
>> >> it does run contrary to the design. Ah well, I suppose it's better off
>> >> being degraded rather than unusable.
>> >
>> > Given this is an explicit setting I think device-dax should explicitly
>> > fail to enable in the presence of this flag to preserve the
>> > application visible behavior.
>> >
>> > I.e. if device-dax was enabled after this setting was made then I
>> > think future faults should fail as well.
>>
>> Not sure I understood that. Now we are disabling the ability to map
>> pages as huge pages. I am now considering that this should not be
>> user configurable. Ie, this is something that platform can use to avoid
>> dax forcing huge page mapping, but if the architecture can enable huge
>> dax mapping, we should always default to using that.
>
> No, that's an application visible behavior regression. The side effect
> of this setting is that all huge-page configured device-dax instances
> must be disabled.

So if the device was created with a nd_pfn->align value of PMD_SIZE, that is
an indication that we would map the pages in PMD_SIZE?

Ok with that understanding, If the align value is not a supported
mapping size, we fail initializing the device. 


>
>> Now w.r.t to failures, can device-dax do an opportunistic huge page
>> usage?
>
> device-dax explicitly disclaims the ability to do opportunistic mappings.
>
>> I haven't looked at the device-dax details fully yet. Do we make the
>> assumption of the mapping page size as a format w.r.t device-dax? Is that
>> derived from nd_pfn->align value?
>
> Correct.
>
>>
>> Here is what I am working on:
>> 1) If the platform doesn't support huge page and if the device superblock
>> indicated that it was created with huge page support, we fail the device
>> init.
>
> Ok.
>
>> 2) Now if we are creating a new namespace without huge page support in
>> the platform, then we force the align details to PAGE_SIZE. In such a
>> configuration when handling dax fault even with THP enabled during
>> the build, we should not try to use hugepage. This I think we can
>> achieve by using TRANSPARENT_HUGEPAEG_DAX_FLAG.
>
> How is this dynamic property communicated to the guest?

via device tree on powerpc. We have a device tree node indicating
supported page sizes.

>
>>
>> Also even if the user decided to not use THP, by
>> echo "never" > transparent_hugepage/enabled , we should continue to map
>> dax fault using huge page on platforms that can support huge pages.
>>
>> This still doesn't cover the details of a device-dax created with
>> PAGE_SIZE align later booted with a kernel that can do hugepage dax.How
>> should we handle that? That makes me think, this should be a VMA flag
>> which got derived from device config? May be use VM_HUGEPAGE to indicate
>> if device should use a hugepage mapping or not?
>
> device-dax configured with PAGE_SIZE always gets PAGE_SIZE mappings.

Now what will be page size used for mapping vmemmap? Architectures
possibly will use PMD_SIZE mapping if supported for vmemmap. Now a
device-dax with struct page in the device will have pfn reserve area aligned
to PAGE_SIZE with the above example? We can't map that using
PMD_SIZE page size?

-aneesh

