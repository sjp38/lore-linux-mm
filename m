Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLACK,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78866C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 15:31:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D1CF2081C
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 15:31:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LDlo2Jtn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D1CF2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B40D76B0005; Mon, 20 May 2019 11:30:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF1A56B0006; Mon, 20 May 2019 11:30:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B8B66B0007; Mon, 20 May 2019 11:30:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 75FB96B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 11:30:59 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id d10so723426ywh.12
        for <linux-mm@kvack.org>; Mon, 20 May 2019 08:30:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=SXUGhLzqu7OWeZA9OhKeGyoXs0a41JQJFMDBXBRPnVs=;
        b=Twp9bHyqkbXZut+VfGrNHctEYJJRQpLeb1Wx6WlTYfZ6VlWLdO/1BSuFcp4yTHUOVn
         10PeJt3Kis++rw9z1jh/Xa5gGSUJpHy5lSP7YubBGxheVxegirXdRz2SDVng24QF/0oi
         X+BNVfD13UY4aL3qvfuQ6LeEzta9yyO93zvUL4eFtciRaxkxHYYnalBzmjWCfE/bZFV7
         dDixtrIwVCzOJupUhwFT/Y5BDTNiwhnZtpclfl0AvyXnawwb2Aqo2wWTgJTTLMzF9ik3
         Nth15i8x+aJQ/G3BI2HUwf5Gq/dtwSAPrDBErbK1JaC/LzLRD2GAfjvZtghYd0ScG+GH
         Z3PQ==
X-Gm-Message-State: APjAAAXYf/efQiaIeXa7uwwF24VbWIDWslaxicOL1LyR7S+BPQnfhBlW
	LAbKHcXmZq4R5aWdXKa3OL4fyjXBTOZSjcc/RxEzrHIIIUNpA1uJcI1FPtFhcSrAnPDkvRNtCDr
	JZB/zNykzlM1ADVAJXmx9BlgNUJV6ZKHjvUAMl2t9BiZ81xMPaaheDoiY5rbhcxf4JQ==
X-Received: by 2002:a25:bb8b:: with SMTP id y11mr34974389ybg.101.1558366259157;
        Mon, 20 May 2019 08:30:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdkQGUUXpbU76Y7mjI5QtlNp+2Us/wk51HbLaWojqGq4M6RrRDiXzYmNGvblDTYOJiAcx2
X-Received: by 2002:a25:bb8b:: with SMTP id y11mr34974342ybg.101.1558366258366;
        Mon, 20 May 2019 08:30:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558366258; cv=none;
        d=google.com; s=arc-20160816;
        b=bJR/5WyjV9fB3DdmFHErvjExvKdDJuGCRlxpqXy+8Fhqi+YymecJSAsNUgizrJdGaX
         xwPnRMPWtzxiVDPMNKskJJvKcWSFyAPMXUgHqrpnSm/uULJeQB8nUF9/WyHuQ3ieHRYb
         HSpjb5upWcrj7aWbLFy0SuuGPnM2t/1xjXA55bzcFgEITyy91i+gkMjQ9XmcR6aSD2XX
         8byUHU9GUNC5LwlNvtsmuiJnyL34m3toQCk4hdp6LICgul7F2uYXTaqX1y04ULxobd5g
         nNYB8eClGmcmHY8h2uKxDHPE/0vOKScMd2D2XgbmMeswhcjFnbLJLRJ/6SBFpvGrOZpi
         mRpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=SXUGhLzqu7OWeZA9OhKeGyoXs0a41JQJFMDBXBRPnVs=;
        b=TMFC5Y/fHgRmVRoqfro0WIMncOcVew6Nc8UUWEm+QVVtKlvGsRofBLFTtJFX9TldQm
         d2cLtykJb/ca6yVCFDCasJLUWEN53oO0hlVhi9kEXZwzxl1oDTZK0m9xxw8TvqTiv38O
         kFFF1X/k5iD2axp/FdQP1HrKQjbxdkiyaOFEm1lFw3ivOqy3X0nPx+IEk/mEQg95JRAI
         DEeJtEZmNHRc23uxx/9gHGWpSBM6fQEILQ4e1SgZS8MUz8bwCmAIdFzyrduMGuqN0NBN
         sjQ0ogPja0qQ25OV/00HKvEKvZbtZtlDyNg0EDx9SS1bMo9sXwocrcwBDbyQk2WywGeR
         qGJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LDlo2Jtn;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 129si4669428ybz.318.2019.05.20.08.30.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 08:30:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=LDlo2Jtn;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4KFIvpF144705;
	Mon, 20 May 2019 15:30:35 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=SXUGhLzqu7OWeZA9OhKeGyoXs0a41JQJFMDBXBRPnVs=;
 b=LDlo2JtnsgqOL7mMI0IvGprzfGCy4to4pDQltq8uHsDWRMZ5fLF/GBmkz/DPJG16d8+E
 AphQu0yTg9IX/1qILAVa03FMrn/a0QMIcIuzCfG1x9RXcoTeKLnRbqhxI/u2l3T5i+FO
 sRlFZbwrPkqowmNwuDTdSihMC/nz2onnFmvR1s6zTFTGeAGe8PUto+cDd13QJ16HajNT
 QbD1ITdOCo1utBuP6VExYHrORa14RnduNx9MSIKtrhSnSUFWInHvA7sGpIa4C3sHrOG/
 WMBhF9YM8ifc8XjdVeMUyguDzXTtV5vjfUAJ6BjL40xkPh1CGr3Uvt8OkhE+dqxwuqE3 /g== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2sj9ft7sn9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 20 May 2019 15:30:35 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4KFTuDs046722;
	Mon, 20 May 2019 15:30:34 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2sks18nr8g-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 20 May 2019 15:30:34 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4KFUL5K012431;
	Mon, 20 May 2019 15:30:21 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 20 May 2019 15:30:21 +0000
Date: Mon, 20 May 2019 11:30:20 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
        Alan Tull <atull@kernel.org>,
        Alex Williamson <alex.williamson@redhat.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Christoph Lameter <cl@linux.com>,
        Christophe Leroy <christophe.leroy@c-s.fr>,
        Davidlohr Bueso <dave@stgolabs.net>,
        Jason Gunthorpe <jgg@mellanox.com>,
        Mark Rutland <mark.rutland@arm.com>,
        Michael Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>,
        Paul Mackerras <paulus@ozlabs.org>,
        Steve Sistare <steven.sistare@oracle.com>, Wu Hao <hao.wu@intel.com>,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: add account_locked_vm utility function
Message-ID: <20190520153020.mzvjsjwefwxz6cau@ca-dmjordan1.us.oracle.com>
References: <20190503201629.20512-1-daniel.m.jordan@oracle.com>
 <4b42057f-b998-f87c-4e0f-a91abcb366f9@ozlabs.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4b42057f-b998-f87c-4e0f-a91abcb366f9@ozlabs.ru>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9262 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=18 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905200100
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9262 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=18 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905200100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 04:19:34PM +1000, Alexey Kardashevskiy wrote:
> On 04/05/2019 06:16, Daniel Jordan wrote:
> > locked_vm accounting is done roughly the same way in five places, so
> > unify them in a helper.  Standardize the debug prints, which vary
> > slightly.
> 
> And I rather liked that prints were different and tell precisely which
> one of three each printk is.

I'm not following.  One of three...callsites?  But there were five callsites.

Anyway, I added a _RET_IP_ to the debug print so you can differentiate.

> I commented below but in general this seems working.
> 
> Tested-by: Alexey Kardashevskiy <aik@ozlabs.ru>

Thanks!  And for the review as well.

> > diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
> > index 6b64e45a5269..d39a1b830d82 100644
> > --- a/drivers/vfio/vfio_iommu_spapr_tce.c
> > +++ b/drivers/vfio/vfio_iommu_spapr_tce.c
> > @@ -34,49 +35,13 @@
> >  static void tce_iommu_detach_group(void *iommu_data,
> >  		struct iommu_group *iommu_group);
> >  
> > -static long try_increment_locked_vm(struct mm_struct *mm, long npages)
> > +static int tce_account_locked_vm(struct mm_struct *mm, unsigned long npages,
> > +				 bool inc)
> >  {
> > -	long ret = 0, locked, lock_limit;
> > -
> >  	if (WARN_ON_ONCE(!mm))
> >  		return -EPERM;
> 
> 
> If this WARN_ON is the only reason for having tce_account_locked_vm()
> instead of calling account_locked_vm() directly, you can then ditch the
> check as I have never ever seen this triggered.

Great, will do.

> > diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
> > index d0f731c9920a..15ac76171ccd 100644
> > --- a/drivers/vfio/vfio_iommu_type1.c
> > +++ b/drivers/vfio/vfio_iommu_type1.c
> > @@ -273,25 +273,14 @@ static int vfio_lock_acct(struct vfio_dma *dma, long npage, bool async)
> >  		return -ESRCH; /* process exited */
> >  
> >  	ret = down_write_killable(&mm->mmap_sem);
> > -	if (!ret) {
> > -		if (npage > 0) {
> > -			if (!dma->lock_cap) {
> > -				unsigned long limit;
> > -
> > -				limit = task_rlimit(dma->task,
> > -						RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> > -
> > -				if (mm->locked_vm + npage > limit)
> > -					ret = -ENOMEM;
> > -			}
> > -		}
> > +	if (ret)
> > +		goto out;
> 
> 
> A single "goto" to jump just 3 lines below seems unnecessary.

No strong preference here, I'll take out the goto.

> > +int __account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc,
> > +			struct task_struct *task, bool bypass_rlim)
> > +{
> > +	unsigned long locked_vm, limit;
> > +	int ret = 0;
> > +
> > +	locked_vm = mm->locked_vm;
> > +	if (inc) {
> > +		if (!bypass_rlim) {
> > +			limit = task_rlimit(task, RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> > +			if (locked_vm + pages > limit) {
> > +				ret = -ENOMEM;
> > +				goto out;
> > +			}
> > +		}
> 
> Nit:
> 
> if (!ret)
> 
> and then you don't need "goto out".

Ok, sure.

> > +		mm->locked_vm = locked_vm + pages;
> > +	} else {
> > +		WARN_ON_ONCE(pages > locked_vm);
> > +		mm->locked_vm = locked_vm - pages;
> 
> 
> Can go negative here. Not a huge deal but inaccurate imo.

I hear you, but setting a negative value to zero, as we had done previously,
doesn't make much sense to me.

