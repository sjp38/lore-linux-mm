Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2AFAC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 11:50:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BB43206A3
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 11:50:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BB43206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C4AA6B0005; Tue,  7 May 2019 07:50:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8747C6B0006; Tue,  7 May 2019 07:50:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 762D66B0007; Tue,  7 May 2019 07:50:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 528D26B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 07:50:06 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id k10so6957352ywb.18
        for <linux-mm@kvack.org>; Tue, 07 May 2019 04:50:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:mime-version:message-id;
        bh=P3ALw+vzCWjW7ktXAbz1G3WvIMbkt26m78wjtEzUhj4=;
        b=qMM4oM2D2GD1GnxepuFFZ3cxMJ11RLtH13nH968/n5P2Tzlk2Jk8afLqpGeL1yfrA+
         xnPp+EwMpMyOoLYQ4yDhHsdmuVRqe+hdGUU+kzgyyH/o4bI7zk1hTncXSQmh7+WDbiHv
         PCOzl2i78WagC7+rN6GOj0orocgSWFSfiPpG7DVbucziOlymwekNx7UygqrHLClvR3GK
         v7ixbOJ0n2NZo2pbrIC5wG9ApC4jwb/Kr3ftluoPLgZ17lger3b0mBWobuqxudw4VIYo
         1vKySy89tdb47ZyUTEJBQJKzt8fKfprSEPqJhgU4/nD6jADQITy5bgYayR/lngPEGJBg
         RGJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW8ZgR7h65k8Zue3IpoO/7g6JFNCb6TL5V2zXG+xpoKSQ/MEWBQ
	H7/3IcseZcezQGQ/3EpdERG24Z7BiH4ykiwZoakk8NvyKnI0+5ZSuLhWrOb9ylySs75PQ9nDHL5
	BdZ4MYCZRQ2un1oqPC7X3JT24fb/53Vgf54wTnCwrfw+NsIXfFA+uDFlWIjon1S4AkQ==
X-Received: by 2002:a25:2f49:: with SMTP id v70mr11140133ybv.370.1557229806009;
        Tue, 07 May 2019 04:50:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjL3gxJhFsMxfn073AlhtxC3VivqOoHLcGmI5ZO57LoKlwVwmG0ZyP5xs19qWKJSuUPIIq
X-Received: by 2002:a25:2f49:: with SMTP id v70mr11140102ybv.370.1557229805354;
        Tue, 07 May 2019 04:50:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557229805; cv=none;
        d=google.com; s=arc-20160816;
        b=0PMyJpU4JmLEm1AvakOonkHodiRQn8K6kHhyBsarXENAbW1Px/48g46Gya5iGVQPjm
         aXz3vGX+DKFLpfaA+TBVHvh0EKm/MTnXK6aHAhozHPtCsQER6QKD9fb3Ln8YFMD2GwUI
         Ge15hIfPgVTpT2eYO8sLuaEho61DZUEV/shIf6z8HbWJS5TSWM/Q7gmcKXnj7BUD4gLk
         6n2ybokSwnees+3WsyJGICSUD11UGMbQ1ZhMvtV1KPU7d6f1MA0d+8YlhiyQ1iEwp+6v
         XrNRk0EiQnh3mSrT2dJqcSLxor+MCAxt3d9hH0YsAU4Fks4k51+obIhLeRpxTM17hyjF
         G3eQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:mime-version:date:references:in-reply-to:subject:cc:to
         :from;
        bh=P3ALw+vzCWjW7ktXAbz1G3WvIMbkt26m78wjtEzUhj4=;
        b=mpIKasq4T6W8sB7pRn9iGfCUMJpB+Mk61NozvjZ5FwuY8K+nYbbHrolTTBA6qBWs45
         c0Q0QYX9UsNaSO0GIi701YE4Hy6wmB9AzbCNwhL8LaA7lGzcWCJC5VRxvuLq+Pjy1Gt6
         De3TFfOwO6kcVQ8Ehk9PulPL0Fx0H6qMbSExpDJoUu8qB70ITKxJnBzSOza+DRKmZl6q
         ZpPSOSYIfDRvKI9HACvSQpS2txzdjJC1ohuQLyCIvW7cfYXr2P6fNP1MNSsdye4TNAUK
         e0OADE6wxgWrghBAa65hqH2JZGeRxQzQbKbzH5JIG0pDoLBXYAINnj0AaFeHESv4e8ii
         JwSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id x3si6342336ywc.23.2019.05.07.04.50.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 04:50:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aneesh.kumar@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=aneesh.kumar@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x47Bm9Hc088674
	for <linux-mm@kvack.org>; Tue, 7 May 2019 07:50:04 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2sb9dj06cu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 May 2019 07:50:04 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Tue, 7 May 2019 12:50:01 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 7 May 2019 12:49:58 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x47Bnvdq62652642
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 7 May 2019 11:49:58 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id D5DAAAE051;
	Tue,  7 May 2019 11:49:57 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 01B7DAE04D;
	Tue,  7 May 2019 11:49:57 +0000 (GMT)
Received: from skywalker.linux.ibm.com (unknown [9.85.196.155])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue,  7 May 2019 11:49:56 +0000 (GMT)
X-Mailer: emacs 26.1 (via feedmail 11-beta-1 I)
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
To: dan.j.williams@intel.com
Cc: linux-nvdimm@lists.01.org, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v2] drivers/dax: Allow to include DEV_DAX_PMEM as builtin
In-Reply-To: <20190401051421.17878-1-aneesh.kumar@linux.ibm.com>
References: <20190401051421.17878-1-aneesh.kumar@linux.ibm.com>
Date: Tue, 07 May 2019 06:49:55 -0500
MIME-Version: 1.0
Content-Type: text/plain
X-TM-AS-GCONF: 00
x-cbid: 19050711-0028-0000-0000-0000036B2C6B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19050711-0029-0000-0000-0000242AA536
Message-Id: <87pnoumql8.fsf@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-07_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1011 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=939 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905070078
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hi Dan,

"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:

> This move the dependency to DEV_DAX_PMEM_COMPAT such that only
> if DEV_DAX_PMEM is built as module we can allow the compat support.
>
> This allows to test the new code easily in a emulation setup where we
> often build things without module support.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>

Any update on this. Can we merge this?

> ---
> Changes from V1:
> * Make sure we only build compat code as module
>
>  drivers/dax/Kconfig | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/dax/Kconfig b/drivers/dax/Kconfig
> index 5ef624fe3934..a59f338f520f 100644
> --- a/drivers/dax/Kconfig
> +++ b/drivers/dax/Kconfig
> @@ -23,7 +23,6 @@ config DEV_DAX
>  config DEV_DAX_PMEM
>  	tristate "PMEM DAX: direct access to persistent memory"
>  	depends on LIBNVDIMM && NVDIMM_DAX && DEV_DAX
> -	depends on m # until we can kill DEV_DAX_PMEM_COMPAT
>  	default DEV_DAX
>  	help
>  	  Support raw access to persistent memory.  Note that this
> @@ -50,7 +49,7 @@ config DEV_DAX_KMEM
>  
>  config DEV_DAX_PMEM_COMPAT
>  	tristate "PMEM DAX: support the deprecated /sys/class/dax interface"
> -	depends on DEV_DAX_PMEM
> +	depends on m && DEV_DAX_PMEM=m
>  	default DEV_DAX_PMEM
>  	help
>  	  Older versions of the libdaxctl library expect to find all
> -- 
> 2.20.1

