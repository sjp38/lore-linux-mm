Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12DF7C072A4
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 05:41:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C590A20815
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 05:41:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C590A20815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9235E6B0007; Wed, 22 May 2019 01:41:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D1936B0008; Wed, 22 May 2019 01:41:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C0C76B000A; Wed, 22 May 2019 01:41:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 449766B0007
	for <linux-mm@kvack.org>; Wed, 22 May 2019 01:41:30 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id t1so1030702pfa.10
        for <linux-mm@kvack.org>; Tue, 21 May 2019 22:41:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=oAfmG1jgQhZAEI5ey+XiueHNcmDNfzT4VCX/DKbyk0I=;
        b=CqsqrLhRA54Yg+cCAkWl3Q9gcBnaTIzQ7sHrDv33e3usVZwc5paHjQiCBDTGWsOLXR
         SK6t+xCglHhugPUkDdxeEAKEvvBlsjTK/uZLvWfv5ZW/McSLZWg7Drto20EXKAXg3kCW
         MwkdIFEAEwKACcRqXPJFyunN7zo37jo4CaUU6RbrGLc/DqljCJo1TrDx4clylT/bR34T
         QSLurrk81DuZiTlfPfPraly2CtaINkdSB6F6y5wA6GR44jWY82lRSFmRRjZAwk+KmUPs
         oPmDpI7uNnmXC8tDf9gg7RERTGuzu0Nv8dHwFS0pXnPnppdj5XhEkWOia0mo2/TU8AyE
         tqyg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW66WKMhvQhzBylSojuQ2akEbY0m3L++SDvOQwBXrflD2aOKpzB
	cPA7MMSYSBlDmfO5jX5SyDqSFzncLe1UckZS5EKlDFHpjdhu0tHob257iNEm+TiZzExcRuZr7P3
	B5xIa8iPgTHp4cSyVQP5+NAyibToSLA5echzv0J22aWvYL310jD1MQiXLhUjGKhWEuQ==
X-Received: by 2002:a65:624f:: with SMTP id q15mr88020122pgv.436.1558503689876;
        Tue, 21 May 2019 22:41:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIeeXbqsr/dfDGg8LpQZs6nkwak+v2Xf+eH9KR/LA6e/ihw3aOhnSWXJY81CEGtPg0aI2A
X-Received: by 2002:a65:624f:: with SMTP id q15mr88020046pgv.436.1558503688620;
        Tue, 21 May 2019 22:41:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558503688; cv=none;
        d=google.com; s=arc-20160816;
        b=YjM5CtAPGZLuZpva9qsNGw2wIYiH9ngN/01w9TZucyMLnRHDa425eVyVSrbSKpH8KE
         5azB/xdh529HKDhkcP36sn/gxvGl8ZOKqg8ry/aaKusRTpsxD0vLBi14Pkk/VgkgDJmk
         7gEmWUd+z+67fU1o36GzCoF7ClrTPfjk6I2ZHfJizCa8IyNIcbRiwWJSSU2YyQjX5GhJ
         XnxtGEA59gXAxMN40bSq2J/RXqVqRpDQJNt/N74XhUV7L09KREiqB1idPGwJIiG4H+fD
         8+z2WWUde058TTmM7LO6PgdlXi+1LGO+GlWhQI1GZiUDzYfA5KDkayVVaVmiq3mb2I38
         lqEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=oAfmG1jgQhZAEI5ey+XiueHNcmDNfzT4VCX/DKbyk0I=;
        b=sCfavSHWVkryvFs3N0vQZHdIPGudqMJspoz0zQCU7aIZnhmSaaE/hYal8j3gMBH+HH
         3u/imL9dgRf/laRBZXdo21govCv40EtHumqwqBgTPplMSXU8TDprwdJBhcSWKizQAAif
         JYoOe6vp1CEqRjK5ZtfBb3QUvWzEImRMAOXiAr7OTiqMY6BJQoqlZ72nnZu+ItcC0pDr
         dF1u9VYWXXbq5Y4qZ2qciFXYZYlmoMmmmHlIUcVBxl1bf4E5K3c7HE9zRgt3YhONGOQM
         CBjtA49CWX/8rgBy2fNmsmqMNy7aAs7+UMcE1XthEFeP30HlgHZANLCrgjc96hFnPfDO
         v3nQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w69si16969829pgd.165.2019.05.21.22.41.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 22:41:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4M5b2Fm032928
	for <linux-mm@kvack.org>; Wed, 22 May 2019 01:41:27 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2smyayt5cj-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 May 2019 01:41:27 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 22 May 2019 06:41:27 +0100
Received: from b03cxnp07029.gho.boulder.ibm.com (9.17.130.16)
	by e31.co.us.ibm.com (192.168.1.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 22 May 2019 06:41:23 +0100
Received: from b03ledav004.gho.boulder.ibm.com (b03ledav004.gho.boulder.ibm.com [9.17.130.235])
	by b03cxnp07029.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x4M5fMtp10748274
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 22 May 2019 05:41:22 GMT
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AB98D7805F;
	Wed, 22 May 2019 05:41:22 +0000 (GMT)
Received: from b03ledav004.gho.boulder.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 20D9C7805C;
	Wed, 22 May 2019 05:41:21 +0000 (GMT)
Received: from [9.124.31.87] (unknown [9.124.31.87])
	by b03ledav004.gho.boulder.ibm.com (Postfix) with ESMTP;
	Wed, 22 May 2019 05:41:20 +0000 (GMT)
Subject: Re: [PATCH] mm/nvdimm: Use correct #defines instead of opencoding
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>,
        linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
        "Oliver O'Halloran" <oohall@gmail.com>
References: <20190514025604.9997-1-aneesh.kumar@linux.ibm.com>
 <CAPcyv4iNgFbSq0Hqb+CStRhGWMHfXx7tL3vrDaQ95DcBBY8QCQ@mail.gmail.com>
 <f99c4f11-a43d-c2d3-ab4f-b7072d090351@linux.ibm.com>
 <CAPcyv4gOr8SFbdtBbWhMOU-wdYuMCQ4Jn2SznGRsv6Vku97Xnw@mail.gmail.com>
 <02d1d14d-650b-da38-0828-1af330f594d5@linux.ibm.com>
 <CAPcyv4jcSgg0wxY9FAM4ke9JzVc9Pu3qe6dviS3seNgHfG2oNw@mail.gmail.com>
 <87mujgcf0h.fsf@linux.ibm.com>
 <CAPcyv4j5Y+AFkbvYjDnfqTdmN_Sq=O0qfGUorgpjAE8Ww7vH=A@mail.gmail.com>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Date: Wed, 22 May 2019 11:11:19 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4j5Y+AFkbvYjDnfqTdmN_Sq=O0qfGUorgpjAE8Ww7vH=A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-TM-AS-GCONF: 00
x-cbid: 19052205-8235-0000-0000-00000E9C8470
X-IBM-SpamModules-Scores: 
X-IBM-SpamModules-Versions: BY=3.00011141; HX=3.00000242; KW=3.00000007;
 PH=3.00000004; SC=3.00000286; SDB=6.01206830; UDB=6.00633747; IPR=6.00987805;
 MB=3.00026996; MTD=3.00000008; XFM=3.00000015; UTC=2019-05-22 05:41:25
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19052205-8236-0000-0000-000045ABA866
Message-Id: <d328ce41-4a65-c35e-72d7-74e722795428@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-22_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905220040
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/21/19 9:37 PM, Dan Williams wrote:
> On Tue, May 21, 2019 at 2:51 AM Aneesh Kumar K.V
> <aneesh.kumar@linux.ibm.com> wrote:


....

>>
>> Something like the below (Not tested). I am not sure what we will init the page_size
>> for minor version < 3. This will mark the namespace disabled if the
>> PAGE_SIZE and sizeof(struct page) doesn't match with the values used
>> during namespace create.
> 
> Yes, this is on the right track.
> 
> I would special-case page_size == 0 as 4096 and page_struct_size == 0
> as 64. If either of those is non-zero then the info-block version
> needs to be revved and it needs to be crafted to make older kernels
> fail to parse it.
> 

page_size = SZ_4K implies we fail to enable namesepaces created on ppc64 
till now. We do work fine with page_size = PAGE_SIZE. It is a few error 
check and pfn_sb->npfns that got wrong values. We do reserve the correct 
space for the required pfns even when we recorded wrong pfn_sb->npfs.


> There was an earlier attempt to implement minimum info-block versions here:
> 
> https://lore.kernel.org/lkml/155000670159.348031.17631616775326330606.stgit@dwillia2-desk3.amr.corp.intel.com/
> 
> ...but that was dropped in favor of the the "sub-section" patches.
> 

Ok i will pick that too.

-aneesh

