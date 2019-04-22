Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC5C4C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 15:51:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D25B2077C
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 15:51:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D25B2077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F0CAC6B0003; Mon, 22 Apr 2019 11:51:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBD106B0006; Mon, 22 Apr 2019 11:51:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D83C36B0007; Mon, 22 Apr 2019 11:51:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id B33A86B0003
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:51:55 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id g1so565992qkm.3
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 08:51:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=fC072qf+mCMjRutEAQYtab5sKujsgZWzioVp6Qf+3rw=;
        b=jbsG6D1ZD4AcbFfhTgiYV9Cw1HMINooTN1klGxntKoUeIrIeqzW7YrwLUhhCyZ2DS7
         rXEoO1oRFPHesMH8EvG9mw8Ib2s1PnwcCzn6bBt0NZ3Z+TOXShWOyeYIO0EqhSvQjhoW
         OV8XnuMbCBZIJ54mCtopbem+C0xuYd2Xm7FeMVqS29ogMU6HMSZcjQLOxcChChsTR23N
         k1X8uD9idNANmKEt1gRTGeSipT34k626vhbKv238+3TRt7nAH5x5CY2BTttdK7u9aCZZ
         3DhqSl6bobM/WQqPEMJoJjbUznOKSDxMykPguuLWYKxC0BdzJ5vOGxUI3dpGu9a+h+NK
         cXYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWrORf7lgVkJEtRJMQacIV6OdeFmBVs6jtxpqQqUaPnslt2mbjc
	CNwOdAdqYU1nc39oKnM8Uo3W+RZ4LtfeLB6Zg+sx53WsPwMFgTGLK2QTNTeXCxIA4yMbNlaQWNk
	jwYDLSkBqnf1XCtLhxe4x/ZEBmI5R1ff85JNmtOngEIjU21JAS9J36+bkKFEPIKWHHQ==
X-Received: by 2002:ac8:22f3:: with SMTP id g48mr15530778qta.333.1555948315329;
        Mon, 22 Apr 2019 08:51:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxeost4QIJK9aj9RyGLd9ittz/fqwZ6wTziI0Hm/MUZ0X1Vo+7leumA+FveqTrY6+KUT39O
X-Received: by 2002:ac8:22f3:: with SMTP id g48mr15530717qta.333.1555948314423;
        Mon, 22 Apr 2019 08:51:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555948314; cv=none;
        d=google.com; s=arc-20160816;
        b=zt9TwUHHFMolaOzU7mlpJoe7Y8avg5YZrGkPmtU7kwEgrNYYNhycQnhCzw6KhHKYtE
         nG5nykAPek+9+OiLiHhpikOtlOGzq3VPjoUqXnGeDxhLrr4redbhzupJiQC582hHzNcZ
         OzbOyZPRX5fWKzIfh5THnjw78o8Jv5lsVXEz5VZQCUzzBHYsbCgpVOjmpqtr5YELZqwb
         nvaB4oCRiHjJobPrXv7oY147xY4hjgtZYes50xx0DaYkbh24/LoiTGscAQv3LVNG93Eu
         dDsPXQhBoJ9TDTHj+Dz6wObq1JjfbqDswhLXzsAzoU4XIIErA42wx5FM8tEGizx1w12q
         2elg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=fC072qf+mCMjRutEAQYtab5sKujsgZWzioVp6Qf+3rw=;
        b=J388/r6qFY8DSPAeXpbTfW99lZBkpUAd+Po269CZQYYAuhfXviHclick+MSGs8VOVy
         Hgufh4F30AjIZDn/+G1BrCJQizpZ8977a/0xRELoUrJ8re6WtJesG4qTFQIiG6kbI3l0
         YkmBYmcuP1SlkGfwtb/R8mOFLi6d4oHJxqlYFalJkuxLb+syFVCLBiaYgMWV02MEAPrN
         cx0fCVsvfC6HtUxUQPLO428MdmWbz0SnA9cQalqYGuAPZZQvMagFInDqcbol0NZkVEst
         mj5jS1yyCCEV593FBCk1N4EHjZcsLwCXfn7RPnOx79JBqv8SXMsNCjPuyr3Fw4A3Hndq
         gycw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z28si1393032qtb.61.2019.04.22.08.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 08:51:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BBD2C307D867;
	Mon, 22 Apr 2019 15:51:52 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 730DE5D9D4;
	Mon, 22 Apr 2019 15:51:44 +0000 (UTC)
Date: Mon, 22 Apr 2019 11:51:42 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
	kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
	jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 09/31] mm: VMA sequence count
Message-ID: <20190422155142.GD3450@redhat.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-10-ldufour@linux.ibm.com>
 <20190418224857.GI11645@redhat.com>
 <d217e71c-7d55-ce1a-6461-ce1de732fb57@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <d217e71c-7d55-ce1a-6461-ce1de732fb57@linux.ibm.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 22 Apr 2019 15:51:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 05:45:57PM +0200, Laurent Dufour wrote:
> Hi Jerome,
> 
> Thanks a lot for reviewing this series.
> 
> Le 19/04/2019 à 00:48, Jerome Glisse a écrit :
> > On Tue, Apr 16, 2019 at 03:45:00PM +0200, Laurent Dufour wrote:
> > > From: Peter Zijlstra <peterz@infradead.org>
> > > 
> > > Wrap the VMA modifications (vma_adjust/unmap_page_range) with sequence
> > > counts such that we can easily test if a VMA is changed.
> > > 
> > > The calls to vm_write_begin/end() in unmap_page_range() are
> > > used to detect when a VMA is being unmap and thus that new page fault
> > > should not be satisfied for this VMA. If the seqcount hasn't changed when
> > > the page table are locked, this means we are safe to satisfy the page
> > > fault.
> > > 
> > > The flip side is that we cannot distinguish between a vma_adjust() and
> > > the unmap_page_range() -- where with the former we could have
> > > re-checked the vma bounds against the address.
> > > 
> > > The VMA's sequence counter is also used to detect change to various VMA's
> > > fields used during the page fault handling, such as:
> > >   - vm_start, vm_end
> > >   - vm_pgoff
> > >   - vm_flags, vm_page_prot
> > >   - vm_policy
> > 
> > ^ All above are under mmap write lock ?
> 
> Yes, changes are still made under the protection of the mmap_sem.
> 
> > 
> > >   - anon_vma
> > 
> > ^ This is either under mmap write lock or under page table lock
> > 
> > So my question is do we need the complexity of seqcount_t for this ?
> 
> The sequence counter is used to detect write operation done while readers
> (SPF handler) is running.
> 
> The implementation is quite simple (here without the lockdep checks):
> 
> static inline void raw_write_seqcount_begin(seqcount_t *s)
> {
> 	s->sequence++;
> 	smp_wmb();
> }
> 
> I can't see why this is too complex here, would you elaborate on this ?
> 
> > 
> > It seems that using regular int as counter and also relying on vm_flags
> > when vma is unmap should do the trick.
> 
> vm_flags is not enough I guess an some operation are not impacting the
> vm_flags at all (resizing for instance).
> Am I missing something ?
> 
> > 
> > vma_delete(struct vm_area_struct *vma)
> > {
> >      ...
> >      /*
> >       * Make sure the vma is mark as invalid ie neither read nor write
> >       * so that speculative fault back off. A racing speculative fault
> >       * will either see the flags as 0 or the new seqcount.
> >       */
> >      vma->vm_flags = 0;
> >      smp_wmb();
> >      vma->seqcount++;
> >      ...
> > }
> 
> Well I don't think we can safely clear the vm_flags this way when the VMA is
> unmap, I think it is used later when cleaning is doen.
> 
> Later in this series, the VMA deletion is managed when the VMA is unlinked
> from the RB Tree. That is checked using the vm_rb field's value, and managed
> using RCU.
> 
> > Then:
> > speculative_fault_begin(struct vm_area_struct *vma,
> >                          struct spec_vmf *spvmf)
> > {
> >      ...
> >      spvmf->seqcount = vma->seqcount;
> >      smp_rmb();
> >      spvmf->vm_flags = vma->vm_flags;
> >      if (!spvmf->vm_flags) {
> >          // Back off the vma is dying ...
> >          ...
> >      }
> > }
> > 
> > bool speculative_fault_commit(struct vm_area_struct *vma,
> >                                struct spec_vmf *spvmf)
> > {
> >      ...
> >      seqcount = vma->seqcount;
> >      smp_rmb();
> >      vm_flags = vma->vm_flags;
> > 
> >      if (spvmf->vm_flags != vm_flags || seqcount != spvmf->seqcount) {
> >          // Something did change for the vma
> >          return false;
> >      }
> >      return true;
> > }
> > 
> > This would also avoid the lockdep issue described below. But maybe what
> > i propose is stupid and i will see it after further reviewing thing.
> 
> That's true that the lockdep is quite annoying here. But it is still
> interesting to keep in the loop to avoid 2 subsequent write_seqcount_begin()
> call being made in the same context (which would lead to an even sequence
> counter value while write operation is in progress). So I think this is
> still a good thing to have lockdep available here.

Ok so i had to read everything and i should have read everything before
asking all of the above. It does look good in fact, what worried my in
this patch is all the lockdep avoidance as it is usualy a red flags.

But after thinking long and hard i do not see how to easily solve that
one as unmap_page_range() is in so many different path... So what is done
in this patch is the most sane thing. Sorry for the noise.

So for this patch:

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

