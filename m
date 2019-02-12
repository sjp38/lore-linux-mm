Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBADDC282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:56:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68F3E222C5
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:56:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68F3E222C5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA87C8E0002; Tue, 12 Feb 2019 13:56:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A58AA8E0001; Tue, 12 Feb 2019 13:56:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 946758E0002; Tue, 12 Feb 2019 13:56:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6980E8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:56:57 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d13so3691939qth.6
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:56:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/k1iyzfDcvu7lH9PXGXFz9zsyg69wRbygDedX0js/C8=;
        b=UaWgAGLFFQh5jknmmZOGp5LDkwYiRR86mx6XtQmiag3xi9sj7PixofY7PCzqG/f9ai
         ewKUB/m7eFq8sTLy9wu7rmANiu7BjCLtCLTUyt+x8nY/h5BXgce1ZD5/7Z7hRaKH2xyc
         e72FhKBoztCEqXvwzzJKh6w/z3bQZhihv/fuRLh9RKlqAV+9yz9bOj2OABZf+sKJBJHb
         /vHEeKadBaGyD4TL5zBjvbSmVdDMARP+i2zAA/7XuO2+ZxbL/vH0y5C/Cu887X/2QBdU
         6Nv4/+ZAN2eYq4n7RJ2OSjWlhjtil7j9OXhTcuOVf3xDb8+Pz0Ppe+RdfWEkyrtly6wq
         3Zsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alex.williamson@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=alex.williamson@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua25MY23NuVVHqNieVTs2FSVEOCmd/DuRBZydKz1ICgYpcnFAgQ
	zvsXrrQda7JHDL7QpY6TxEYNskaDQf8LPWZsiaYQ5daZy6vE51WQX/c1llhexUic2QXQ/lmXohb
	8E+RIKaSUpMQxF/FOdV0Pdrzm+zcsYh/XQ5lHzSgAMJCJhN53ez/LN9u9Anvi1Klx9A==
X-Received: by 2002:a0c:9802:: with SMTP id c2mr2083242qvd.13.1549997817169;
        Tue, 12 Feb 2019 10:56:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYH4UyOagw4rT0J6Ik+gGGG+r1kUnu6hSpW9vRLij7HpihUXBGP7nxM4dGRqNCtzLOqGWv7
X-Received: by 2002:a0c:9802:: with SMTP id c2mr2083196qvd.13.1549997816437;
        Tue, 12 Feb 2019 10:56:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549997816; cv=none;
        d=google.com; s=arc-20160816;
        b=LAkBagN9TLBlza87m9JbBBj0xMrJNvcAP+qmR079DTwrpvn8OLSOO566RmhgLX2Mj9
         LaCHJSmF9SNDDPjL7jv33jjR9B2fe9HeUwISI5BozQreGMnuiQ/GIFr8thx6Oa4F2qly
         52T11FbzUEaQc4yhA0nFzwU7ZeqWiPPRQgk9JI0ztMbWszqZ//HnGIBoesYEcEWhZ4Hw
         wQvsT1smKOa+pydO53Pzfn1sMK6Ox8IDORGIdQkGi+tTUumoxxUH1L2RRRrW7yRk5uiu
         QXPYxIPedoekQEj4Kl1AWwN2O8GqgcEPcKyXayuACmnuzaeboR4ENeV359u0BUaqd0CZ
         0eRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=/k1iyzfDcvu7lH9PXGXFz9zsyg69wRbygDedX0js/C8=;
        b=w41nTuYeglcgysg72dBydsXBbIf5GCE/RPfuUdBzrj/SIIasKUWgTRqQ5GoXrvowLw
         zO3+Ht37GCcqCy7FPIvD2cBK/WsWsMDxl/C1XAsYO6/uW8EPkqw7CHYbs2JVeIdjcs0W
         SqO9vzvy8o47dIkwXeEdZPyXppx1SY9wRykxIdkipS+43WoX01HMIST/HcBHr5qre4rf
         fVTAzmVhW3Y74tMgoFn6n0+euA9H4MfvdAVKw/v3+nNy8sb4jMZ1kv6mUyi+SBZ4ZXBy
         SBioIAWKfEh2DUuHzoWaLbHWQN93NnWha4XE42S7zDD/PDrVuybYp5V879rxaPH0ccQC
         cqWA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alex.williamson@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=alex.williamson@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x11si841780qka.38.2019.02.12.10.56.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 10:56:56 -0800 (PST)
Received-SPF: pass (google.com: domain of alex.williamson@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alex.williamson@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=alex.williamson@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9C9083DE2F;
	Tue, 12 Feb 2019 18:56:54 +0000 (UTC)
Received: from w520.home (ovpn-116-24.phx2.redhat.com [10.3.116.24])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4EC985C22F;
	Tue, 12 Feb 2019 18:56:53 +0000 (UTC)
Date: Tue, 12 Feb 2019 11:56:52 -0700
From: Alex Williamson <alex.williamson@redhat.com>
To: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, jgg@ziepe.ca,
 akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz, cl@linux.com,
 linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
 linux-kernel@vger.kernel.org, paulus@ozlabs.org, benh@kernel.crashing.org,
 mpe@ellerman.id.au, hao.wu@intel.com, atull@kernel.org, mdf@kernel.org
Subject: Re: [PATCH 2/5] vfio/spapr_tce: use pinned_vm instead of locked_vm
 to account pinned pages
Message-ID: <20190212115652.6cf9a20b@w520.home>
In-Reply-To: <ee4d14db-05c3-6208-503c-16e287fa78eb@ozlabs.ru>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
	<20190211224437.25267-3-daniel.m.jordan@oracle.com>
	<ee4d14db-05c3-6208-503c-16e287fa78eb@ozlabs.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 12 Feb 2019 18:56:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2019 17:56:18 +1100
Alexey Kardashevskiy <aik@ozlabs.ru> wrote:

> On 12/02/2019 09:44, Daniel Jordan wrote:
> > Beginning with bc3e53f682d9 ("mm: distinguish between mlocked and pinned
> > pages"), locked and pinned pages are accounted separately.  The SPAPR
> > TCE VFIO IOMMU driver accounts pinned pages to locked_vm; use pinned_vm
> > instead.
> > 
> > pinned_vm recently became atomic and so no longer relies on mmap_sem
> > held as writer: delete.
> > 
> > Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
> > ---
> >  Documentation/vfio.txt              |  6 +--
> >  drivers/vfio/vfio_iommu_spapr_tce.c | 64 ++++++++++++++---------------
> >  2 files changed, 33 insertions(+), 37 deletions(-)
> > 
> > diff --git a/Documentation/vfio.txt b/Documentation/vfio.txt
> > index f1a4d3c3ba0b..fa37d65363f9 100644
> > --- a/Documentation/vfio.txt
> > +++ b/Documentation/vfio.txt
> > @@ -308,7 +308,7 @@ This implementation has some specifics:
> >     currently there is no way to reduce the number of calls. In order to make
> >     things faster, the map/unmap handling has been implemented in real mode
> >     which provides an excellent performance which has limitations such as
> > -   inability to do locked pages accounting in real time.
> > +   inability to do pinned pages accounting in real time.
> >  
> >  4) According to sPAPR specification, A Partitionable Endpoint (PE) is an I/O
> >     subtree that can be treated as a unit for the purposes of partitioning and
> > @@ -324,7 +324,7 @@ This implementation has some specifics:
> >  		returns the size and the start of the DMA window on the PCI bus.
> >  
> >  	VFIO_IOMMU_ENABLE
> > -		enables the container. The locked pages accounting
> > +		enables the container. The pinned pages accounting
> >  		is done at this point. This lets user first to know what
> >  		the DMA window is and adjust rlimit before doing any real job.

I don't know of a ulimit only covering pinned pages, so for
documentation it seems more correct to continue referring to this as
locked page accounting.

> > @@ -454,7 +454,7 @@ This implementation has some specifics:
> >  
> >     PPC64 paravirtualized guests generate a lot of map/unmap requests,
> >     and the handling of those includes pinning/unpinning pages and updating
> > -   mm::locked_vm counter to make sure we do not exceed the rlimit.
> > +   mm::pinned_vm counter to make sure we do not exceed the rlimit.
> >     The v2 IOMMU splits accounting and pinning into separate operations:
> >  
> >     - VFIO_IOMMU_SPAPR_REGISTER_MEMORY/VFIO_IOMMU_SPAPR_UNREGISTER_MEMORY ioctls
> > diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
> > index c424913324e3..f47e020dc5e4 100644
> > --- a/drivers/vfio/vfio_iommu_spapr_tce.c
> > +++ b/drivers/vfio/vfio_iommu_spapr_tce.c
> > @@ -34,9 +34,11 @@
> >  static void tce_iommu_detach_group(void *iommu_data,
> >  		struct iommu_group *iommu_group);
> >  
> > -static long try_increment_locked_vm(struct mm_struct *mm, long npages)
> > +static long try_increment_pinned_vm(struct mm_struct *mm, long npages)
> >  {
> > -	long ret = 0, locked, lock_limit;
> > +	long ret = 0;
> > +	s64 pinned;
> > +	unsigned long lock_limit;
> >  
> >  	if (WARN_ON_ONCE(!mm))
> >  		return -EPERM;
> > @@ -44,39 +46,33 @@ static long try_increment_locked_vm(struct mm_struct *mm, long npages)
> >  	if (!npages)
> >  		return 0;
> >  
> > -	down_write(&mm->mmap_sem);
> > -	locked = mm->locked_vm + npages;
> > +	pinned = atomic64_add_return(npages, &mm->pinned_vm);
> >  	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> > -	if (locked > lock_limit && !capable(CAP_IPC_LOCK))
> > +	if (pinned > lock_limit && !capable(CAP_IPC_LOCK)) {
> >  		ret = -ENOMEM;
> > -	else
> > -		mm->locked_vm += npages;
> > +		atomic64_sub(npages, &mm->pinned_vm);
> > +	}
> >  
> > -	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %ld/%ld%s\n", current->pid,
> > +	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %ld/%lu%s\n", current->pid,
> >  			npages << PAGE_SHIFT,
> > -			mm->locked_vm << PAGE_SHIFT,
> > -			rlimit(RLIMIT_MEMLOCK),
> > -			ret ? " - exceeded" : "");
> > -
> > -	up_write(&mm->mmap_sem);
> > +			atomic64_read(&mm->pinned_vm) << PAGE_SHIFT,
> > +			rlimit(RLIMIT_MEMLOCK), ret ? " - exceeded" : "");
> >  
> >  	return ret;
> >  }
> >  
> > -static void decrement_locked_vm(struct mm_struct *mm, long npages)
> > +static void decrement_pinned_vm(struct mm_struct *mm, long npages)
> >  {
> >  	if (!mm || !npages)
> >  		return;
> >  
> > -	down_write(&mm->mmap_sem);
> > -	if (WARN_ON_ONCE(npages > mm->locked_vm))
> > -		npages = mm->locked_vm;
> > -	mm->locked_vm -= npages;
> > -	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %ld/%ld\n", current->pid,
> > +	if (WARN_ON_ONCE(npages > atomic64_read(&mm->pinned_vm)))
> > +		npages = atomic64_read(&mm->pinned_vm);
> > +	atomic64_sub(npages, &mm->pinned_vm);
> > +	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %ld/%lu\n", current->pid,
> >  			npages << PAGE_SHIFT,
> > -			mm->locked_vm << PAGE_SHIFT,
> > +			atomic64_read(&mm->pinned_vm) << PAGE_SHIFT,
> >  			rlimit(RLIMIT_MEMLOCK));
> > -	up_write(&mm->mmap_sem);  
> 
> 
> So it used to be down_write+up_write and stuff in between.
> 
> Now it is 3 independent accesses (actually 4 but the last one is
> diagnostic) with no locking around them. Why do not we need a lock
> anymore precisely? Thanks,

The first 2 look pretty sketchy to me, is there a case where you don't
know how many pages you've pinned to unpin them?  And can it ever
really be correct to just unpin whatever remains?  The last access is
diagnostic, which leaves 1.  Daniel's rework to warn on a negative
result looks more sane. Thanks,

Alex

