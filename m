Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6974DC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 16:06:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05212206DF
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 16:06:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05212206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 669016B02A2; Wed, 10 Apr 2019 12:06:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 61A706B02A4; Wed, 10 Apr 2019 12:06:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E1AF6B02A5; Wed, 10 Apr 2019 12:06:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 295AC6B02A2
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 12:06:36 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z34so2682204qtz.14
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 09:06:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=CmWeOmoJ1YXz0EVwdgPqJirAFc0NO1Gs+YtUA24NW64=;
        b=mojfqE75SIwQdqXEalvnDFdSQGQMsfdqJqR8Rg5onfcyH9i42bfFyiTtcIcL94zlr3
         TEn8mPClbKW+tjpoufa+fpPwUwAecgHJdC5lB/o8WxZ12YrBKYbMYnG/KDidn/TKd+fU
         cftnxJ3/q3IeXrwzT1Sqlg7rpObIaGYgOCuYt9R+98zXDZgccWA81XmoGn18mL9ov6Nb
         DGAuPgY4HtiNaOjvDKL2hSPNv4EfnWW4Cw+sI7O/mLR0UJAcxX3gVQU/PO4kyyMAf92Q
         j9jV6OG+r1d23mB7mblBf1Son+twy+ur7YePlBcH9JS5bA0lS8mfg3DdDyO+FZ7HAQcH
         QJpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXPdjnunzWQ/5+ponj45Mq8lJCR8GBKFNTSslIgxBPookTryYfG
	h0VET08pj1snayK/0r9lzoSHarKlb23vsqt/ujS3ZkIPaqf/BIj3V6bF2xbwJEXY9jB6ZUU9q+D
	ffMVFaxgtbK346FV1WvLPS3ihWz+e4Co+dcJOchEk/feqvyfEZqguwnCksCakyrZNWw==
X-Received: by 2002:ac8:308a:: with SMTP id v10mr37303162qta.185.1554912395908;
        Wed, 10 Apr 2019 09:06:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkYJfaYLD4/THPJItfssy36x4+yskzCDJ/RP2r8uHdHxl4XmqwjzlqBli6tgtPS6bW0akX
X-Received: by 2002:ac8:308a:: with SMTP id v10mr37303062qta.185.1554912394905;
        Wed, 10 Apr 2019 09:06:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554912394; cv=none;
        d=google.com; s=arc-20160816;
        b=wSkkuqkDkw3Y9PToibrNHjVWB2cjvEbi+cU1lqaHBnfblaf/jrMZpJY4F9ZEt1YCbM
         hnfFhqR+FD2uy3omcUPA79l2fKfRXFZYHFz4+OHWBP2R+J8bVftwgeDXBPLpzEW8eL8u
         1rGATnvknjm9ti90AvpkaDQrcRYJQKy2RQtfTHKvBBwCj11r4p4EIL0ODI7ZK0v6ui8Z
         N3IuU4Gp5vnAGd4G3MMOSWhlZA5DTGx7LIAzIO1l4Sjhr+biTzfWG9uFcg5Axw2nD5tR
         kvOn+c7NtcqWHzbj3Uce1wqDls0vg5pVim8qFR264KPlor+vG9/0fV7G/5tbqC4KJxLR
         cDtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=CmWeOmoJ1YXz0EVwdgPqJirAFc0NO1Gs+YtUA24NW64=;
        b=wJ/vQRXbUPWubimI53dfxZ2Ul7E1FArqXFk4o+BMaf9KruT6w1zvAWWvFJ9k03UEQv
         3Ue8sCtTR/YYYQ8IrjwKhhxuojqvNQWDIkArmOsl4HHKDFxjxO9PZFpFLkO3SmEbMN6f
         SJl85cEUD4OjVbJ9g3a2AzuoK+fmUCK08/fUnYZzegYXBUktD06JVoXUVXkT0EIYBJwu
         yhkscyjtyY2p47v9R1u5ddJdAGSVwvvw+CpEMTF5RDA/s2vOQcvVvAjVrbbQbwCplQYU
         av7Iq3Uu0ipAiFzhPtaq3+LrKdFnbYUHRqsW7WGbxEzaO/vUoQJoZljGgNJRNR/hI0f/
         9bJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n36si11067049qtc.149.2019.04.10.09.06.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 09:06:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C3FA0300745F;
	Wed, 10 Apr 2019 16:06:33 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D67885DA5B;
	Wed, 10 Apr 2019 16:06:28 +0000 (UTC)
Date: Wed, 10 Apr 2019 12:06:27 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>, Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v6 0/8] mmu notifier provide context informations
Message-ID: <20190410160626.GA3273@redhat.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
 <20190409150855.a6cfee7e7c5698a9cd8ecb7c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190409150855.a6cfee7e7c5698a9cd8ecb7c@linux-foundation.org>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 10 Apr 2019 16:06:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 03:08:55PM -0700, Andrew Morton wrote:
> On Tue, 26 Mar 2019 12:47:39 -0400 jglisse@redhat.com wrote:
> 
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > (Andrew this apply on top of my HMM patchset as otherwise you will have
> >  conflict with changes to mm/hmm.c)
> > 
> > Changes since v5:
> >     - drop KVM bits waiting for KVM people to express interest if they
> >       do not then i will post patchset to remove change_pte_notify as
> >       without the changes in v5 change_pte_notify is just useless (it
> >       it is useless today upstream it is just wasting cpu cycles)
> >     - rebase on top of lastest Linus tree
> > 
> > Previous cover letter with minor update:
> > 
> > 
> > Here i am not posting users of this, they already have been posted to
> > appropriate mailing list [6] and will be merge through the appropriate
> > tree once this patchset is upstream.
> > 
> > Note that this serie does not change any behavior for any existing
> > code. It just pass down more information to mmu notifier listener.
> > 
> > The rational for this patchset:
> > 
> > CPU page table update can happens for many reasons, not only as a
> > result of a syscall (munmap(), mprotect(), mremap(), madvise(), ...)
> > but also as a result of kernel activities (memory compression, reclaim,
> > migration, ...).
> > 
> > This patch introduce a set of enums that can be associated with each
> > of the events triggering a mmu notifier:
> > 
> >     - UNMAP: munmap() or mremap()
> >     - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
> >     - PROTECTION_VMA: change in access protections for the range
> >     - PROTECTION_PAGE: change in access protections for page in the range
> >     - SOFT_DIRTY: soft dirtyness tracking
> > 
> > Being able to identify munmap() and mremap() from other reasons why the
> > page table is cleared is important to allow user of mmu notifier to
> > update their own internal tracking structure accordingly (on munmap or
> > mremap it is not longer needed to track range of virtual address as it
> > becomes invalid). Without this serie, driver are force to assume that
> > every notification is an munmap which triggers useless trashing within
> > drivers that associate structure with range of virtual address. Each
> > driver is force to free up its tracking structure and then restore it
> > on next device page fault. With this serie we can also optimize device
> > page table update [6].
> > 
> > More over this can also be use to optimize out some page table updates
> > like for KVM where we can update the secondary MMU directly from the
> > callback instead of clearing it.
> 
> We seem to be rather short of review input on this patchset.  ie: there
> is none.

I forgot to update the review tag but Ralph did review v5:
https://lkml.org/lkml/2019/2/22/564
https://lkml.org/lkml/2019/2/22/561
https://lkml.org/lkml/2019/2/22/558
https://lkml.org/lkml/2019/2/22/710
https://lkml.org/lkml/2019/2/22/711
https://lkml.org/lkml/2019/2/22/695
https://lkml.org/lkml/2019/2/22/738
https://lkml.org/lkml/2019/2/22/757

and since this v6 is a rebase just with better comments here and
there i believe those reviews holds.

> 
> > ACKS AMD/RADEON https://lkml.org/lkml/2019/2/1/395
> 
> OK, kind of ackish, but not a review.
> 
> > ACKS RDMA https://lkml.org/lkml/2018/12/6/1473
> 
> This actually acks the infiniband part of a patch which isn't in this
> series.

This to show that they are end user and that those end user are
wanted. Also obviously i will be using this within HMM and thus
it will be use by mlx5, nouveau and amdgpu (which are all the
HMM user that are either upstream or queue up for 5.2 or 5.3).

> So we have some work to do, please.  Who would be suitable reviewers?

Anyone willing to review mmu notifier code. I believe this patchset is
not that hard to review this is about giving contextual informations
on why mmu notifier are happening it does not change the logic of any-
thing. They are no maintainers for the mmu notifier so i don't have a
person i can single out for review, thought given i have been the one
doing most changes in that area it could fall on me ...

Cheers,
Jérôme

