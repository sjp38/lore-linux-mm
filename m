Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5234C10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 09:17:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F43B20840
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 09:17:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F43B20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E01D28E0003; Wed,  6 Mar 2019 04:17:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB0D98E0002; Wed,  6 Mar 2019 04:17:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C77CC8E0003; Wed,  6 Mar 2019 04:17:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4278E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 04:17:47 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id 200so14549659ywe.11
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 01:17:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version
         :content-transfer-encoding:message-id;
        bh=MQutO4PNejxSC9ihD2PtDGTNLwK2NFqZzzeAShUj+lY=;
        b=ElQYNvE4Gd7Giz7MoXRgwcm4Ljrg0eLNtD1z2XfANLuybHvTYNddExBBoGZiavvyGK
         /0h8lzewJBoQQrjDI89afYxNpuCp8vwrlTSwmXz7hldt9Js0rBdFfBR4V/8L0ZwucTRA
         mJFbgiaOmA7S2stpjhcKGpcB1ldhMYmFueuf4kfeF212h0B4OSjolJ3taXIDug4XyIbG
         iQp1iIjMXn7aKXCWgb0QQP8D3d2G9sGDZzA5mp1RYzZZMMfxiKfc2UTaYTbsbAGWuVYe
         /bRcR8gN9ILcfV0/r4iiJis4R4p4FbHOh7dBtlVNKDC8FWL+v3alDOUynkCgHPIc8VZZ
         tYdw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUUmzuh8m9Up72JxjpxMelJGAquJccmeoR8H/aZ2m1mWoMA39Rk
	oTXXmoV1qaDLW0NPt6sDPrNVr4VQkL+vuvkzlSrVQ/eZHfkIXxmtMD/kYoNomniWeSrQdO2sx+8
	bq8c/+kOPV/Lp4w3T4bSg8HjdsCckDRVdF35cumD1E/b8T9Q+2SQSsOTnJhinERMnCw==
X-Received: by 2002:a5b:642:: with SMTP id o2mr5685831ybq.32.1551863867306;
        Wed, 06 Mar 2019 01:17:47 -0800 (PST)
X-Google-Smtp-Source: APXvYqxLNCzF3F4sn//3+S+MKERSvqzrIPuWXJ4/e1s1Pa9S+t3I3bCkyJnsxsNSOnFNavor0UxK
X-Received: by 2002:a5b:642:: with SMTP id o2mr5685787ybq.32.1551863866359;
        Wed, 06 Mar 2019 01:17:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551863866; cv=none;
        d=google.com; s=arc-20160816;
        b=uKnB7Lh25rII/8cizBK6EH4jmyK1Z0ITIQszPEeqERVYu+cIlN3+IxDZfnuQjZQqaf
         GnAyBb0GziCl2mdB6lvGAMRbZC8Cqt1hOhKo8798dZQExgUewJWiKNLjL3kpGsGFQxCg
         tPseTtxwiSTPsJ4vvNrQKHogQXDiBtdOyzpCXixEZEQSYgb9tHABqkZmrnUf+OoFVHTG
         naBZoKMO7HUZRIxp/hLUG8E7H/UVpR2Am18jM5k27sA555EormQUFxcTXBvKsYxjhy63
         VrOAI/l5cMg5JbCfE4SDFp7EPQ8F2Ck9np7rhhrOxB0SymXO/5sJv+1yVlxPAbwbty3J
         Uh9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:mime-version:date:references
         :in-reply-to:subject:cc:to:from;
        bh=MQutO4PNejxSC9ihD2PtDGTNLwK2NFqZzzeAShUj+lY=;
        b=RUXYt68VugpF1MY7q+BYYjkc2Y6HxEHx/LBIvS7EgGRoSo/JRfKvRHij3rsWG0OaTJ
         sBcSwOrgdMT5o2x/RKlddRrykdkp4NCLo/Zrrc1gCbkchXp2STwr2czfC6TMaSM9AoFR
         N1VkcHiFauTxoJTh/Y36JoL6RwNG/pOK8Txt68DvX62TUfCGwlqWbShpepX+3UtDIFIr
         ZAGAzQcTu/1Z0YRXfewubolqtZYY9rLYEnuDQvnzPo4PYFj4BNpWi/goxYoEZbTjaTIB
         WV/rk603u34vcWt2RwtckoUthxn0z0vfOvpl32APZlGC+OggEK3dZlgBJh1PRO9jGYeJ
         IFxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y185si527454ybc.281.2019.03.06.01.17.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 01:17:46 -0800 (PST)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2694942034625
	for <linux-mm@kvack.org>; Wed, 6 Mar 2019 04:17:45 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2r2a8emb2j-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 06 Mar 2019 04:17:45 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 6 Mar 2019 09:17:42 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 6 Mar 2019 09:17:39 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x269Hc9p24641788
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Wed, 6 Mar 2019 09:17:38 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B2DF911C052;
	Wed,  6 Mar 2019 09:17:38 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 10D9E11C050;
	Wed,  6 Mar 2019 09:17:36 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.199.59.8])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed,  6 Mar 2019 09:17:35 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>, Oliver <oohall@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
        Jan Kara <jack@suse.cz>, Michael Ellerman <mpe@ellerman.id.au>,
        Ross Zwisler <zwisler@kernel.org>, Linux MM <linux-mm@kvack.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        linux-nvdimm@lists.01.org
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
In-Reply-To: <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com> <20190228083522.8189-2-aneesh.kumar@linux.ibm.com> <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com> <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com>
Date: Wed, 06 Mar 2019 14:47:33 +0530
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-TM-AS-GCONF: 00
x-cbid: 19030609-0016-0000-0000-0000025E6DC4
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19030609-0017-0000-0000-000032B8F4B1
Message-Id: <87k1hc8iqa.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-06_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903060063
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

> On Thu, Feb 28, 2019 at 1:40 AM Oliver <oohall@gmail.com> wrote:
>>
>> On Thu, Feb 28, 2019 at 7:35 PM Aneesh Kumar K.V
>> <aneesh.kumar@linux.ibm.com> wrote:
>> >
>> > Add a flag to indicate the ability to do huge page dax mapping. On arc=
hitecture
>> > like ppc64, the hypervisor can disable huge page support in the guest.=
 In
>> > such a case, we should not enable huge page dax mapping. This patch ad=
ds
>> > a flag which the architecture code will update to indicate huge page
>> > dax mapping support.
>>
>> *groan*
>>
>> > Architectures mostly do transparent_hugepage_flag =3D 0; if they can't
>> > do hugepages. That also takes care of disabling dax hugepage mapping
>> > with this change.
>> >
>> > Without this patch we get the below error with kvm on ppc64.
>> >
>> > [  118.849975] lpar: Failed hash pte insert with error -4
>> >
>> > NOTE: The patch also use
>> >
>> > echo never > /sys/kernel/mm/transparent_hugepage/enabled
>> > to disable dax huge page mapping.
>> >
>> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> > ---
>> > TODO:
>> > * Add Fixes: tag
>> >
>> >  include/linux/huge_mm.h | 4 +++-
>> >  mm/huge_memory.c        | 4 ++++
>> >  2 files changed, 7 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
>> > index 381e872bfde0..01ad5258545e 100644
>> > --- a/include/linux/huge_mm.h
>> > +++ b/include/linux/huge_mm.h
>> > @@ -53,6 +53,7 @@ vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct =
*vma, unsigned long addr,
>> >                         pud_t *pud, pfn_t pfn, bool write);
>> >  enum transparent_hugepage_flag {
>> >         TRANSPARENT_HUGEPAGE_FLAG,
>> > +       TRANSPARENT_HUGEPAGE_DAX_FLAG,
>> >         TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
>> >         TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
>> >         TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
>> > @@ -111,7 +112,8 @@ static inline bool __transparent_hugepage_enabled(=
struct vm_area_struct *vma)
>> >         if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FL=
AG))
>> >                 return true;
>> >
>> > -       if (vma_is_dax(vma))
>> > +       if (vma_is_dax(vma) &&
>> > +           (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_D=
AX_FLAG)))
>> >                 return true;
>>
>> Forcing PTE sized faults should be fine for fsdax, but it'll break
>> devdax. The devdax driver requires the fault size be >=3D the namespace
>> alignment since devdax tries to guarantee hugepage mappings will be
>> used and PMD alignment is the default. We can probably have devdax
>> fall back to the largest size the hypervisor has made available, but
>> it does run contrary to the design. Ah well, I suppose it's better off
>> being degraded rather than unusable.
>
> Given this is an explicit setting I think device-dax should explicitly
> fail to enable in the presence of this flag to preserve the
> application visible behavior.
>
> I.e. if device-dax was enabled after this setting was made then I
> think future faults should fail as well.

Not sure I understood that. Now we are disabling the ability to map
pages as huge pages. I am now considering that this should not be
user configurable. Ie, this is something that platform can use to avoid
dax forcing huge page mapping, but if the architecture can enable huge
dax mapping, we should always default to using that.

Now w.r.t to failures, can device-dax do an opportunistic huge page
usage? I haven't looked at the device-dax details fully yet. Do we make the
assumption of the mapping page size as a format w.r.t device-dax? Is that
derived from nd_pfn->align value?

Here is what I am working on:
1) If the platform doesn't support huge page=C2=A0and if the device superbl=
ock
indicated that it was created with huge page support, we fail the device
init.

2) Now if we are creating a new namespace without huge page support in
the platform, then we force the align details to PAGE_SIZE. In such a
configuration when handling dax fault even with THP enabled during
the build, we should not try to use hugepage. This I think we can
achieve by using TRANSPARENT_HUGEPAEG_DAX_FLAG.

Also even if the user decided to not use THP, by
echo "never" > transparent_hugepage/enabled , we should continue to map
dax fault using huge page on platforms that can support huge pages.

This still doesn't cover the details of a device-dax created with
PAGE_SIZE align later booted with a kernel that can do hugepage dax.How
should we handle that? That makes me think, this should be a VMA flag
which got derived from device config? May be use VM_HUGEPAGE to indicate
if device should use a hugepage mapping or not?

-aneesh

