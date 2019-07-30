Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E740BC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:08:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D33920657
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 15:08:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D33920657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 18F788E0009; Tue, 30 Jul 2019 11:08:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 140928E0001; Tue, 30 Jul 2019 11:08:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02DDB8E0009; Tue, 30 Jul 2019 11:08:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D23A08E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 11:08:40 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k13so55307114qkj.4
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 08:08:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=HzqScm+MgZUE/z+FZh2jR3LjGduzejNoschvUbrV2xA=;
        b=nxhJbLcKj7yN7e644I+dOcpV2KJ2H2C5fbtYa1GkDA2IIPQz8VuxoOA33UmiWJfnVr
         ePOc5CEIYK1cXLgcOF1WQq6np9TiNDodiAQaSXHGMci2+pxPgmLQ8tidFvbgSrGlLpIF
         qDz8BETTdE2SIkUhyk8GQBOn/+KxBALmZR347/XLRpj2DBFAHnaJ//rquCiQFVVJIxWU
         yzuKDUf1zZavfX6O4h4DVhDl32Xb/EfRH4Jr9NvWwteyeDAKGCj4l+h7cumfLbt1HnCo
         yGWzjkLZBAGY9RBDqaY5y5ybyDhJy6KoWQjY+nzsRtgP0I4sli3axKB299m+1ypiLDPY
         NCiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU/wMCtjwr31pFLidnlBo7TNHC6U7JqtkVlDRhiLC4SeE8jPBAU
	cSMumzCvdlPJeqeZp0Iegc3uznyNsiQOC7kFR951scLFp7yWajeMf/2ib1zFI6OjgMC5iMkmRWj
	C6+dNIKqQ72ScoGmNoFEJw8jQCqfE/elOuu/JGGi8ZA8J343Zfc/WgUgLqIR8n+1a6A==
X-Received: by 2002:a05:620a:15f1:: with SMTP id p17mr23563017qkm.246.1564499320611;
        Tue, 30 Jul 2019 08:08:40 -0700 (PDT)
X-Received: by 2002:a05:620a:15f1:: with SMTP id p17mr23562945qkm.246.1564499319708;
        Tue, 30 Jul 2019 08:08:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564499319; cv=none;
        d=google.com; s=arc-20160816;
        b=i3/IykpLHWV9fr4z1k/AR5cjuKGvEEwUd0WKQw/UvqiB5ORkRVO1ZZCH2LBMOh1MO+
         JIxccCvx5KBg+a98lhnWYanTqeWEN6yYKkv7uTFIqKLkwpNWLOsz77Re7RN05QKIg2gi
         mYpX9rMDaamCqPXoXIyHwtJteToQDTzyOmwdJl8PvCnt9Kbmht4s9hf0lkBkcbJ4JLiy
         WZDwIHoQuwH8lEyqoME4ujC1BEx8Telb6MF+AbfHtElz8F/PiIl2IzOLKr1NvLfeMtwy
         20P7jVOH6CPFGt7oD86df58PS2/KR/lBjO42xY3yN8aqgstvkjOInHmpSGKA6agTw791
         pvEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=HzqScm+MgZUE/z+FZh2jR3LjGduzejNoschvUbrV2xA=;
        b=NOJu/BH9GHr7nXHSNgbMPylgfKijCE05VnQXKnK8HjVbHiUHcIdqevppqBDYPVZKLW
         9Clv+6tje6dcoXN3SlUpO+E6H3HR01bTXIpWhdl7q0INIkYgvkyoA2LhDLntJmQrSCzQ
         rhAsF+9ey5FhLi+92qWYxAjwlg+e2Xr5OVr+3+TQ2xY5XeEMxZBzBurPJ9WvI9kPKenW
         854EPyXFjZnwj34p+RdQu8NF/70pfLhThqg1QZ59IQvR71hcSm2wTEQUDdKespIiqeVG
         yBCqALn/WeA2xz2TX+qJEg4luFJNb0Zxz0B0Quta6ngXyiQZHAu40KThPWjJ392snj0l
         FAYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m17sor84219164qtp.16.2019.07.30.08.08.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Jul 2019 08:08:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqyAEcQ2rI90c7ov4XOcxi/h1Ciz83jV4TqK4E5vsU115tJuJqCFIr/5rf4KY/QKmO1zU9cv0g==
X-Received: by 2002:ac8:2b14:: with SMTP id 20mr84731688qtu.295.1564499319358;
        Tue, 30 Jul 2019 08:08:39 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id z1sm29387735qke.122.2019.07.30.08.08.32
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 30 Jul 2019 08:08:38 -0700 (PDT)
Date: Tue, 30 Jul 2019 11:08:30 -0400
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
Message-ID: <20190730110633-mutt-send-email-mst@kernel.org>
References: <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <aaefa93e-a0de-1c55-feb0-509c87aae1f3@redhat.com>
 <20190726094756-mutt-send-email-mst@kernel.org>
 <0792ee09-b4b7-673c-2251-e5e0ce0fbe32@redhat.com>
 <20190729045127-mutt-send-email-mst@kernel.org>
 <4d43c094-44ed-dbac-b863-48fc3d754378@redhat.com>
 <20190729104028-mutt-send-email-mst@kernel.org>
 <96b1d67c-3a8d-1224-e9f0-5f7725a3dc10@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <96b1d67c-3a8d-1224-e9f0-5f7725a3dc10@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 03:44:47PM +0800, Jason Wang wrote:
> 
> On 2019/7/29 下午10:44, Michael S. Tsirkin wrote:
> > On Mon, Jul 29, 2019 at 10:24:43PM +0800, Jason Wang wrote:
> > > On 2019/7/29 下午4:59, Michael S. Tsirkin wrote:
> > > > On Mon, Jul 29, 2019 at 01:54:49PM +0800, Jason Wang wrote:
> > > > > On 2019/7/26 下午9:49, Michael S. Tsirkin wrote:
> > > > > > > > Ok, let me retry if necessary (but I do remember I end up with deadlocks
> > > > > > > > last try).
> > > > > > > Ok, I play a little with this. And it works so far. Will do more testing
> > > > > > > tomorrow.
> > > > > > > 
> > > > > > > One reason could be I switch to use get_user_pages_fast() to
> > > > > > > __get_user_pages_fast() which doesn't need mmap_sem.
> > > > > > > 
> > > > > > > Thanks
> > > > > > OK that sounds good. If we also set a flag to make
> > > > > > vhost_exceeds_weight exit, then I think it will be all good.
> > > > > After some experiments, I came up two methods:
> > > > > 
> > > > > 1) switch to use vq->mutex, then we must take the vq lock during range
> > > > > checking (but I don't see obvious slowdown for 16vcpus + 16queues). Setting
> > > > > flags during weight check should work but it still can't address the worst
> > > > > case: wait for the page to be swapped in. Is this acceptable?
> > > > > 
> > > > > 2) using current RCU but replace synchronize_rcu() with vhost_work_flush().
> > > > > The worst case is the same as 1) but we can check range without holding any
> > > > > locks.
> > > > > 
> > > > > Which one did you prefer?
> > > > > 
> > > > > Thanks
> > > > I would rather we start with 1 and switch to 2 after we
> > > > can show some gain.
> > > > 
> > > > But the worst case needs to be addressed.
> > > 
> > > Yes.
> > > 
> > > 
> > > > How about sending a signal to
> > > > the vhost thread?  We will need to fix up error handling (I think that
> > > > at the moment it will error out in that case, handling this as EFAULT -
> > > > and we don't want to drop packets if we can help it, and surely not
> > > > enter any error states.  In particular it might be especially tricky if
> > > > we wrote into userspace memory and are now trying to log the write.
> > > > I guess we can disable the optimization if log is enabled?).
> > > 
> > > This may work but requires a lot of changes.
> > I agree.
> > 
> > > And actually it's the price of
> > > using vq mutex.
> > Not sure what's meant here.
> 
> 
> I mean if we use vq mutex, it means the critical section was increased and
> we need to deal with swapping then.
> 
> 
> > 
> > > Actually, the critical section should be rather small, e.g
> > > just inside memory accessors.
> > Also true.
> > 
> > > I wonder whether or not just do synchronize our self like:
> > > 
> > > static void inline vhost_inc_vq_ref(struct vhost_virtqueue *vq)
> > > {
> > >          int ref = READ_ONCE(vq->ref);
> > > 
> > >          WRITE_ONCE(vq->ref, ref + 1);
> > > smp_rmb();
> > > }
> > > 
> > > static void inline vhost_dec_vq_ref(struct vhost_virtqueue *vq)
> > > {
> > >          int ref = READ_ONCE(vq->ref);
> > > 
> > > smp_wmb();
> > >          WRITE_ONCE(vq->ref, ref - 1);
> > > }
> > > 
> > > static void inline vhost_wait_for_ref(struct vhost_virtqueue *vq)
> > > {
> > >          while (READ_ONCE(vq->ref));
> > > mb();
> > > }
> > Looks good but I'd like to think of a strategy/existing lock that let us
> > block properly as opposed to spinning, that would be more friendly to
> > e.g. the realtime patch.
> 
> 
> Does it make sense to disable preemption in the critical section? Then we
> don't need to block and we have a deterministic time spent on memory
> accssors?

Hmm maybe. I'm getting really nervious at this point - we
seem to be using every trick in the book.

> 
> > 
> > > Or using smp_load_acquire()/smp_store_release() instead?
> > > 
> > > Thanks
> > These are cheaper on x86, yes.
> 
> 
> Will use this.
> 
> Thanks
> 
> 

This looks suspiciously like a seqlock though.
Can that be used somehow?

