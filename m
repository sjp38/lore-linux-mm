Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BCBACC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 21:30:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75C4B21900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 21:30:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75C4B21900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BBDF6B0006; Fri, 22 Mar 2019 17:30:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14AB06B0007; Fri, 22 Mar 2019 17:30:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8EE36B0008; Fri, 22 Mar 2019 17:30:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A5FFD6B0006
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 17:30:49 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z14so3311408pgv.0
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 14:30:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=sZ9EI/gHJ7LKf1LtjqfukTdkZdsh0ZWTKCVRiRaAPoY=;
        b=Fs8y1qT125iVi+cKU1Si3t40BMvbuEmJxFm+tO/JMPRTQW8YBPXz6BQ8d2RepCkXsv
         Q+7dOOa35RM7r3bBEjEwUOGVbL5k4xymphduhROnRj+JywRl9mzC1hYceX1gMR9wMDmE
         zP0hNBluNZfHuiyF+hmF5GQNroFrYj+bUOXq7TTB/wp1yanfOI6fowNj/AmjlfqA7ZyX
         wKxg/SqdT0uw/kiI5ehgZKLYgLhJCOBddg/gNK0YcQ91yZ465aoytGMAHDAiygyvfAxK
         rw/oPapwg1mr/xb/n2MZvVequx5OipWjOeg4aXq16pMESB1WPffXq2ylAhdcKmR9EQ1O
         q5rQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAUPvDLgxAizO8SvjAWtz/IUjUVqivSc5WuMnFDO2zYsIXcBwcpZ
	yPQmo52c5wmAOz1Hhypo1d/JeaGJWWpHsIlyhSOe4zVIc6vZEZasY6NYvFq5Wc34vqnqXH50t5n
	YLBlcyGNeLzjiSjj7ywCIq2MbWPewCIteaRAYdj2sRl1r6qWh8hbvJsd6d92YtIofrg==
X-Received: by 2002:a62:7042:: with SMTP id l63mr11208205pfc.1.1553290249363;
        Fri, 22 Mar 2019 14:30:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxEgWDyYZ9dKGYCtuJ+fsg7t3Kz5NEw9mmWqspLUrkCrosbna6AsMV+WYnrZcRcEmqC/YSy
X-Received: by 2002:a62:7042:: with SMTP id l63mr11208140pfc.1.1553290248631;
        Fri, 22 Mar 2019 14:30:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553290248; cv=none;
        d=google.com; s=arc-20160816;
        b=N620p87YWo3JXRuMzUAQndXfZRemQ5aqe/th0kpyPqR50LALtyR3eKx8938RKP0fOq
         pKmKXPF/fXpEt5HOjR0qk+USeFIe5IRQkFLkh0PEd9u84JVhIfjqtQvUEMX11TAN92f2
         YuogOItMqseccUyOAIAot8xX+Aw66ZpichYnX53ZU5es7oV39Ud9tQtb0W8XN1wVYfT4
         6BtD8BAGzKzJfIS1XlxUCZWMpehlEmQEjW3LHo/6BlXgbElZ3x676y4lSfS4rKo2AwVY
         Dh64rOYiQULAcFj02ie7VRz9ayfyK/Jmdw0x8xd5ufI2jC6UAtN0/gia1k7u2DwRNw3e
         xbZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=sZ9EI/gHJ7LKf1LtjqfukTdkZdsh0ZWTKCVRiRaAPoY=;
        b=ZfCc7NtU2DNgiVnsdRG7MFeW7k0YvYK9AnF0jgHjgbIG0y1/aGt6TV/oYkjnUG+Zd5
         7aRD3xeqwUX2Foc8DgQW6GZiTiYELnT/8Bju4v7E6pMIkDbGGBZYnSxXKySCVOSm6blW
         QAoOFVul0tJ3jlrwiymlGds1XmcJtNPEJwWZAy+rGCEGSal1fITHVKfr3P+unGWF5ljl
         L2XQ2g8blJQvarUwoU64ykckIF5Vkgn3g/z/ua/oJNbkdE+ZARgSQ8INgte2KGadxKV8
         UagvxMwcf5Gmy31/a44i5gSUyEAKNuuTOIuPd0qK9UnLTvnUbiyYoagKdcg6K2rUNiaN
         Ss9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l11si7653898pgc.473.2019.03.22.14.30.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 14:30:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2MLT8GK057374
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 17:30:48 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rd4sry1e9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 17:30:47 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Fri, 22 Mar 2019 21:30:35 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 22 Mar 2019 21:30:29 -0000
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2MLUcr541615510
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 22 Mar 2019 21:30:38 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 5C5FDA405B;
	Fri, 22 Mar 2019 21:30:38 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 675B8A405C;
	Fri, 22 Mar 2019 21:30:36 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.206.23])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Fri, 22 Mar 2019 21:30:36 +0000 (GMT)
Date: Fri, 22 Mar 2019 23:30:34 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Sakari Ailus <sakari.ailus@linux.intel.com>
Cc: Petr Mladek <pmladek@suse.com>, linux-kernel@vger.kernel.org,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        linux-arm-kernel@lists.infradead.org, sparclinux@vger.kernel.org,
        linux-um@lists.infradead.org, xen-devel@lists.xenproject.org,
        linux-acpi@vger.kernel.org, linux-pm@vger.kernel.org,
        drbd-dev@lists.linbit.com, linux-block@vger.kernel.org,
        linux-mmc@vger.kernel.org, linux-nvdimm@lists.01.org,
        linux-pci@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mm@kvack.org, ceph-devel@vger.kernel.org, netdev@vger.kernel.org
Subject: Re: [PATCH 1/2] treewide: Switch printk users from %pf and %pF to
 %ps and %pS, respectively
References: <20190322132108.25501-1-sakari.ailus@linux.intel.com>
 <20190322132108.25501-2-sakari.ailus@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190322132108.25501-2-sakari.ailus@linux.intel.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19032221-0016-0000-0000-0000026616B6
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19032221-0017-0000-0000-000032C13E1F
Message-Id: <20190322213034.GA9303@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-22_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903220152
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 22, 2019 at 03:21:07PM +0200, Sakari Ailus wrote:
> %pF and %pf are functionally equivalent to %pS and %ps conversion
> specifiers. The former are deprecated, therefore switch the current users
> to use the preferred variant.
> 
> The changes have been produced by the following command:
> 
> 	git grep -l '%p[fF]' | grep -v '^\(tools\|Documentation\)/' | \
> 	while read i; do perl -i -pe 's/%pf/%ps/g; s/%pF/%pS/g;' $i; done
> 
> And verifying the result.
> 
> Signed-off-by: Sakari Ailus <sakari.ailus@linux.intel.com>
> ---

For

>  mm/memblock.c                           | 12 ++++++------

Acked-by: Mike Rapoport <rppt@linux.ibm.com>

