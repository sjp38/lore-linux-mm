Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD52DC28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:33:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A145A20874
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 21:33:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A145A20874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E34E6B026C; Wed,  5 Jun 2019 17:33:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 36BA96B026F; Wed,  5 Jun 2019 17:33:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E6526B0270; Wed,  5 Jun 2019 17:33:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D83F46B026C
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 17:33:54 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e69so61909pgc.7
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 14:33:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=azmacorJAvog4j2bVWZyOWJK+eLY7Yz8Mt/agm7rg8E=;
        b=IJXPiU7xOL3bsLl72+4EhDucNOxykeyUs54IWBqcKq8H6WH0SyCRJ+7969m1ZJ5fZn
         ClcyiHAVb99DDa3CJNv5fUKwCVVhiTWS643DPDLjUA6CsjIOBBMoxtkqXqJnuig3jJRX
         0sNru2hX3z4miokPkqvQvvYoaDCHBGblYsj2CMrzREIgYL4nY1MHRamDis2kxBfzdB1X
         8KgIQECTtsb/o3EFQPGZPlxBayjSDn6bKKqMOtyslGaDok+7/Lq1kKDyXHsAwkx1SuZZ
         N3rnYerMs1EGazX5ht3C4bKMSgpD7zGY0PkY1HguBGpx1Cubw2Ji5k6OkblzM0PeqN79
         u8YA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAW+L8KkpJeT8a/Bbogsu7PRxUC8lmCPZZOfSgV5ExC3i/+qU3Oa
	Bd6CAOKNMBbhx9EI1p1QbaI3QASwGtFia1W3Ei+6xA9d+GfaLgGzRLlYMtYAWf3C8wj0S/qIraL
	c+RWiJcngy4p+okdyVoNfD6THe37MgT27AUT/a3uMtgsOgrth7wtyzCNmw8AX0e+9Dw==
X-Received: by 2002:a17:902:ba82:: with SMTP id k2mr37826811pls.323.1559770434525;
        Wed, 05 Jun 2019 14:33:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/9h3rcHLDel5JrdSBx00sNkGcmCC+6vm+c/V87GZZ+wXfcMz78EUgWzIVjvnySWSaABiT
X-Received: by 2002:a17:902:ba82:: with SMTP id k2mr37826762pls.323.1559770433785;
        Wed, 05 Jun 2019 14:33:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559770433; cv=none;
        d=google.com; s=arc-20160816;
        b=kdj8tMRGEjvg6CVgwvoIDRVo/MFVeC0hYAzvON7oe8P3Y6wYTMFabxAK5l1BsIGf1h
         4UPHIISkRXPxMYwO601SMYEu8h3FZ5ldreuHwRVJjm1ai3M7uqVVM0YpnzSKA0IzfiNJ
         2OAow+IUeX3C2eEXrG2FYuTKKD26F0SVosFswH7EZ5bKt+zU0gTlbrdV6QHMFeBojWle
         Aa32i8RLy4XtOrQxZtk75V7AS31oPsh8cyCoFsCuI2tDvEEGle0eMIQEVRiHaoEgw9iI
         aU+7HgiK0Sj+ZVPop2DD7XDPK1fMlYu8lPJScF12HWBpzpIEOQgN9EYO1YyRUWnXsugl
         vrGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=azmacorJAvog4j2bVWZyOWJK+eLY7Yz8Mt/agm7rg8E=;
        b=0dSXeSRheRzj9xK7J14/MTBTbqzUiRLKy4rb1frV/Lat5dix/QIDciQtIU59PjZj6O
         AY3ntyMCcKIEEIeYzY8da0f0PQYnePzzkz7YOVhuA/iNVEz/wA1QdRoKU1Mf+oVEkBrX
         urpDMIw9rb228JMi0eeOQQ1VAhS0Xo4KNr2wnRqKdQtKSZ3MEO/secaweHHqRB1iO3og
         4+BiFAEN1/GNJ9UnrBy/XPQ7dFgkPmFuYOqQ4PfBjvAcnRQF3xXO42NIGcz2S8egsUZ6
         BxAB5sgLVI3cjg6g4EOkmHHooVncaQrYj0s+YxGKO6lpPyhgLoq2Y3TdiNDH4auqmp1Y
         YN+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e4si8747pjj.34.2019.06.05.14.33.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 14:33:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x55LWDhZ067823
	for <linux-mm@kvack.org>; Wed, 5 Jun 2019 17:33:53 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2sxhne2s7k-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Jun 2019 17:33:52 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 5 Jun 2019 22:33:50 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 5 Jun 2019 22:33:46 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x55LXjbm54984766
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 5 Jun 2019 21:33:45 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id ABD83A405F;
	Wed,  5 Jun 2019 21:33:45 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 80203A4054;
	Wed,  5 Jun 2019 21:33:44 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.19])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Wed,  5 Jun 2019 21:33:44 +0000 (GMT)
Date: Thu, 6 Jun 2019 00:33:42 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, catalin.marinas@arm.com,
        will.deacon@arm.com, linux-kernel@vger.kernel.org, mhocko@kernel.org,
        linux-mm@kvack.org, vdavydov.dev@gmail.com, hannes@cmpxchg.org,
        cgroups@vger.kernel.org, linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH -next] arm64/mm: fix a bogus GFP flag in pgd_alloc()
References: <1559656836-24940-1-git-send-email-cai@lca.pw>
 <20190604142338.GC24467@lakrids.cambridge.arm.com>
 <20190604143020.GD24467@lakrids.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604143020.GD24467@lakrids.cambridge.arm.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19060521-0020-0000-0000-000003469105
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19060521-0021-0000-0000-00002199A1F4
Message-Id: <20190605213342.GA7023@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-05_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=60 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906050136
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 03:30:20PM +0100, Mark Rutland wrote:
> On Tue, Jun 04, 2019 at 03:23:38PM +0100, Mark Rutland wrote:
> > On Tue, Jun 04, 2019 at 10:00:36AM -0400, Qian Cai wrote:
> > > The commit "arm64: switch to generic version of pte allocation"
> > > introduced endless failures during boot like,
> > > 
> > > kobject_add_internal failed for pgd_cache(285:chronyd.service) (error:
> > > -2 parent: cgroup)
> > > 
> > > It turns out __GFP_ACCOUNT is passed to kernel page table allocations
> > > and then later memcg finds out those don't belong to any cgroup.
> > 
> > Mike, I understood from [1] that this wasn't expected to be a problem,
> > as the accounting should bypass kernel threads.
> > 
> > Was that assumption wrong, or is something different happening here?
> > 
> > > backtrace:
> > >   kobject_add_internal
> > >   kobject_init_and_add
> > >   sysfs_slab_add+0x1a8
> > >   __kmem_cache_create
> > >   create_cache
> > >   memcg_create_kmem_cache
> > >   memcg_kmem_cache_create_func
> > >   process_one_work
> > >   worker_thread
> > >   kthread
> > > 
> > > Signed-off-by: Qian Cai <cai@lca.pw>
> > > ---
> > >  arch/arm64/mm/pgd.c | 2 +-
> > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > 
> > > diff --git a/arch/arm64/mm/pgd.c b/arch/arm64/mm/pgd.c
> > > index 769516cb6677..53c48f5c8765 100644
> > > --- a/arch/arm64/mm/pgd.c
> > > +++ b/arch/arm64/mm/pgd.c
> > > @@ -38,7 +38,7 @@ pgd_t *pgd_alloc(struct mm_struct *mm)
> > >  	if (PGD_SIZE == PAGE_SIZE)
> > >  		return (pgd_t *)__get_free_page(gfp);
> > >  	else
> > > -		return kmem_cache_alloc(pgd_cache, gfp);
> > > +		return kmem_cache_alloc(pgd_cache, GFP_PGTABLE_KERNEL);
> > 
> > This is used to allocate PGDs for both user and kernel pagetables (e.g.
> > for the efi runtime services), so while this may fix the regression, I'm
> > not sure it's the right fix.
> 
> I see that since [1], pgd_alloc() was updated to special-case the
> init_mm, which is not sufficient for cases like:
> 
> 	efi_mm.pgd = pgd_alloc(&efi_mm)
> 
> ... which occurs in a kthread.
> 
> So let's have a pgd_alloc_kernel() to make that explicit.

I've hit "send" before seeing this one :)

Well, to be completely on the safe side an explicit pgd_alloc_kernel()
sounds right. Then it won't be subject to future changes in memcg and will
always "Do The Right Thing".
 
> Thanks,
> Mark.
> 

-- 
Sincerely yours,
Mike.

