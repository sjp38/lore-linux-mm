Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 090A8C76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 15:02:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A55782239F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 15:02:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A55782239F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1CE168E0003; Tue, 23 Jul 2019 11:02:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A6238E0002; Tue, 23 Jul 2019 11:02:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BD548E0003; Tue, 23 Jul 2019 11:02:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id DEDC68E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 11:02:47 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id m198so36570123qke.22
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 08:02:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=R5M2K4AjBjzXbSZ/zP6imFgwCWLsiDqliCyMwtU6WVA=;
        b=KrK1Whe0U3+9paAQfWJv4IRvX4VnrwurNYIsrz250K9nCh8w1g07A6gO8hRKRXLEfj
         DGqRYz9Qgm1oXSYdF7tDIt2NUgYHK1Hkhx7YnLvMHw4Zvs3/20i1UrjnRCii+SX8chmh
         iBPHH5OnPG/Q3TqkFikWOnJiPIkkUBuHhaFd5HJMimJjytDVvF4IReKKrBDjqUTuDCJq
         m50ZDNVsXZrK+M8fTyvNE6oxbWLETtDwlpe0nNEtd81P6Xg536q4MLuvOelVfA9d3RGc
         dneyoaG7gX4NLS9DX63Si3unt+nUKTeDhFYyi7rxOR5+EdpYDGrUxLr0fbRGbKpbbSqu
         kylw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAULHhjK6w786naf5U2dhtTmzC9Li1m5LyLqGANGIEVILPv4/SSF
	aYYdaI0yk6e4vo2o5SWRrdd8RLY/9ZLJpWDWnR3hixRqRnztb2dqkTLFvg5Gwfdn8raJ75PAQ9g
	MeyIVX40PfRgEXmiHuJHJr7SkFsDVvhdE0/26hjnnL56xGxliGkoKNy/comyYIo3UQg==
X-Received: by 2002:a0c:9916:: with SMTP id h22mr54031562qvd.95.1563894167662;
        Tue, 23 Jul 2019 08:02:47 -0700 (PDT)
X-Received: by 2002:a0c:9916:: with SMTP id h22mr54031507qvd.95.1563894166886;
        Tue, 23 Jul 2019 08:02:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563894166; cv=none;
        d=google.com; s=arc-20160816;
        b=EyTpcNSMLY5Tha17s2vAmTTK5LShC55nJu+3iKEQ+p7Tn9BD9srEFmNID1tRsWmeLV
         zKgjE8N5XZWVgvt7LEcAzr2fvjM56qDpMhQCQST05vSOVguWItWoSc6fdrSXngonuQbF
         nAS8e+5qA/sQ/HzTcdW1YDGtizUXpmMcbY+BPlqatNGgwSgrnWEnTEdfpIvUqtBG/+sK
         rR+pCCY2f4B9Ix4y+7Qwj8vNhiAwJn/GyzR9eSTlq4EQSFSIddcnX4uhgYjJulEg4gf2
         JUUP8urg/T0cSC8om01bxX0H3K610tlekvIshSgBomj3FOMNmyP89+9bIvgWeImCMAsr
         S9Rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=R5M2K4AjBjzXbSZ/zP6imFgwCWLsiDqliCyMwtU6WVA=;
        b=PijxsPmNp6P7mukEQvE8zf3xXOPRb8yzqkdYDuiskgq3pGO6twXLuLMZsagEybxUkQ
         oE5wTJN9XBMtg8VRxWak84zQhj9iBsomX9ylNJUDpzLOFl/72yfnDaCIjS0/6LnWIEeP
         7j7e/8Ejg4pouvBMSg2mXSMiohQ0zKRMPGsOXjIGNNQNKz3NdNdxclM231G/kDtNX0S6
         azO5EISfv1WhXTRuXuwyA4hjcqTsFviB4IrcY+x++0A6EXq10OzeQAT1QFfdxD53PvyQ
         typg8MV4aM4FA0Shxfs08qcCvzRSAQQhAYABGWNmfmSHMa1LcxH+VXEVZcuSuLEnDUDO
         6oiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y85sor24404565qka.135.2019.07.23.08.02.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 08:02:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxzk6SWsTdinjKSsA/de1iMdf+1ZzQW/oUQt2F/o3dsQk8ga4tD5zxAx4DzheYaNy643xaKrA==
X-Received: by 2002:ae9:e20c:: with SMTP id c12mr49989037qkc.210.1563894166621;
        Tue, 23 Jul 2019 08:02:46 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id s25sm18898787qkm.130.2019.07.23.08.02.39
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 08:02:45 -0700 (PDT)
Date: Tue, 23 Jul 2019 11:02:37 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
	aarcange@redhat.com, akpm@linux-foundation.org,
	christian@brauner.io, davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jglisse@redhat.com,
	keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: WARNING in __mmdrop
Message-ID: <20190723110219-mutt-send-email-mst@kernel.org>
References: <20190721044615-mutt-send-email-mst@kernel.org>
 <75c43998-3a1c-676f-99ff-3d04663c3fcc@redhat.com>
 <20190722035657-mutt-send-email-mst@kernel.org>
 <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
 <20190723010156-mutt-send-email-mst@kernel.org>
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032800-mutt-send-email-mst@kernel.org>
 <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
 <20190723062221-mutt-send-email-mst@kernel.org>
 <9baa4214-67fd-7ad2-cbad-aadf90bbfc20@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <9baa4214-67fd-7ad2-cbad-aadf90bbfc20@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 09:34:29PM +0800, Jason Wang wrote:
> 
> On 2019/7/23 下午6:27, Michael S. Tsirkin wrote:
> > > Yes, since there could be multiple co-current invalidation requests. We need
> > > count them to make sure we don't pin wrong pages.
> > > 
> > > 
> > > > I also wonder about ordering. kvm has this:
> > > >          /*
> > > >            * Used to check for invalidations in progress, of the pfn that is
> > > >            * returned by pfn_to_pfn_prot below.
> > > >            */
> > > >           mmu_seq = kvm->mmu_notifier_seq;
> > > >           /*
> > > >            * Ensure the read of mmu_notifier_seq isn't reordered with PTE reads in
> > > >            * gfn_to_pfn_prot() (which calls get_user_pages()), so that we don't
> > > >            * risk the page we get a reference to getting unmapped before we have a
> > > >            * chance to grab the mmu_lock without mmu_notifier_retry() noticing.
> > > >            *
> > > >            * This smp_rmb() pairs with the effective smp_wmb() of the combination
> > > >            * of the pte_unmap_unlock() after the PTE is zapped, and the
> > > >            * spin_lock() in kvm_mmu_notifier_invalidate_<page|range_end>() before
> > > >            * mmu_notifier_seq is incremented.
> > > >            */
> > > >           smp_rmb();
> > > > 
> > > > does this apply to us? Can't we use a seqlock instead so we do
> > > > not need to worry?
> > > I'm not familiar with kvm MMU internals, but we do everything under of
> > > mmu_lock.
> > > 
> > > Thanks
> > I don't think this helps at all.
> > 
> > There's no lock between checking the invalidate counter and
> > get user pages fast within vhost_map_prefetch. So it's possible
> > that get user pages fast reads PTEs speculatively before
> > invalidate is read.
> > 
> > -- 
> 
> 
> In vhost_map_prefetch() we do:
> 
>         spin_lock(&vq->mmu_lock);
> 
>         ...
> 
>         err = -EFAULT;
>         if (vq->invalidate_count)
>                 goto err;
> 
>         ...
> 
>         npinned = __get_user_pages_fast(uaddr->uaddr, npages,
>                                         uaddr->write, pages);
> 
>         ...
> 
>         spin_unlock(&vq->mmu_lock);
> 
> Is this not sufficient?
> 
> Thanks

So what orders __get_user_pages_fast wrt invalidate_count read?

-- 
MST

