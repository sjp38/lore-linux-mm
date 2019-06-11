Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B45C9C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:41:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5876320896
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 12:41:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5876320896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8FC16B000C; Tue, 11 Jun 2019 08:41:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B40B16B0010; Tue, 11 Jun 2019 08:41:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A07926B0266; Tue, 11 Jun 2019 08:41:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8396B000C
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:41:31 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id y3so12647626ybg.12
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:41:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent:message-id;
        bh=XBBPEEWheebAgmh5bb5/i7dtqZUifBg5osJS/QhGcSc=;
        b=HPp9Mq3LPDvD5txxS5GZvV3iHklb8+NDMESP51J2mcXzjDSGPIxwUCcKi/TSVkXdvV
         xDLjjY6JzkPJU0eFb4VdSoIaPblZDldkJH605mTThSYE52hNE/Lla19DV1gHqDVRsccq
         zaExOCtNAKriXcR/Ohw3Ot5Z5powCUVjBB2UwdbM2TipQEV8+b/t5TX2ikpM8GwRVfnF
         gKOBNxAygNbNkjvGCVT5avrHMG4Cug9xPzlJgOCgiLOPpEQHlwsAapRk+pYJUs5LWVS8
         R2xnWwI3S3dKcErSGAF+PvlFfMJWuKv4c5jS1ciLKzCpzdo8W56pWDzR21kC/fzLfVP1
         9bDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAVpOY62hKXNcSQ7YkEcF/jQfHWq1+LvKtaGHgLEclNp6speT2zJ
	Za7R8EYk9H07wWsuNZkcrO+1OjPH3uH3eTV5bmLokJ24x8kFEcaDKCm7qOiKWvxmUZI92CuMd2K
	DKpaVfSF3Uk9T97IvRCXXFKOJzZV8rmWyZJubv6ncd1tUVauDILya5v9ZNnSDviLxMw==
X-Received: by 2002:a5b:ac1:: with SMTP id a1mr32682955ybr.267.1560256891227;
        Tue, 11 Jun 2019 05:41:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgiYZu8TJbAw6c7LBmjBqf79oXR0HP6uJH50rLTu9vlLBgKo2k8od5S1NZVO/lYhDOLsvM
X-Received: by 2002:a5b:ac1:: with SMTP id a1mr32682929ybr.267.1560256890534;
        Tue, 11 Jun 2019 05:41:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560256890; cv=none;
        d=google.com; s=arc-20160816;
        b=jyaj051cEotUWYuLKsglwbJLXMgo6VrYdgTL1goysn+7RIvfRHXSotWARb3tm9CiR2
         AHXwGECwlrdEN9F3nh92R9NkM1D9GEP3oohFcoUEldT1H2ab7/CGM67o/9uSpvGduDSW
         gd45g66DkVl1Ai6jSzueD0A+lcBR+Po2u83jwy9vCClBfvuwMlw46F4ppYDD2y3KdAQQ
         8angNYgSh3uURxBQ0VcD/Pj8L7Uke73DVF6tVQVFC2X1AEB/UqdTNkocy//oscnYAXOw
         kg2/KYQb3ZSvBybvA0c1PU5fgrKndkldx0fpt8AWEeFnn3dBBDD/Yy3y/sfzuC0oiLBr
         nNzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:subject:cc:to:from:date;
        bh=XBBPEEWheebAgmh5bb5/i7dtqZUifBg5osJS/QhGcSc=;
        b=tfxAQV9IZvDd4neA9qgummXzd16ZzIXGZTHVKAgP0VeK5JVxA/IgmuPZQxV7IURZ7L
         eElBR4jnmcdsbwW0jeksS3wB+/pOqsh/Pu20TAen8VQIKX2qhlZHMHzgYjjX2dvd99q8
         QV7kJ48cxuSd0KdzHEo3T0/pUJVU6WlTs1LbU7uv8rVNF2tEB8+7PvM6MKKJIwAPuA9z
         acPGp2jzx2ZZ9s3kdOE4cQ8XSMHb9n9Z78ZMQdKU0iBonLQx809BPXpe8kL8wrYtQBPk
         66o5V4+DUBAa9iuJI3vmzulxGXvIghajyLqRYWe13145chRFov7fM1gLS4dNSz25VNQa
         Xyhw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f12si4904479ywi.438.2019.06.11.05.41.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 05:41:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5BCVvi5096182
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:41:30 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2t2bkttsjm-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 08:41:29 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 11 Jun 2019 13:41:27 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 11 Jun 2019 13:41:23 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5BCfM8E56688832
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 12:41:22 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CC6FB11C052;
	Tue, 11 Jun 2019 12:41:22 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id A368411C050;
	Tue, 11 Jun 2019 12:41:21 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.69])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 11 Jun 2019 12:41:21 +0000 (GMT)
Date: Tue, 11 Jun 2019 15:41:19 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Qian Cai <cai@lca.pw>, Will Deacon <will.deacon@arm.com>,
        akpm@linux-foundation.org, catalin.marinas@arm.com,
        linux-kernel@vger.kernel.org, mhocko@kernel.org, linux-mm@kvack.org,
        vdavydov.dev@gmail.com, hannes@cmpxchg.org, cgroups@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
 <20190604142338.GC24467@lakrids.cambridge.arm.com>
 <20190610114326.GF15979@fuggles.cambridge.arm.com>
 <1560187575.6132.70.camel@lca.pw>
 <20190611100348.GB26409@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190611100348.GB26409@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19061112-0028-0000-0000-000003794EFF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061112-0029-0000-0000-000024393D13
Message-Id: <20190611124118.GA4761@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-11_06:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=60 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906110086
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 11, 2019 at 11:03:49AM +0100, Mark Rutland wrote:
> On Mon, Jun 10, 2019 at 01:26:15PM -0400, Qian Cai wrote:
> > On Mon, 2019-06-10 at 12:43 +0100, Will Deacon wrote:
> > > On Tue, Jun 04, 2019 at 03:23:38PM +0100, Mark Rutland wrote:
> > > > On Tue, Jun 04, 2019 at 10:00:36AM -0400, Qian Cai wrote:
> > > > > The commit "arm64: switch to generic version of pte allocation"
> > > > > introduced endless failures during boot like,
> > > > > 
> > > > > kobject_add_internal failed for pgd_cache(285:chronyd.service) (error:
> > > > > -2 parent: cgroup)
> > > > > 
> > > > > It turns out __GFP_ACCOUNT is passed to kernel page table allocations
> > > > > and then later memcg finds out those don't belong to any cgroup.
> > > > 
> > > > Mike, I understood from [1] that this wasn't expected to be a problem,
> > > > as the accounting should bypass kernel threads.
> > > > 
> > > > Was that assumption wrong, or is something different happening here?
> > > > 
> > > > > 
> > > > > backtrace:
> > > > >   kobject_add_internal
> > > > >   kobject_init_and_add
> > > > >   sysfs_slab_add+0x1a8
> > > > >   __kmem_cache_create
> > > > >   create_cache
> > > > >   memcg_create_kmem_cache
> > > > >   memcg_kmem_cache_create_func
> > > > >   process_one_work
> > > > >   worker_thread
> > > > >   kthread
> > > > > 
> > > > > Signed-off-by: Qian Cai <cai@lca.pw>
> > > > > ---
> > > > >  arch/arm64/mm/pgd.c | 2 +-
> > > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > > 
> > > > > diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
> > > > > index 769516cb6677..53c48f5c8765 100644
> > > > > --- a/arch/arm64/mm/pgd.c
> > > > > +++ b/arch/arm64/mm/pgd.c
> > > > > @@ -38,7 +38,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
> > > > >  	if (PGD_SIZE == PAGE_SIZE)
> > > > >  		return (pgd_t *)__get_free_page(gfp);
> > > > >  	else
> > > > > -		return kmem_cache_alloc(pgd_cache, gfp);
> > > > > +		return kmem_cache_alloc(pgd_cache, GFP_PGTABLE_KERNEL);
> > > > 
> > > > This is used to allocate PGDs for both user and kernel pagetables (e.g.
> > > > for the efi runtime services), so while this may fix the regression, I'm
> > > > not sure it's the right fix.
> > > > 
> > > > Do we need a separate pgd_alloc_kernel()?
> > > 
> > > So can I take the above for -rc5, or is somebody else working on a different
> > > fix to implement pgd_alloc_kernel()?
> > 
> > The offensive commit "arm64: switch to generic version of pte allocation" is not
> > yet in the mainline, but only in the Andrew's tree and linux-next, and I doubt
> > Andrew will push this out any time sooner given it is broken.
> 
> I'd assumed that Mike would respin these patches to implement and use
> pgd_alloc_kernel() (or take gfp flags) and the updated patches would
> replace these in akpm's tree.
> 
> Mike, could you confirm what your plan is? I'm happy to review/test
> updated patches for arm64.

Sorry for the delay, I'm mostly offline these days.

I wanted to understand first what is the reason for the failure. I've tried
to reproduce it with qemu, but I failed to find a bootable configuration
that will have PGD_SIZE != PAGE_SIZE :(

Qian Cai, can you share what is your environment and the kernel config?
 
> Thanks,
> Mark.
> 

-- 
Sincerely yours,
Mike.

