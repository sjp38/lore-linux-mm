Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27C1BC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:57:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD8FD240CC
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 18:57:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD8FD240CC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 668E96B0266; Wed, 29 May 2019 14:57:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F1C16B026A; Wed, 29 May 2019 14:57:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4B9136B026B; Wed, 29 May 2019 14:57:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC8A6B0266
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:57:13 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id a22so1549751otr.21
        for <linux-mm@kvack.org>; Wed, 29 May 2019 11:57:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=4B5o5kXBl17KRVPTqxWmo/1UpH9myo7P4pIY41nWoRI=;
        b=dTVi44rfy5hVHPeW1yB00qOy3sZyW1kfmR5DWGU6uxldl60DVbhwGB6Nhvgx4amkwb
         I5mx/Y5du+ztT0zm+AuobcKPIxZsHA/DE5r4Ih5YK7797Ex5Yx+2dteklbPLTqynxFTJ
         b+j3pWBA6uVC4tAgGz1MB+kIDZ+DYuQMmbp5O9Vmbj4incL7X/rUoIU0AO/aHzlNnPVp
         zLWApNwdNMrAwi00tVrARJlglW6ujlRK+bqJ1WGiNtEHDQ0TeTIoCVaoKfE4I8M1/05A
         DJVKLzaQ26eivFEekoUwZL0lMlgK/kMyE6sw6tFUNUD2vVXnIXaISsDlFBhhDZAh7O0S
         I+SA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alex.williamson@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=alex.williamson@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXwN+MGCe6sVzU4SgO1JMVt5EHEcj7nuPL7iQ8hAK8jTmSXMsQy
	G7Fad6FLYd1nu4SgJ7cVVuKHE387K12PP88noOeBavF8WSR9CJZVbVO/ykeaxLS6+d55KO5Nfpn
	uKjsLO8RggWmgZNEKauxy/sUQv4yMGiuo+mn2COO44ESCVbttLNDIqi6HL+xkUB0HYw==
X-Received: by 2002:aca:bcc6:: with SMTP id m189mr2003002oif.120.1559156232727;
        Wed, 29 May 2019 11:57:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvtu3w8CTr5CO7CXcAq1JEAbW2lJ8QnsKLGjqpMMCWifyBcQ0vPAKzkjTJR76I7aDRCi/1
X-Received: by 2002:aca:bcc6:: with SMTP id m189mr2002715oif.120.1559156227118;
        Wed, 29 May 2019 11:57:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559156227; cv=none;
        d=google.com; s=arc-20160816;
        b=EcEyk2J94fAihdgMUuWbZnREWmWTaTYUzsMQvjD6obqcE3dlcpPq+OGavGuPJIak5j
         gFtaDl9gnaK85UjgH9Wrt9Hix9nleDyN3WI6TEHf4aTSySiccfPCfIWf8n9Vfx2A1Nmz
         vNV4ptjmdG2XPCuQinD3Gn2HBFyAyPc48k81WQzDT38QgHT84alNEKjLc1xFb/XWo+nI
         qVQaN5Dgq3ds6C5/kPR+caaq6PdJbM+h1+8nAnFt9I4pcYg+49WGOOrccV1WyyFYrR8d
         +P9vroUDnNGR0jRlXHFesBZjtA2ThfUlcFLPodP1y7hWgWmT/MTv7Zf6JaSnnjByqB6J
         qTeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=4B5o5kXBl17KRVPTqxWmo/1UpH9myo7P4pIY41nWoRI=;
        b=owhMkOrCo5NXGZsXEx+HKOGrKc8D8xWBo7txriwZfDFuLe2yVkf8qFhqncJsHpzgxg
         vL5r+kPADNwWilXhtpmi897f2xCNd/OuFGVeGOYz24oD/keLlG0TEuYb0THUoCJ/0gOj
         ipb21VVFYDpW7S1lZnyXFRBMudnxonnJMWinIzdPu9n7PJKrw9ePFsfOssYqqDdC8ypU
         DkuYj3zD/eohgdX0yygswDv4pjhfKW4WowLVVnUgz7FI8vhCfUBWh0PdZixmqR+qYwb9
         uhS6NGtWjKMG9ZZDUFwrUhkY/Xj2hlvQKaohMUjigo9hgnqdKXbRSNhf2ivjnUG8aNTD
         m1Ww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alex.williamson@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=alex.williamson@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g2si101911otq.74.2019.05.29.11.57.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 11:57:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of alex.williamson@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alex.williamson@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=alex.williamson@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3C55F30C1B92;
	Wed, 29 May 2019 18:56:41 +0000 (UTC)
Received: from x1.home (ovpn-116-22.phx2.redhat.com [10.3.116.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6A9CF5C5DF;
	Wed, 29 May 2019 18:56:28 +0000 (UTC)
Date: Wed, 29 May 2019 12:56:27 -0600
From: Alex Williamson <alex.williamson@redhat.com>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexey Kardashevskiy
 <aik@ozlabs.ru>, Alan Tull <atull@kernel.org>, Benjamin Herrenschmidt
 <benh@kernel.crashing.org>, Christoph Lameter <cl@linux.com>, Christophe
 Leroy <christophe.leroy@c-s.fr>, Davidlohr Bueso <dave@stgolabs.net>, Jason
 Gunthorpe <jgg@mellanox.com>, Mark Rutland <mark.rutland@arm.com>, Michael
 Ellerman <mpe@ellerman.id.au>, Moritz Fischer <mdf@kernel.org>, Paul
 Mackerras <paulus@ozlabs.org>, Steve Sistare <steven.sistare@oracle.com>,
 Wu Hao <hao.wu@intel.com>, linux-mm@kvack.org, kvm@vger.kernel.org,
 kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-fpga@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] mm: add account_locked_vm utility function
Message-ID: <20190529125627.0cb5b704@x1.home>
In-Reply-To: <20190528150424.tjbaiptpjhzg7y75@ca-dmjordan1.us.oracle.com>
References: <de375582-2c35-8e8a-4737-c816052a8e58@ozlabs.ru>
	<20190524175045.26897-1-daniel.m.jordan@oracle.com>
	<20190525145118.bfda2d75a14db05a001e49ad@linux-foundation.org>
	<20190528150424.tjbaiptpjhzg7y75@ca-dmjordan1.us.oracle.com>
Organization: Red Hat
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 29 May 2019 18:57:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 May 2019 11:04:24 -0400
Daniel Jordan <daniel.m.jordan@oracle.com> wrote:

> On Sat, May 25, 2019 at 02:51:18PM -0700, Andrew Morton wrote:
> > On Fri, 24 May 2019 13:50:45 -0400 Daniel Jordan <daniel.m.jordan@oracle.com> wrote:
> >   
> > > locked_vm accounting is done roughly the same way in five places, so
> > > unify them in a helper.  Standardize the debug prints, which vary
> > > slightly, but include the helper's caller to disambiguate between
> > > callsites.
> > > 
> > > Error codes stay the same, so user-visible behavior does too.  The one
> > > exception is that the -EPERM case in tce_account_locked_vm is removed
> > > because Alexey has never seen it triggered.
> > > 
> > > ...
> > >
> > > --- a/include/linux/mm.h
> > > +++ b/include/linux/mm.h
> > > @@ -1564,6 +1564,25 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
> > >  int get_user_pages_fast(unsigned long start, int nr_pages,
> > >  			unsigned int gup_flags, struct page **pages);
> > >  
> > > +int __account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc,
> > > +			struct task_struct *task, bool bypass_rlim);
> > > +
> > > +static inline int account_locked_vm(struct mm_struct *mm, unsigned long pages,
> > > +				    bool inc)
> > > +{
> > > +	int ret;
> > > +
> > > +	if (pages == 0 || !mm)
> > > +		return 0;
> > > +
> > > +	down_write(&mm->mmap_sem);
> > > +	ret = __account_locked_vm(mm, pages, inc, current,
> > > +				  capable(CAP_IPC_LOCK));
> > > +	up_write(&mm->mmap_sem);
> > > +
> > > +	return ret;
> > > +}  
> > 
> > That's quite a mouthful for an inlined function.  How about uninlining
> > the whole thing and fiddling drivers/vfio/vfio_iommu_type1.c to suit. 
> > I wonder why it does down_write_killable and whether it really needs
> > to...  
> 
> Sure, I can uninline it.  vfio changelogs don't show a particular reason for
> _killable[1].  Maybe Alex has something to add.  Otherwise I'll respin without
> it since the simplification seems worth removing _killable.
> 
> [1] 0cfef2b7410b ("vfio/type1: Remove locked page accounting workqueue")

A userspace vfio driver maps DMA via an ioctl through this path, so I
believe I used killable here just to be friendly that it could be
interrupted and we could fall out with an errno if it were stuck here.
No harm, no foul, the user's mapping is aborted and unwound.  If we're
deadlocked or seriously contended on mmap_sem, maybe we're already in
trouble, but it seemed like a valid and low hanging use case for
killable.  Thanks,

Alex

