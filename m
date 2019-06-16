Return-Path: <SRS0=z6ed=UP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FDF9C31E49
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 03:50:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BB5D2084D
	for <linux-mm@archiver.kernel.org>; Sun, 16 Jun 2019 03:50:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BB5D2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEDA66B0005; Sat, 15 Jun 2019 23:50:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9FA76B0006; Sat, 15 Jun 2019 23:50:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8F168E0001; Sat, 15 Jun 2019 23:50:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id B861E6B0005
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 23:50:18 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id u3so7489809ybu.7
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 20:50:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=8tzI7/Jx0Nps2iURLacuN0RtP13PIB8dpM6hJJgr1Ao=;
        b=t7HsTDvXHEJ/k8plXwbcIipebAdflTYwEe//2gkm+WagLXgfB8PYHyYHva8c0VjNot
         6CpaDE34R6lbY+lCcAXpvBDFpuCGyuDPrvAU/VBRhDL5YVJ1ic5I3qg8u940ZxwO5i72
         FkSaTtDc+C5jR68g2XimvO5POxOMxqFhjnHjyGIqIWBSC5G/tIWpCe2TNe8qDZW3nhXL
         i5mon3bvNPy7E1Vq7gp/V9olVxKqN4t/sHNFx4e9UsA9Zdfrt5Y4PXW+GEaFzCVeN1k7
         H+0Q1Zg4J8iT9sn5MM6nHkBMsHZ+5t8MR3KLDQsgEeK4hd78Tj9HZfLUeAQ9dKILesK4
         kdOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXqF8/Jx8ED2wwopTwSvSzKw48jYnpWgVfkDS7tPRsHBGjbA8g/
	dbdOWObKUwOSkdypfzds/F7FFTidDA+x9AwJAqcxpnVGk4ds3i/JcPmUpN4rRFuf71hTHVFKczO
	L4cVazxkkPr4P4FuhyYbGRKXWYDsP8LneLjXgbofEHDbdiYwUvolxA93LJmm43aMSuQ==
X-Received: by 2002:a81:d20b:: with SMTP id x11mr46422848ywi.47.1560657018412;
        Sat, 15 Jun 2019 20:50:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxr6u+vp+UURy7EGCBLt5Rstordl+7krcIdPRWpbQc92ANpODY0gmFyXflZUAJKoWpQFfOC
X-Received: by 2002:a81:d20b:: with SMTP id x11mr46422825ywi.47.1560657017613;
        Sat, 15 Jun 2019 20:50:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560657017; cv=none;
        d=google.com; s=arc-20160816;
        b=vyJ7FmMiJEz/T08BQ+DjBksZHxPVIf2Ji0vm3o93AXBg4qgQdE7BRSbXCj5pt8pofK
         0r51jkNvc0tDBb4RONClLV5LyucW+RUezMkm7o2scvQsxESLVKH7UUdBhQz8dTZvhrVJ
         p2S6ffhNXnLZ6AybVKoHTuO6Qlv51gSzL7oJ603ULF51KQFThGedujd7BSuG6k+YAd2f
         mf9rlnYTH9FileCTsMPRFNW0dKTpw0IcTPwnOw409A/w1Q2iy/Npk/wytKWEsmlpCJlN
         /TOq8OF2zMl9Xuod/YXbto5Dl9Hl85dlaJelEtDGDMEKkfF3XWYpMnv6mFlBx41qugUj
         EwlQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=8tzI7/Jx0Nps2iURLacuN0RtP13PIB8dpM6hJJgr1Ao=;
        b=z7wFyDJ2iuQ7r9x/C+AYd1mgAqzaRVD7BScvWEgsJlCNNOfhHrZDB4wCdyLAufvHqh
         nHrGD6lbn5BWf3UW+t5KBBDlyGltP5OmPa+Ob2HycFU6wqGKgPbVKf0VNtrNb0Jb83oB
         HrxvVJ0fcwutXMNILH/UfRTkcyeW8mEjiO1W5QU0qxZGdavM/ojw/56HK1KXccTJVk4q
         rDRjmoMukBXilfegyFSNZBRMKTwEeNo9Fz+Qj07Hs9ZwZqa2NZVydnFXOqXui0LRQY8O
         osWsb0DxpFLuUFxn5c985wZzdczKrpBiaMrRH4ggUk9UhGTyyhPLtdWndzgv+1Wvj5w0
         jrDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f125si2760188ywb.145.2019.06.15.20.50.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 20:50:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5G3lMQI125045
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 23:50:17 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2t5dwx8ece-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 23:50:16 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Sun, 16 Jun 2019 04:50:15 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sun, 16 Jun 2019 04:50:12 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5G3oBUR49348710
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 16 Jun 2019 03:50:11 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 51C71AE057;
	Sun, 16 Jun 2019 03:50:11 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 8981FAE04D;
	Sun, 16 Jun 2019 03:50:09 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.86.48])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Sun, 16 Jun 2019 03:50:09 +0000 (GMT)
X-Mailer: emacs 26.2 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Oscar Salvador <osalvador@suse.de>, Qian Cai <cai@lca.pw>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux MM <linux-mm@kvack.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        jmoyer <jmoyer@redhat.com>
Subject: Re: [PATCH -next] mm/hotplug: skip bad PFNs from pfn_to_online_page()
In-Reply-To: <CAPcyv4j_QQB8SrhTqL2mnEEHGYCg4H7kYanChiww35k0fwNv8Q@mail.gmail.com>
References: <1560366952-10660-1-git-send-email-cai@lca.pw> <CAPcyv4hn0Vz24s5EWKr39roXORtBTevZf7dDutH+jwapgV3oSw@mail.gmail.com> <CAPcyv4iuNYXmF0-EMP8GF5aiPsWF+pOFMYKCnr509WoAQ0VNUA@mail.gmail.com> <1560376072.5154.6.camel@lca.pw> <87lfy4ilvj.fsf@linux.ibm.com> <20190614153535.GA9900@linux> <c3f2c05d-e42f-c942-1385-664f646ddd33@linux.ibm.com> <CAPcyv4j_QQB8SrhTqL2mnEEHGYCg4H7kYanChiww35k0fwNv8Q@mail.gmail.com>
Date: Sun, 16 Jun 2019 09:19:42 +0530
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19061603-0016-0000-0000-000002897078
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061603-0017-0000-0000-000032E6B591
Message-Id: <87imt6i3zd.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-16_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=27 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906160035
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

> On Fri, Jun 14, 2019 at 9:18 AM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:
>>
>> On 6/14/19 9:05 PM, Oscar Salvador wrote:
>> > On Fri, Jun 14, 2019 at 02:28:40PM +0530, Aneesh Kumar K.V wrote:
>> >> Can you check with this change on ppc64.  I haven't reviewed this series yet.
>> >> I did limited testing with change . Before merging this I need to go
>> >> through the full series again. The vmemmap poplulate on ppc64 needs to
>> >> handle two translation mode (hash and radix). With respect to vmemap
>> >> hash doesn't setup a translation in the linux page table. Hence we need
>> >> to make sure we don't try to setup a mapping for a range which is
>> >> arleady convered by an existing mapping.
>> >>
>> >> diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
>> >> index a4e17a979e45..15c342f0a543 100644
>> >> --- a/arch/powerpc/mm/init_64.c
>> >> +++ b/arch/powerpc/mm/init_64.c
>> >> @@ -88,16 +88,23 @@ static unsigned long __meminit vmemmap_section_start(unsigned long page)
>> >>    * which overlaps this vmemmap page is initialised then this page is
>> >>    * initialised already.
>> >>    */
>> >> -static int __meminit vmemmap_populated(unsigned long start, int page_size)
>> >> +static bool __meminit vmemmap_populated(unsigned long start, int page_size)
>> >>   {
>> >>      unsigned long end = start + page_size;
>> >>      start = (unsigned long)(pfn_to_page(vmemmap_section_start(start)));
>> >>
>> >> -    for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page)))
>> >> -            if (pfn_valid(page_to_pfn((struct page *)start)))
>> >> -                    return 1;
>> >> +    for (; start < end; start += (PAGES_PER_SECTION * sizeof(struct page))) {
>> >>
>> >> -    return 0;
>> >> +            struct mem_section *ms;
>> >> +            unsigned long pfn = page_to_pfn((struct page *)start);
>> >> +
>> >> +            if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
>> >> +                    return 0;
>> >
>> > I might be missing something, but is this right?
>> > Having a section_nr above NR_MEM_SECTIONS is invalid, but if we return 0 here,
>> > vmemmap_populate will go on and populate it.
>>
>> I should drop that completely. We should not hit that condition at all.
>> I will send a final patch once I go through the full patch series making
>> sure we are not breaking any ppc64 details.
>>
>> Wondering why we did the below
>>
>> #if defined(ARCH_SUBSECTION_SHIFT)
>> #define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
>> #elif defined(PMD_SHIFT)
>> #define SUBSECTION_SHIFT (PMD_SHIFT)
>> #else
>> /*
>>   * Memory hotplug enabled platforms avoid this default because they
>>   * either define ARCH_SUBSECTION_SHIFT, or PMD_SHIFT is a constant, but
>>   * this is kept as a backstop to allow compilation on
>>   * !ARCH_ENABLE_MEMORY_HOTPLUG archs.
>>   */
>> #define SUBSECTION_SHIFT 21
>> #endif
>>
>> why not
>>
>> #if defined(ARCH_SUBSECTION_SHIFT)
>> #define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
>> #else
>> #define SUBSECTION_SHIFT  SECTION_SHIFT
>> #endif
>>
>> ie, if SUBSECTION is not supported by arch we have one sub-section per
>> section?
>
> A couple comments:
>
> The only reason ARCH_SUBSECTION_SHIFT exists is because PMD_SHIFT on
> PowerPC was a non-constant value. However, I'm planning to remove the
> distinction in the next rev of the patches. Jeff rightly points out
> that having a variable subsection size per arch will lead to
> situations where persistent memory namespaces are not portable across
> archs. So I plan to just make SUBSECTION_SHIFT 21 everywhere.

What is the dependency between subsection and pageblock_order? Shouldn't
subsection size >= pageblock size?

We do have pageblock size drived from HugeTLB size.

-aneesh

