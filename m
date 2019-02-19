Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5480C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:46:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63FCE20838
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 17:46:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63FCE20838
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 151008E0004; Tue, 19 Feb 2019 12:46:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 102E88E0003; Tue, 19 Feb 2019 12:46:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 019F98E0004; Tue, 19 Feb 2019 12:46:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id CDE2B8E0003
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:46:26 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id b40so4974491qte.1
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 09:46:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=X7P9WIH2igbgzA0L2TbfN4vjhw3e82ZQwYvrqY3JYUg=;
        b=T5IiTZPrlmqbap2AgKf2BfaLkhQC9SbvJNdnD7UQ+AONL0F/IYpyp5l9VUigutYcFx
         hL6ukWhqRIEDNi/Qy2pHqQQRISalevIQcpmBunSe1mRzFfyRsCnhzc0rW6OUor80amL2
         H/Ix7PmgcM0t6m7q1n0bHieRYyav/34+1TrPlpvReeTupn/S/Rg1L3fdh0R8P8r88+ei
         sQCszRsRm9TTpCKfnVaT/PCYyN8ubbB0Y+SPrASxnDEauFknnBRaPl86bjLTcM7FBFfK
         tB0jTspe5w7RtsMOcx2dbgUDrr7McZCIepKU0wTUB2z7bJ4kxkkl6QPnbpm0KX8b98gR
         ao9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAua8tJPZh3a30HsyCQsm66Jp2rEN16Qo1O7qr4abkhZRi5FW/7+z
	PhhSo2Apnkydd/p5rp8SbiA0VpKYL5Y7kcKpFu2MstdZptia2YOisCzGR3ec47S+dYO+apc4Vwt
	BmsyCt5k6ZQBZgficVEj0j8Zbbr3Qy4Hz02daQ27cnEKg5Keq7Y6Y+e5VCtSDtNvJdw==
X-Received: by 2002:ae9:e64d:: with SMTP id x13mr1893219qkl.325.1550598386628;
        Tue, 19 Feb 2019 09:46:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYr6HUgVfsoyImn2p+EyoEst3T+ZugJj3kV/APSsHAhEbifAup9Yg5DDrVd/Ewc01fFMKMi
X-Received: by 2002:ae9:e64d:: with SMTP id x13mr1893182qkl.325.1550598386079;
        Tue, 19 Feb 2019 09:46:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550598386; cv=none;
        d=google.com; s=arc-20160816;
        b=tDBGGw93FhYbsarJwm/ayN9gWleqJMW5UbfXZfRXbw9ncgqH1759MzSo4tuB3q2DfI
         CBR9szFSWEMYT2XqAi9qvVKIYBe7ZWj4tPvXgZGA0Fwkv+TSp+7JwwFaWpQAqD52CsTa
         aDZsWlpmSDixgZFcdfbW69UoBJg2SCUCFM33jYzmLWcFAbvheqnbVSM2hduu+7E3USs9
         YkjRT8QeATgfw5E2A2yjV9KaY6BpjE9XJYwVfJWUMbw/qWx/ozp0iCPdn/o8O4SrT3xQ
         Tuy0wKB2+dkvwZUkWt+ZP86Z5lXGbDP05OxIwfox+YTJMQqdtk2d50hAbPYQFmZpLyJP
         TGWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=X7P9WIH2igbgzA0L2TbfN4vjhw3e82ZQwYvrqY3JYUg=;
        b=Dj1LWTs0dBZfFQQUdiwg6b7GG5cjSA3kt0k1Fl8NRICU9P2jU1YWyO/khnplfCcYQS
         g6UrvPzVQSWUwxtYp7hdrX6zBxUJQ+Oe1f78wbI5KkJj89a4e2THve69Mr0peLx4SC8i
         oJyVENS9WJCruq+6m0WmsAb/bhkNiwPlP7K/Z14MV4hvegwcDHLi7EhqPKHScdyjdY5y
         9ou8ToRxq4u7t6INZDUew+bS5RsHwULcTezhnFsLGMFfX7anzyCKXB941NT+tk8B4a1j
         tekddIapTUoHuiz+xhZsY0jIQIqlN2NFySeaFnqMFUtyIdDwDWkHkVObaPliScf2sjCh
         skdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m49si2902743qvm.204.2019.02.19.09.46.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 09:46:26 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1JHhhE1019565
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:46:25 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qrmgn6re6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:46:24 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 19 Feb 2019 17:46:23 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 19 Feb 2019 17:46:19 -0000
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1JHkIOE28835916
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 19 Feb 2019 17:46:18 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 712E4AE045;
	Tue, 19 Feb 2019 17:46:18 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id F0A7FAE057;
	Tue, 19 Feb 2019 17:46:14 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.206.228])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 19 Feb 2019 17:46:14 +0000 (GMT)
Date: Tue, 19 Feb 2019 19:46:11 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peng Fan <peng.fan@nxp.com>,
        "labbott@redhat.com" <labbott@redhat.com>,
        "mhocko@suse.com" <mhocko@suse.com>,
        "iamjoonsoo.kim@lge.com" <iamjoonsoo.kim@lge.com>,
        "rppt@linux.vnet.ibm.com" <rppt@linux.vnet.ibm.com>,
        "m.szyprowski@samsung.com" <m.szyprowski@samsung.com>,
        "rdunlap@infradead.org" <rdunlap@infradead.org>,
        "andreyknvl@google.com" <andreyknvl@google.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "van.freenix@gmail.com" <van.freenix@gmail.com>,
        Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm/cma: cma_declare_contiguous: correct err handling
References: <20190214125704.6678-1-peng.fan@nxp.com>
 <20190214123824.fe95cc2e603f75382490bfb4@linux-foundation.org>
 <b78470e8-b204-4a7e-f9cc-eff9c609f480@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b78470e8-b204-4a7e-f9cc-eff9c609f480@suse.cz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021917-0008-0000-0000-000002C26115
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021917-0009-0000-0000-0000222E943D
Message-Id: <20190219174610.GA32749@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-19_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902190129
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 05:55:33PM +0100, Vlastimil Babka wrote:
> On 2/14/19 9:38 PM, Andrew Morton wrote:
> > On Thu, 14 Feb 2019 12:45:51 +0000 Peng Fan <peng.fan@nxp.com> wrote:
> > 
> >> In case cma_init_reserved_mem failed, need to free the memblock allocated
> >> by memblock_reserve or memblock_alloc_range.
> >>
> >> ...
> >>
> >> --- a/mm/cma.c
> >> +++ b/mm/cma.c
> >> @@ -353,12 +353,14 @@ int __init cma_declare_contiguous(phys_addr_t base,
> >>  
> >>  	ret = cma_init_reserved_mem(base, size, order_per_bit, name, res_cma);
> >>  	if (ret)
> >> -		goto err;
> >> +		goto free_mem;
> >>  
> >>  	pr_info("Reserved %ld MiB at %pa\n", (unsigned long)size / SZ_1M,
> >>  		&base);
> >>  	return 0;
> >>  
> >> +free_mem:
> >> +	memblock_free(base, size);
> >>  err:
> >>  	pr_err("Failed to reserve %ld MiB\n", (unsigned long)size / SZ_1M);
> >>  	return ret;
> > 
> > This doesn't look right to me.  In the `fixed==true' case we didn't
> > actually allocate anything and in the `fixed==false' case, the
> > allocated memory is at `addr', not at `base'.
> 
> I think it's ok as the fixed==true path has "memblock_reserve()", but
> better leave this to the memblock maintainer :)

As Peng Fan noted in the other e-mail, fixed==true has memblock_reserve()
and fixed==false resets base = addr, so this is Ok.
 
> There's also 'kmemleak_ignore_phys(addr)' which should probably be
> undone (or not called at all) in the failure case. But it seems to be
> missing from the fixed==true path?

Well, memblock and kmemleak interaction does not seem to have clear
semantics anyway. memblock_free() calls kmemleak_free_part_phys() which
does not seem to care about ignored objects.
As for the fixed==true path, memblock_reserve() does not register the area
with kmemleak, so there would be no object to free in memblock_free().
AFAIU, kmemleak simply ignores this.

Catalin, can you comment please?

-- 
Sincerely yours,
Mike.

