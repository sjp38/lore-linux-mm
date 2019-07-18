Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C743BC76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:26:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 83EDE204FD
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 06:26:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83EDE204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 297426B000C; Thu, 18 Jul 2019 02:26:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 222418E0003; Thu, 18 Jul 2019 02:26:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09A7C8E0001; Thu, 18 Jul 2019 02:26:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5DE86B000C
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:26:21 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a21so9234868pgv.0
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 23:26:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=jPGhX+/Z0nbq38Tjjof8qt4T5daU7biLJaz7DkaR4d0=;
        b=BCSt0lNfbydWLoPCb2fJDI/S/NM4BpwjalyXF+ns6iIQzpSrh2/foPITWxnolFt8kY
         QCuKGNUdb4lB8uRumHZvOoI9Px9rxqJtK0/WV9o6kCvceeZQNT2Gn9i6dM82SrlYn2C/
         nJhwc05u/nlpQSFf7lWgUG53PJLd9WtL7cDSzA3uBU6QngGt9ZBjOpB3SXeQVv9z6igW
         4A6DHY+tsCENI8Q74DPItEgikFHaTykLQYogW5cqjj5hs844cwQZ9LYmhtjLvHWHKVMy
         eWToxvSjr/PTOicBb/eSIVqKpEKQUij3M28LONsuJidk1F+fjhCP+SxhNa1Toz6bm8kG
         1VNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWwp19L7cHGBZZO3b7EtQ5CoDc7R+mrh6CsoHiyYj6ngfQVMT/q
	uVN3PYENi42rUNENWp3zEVL6Rfci+MoiqauzWkm9jo82NhwOio7MsyOCaLYgLI+vFfPx+lDqUEw
	kWrEV5U/Bpt66iIDQO0nmjsvJ5mGgnkf4oXJhIj9KLJEA2hB2Lgu1QDCAjWRBpe820w==
X-Received: by 2002:a17:90a:b011:: with SMTP id x17mr49539201pjq.113.1563431181464;
        Wed, 17 Jul 2019 23:26:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzjkTlzWLTf3QP1lvxwRfp+pbxIp4bl7gj2QtSxGYn+H2zJz4RIBCQwgKC3gaau75NbbWr8
X-Received: by 2002:a17:90a:b011:: with SMTP id x17mr49539151pjq.113.1563431180717;
        Wed, 17 Jul 2019 23:26:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563431180; cv=none;
        d=google.com; s=arc-20160816;
        b=YntZ5sFcFQYs7LPbaqEa+LzXsoNLFQ+MfvBTEHtfc4RFEEBxaa2VrRd3nKpo43A28+
         IcDv+xmOFytIobsOTPCXofNqvWTiB8T0APWhl5RG5DrPsJBCxp0VSorUurAitcyog5Zd
         Xcm9UeivccASfqIFjAUiRTzNQl614gRoQWw5M2wI9xcS26zlo9UYrW4SNGW7vZJhfM9q
         ISJzhH0zp96yxKeW3nZsnQxx7gbPN23aStclMSbsFCWGZIoRnSudaE0d2z8Dh29XaeuC
         KwHVMd5TI7BG+H1h/j7gneREKxH7Rh6So110S+E1+CYuSoqWmSPLkKM0YQCoZACTCKlJ
         7RKw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=jPGhX+/Z0nbq38Tjjof8qt4T5daU7biLJaz7DkaR4d0=;
        b=TQ++keoq7RSJwxLm38JyZAcNu+lpwGaUUp0pxFfKXACtwbVERUoKOTb956fQ3Sx5ME
         2tvzmcEDtU3mye/NKxGYVfKkkARjbnbfCWPRKaBojIzRlMPtonulsjMJjVlLVzgN8Jfp
         KJAkzjqbNQMLSi3ZAKUcJgkIVD5H2XhPgE/nysWJjsUGZ7c9sm9SIQFenoUf0QLo1ugM
         jvBtP+8JFzP34xS7qM41U04BjYap2zcp4pBCF39AmZgDlPftWsGNpqr0/19Udx2bk9MU
         qejgg1LE7tP6OuEv7PRr7e7TkVtCJVFAetSuUBhCdTKOTxm8RGxOS9d+0N8ThlG4izFo
         rL8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d10si888431pgo.359.2019.07.17.23.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 23:26:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6I6N3kU034176
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:26:20 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ttj82bekw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 02:26:19 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 18 Jul 2019 07:26:17 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 18 Jul 2019 07:26:13 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x6I6QCkb43516064
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 18 Jul 2019 06:26:12 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 20EC7AE045;
	Thu, 18 Jul 2019 06:26:12 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 3192AAE053;
	Thu, 18 Jul 2019 06:26:11 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.168])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 18 Jul 2019 06:26:11 +0000 (GMT)
Date: Thu, 18 Jul 2019 09:26:09 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Leonardo Bras <leonardo@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki" <rafael@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@oracle.com>,
        =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [PATCH 1/1] mm/memory_hotplug: Adds option to hot-add memory in
 ZONE_MOVABLE
References: <20190718024133.3873-1-leonardo@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190718024133.3873-1-leonardo@linux.ibm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19071806-0016-0000-0000-00000293E773
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19071806-0017-0000-0000-000032F1C1E3
Message-Id: <20190718062608.GA20726@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-18_02:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1907180072
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 17, 2019 at 11:41:34PM -0300, Leonardo Bras wrote:
> Adds an option on kernel config to make hot-added memory online in
> ZONE_MOVABLE by default.
> 
> This would be great in systems with MEMORY_HOTPLUG_DEFAULT_ONLINE=y by
> allowing to choose which zone it will be auto-onlined
 
Please add more elaborate description of the problem you are solving and
the solution outline.


> Signed-off-by: Leonardo Bras <leonardo@linux.ibm.com>
> ---
>  drivers/base/memory.c |  3 +++
>  mm/Kconfig            | 14 ++++++++++++++
>  2 files changed, 17 insertions(+)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index f180427e48f4..378b585785c1 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -670,6 +670,9 @@ static int init_memory_block(struct memory_block **memory,
>  	mem->state = state;
>  	start_pfn = section_nr_to_pfn(mem->start_section_nr);
>  	mem->phys_device = arch_get_memory_phys_device(start_pfn);
> +#ifdef CONFIG_MEMORY_HOTPLUG_MOVABLE
> +	mem->online_type = MMOP_ONLINE_MOVABLE;
> +#endif

Does it has to be a compile time option?
Seems like this can be changed at run time or at least at boot.
  
>  	ret = register_memory(mem);
>  
> diff --git a/mm/Kconfig b/mm/Kconfig
> index f0c76ba47695..74e793720f43 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -180,6 +180,20 @@ config MEMORY_HOTREMOVE
>  	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>  	depends on MIGRATION
>  
> +config MEMORY_HOTPLUG_MOVABLE
> +	bool "Enhance the likelihood of hot-remove"
> +	depends on MEMORY_HOTREMOVE
> +	help
> +	  This option sets the hot-added memory zone to MOVABLE which
> +	  drastically reduces the chance of a hot-remove to fail due to
> +	  unmovable memory segments. Kernel memory can't be allocated in
> +	  this zone.
> +
> +	  Say Y here if you want to have better chance to hot-remove memory
> +	  that have been previously hot-added.
> +	  Say N here if you want to make all hot-added memory available to
> +	  kernel space.
> +
>  # Heavily threaded applications may benefit from splitting the mm-wide
>  # page_table_lock, so that faults on different parts of the user address
>  # space can be handled with less contention: split it at this NR_CPUS.
> -- 
> 2.20.1
> 

-- 
Sincerely yours,
Mike.

