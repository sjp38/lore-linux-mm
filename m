Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71F04C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:41:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37DA7214DA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:41:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37DA7214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA2378E0003; Tue, 12 Feb 2019 09:41:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C50088E0001; Tue, 12 Feb 2019 09:41:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B67368E0003; Tue, 12 Feb 2019 09:41:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 70F478E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:41:05 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id m3so2574833pfj.14
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:41:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=dbX/YXLo6Xa1YFpN4EFI1rekgVsrdlB17Tc9ubbErvU=;
        b=j2rVdmT5lVjF/haIvDsBouPZdbQU2cg2rIQkmLk9MHsCFiqaRMVRj0844ZHcSxt210
         dHSy4Jo9GStcnSeiosuTX4GRw6LyQWmEQB2gOLH7kS+/lZSytPhytbLvYqjHWZ+kIL/l
         +/qVwf44UEovciSZOp3fLCyKjmGTk9pQJgRsXKvRa7e55TH759R0tr5v0g+qW65TmPcA
         zZIrxISdNzdZKxN0jpXbNXaASOjI1FOGb5EbCm88VwKB4hXcQsnLPKpFMNdlwtXm57SP
         NrmlufJ5ObDf+Ida7lLz13kjaoDmyiWpLUtSvqDgH9/lwRaqMsGSIK24An7K2AShJtn4
         1ucw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuYgqQDYFWc1XIEopFlmTJTuWOadapN74jiM3N5mQjUXlvZPRfQv
	V/Y6ZX48B7h00KBhqgAqB6a+pWCmObkIrBzl4fLGZXPLzj41iKwRPsvoYd2B70qjnFJfuIu/Cgy
	kTDVYu0JaBHlCEpx7f5/gXxCnNUeQ07iuzXtC7fYPfpBEQNfa5Ac2qdePBvVJXkaxUg==
X-Received: by 2002:a63:9f19:: with SMTP id g25mr3949706pge.327.1549982465132;
        Tue, 12 Feb 2019 06:41:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbLuOWjTV+oMOVftWTCcA+zT01GE69cRNZ0aeDMkcTG32aAULTN1pJkimB3/Q+xtKeKLgtf
X-Received: by 2002:a63:9f19:: with SMTP id g25mr3949650pge.327.1549982464222;
        Tue, 12 Feb 2019 06:41:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549982464; cv=none;
        d=google.com; s=arc-20160816;
        b=uE5i7b52GuMWOhjkXC+frvcy29tYBW1vpFAawWoEKLCf6gJPc5aBb8vATbax5jXE02
         Cl77PGhKeBKQdJ+rZPBI471etMZPn9ARzo7RDhJmThOFC5mvGVY82k5wQ+YkzALACvU/
         c2onKG3rot/vGXmk0+uB69CDxlH4XtiP030K+v+9B40IQQJiTuBT6G2TqJcwkSivxH9L
         T3LE0B4bLjwXbvgpGIno0mufY2mFdaAjQGzwG9OjleTPqTRTje37ujwCOIHjNWlL+VY2
         jxtKyB1jW5rxAfTlKk8evU6bsEAF259n+A78dGaLtjtRC/xREM4PSYvI4uUKiP9t0aL7
         WhvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=dbX/YXLo6Xa1YFpN4EFI1rekgVsrdlB17Tc9ubbErvU=;
        b=HW00XWYYgQNIhddIai4L1K2VWmNBedeu5x/8pKKmAUisrUL580tSTJpYEQwET3WorF
         shbD2GV+F55OTK8Xc5HdIDY1s4lxgx9H1siqeZlynHn6fvN5hOvvCdYVhV16B6aOaiT0
         djtP4F/Y4TrWQZjB4euiP5DYu3wvc1jlWUD88yuJyOj/9WOIHRxstioDLPcIhBz2nuOX
         ohJw1P4wPmv7fTP/Ii9e81XyUz1mt3PUnf5OHfl+04tfQy8OtPQUL2JMDk6+K1mAhRqF
         Guf3zy7pCsbyRXtIs+v62a+FNXnpXOCUAqqpKZw3KM0xcykTge7AEn/mvgM9fvhY1/fK
         duEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l11si11767125pgq.12.2019.02.12.06.41.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 06:41:04 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1CEdbEG108036
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:41:03 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qkx4snsxc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:41:03 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 12 Feb 2019 14:40:58 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 12 Feb 2019 14:40:56 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1CEetRV51707922
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 14:40:55 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 14FDA5205A;
	Tue, 12 Feb 2019 14:40:55 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.59.139])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 83CC752051;
	Tue, 12 Feb 2019 14:40:54 +0000 (GMT)
Date: Tue, 12 Feb 2019 16:40:52 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
        Helge Deller <deller@gmx.de>, linux-parisc@vger.kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] parisc: use memblock_alloc() instead of custom
 get_memblock()
References: <1549979990-6642-1-git-send-email-rppt@linux.ibm.com>
 <20190212141418.GM12668@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212141418.GM12668@bombadil.infradead.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021214-0016-0000-0000-000002558FC0
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021214-0017-0000-0000-000032AFB1EE
Message-Id: <20190212144052.GB20902@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-12_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=894 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902120106
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 06:14:18AM -0800, Matthew Wilcox wrote:
> On Tue, Feb 12, 2019 at 03:59:50PM +0200, Mike Rapoport wrote:
> > -static void * __init get_memblock(unsigned long size)
> > -{
> > -	static phys_addr_t search_addr __initdata;
> > -	phys_addr_t phys;
> > -
> > -	if (!search_addr)
> > -		search_addr = PAGE_ALIGN(__pa((unsigned long) &_end));
> > -	search_addr = ALIGN(search_addr, size);
> > -	while (!memblock_is_region_memory(search_addr, size) ||
> > -		memblock_is_region_reserved(search_addr, size)) {
> > -		search_addr += size;
> > -	}
> > -	phys = search_addr;
> 
> This implies to me that the allocation will be 'size' aligned.
> 
> >  		if (!pmd) {
> > -			pmd = (pmd_t *) get_memblock(PAGE_SIZE << PMD_ORDER);
> > +			pmd = memblock_alloc(PAGE_SIZE << PMD_ORDER,
> > +					     SMP_CACHE_BYTES);
> 
> So why would this only need to be cacheline aligned?  It's pretty common
> for hardware to require that pgd/pud/pmd/pte tables be naturally aligned.
> 
> > @@ -700,7 +683,10 @@ static void __init pagetable_init(void)
> >  	}
> >  #endif
> >  
> > -	empty_zero_page = get_memblock(PAGE_SIZE);
> > +	empty_zero_page = memblock_alloc(PAGE_SIZE, SMP_CACHE_BYTES);
> 
> ... and surely the zero page also needs to be page aligned, by definition.
 
Right, I've completely missed the alignment. Will fix.

-- 
Sincerely yours,
Mike.

