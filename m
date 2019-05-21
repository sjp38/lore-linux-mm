Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27892C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:51:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C409321773
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 09:51:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C409321773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 60F546B000D; Tue, 21 May 2019 05:51:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C01B6B000E; Tue, 21 May 2019 05:51:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 486576B0010; Tue, 21 May 2019 05:51:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21D936B000D
	for <linux-mm@kvack.org>; Tue, 21 May 2019 05:51:05 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id 83so16815659ybo.11
        for <linux-mm@kvack.org>; Tue, 21 May 2019 02:51:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=t0tx6SnHDotzhdP9gz3SaYa3cK+t02WMuaJezP2R0tw=;
        b=qkubTSjtIcE3KPXF50r7d83efGqyXnT1JhzIK7HNNJiUhTsABrKPQYpR5hjS1lbCDW
         Rx3SSR9tQN7z6Pk7dwEAASmtqmGNoLwjLFEUuvlRgCEwhRMTogJOYvW9v8389jkOB/SE
         wrfLrVokaZsoyTv2ZKMGAst3wc6fGYzNXYOGR9h48wran4YEdpN93+VQFXmIFrkRFtSH
         d91CVLtDk4mdcGatWsw5Cer8NHV2u7YPqinRLNQUBQ5CCwaiZcJuCYbhxgTrqqVUDruJ
         0KClvek7q6eKPKG2/y0Il0NirpldKVLx8C61jgdtTZRPeqKiYZaV6s0ozIvbt6RQng+c
         AG0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXVa7obK/Rt5tGhLMMo0g6CU/tboFqlae2afAXk9dmAx83ITbEW
	hk1oCZdDqBX59Nu3mA1U34VPHDGCKkSnrt/R83gvRWW17Pks8Zf8cmsYM0eVzRM3xPzMY0cCmAe
	cu/R4c+LG7M32KysQc5pbsEwAhWXFv5PbTaoexEOFZT0VHS9UaPHmj4NatEc/z6MwFA==
X-Received: by 2002:a25:55c3:: with SMTP id j186mr37018974ybb.255.1558432264852;
        Tue, 21 May 2019 02:51:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxc7+mLIPkyK81hoJsDj7FXZkf9plNbJyvoMe06Uxfny0hfGFJMjchmDlFUSbf/PMTiL7BZ
X-Received: by 2002:a25:55c3:: with SMTP id j186mr37018952ybb.255.1558432263889;
        Tue, 21 May 2019 02:51:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558432263; cv=none;
        d=google.com; s=arc-20160816;
        b=tof/KJZgEoAambRFzDUqNfiSblL3T53LGbVd2SK7utbadbaDt4FXfHgBpFRrN5BwNG
         S5iMHoKz8o93HUgdAPu+hafa5IWp6yG6e+zPyNsS/rfT/FfftByo4sXA8uZgVO8VuOji
         1dOUgdVqox7YVVeUEt+9S0wmyVT39RevZdBsAe1gokPc4xSVisf4odGsB0h0+mntQ9xk
         qbA+bMm6rimMTX8OpGWkqmSmV37dYsS/Zt//E8UobyhQ2CKjb0HRqGEksbJHexnTL2PQ
         wvqT0GaD756YY+7EUAa0JT/u+hbkhmQfPFFINikdi2udDnYoV2Bhvyf/+zboFlm5S4+p
         17WA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=t0tx6SnHDotzhdP9gz3SaYa3cK+t02WMuaJezP2R0tw=;
        b=AUpGttd8766UUMvOWrcol8EaoDLpQtu1uFRm5Wc2ql6C6RNfzYLmXyYBrcp4NPKU4x
         0OiDR1Wv33O3HjrnlU/FWexYv6OZ4bsQZ4iWcy/SmfO6gKVSOs4Y9OmG8O5NIbCU01RG
         Ie8gpH+14TROwJ9qzMHZ3WxHGMbHa/KQc7zPv6vZ+V2ouFrSw9+0xt3CROovuAWrhcOf
         h61suSnYWJdrqnn3n9ufFhzMa+A0TKZo2F5kCQz6u7n3SPMWPnTLplhEVuiO2/P02v3X
         ISoa968Q5TQ4mUqIuPeCGM9EpuRTW0uzOcb6hGgxPZipJaoNpZZZtqxo/vLogiVZgCZQ
         KiKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i3si5931478yba.16.2019.05.21.02.51.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 02:51:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4L9eNhc004321
	for <linux-mm@kvack.org>; Tue, 21 May 2019 05:51:03 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2smd06w29n-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 21 May 2019 05:51:03 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 21 May 2019 10:51:00 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 21 May 2019 10:50:57 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4L9ouZq19398902
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 21 May 2019 09:50:56 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8CC484203F;
	Tue, 21 May 2019 09:50:56 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id ABB9D42045;
	Tue, 21 May 2019 09:50:55 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.124.31.61])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 21 May 2019 09:50:55 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Subject: Re: [PATCH] mm/nvdimm: Use correct #defines instead of opencoding
In-Reply-To: <CAPcyv4jcSgg0wxY9FAM4ke9JzVc9Pu3qe6dviS3seNgHfG2oNw@mail.gmail.com>
References: <20190514025604.9997-1-aneesh.kumar@linux.ibm.com> <CAPcyv4iNgFbSq0Hqb+CStRhGWMHfXx7tL3vrDaQ95DcBBY8QCQ@mail.gmail.com> <f99c4f11-a43d-c2d3-ab4f-b7072d090351@linux.ibm.com> <CAPcyv4gOr8SFbdtBbWhMOU-wdYuMCQ4Jn2SznGRsv6Vku97Xnw@mail.gmail.com> <02d1d14d-650b-da38-0828-1af330f594d5@linux.ibm.com> <CAPcyv4jcSgg0wxY9FAM4ke9JzVc9Pu3qe6dviS3seNgHfG2oNw@mail.gmail.com>
Date: Tue, 21 May 2019 15:20:54 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19052109-0008-0000-0000-000002E8DFAA
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052109-0009-0000-0000-00002255952D
Message-Id: <87mujgcf0h.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-21_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905210062
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

> On Mon, May 13, 2019 at 9:46 PM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
>>
>> On 5/14/19 9:42 AM, Dan Williams wrote:
>> > On Mon, May 13, 2019 at 9:05 PM Aneesh Kumar K.V
>> > <aneesh.kumar@linux.ibm.com> wrote:
>> >>
>> >> On 5/14/19 9:28 AM, Dan Williams wrote:
>> >>> On Mon, May 13, 2019 at 7:56 PM Aneesh Kumar K.V
>> >>> <aneesh.kumar@linux.ibm.com> wrote:
>> >>>>
>> >>>> The nfpn related change is needed to fix the kernel message
>> >>>>
>> >>>> "number of pfns truncated from 2617344 to 163584"
>> >>>>
>> >>>> The change makes sure the nfpns stored in the superblock is right value.
>> >>>>
>> >>>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>> >>>> ---
>> >>>>    drivers/nvdimm/pfn_devs.c    | 6 +++---
>> >>>>    drivers/nvdimm/region_devs.c | 8 ++++----
>> >>>>    2 files changed, 7 insertions(+), 7 deletions(-)
>> >>>>
>> >>>> diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
>> >>>> index 347cab166376..6751ff0296ef 100644
>> >>>> --- a/drivers/nvdimm/pfn_devs.c
>> >>>> +++ b/drivers/nvdimm/pfn_devs.c
>> >>>> @@ -777,8 +777,8 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>> >>>>                    * when populating the vmemmap. This *should* be equal to
>> >>>>                    * PMD_SIZE for most architectures.
>> >>>>                    */
>> >>>> -               offset = ALIGN(start + reserve + 64 * npfns,
>> >>>> -                               max(nd_pfn->align, PMD_SIZE)) - start;
>> >>>> +               offset = ALIGN(start + reserve + sizeof(struct page) * npfns,
>> >>>> +                              max(nd_pfn->align, PMD_SIZE)) - start;
>> >>>
>> >>> No, I think we need to record the page-size into the superblock format
>> >>> otherwise this breaks in debug builds where the struct-page size is
>> >>> extended.
>> >>>
>> >>>>           } else if (nd_pfn->mode == PFN_MODE_RAM)
>> >>>>                   offset = ALIGN(start + reserve, nd_pfn->align) - start;
>> >>>>           else
>> >>>> @@ -790,7 +790,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
>> >>>>                   return -ENXIO;
>> >>>>           }
>> >>>>
>> >>>> -       npfns = (size - offset - start_pad - end_trunc) / SZ_4K;
>> >>>> +       npfns = (size - offset - start_pad - end_trunc) / PAGE_SIZE;
>> >>>
>> >>> Similar comment, if the page size is variable then the superblock
>> >>> needs to explicitly account for it.
>> >>>
>> >>
>> >> PAGE_SIZE is not really variable. What we can run into is the issue you
>> >> mentioned above. The size of struct page can change which means the
>> >> reserved space for keeping vmemmap in device may not be sufficient for
>> >> certain kernel builds.
>> >>
>> >> I was planning to add another patch that fails namespace init if we
>> >> don't have enough space to keep the struct page.
>> >>
>> >> Why do you suggest we need to have PAGE_SIZE as part of pfn superblock?
>> >
>> > So that the kernel has a chance to identify cases where the superblock
>> > it is handling was created on a system with different PAGE_SIZE
>> > assumptions.
>> >
>>
>> The reason to do that is we don't have enough space to keep struct page
>> backing the total number of pfns? If so, what i suggested above should
>> handle that.
>>
>> or are you finding any other reason why we should fail a namespace init
>> with a different PAGE_SIZE value?
>
> I want the kernel to be able to start understand cross-architecture
> and cross-configuration geometries. Which to me means incrementing the
> info-block version and recording PAGE_SIZE and sizeof(struct page) in
> the info-block directly.
>
>> My another patch handle the details w.r.t devdax alignment for which
>> devdax got created with PAGE_SIZE 4K but we are now trying to load that
>> in a kernel with PAGE_SIZE 64k.
>
> Sure, but what about the reverse? These info-block format assumptions
> are as fundamental as the byte-order of the info-block, it needs to be
> cross-arch compatible and the x86 assumptions need to be fully lifted.

Something like the below (Not tested). I am not sure what we will init the page_size
for minor version < 3. This will mark the namespace disabled if the
PAGE_SIZE and sizeof(struct page) doesn't match with the values used
during namespace create. 

diff --git a/drivers/nvdimm/pfn.h b/drivers/nvdimm/pfn.h
index dde9853453d3..d6e0933d0dd4 100644
--- a/drivers/nvdimm/pfn.h
+++ b/drivers/nvdimm/pfn.h
@@ -36,6 +36,9 @@ struct nd_pfn_sb {
 	__le32 end_trunc;
 	/* minor-version-2 record the base alignment of the mapping */
 	__le32 align;
+	/* minor-version-3 record the page size and struct page size */
+	__le32 page_size;
+	__le32 page_struct_size;
 	u8 padding[4000];
 	__le64 checksum;
 };
diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 6f9f78858018..bbc1d792d7f3 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -477,6 +477,15 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 	if (__le16_to_cpu(pfn_sb->version_minor) < 2)
 		pfn_sb->align = 0;
 
+	if (__le16_to_cpu(pfn_sb->version_minor) < 3) {
+		/*
+		 * For a large part we use PAGE_SIZE. But we
+		 * do have some accounting code using SIZE_4K.
+		 */
+		pfn_sb->page_size = cpu_to_le32(PAGE_SIZE);
+		pfn_sb->page_struct_size = cpu_to_le32(64);
+	}
+
 	switch (le32_to_cpu(pfn_sb->mode)) {
 	case PFN_MODE_RAM:
 	case PFN_MODE_PMEM:
@@ -504,6 +513,12 @@ int nd_pfn_validate(struct nd_pfn *nd_pfn, const char *sig)
 		return -EOPNOTSUPP;
 	}
 
+	if (le32_to_cpu(pfn_sb->page_size) != PAGE_SIZE)
+		return -EOPNOTSUPP;
+
+	if (le32_to_cpu(pfn_sb->page_struct_size) != sizeof(struct page))
+		return -EOPNOTSUPP;
+
 	if (!nd_pfn->uuid) {
 		/*
 		 * When probing a namepace via nd_pfn_probe() the uuid
@@ -798,7 +813,7 @@ static int nd_pfn_init(struct nd_pfn *nd_pfn)
 	memcpy(pfn_sb->uuid, nd_pfn->uuid, 16);
 	memcpy(pfn_sb->parent_uuid, nd_dev_to_uuid(&ndns->dev), 16);
 	pfn_sb->version_major = cpu_to_le16(1);
-	pfn_sb->version_minor = cpu_to_le16(2);
+	pfn_sb->version_minor = cpu_to_le16(3);
 	pfn_sb->start_pad = cpu_to_le32(start_pad);
 	pfn_sb->end_trunc = cpu_to_le32(end_trunc);
 	pfn_sb->align = cpu_to_le32(nd_pfn->align);

