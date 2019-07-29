Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F319C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:44:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27CAB216C8
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 14:44:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27CAB216C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 898208E0008; Mon, 29 Jul 2019 10:44:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 84A288E0007; Mon, 29 Jul 2019 10:44:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 737B58E0008; Mon, 29 Jul 2019 10:44:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 571A48E0007
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 10:44:49 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f28so55334864qtg.2
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 07:44:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=DoNqX8RWU8p5wa0hRf4mpfQk5+CoY4k3BggOB+rTukY=;
        b=NAWPwh7CGZeCI3xPXq0UTsuVAWbrFKuo1fTELOW4ZctUXlOb/p7AZTGlPpHA5gFVQp
         HKJK+YK7T0DxAdc/2SY9fBDTf3jZK1S7Eb/XrXLNk+4olLEg9ufA4n99u6/0Lo9H0aGi
         sl8SkVBZ0AUIAmmNdu8u8P4ctfrB5mjeVjE9ZtdpxzaRc5OgaMMmE29z9aQ3wIzubIeR
         Jx9OX1mB7i7/jGmh2iSR2UxAK7E24s5pBHdK8TVmspbjfgD54jl1sODwq4PipoFI/V+S
         qn7B5vR0r74U10QvEXR3aPF/tu5zhPyTyjG+TukuHyCoyq7qz0x+ichWuDCSltfkfbcp
         WqjA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUFm0/AtWCqZWMVnJTs+c56Tx+E++X7oYgzDkyq17N4uRHbVavM
	IujrZFlQDBtzrrQnow1xHai+PE4Uj/bI3czLxEFZH7fsp3XgUQNIf4Jszq+x9Xn7468Z6mWzMl3
	EAw7JTUedvK7k0M6jtvXjx1wTLpILJn/zJFg+NozkMAch9EiWBg2tgsBZ8Sz1e0NhNw==
X-Received: by 2002:a0c:96e7:: with SMTP id b36mr79885593qvd.155.1564411488967;
        Mon, 29 Jul 2019 07:44:48 -0700 (PDT)
X-Received: by 2002:a0c:96e7:: with SMTP id b36mr79885567qvd.155.1564411488108;
        Mon, 29 Jul 2019 07:44:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564411488; cv=none;
        d=google.com; s=arc-20160816;
        b=LZ4HFdMuCC8OUtwJGDrq04kmAZPp+/fJo8Z35t5cjgiiAgfXEaQ29CKMLI99m1nQMd
         lG420mu9g+RxkH7ZESBwKvVu/W4KLOUt6mmaprYB7BWPm9/6bt5xUr2UtkZCuQxzKvzT
         Zi/JEAOftdngo/6S3iOJISE6MASaWHkk3aI+epiKWQEmbMqTubpgi1bbd/aI/W20A0fq
         xPIIVaszB1uTn0Bj9rTru4Fr61g1JhfvTfnc3OCViU6SjO/Z/IT2HTLfl2jJBqiVo2kF
         lmDzDnK0k71dJORQmX/DcC7voVIiIfQgmgCC7EJPg0qa/SWc1tSMudXOq8qImvJE08/R
         u3Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=DoNqX8RWU8p5wa0hRf4mpfQk5+CoY4k3BggOB+rTukY=;
        b=ExHAhiHkxUf7yrxeWHrW5GI3JpNaZmXQQLwztrQqcTOGDmBNCDmbhA7befdMFpNo5i
         hp8d783OJGV0UcPyrVBpEghz76mOkC0gG+EuAB4jFyPIIDi+hURbHKHiymu5fhP+R5q6
         L+MUD6hCr0NIZTi0fJ3Iutw1YFTKF6TrB5HqKtsXMdNHgRzym+jAiNB2aglwXN5KiLMM
         KdeM4CCBty/2l0CgwKKE+aZvY4rIUtLJDHEXDYcS2CGjs5zt52h4AOHoIAFqHK0VzZqg
         NngR3CRQGnWoNCmN8tVOLypUvhZTC1Ubk4j4oVfM/L564pcZnbJ7xh3xFP7xdJaT1Wwq
         55Sg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c38sor80277681qtb.10.2019.07.29.07.44.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 07:44:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzNcK5rFMdgsRbkuArHCZVYZl892hVxXOzQtGKKSReE48444ntmi3JNc+/o/FUr3NCS9WKM/g==
X-Received: by 2002:ac8:384c:: with SMTP id r12mr77572808qtb.153.1564411487834;
        Mon, 29 Jul 2019 07:44:47 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id h40sm35464987qth.4.2019.07.29.07.44.40
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 07:44:46 -0700 (PDT)
Date: Mon, 29 Jul 2019 10:44:38 -0400
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
Message-ID: <20190729104028-mutt-send-email-mst@kernel.org>
References: <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <aaefa93e-a0de-1c55-feb0-509c87aae1f3@redhat.com>
 <20190726094756-mutt-send-email-mst@kernel.org>
 <0792ee09-b4b7-673c-2251-e5e0ce0fbe32@redhat.com>
 <20190729045127-mutt-send-email-mst@kernel.org>
 <4d43c094-44ed-dbac-b863-48fc3d754378@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4d43c094-44ed-dbac-b863-48fc3d754378@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 10:24:43PM +0800, Jason Wang wrote:
> 
> On 2019/7/29 下午4:59, Michael S. Tsirkin wrote:
> > On Mon, Jul 29, 2019 at 01:54:49PM +0800, Jason Wang wrote:
> > > On 2019/7/26 下午9:49, Michael S. Tsirkin wrote:
> > > > > > Ok, let me retry if necessary (but I do remember I end up with deadlocks
> > > > > > last try).
> > > > > Ok, I play a little with this. And it works so far. Will do more testing
> > > > > tomorrow.
> > > > > 
> > > > > One reason could be I switch to use get_user_pages_fast() to
> > > > > __get_user_pages_fast() which doesn't need mmap_sem.
> > > > > 
> > > > > Thanks
> > > > OK that sounds good. If we also set a flag to make
> > > > vhost_exceeds_weight exit, then I think it will be all good.
> > > 
> > > After some experiments, I came up two methods:
> > > 
> > > 1) switch to use vq->mutex, then we must take the vq lock during range
> > > checking (but I don't see obvious slowdown for 16vcpus + 16queues). Setting
> > > flags during weight check should work but it still can't address the worst
> > > case: wait for the page to be swapped in. Is this acceptable?
> > > 
> > > 2) using current RCU but replace synchronize_rcu() with vhost_work_flush().
> > > The worst case is the same as 1) but we can check range without holding any
> > > locks.
> > > 
> > > Which one did you prefer?
> > > 
> > > Thanks
> > I would rather we start with 1 and switch to 2 after we
> > can show some gain.
> > 
> > But the worst case needs to be addressed.
> 
> 
> Yes.
> 
> 
> > How about sending a signal to
> > the vhost thread?  We will need to fix up error handling (I think that
> > at the moment it will error out in that case, handling this as EFAULT -
> > and we don't want to drop packets if we can help it, and surely not
> > enter any error states.  In particular it might be especially tricky if
> > we wrote into userspace memory and are now trying to log the write.
> > I guess we can disable the optimization if log is enabled?).
> 
> 
> This may work but requires a lot of changes.

I agree.

> And actually it's the price of
> using vq mutex. 

Not sure what's meant here.

> Actually, the critical section should be rather small, e.g
> just inside memory accessors.

Also true.

> 
> I wonder whether or not just do synchronize our self like:
> 
> static void inline vhost_inc_vq_ref(struct vhost_virtqueue *vq)
> {
>         int ref = READ_ONCE(vq->ref);
> 
>         WRITE_ONCE(vq->ref, ref + 1);
> smp_rmb();
> }
> 
> static void inline vhost_dec_vq_ref(struct vhost_virtqueue *vq)
> {
>         int ref = READ_ONCE(vq->ref);
> 
> smp_wmb();
>         WRITE_ONCE(vq->ref, ref - 1);
> }
> 
> static void inline vhost_wait_for_ref(struct vhost_virtqueue *vq)
> {
>         while (READ_ONCE(vq->ref));
> mb();
> }

Looks good but I'd like to think of a strategy/existing lock that let us
block properly as opposed to spinning, that would be more friendly to
e.g. the realtime patch.

> 
> Or using smp_load_acquire()/smp_store_release() instead?
> 
> Thanks

These are cheaper on x86, yes.

> > 

