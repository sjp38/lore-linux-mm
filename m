Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7400FC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:54:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33DCD23426
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 14:54:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33DCD23426
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BAC36B0010; Tue,  4 Jun 2019 10:54:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 96C486B0269; Tue,  4 Jun 2019 10:54:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 80D0F6B026B; Tue,  4 Jun 2019 10:54:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 65BEB6B0010
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 10:54:38 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id g203so19727030ywe.21
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 07:54:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=xDbVH/hVzZYVarLEZ+hSN1ZKRVgwKyT8PP8peuYVMfI=;
        b=tOqP6WWso1tDBnJDrcKpJTRP0y8+iyFHRMZmP5DjG/CRhDI0TqWhbNlANfvDBh+565
         Ece2fdbl8v2kz98/M46KMsoWmdiMhrW2ED3xCphOQbUPVq8Xmr9qSvfmpXsjCTsZYZG4
         WoTt956yBOMF5tHiT9FUDCglhuEK7hIE6w/MXH7lT5u9725Ahz40ebL/xWUMUh8OjBbG
         6rhMu7UlrI2tjFMngdzKpJF8iJ299aT+WNMrZHc6QkM6bUVLIILQzcL73qEG25fiJ6iZ
         Qa3Uf29BhxeGGGA6vuJPdUUou1fyaS4WHT+aw5THVR6m4O4eyWQP8WTNi8nnyunGWzJP
         UPsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVNDloSfxTIoJO59y4+Cj/ZeFCDSWimSGH5jbbnk1qQokcZsgaD
	rti4Fp2a6mQ1nrHBD0yvaxtjN/xw0P9gH9BuHn6AGESNtIkwbMF1UZ6w+dxXVKZixiBu8veT3lv
	tI+wdAdSqoJCZzmPTRzqN5M1YVNPyFQ99MbIwu5mQrzArI9+0zjR7qdJcBKzaJ9+gNw==
X-Received: by 2002:a25:dac8:: with SMTP id n191mr15244261ybf.425.1559660073964;
        Tue, 04 Jun 2019 07:54:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3+9A1IvL4aXenwIsKZmnLR07B4A0oSPd9Ey5PmM1mwW7W69nkSTLS7Q8Xn9eBlS5PVXIw
X-Received: by 2002:a25:dac8:: with SMTP id n191mr15244233ybf.425.1559660073245;
        Tue, 04 Jun 2019 07:54:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559660073; cv=none;
        d=google.com; s=arc-20160816;
        b=o+qlmor9+jA/G87pX9L7fvwgLfdR3rYFX6hbHY729QkdUOA2/4eqGhfSFckQ11YN58
         +VvaV0Id/BM6WCBq04180cFcSaC4UPPzehEXrxPL/jFlzfkrpV3PA2o3muJIvSjn5B3U
         lW0JUpGai1xvqLrz/lUh2DSySPipEfkrsS9V2iX37YtukNArDPXaMD3snHarXInv0pOz
         2Aztr+yThU7UzNgzKZbpOQ461e330WG9yIEZ8Ww7MrXHSeOku4fQTNh6c8bqgJ5ri6g/
         +aV8ksdOJi5oxizfRGvcW3t5kgUcnnIzBMDk+XRTZXwj378HPo9D5mgO64WFwSVI3dp4
         XPZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=xDbVH/hVzZYVarLEZ+hSN1ZKRVgwKyT8PP8peuYVMfI=;
        b=IsvsIZafOPjwH17MYmZsnEOfD5m1raAgDuEtVkqdgUWfVwN21LgmjI/IobuZ0Se0bC
         Q5+h2kUgbnDByGPDgXnfSxFam2UaFwbNUJqptoSChU7oVyojqIzzxg5+aYIR4fyFh+8N
         oFKS5xudp0ohWFm9Rx38FlehaoPlVoPONILdImjttUBt07M/sKGzfM5buKkVT8+aHZSg
         quFGJCpI7v5mbSGhRnlt5Ja2dBgVG746jU+P+5BxF7sMjQRs2XdTcjhyCTbFtc5vaF33
         Kssr+6JFEuIALiALchiwAsUHkbVTxinPWUgugcJ50itTJKyCUGXeh7718KuPHAfQyXB7
         HTHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s8si1148467ybo.446.2019.06.04.07.54.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 07:54:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x54EdNna025645
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 10:54:32 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2swrv869k3-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 10:54:32 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 4 Jun 2019 15:54:30 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 4 Jun 2019 15:54:26 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x54EsPk160882980
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 4 Jun 2019 14:54:25 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A5A23AE045;
	Tue,  4 Jun 2019 14:54:25 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A6587AE055;
	Tue,  4 Jun 2019 14:54:24 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.8.53])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue,  4 Jun 2019 14:54:24 +0000 (GMT)
Date: Tue, 4 Jun 2019 17:54:22 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, catalin.marinas@arm.com,
        will.deacon@arm.com, linux-kernel@vger.kernel.org, mhocko@kernel.org,
        linux-mm@kvack.org, vdavydov.dev@gmail.com, hannes@cmpxchg.org,
        guro@fb.com, cgroups@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
 <20190604142338.GC24467@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604142338.GC24467@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19060414-4275-0000-0000-0000033CA09A
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19060414-4276-0000-0000-0000384CB014
Message-Id: <20190604145422.GG8417@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-04_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=7 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906040097
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 03:23:38PM +0100, Mark Rutland wrote:
> On Tue, Jun 04, 2019 at 10:00:36AM -0400, Qian Cai wrote:
> > The commit "arm64: switch to generic version of pte allocation"
> > introduced endless failures during boot like,
> > 
> > kobject_add_internal failed for pgd_cache(285:chronyd.service) (error:
> > -2 parent: cgroup)
> > 
> > It turns out __GFP_ACCOUNT is passed to kernel page table allocations
> > and then later memcg finds out those don't belong to any cgroup.
> 
> Mike, I understood from [1] that this wasn't expected to be a problem,
> as the accounting should bypass kernel threads.
> 
> Was that assumption wrong, or is something different happening here?

I was under impression that all allocations are going through
__memcg_kmem_charge() which does the bypass.

Apparently, it's not the case :(

> > 
> > backtrace:
> >   kobject_add_internal
> >   kobject_init_and_add
> >   sysfs_slab_add+0x1a8
> >   __kmem_cache_create
> >   create_cache
> >   memcg_create_kmem_cache
> >   memcg_kmem_cache_create_func
> >   process_one_work
> >   worker_thread
> >   kthread
> > 
> > Signed-off-by: Qian Cai <cai@lca.pw>
> > ---
> >  arch/arm64/mm/pgd.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
> > index 769516cb6677..53c48f5c8765 100644
> > --- a/arch/arm64/mm/pgd.c
> > +++ b/arch/arm64/mm/pgd.c
> > @@ -38,7 +38,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
> >  	if (PGD_SIZE == PAGE_SIZE)
> >  		return (pgd_t *)__get_free_page(gfp);
> >  	else
> > -		return kmem_cache_alloc(pgd_cache, gfp);
> > +		return kmem_cache_alloc(pgd_cache, GFP_PGTABLE_KERNEL);
> 
> This is used to allocate PGDs for both user and kernel pagetables (e.g.
> for the efi runtime services), so while this may fix the regression, I'm
> not sure it's the right fix.

Me neither.
 
> Do we need a separate pgd_alloc_kernel()?
 
I'd like to take a closer look at memcg paths once again before adding
pgd_alloc_kernel().

Johannes, Roman, can you please advise anything?

> Thanks,
> Mark.
> 
> [1] https://lkml.kernel.org/r/20190505061956.GE15755@rapoport-lnx
> 

-- 
Sincerely yours,
Mike.

