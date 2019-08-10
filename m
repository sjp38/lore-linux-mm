Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69352C32751
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 14:21:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F23B2086A
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 14:21:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F23B2086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D83F6B0007; Sat, 10 Aug 2019 10:21:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 861756B0008; Sat, 10 Aug 2019 10:21:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72A5D6B000A; Sat, 10 Aug 2019 10:21:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB8F6B0007
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 10:21:20 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y66so63317901pfb.21
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 07:21:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent:message-id;
        bh=R4OaXysmowMPMXTWZaVZae8mYlUzCJYr61J7aJrASso=;
        b=Nygxyd+FefMa4LEv2TezCXdf2Dr63InW6Y96lEcbXTAc4Yy9UojXjW5r5c1fEHY/1B
         b6qoHG0HbHquIGmzfwvbF2QoDYDL+ygHPIud40erMAASVYkThsWY0Y3PWRO9v5UlYX8M
         eyh636AXKZYL88g2sh3phPwpCK88M6QEIUfyfnAKrGUUxCTl4Ny0BesI7jJ3Mlndfruv
         1Z+17MVaz5FBI/CEYlrAo0TjLRDeINyaSQ9hOH0qzQjAb656BVrlvG4C/WTtrr7GLWZt
         IoxuBMIIV5d7PHKYWPLUb/pmb08LPBscpN/QG0lvQg8hFZu5AOtTtEWHCfTmxJfk6x3K
         2aNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWtbDCDvtiAq2qN1UbSv6vg7vOjWGrinXJFlQWg72Iyv00JIs4V
	eQxHKzuzmbTHdlcYZ6yyvi+YQOw83OEyV39zA5OrGLCmSDeVAPPmrN9EcoZPKqInbpvWg2SliQ6
	j618IMRVVTGX+hHdBF6WuA9zq0XPXd9OxIjxpdXoVqFUBR6axrNTYDMlXZaKjnNQ88A==
X-Received: by 2002:a17:90a:1c17:: with SMTP id s23mr14841360pjs.108.1565446879895;
        Sat, 10 Aug 2019 07:21:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3xEMuUGpm7VAI0/gUVdIuXe1+AdNyUeRKEkRuSwIGvCoMVJ5USyWFevKf2Wynx1sTbePt
X-Received: by 2002:a17:90a:1c17:: with SMTP id s23mr14841302pjs.108.1565446879038;
        Sat, 10 Aug 2019 07:21:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565446879; cv=none;
        d=google.com; s=arc-20160816;
        b=qpl4gpbQhNHPT9KNqWB5P7TSS3KkBzg/QPYzRkdTbIx0/lnJnlww2hF/6JqMFYKKPt
         k8DTn0+MYUO1kkYA9hFG+ZQvD7IhRKKHgC2B+BJSw3f+36gO1T+IAh+Y93vMPc80egKc
         5hEudH336viz0X8t700POj71Gt7NRWeU/uLpsk+ad8XJIPx6XLbOEj3YRTwaA7OE1oQt
         AXMJCFVORLpZ7ZuR6GFOMODt/xB7YRFfzSjtfLgSAEOCjL8KOSuBdRQJh1Xk9DZFnuXb
         eEQvEHKGBGDKY59fYIdHsrtT8pti+moUBYDcZ/8XwsYkHYGpD4uuRqopID0UbXwpU+do
         0rWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:reply-to:subject:cc:to:from:date;
        bh=R4OaXysmowMPMXTWZaVZae8mYlUzCJYr61J7aJrASso=;
        b=0azfQXr5EAm9alVifXQRB0mXcTODj0BXwP+2solLT5Sb74MB3sdYEb2iL/tsmcQiDw
         WlNqOKVSusi2lMm5MG9BdrEYMfze4l2Z9K2U/joxwdwpABaYg+ZXQx9oXR8XdmWSTi0y
         Edk66l9bbWJpsxPE1OxvDMXJ+5pVg6K3R0BDUN/iHayQycn4KkSYbmAi2CCqMnwxXnas
         SI/xQ1E9dkAVb65tBZuxAKa8JS5XZ9C4T1OUUkEzBqYRaF/qeO8YhHElEaByioLg/5T+
         4LenDhh3z3/GUyxVRksJB9kL6E6LGsbemzBxQ/1jwVZ4AqNX4H2K7xWwp5USJ87WuHaj
         4XzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b14si56707273pgi.587.2019.08.10.07.21.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Aug 2019 07:21:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bharata@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=bharata@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7AEGeMg058946
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 10:21:18 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2u9t38ysk0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 10:21:17 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Sat, 10 Aug 2019 15:21:15 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sat, 10 Aug 2019 15:21:12 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7AELAKR49283154
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 10 Aug 2019 14:21:10 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 9F220AE055;
	Sat, 10 Aug 2019 14:21:10 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D63C1AE045;
	Sat, 10 Aug 2019 14:21:08 +0000 (GMT)
Received: from in.ibm.com (unknown [9.199.47.133])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Sat, 10 Aug 2019 14:21:08 +0000 (GMT)
Date: Sat, 10 Aug 2019 19:51:06 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Christoph Hellwig <hch@lst.de>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, sukadev@linux.vnet.ibm.com,
        cclaudio@linux.ibm.com
Subject: Re: [PATCH v6 1/7] kvmppc: Driver to manage pages of secure guest
Reply-To: bharata@linux.ibm.com
References: <20190809084108.30343-1-bharata@linux.ibm.com>
 <20190809084108.30343-2-bharata@linux.ibm.com>
 <20190810105819.GA26030@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190810105819.GA26030@lst.de>
User-Agent: Mutt/1.12.0 (2019-05-25)
X-TM-AS-GCONF: 00
x-cbid: 19081014-4275-0000-0000-000003577F07
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19081014-4276-0000-0000-0000386988C0
Message-Id: <20190810142106.GB28418@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-10_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908100159
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 10, 2019 at 12:58:19PM +0200, Christoph Hellwig wrote:
> 
> > +int kvmppc_devm_init(void)
> > +{
> > +	int ret = 0;
> > +	unsigned long size;
> > +	struct resource *res;
> > +	void *addr;
> > +
> > +	size = kvmppc_get_secmem_size();
> > +	if (!size) {
> > +		ret = -ENODEV;
> > +		goto out;
> > +	}
> > +
> > +	ret = alloc_chrdev_region(&kvmppc_devm.devt, 0, 1,
> > +				"kvmppc-devm");
> > +	if (ret)
> > +		goto out;
> > +
> > +	dev_set_name(&kvmppc_devm.dev, "kvmppc_devm_device%d", 0);
> > +	kvmppc_devm.dev.release = kvmppc_devm_release;
> > +	device_initialize(&kvmppc_devm.dev);
> > +	res = devm_request_free_mem_region(&kvmppc_devm.dev,
> > +		&iomem_resource, size);
> > +	if (IS_ERR(res)) {
> > +		ret = PTR_ERR(res);
> > +		goto out_unregister;
> > +	}
> > +
> > +	kvmppc_devm.pagemap.type = MEMORY_DEVICE_PRIVATE;
> > +	kvmppc_devm.pagemap.res = *res;
> > +	kvmppc_devm.pagemap.ops = &kvmppc_devm_ops;
> > +	addr = devm_memremap_pages(&kvmppc_devm.dev, &kvmppc_devm.pagemap);
> > +	if (IS_ERR(addr)) {
> > +		ret = PTR_ERR(addr);
> > +		goto out_unregister;
> > +	}
> 
> It seems a little silly to allocate a struct device just so that we can
> pass it to devm_request_free_mem_region and devm_memremap_pages.  I think
> we should just create non-dev_ versions of those as well.

There is no reason for us to create a device really. If non-dev versions
of the above two routines are present, I can switch.

I will take care of the rest of your comments. Thanks for the review.

Regards,
Bharata.

