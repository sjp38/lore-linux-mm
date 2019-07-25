Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF565C76194
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:53:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70712204EC
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 05:53:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70712204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 008678E001C; Thu, 25 Jul 2019 01:53:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F1FC38E0031; Thu, 25 Jul 2019 01:53:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0E518E001C; Thu, 25 Jul 2019 01:53:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id BF6668E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:53:03 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id r58so43656934qtb.5
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 22:53:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=JO71JAUQG8v5NWS9aFNJS8lKMgEFxdUfgocNmFAYG40=;
        b=CoSAJgEO5IWxCc+yKZXfFizZy5fOt2fsq6cess5KmtA7fFAL7OSFTS0A0gRTAu1m6G
         6xaxAtL1fVXvxm4oC2PRpR1H8eybpVZ0Fso0BFA9gt9HTLO4/cDMMBobSoOTEr12De1j
         cLIZLb034GXehwlcAb6REdAx3BDl+3gz49mAQB22xnvdJSZqqbWMPYly0K5IJ/jXXdjB
         QkQ3/h2QDy/8005aNPv+ljAHcGdIDFxEc0V3mXFKRLn1Wx5R9jPcKIvVSkQLP1924hw4
         9zt2aNunwjKGOlw08/c/xjXfezamgrROuxvVKFN0IUPT3ms9QplfNhRBnZVI6xBVWxhF
         Jnxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWtKqHot4u6jAPVN8tLM6jtZlv3JqDKJ75b0cpQTXQY4rX9uG4t
	N+aSN+xK69DPB9yTzOAO1uqzAQGtmm4z5iR/zN6XXgbJIzXZfmBmJm219aq2RbjDZCvWvSa8qc4
	NJeA3UQVdu7rQ3dBDhlnOph1E1GkOnrC3qID8c/7SVq8zBwobM7z1QW65tSFyQwPVdA==
X-Received: by 2002:a37:8ac3:: with SMTP id m186mr38307122qkd.476.1564033983551;
        Wed, 24 Jul 2019 22:53:03 -0700 (PDT)
X-Received: by 2002:a37:8ac3:: with SMTP id m186mr38307097qkd.476.1564033982844;
        Wed, 24 Jul 2019 22:53:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564033982; cv=none;
        d=google.com; s=arc-20160816;
        b=hFQzMEIwQBu6BUMyWWvrlnzstzu3UDiFH+J+O7+Ky/hUN6uyGlMic3+Jud/Z/mRtc2
         NfT5qiMRyZBtbEOtA14c7BVRdmp+4NSxnCm8QJ4N3vUpH/f5XFix8Mmo593sXgO4/xkC
         39gnA2aCQv7OSNJ0u0NEwB41YOIlp5nR+E8ycNEPHyX/79u2GXitsCgttm6hkO5rzF5P
         g8DFT2BjyER5xmZNcDkW241YWxX5bCGUFcdEaqG1USCHCEO0C5d/kipX9Pf1mZSlHqCR
         uXFyFbiZZ9Z8P66BowsL+sbTGdoyApUkSMJhpSYS4CMVRb7Vomjsum9ojSEHrqyMLyyy
         gIIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=JO71JAUQG8v5NWS9aFNJS8lKMgEFxdUfgocNmFAYG40=;
        b=zWA/s0ZW9HtYkSP4xwJheSBnWeRAqzY82egZ0kkQKsWeDVtXk9ne8evaIwzavkmCCE
         Q5+BxrkJJqRDYxAVKRGHj/a1PSxscbmi21T5yI3IdpytcaAjKZqKG7KApd4Df0vcdsLR
         Pt2Kysz/ZNuHGLI87r0gwx7rQJfcHiYr5tPauhU3Q7CnuBdS+BIeKPCLNdi6w9LecHHt
         CuorPi0iQ/WkRsjz8+WQLPQW2NeExqLVAzaodjiGL7YfRObJnbmC0wdfySz5vpjzA28n
         BPMz/YSwiMRX+mz9bCY4I96zUpi/eIeQKuwHMIO7K+OjelrWm9KBseQ/mdFGW+3uB/cn
         CLKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s65sor27992191qkh.53.2019.07.24.22.53.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 22:53:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzSdjCF8KfvPtVJQN/Fq3QA2lZs756ix2x+aw9grYNxhN50Gd3YATAXPDQIBe87A663Tz88jg==
X-Received: by 2002:a37:91c2:: with SMTP id t185mr56548270qkd.193.1564033982538;
        Wed, 24 Jul 2019 22:53:02 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id p3sm33849924qta.12.2019.07.24.22.52.55
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 22:53:01 -0700 (PDT)
Date: Thu, 25 Jul 2019 01:52:53 -0400
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
Message-ID: <20190725012149-mutt-send-email-mst@kernel.org>
References: <20190722040230-mutt-send-email-mst@kernel.org>
 <4bd2ff78-6871-55f2-44dc-0982ffef3337@redhat.com>
 <20190723010019-mutt-send-email-mst@kernel.org>
 <b4696f2e-678a-bdb2-4b7c-fb4ce040ec2a@redhat.com>
 <20190723032024-mutt-send-email-mst@kernel.org>
 <1d14de4d-0133-1614-9f64-3ded381de04e@redhat.com>
 <20190723035725-mutt-send-email-mst@kernel.org>
 <3f4178f1-0d71-e032-0f1f-802428ceca59@redhat.com>
 <20190723051828-mutt-send-email-mst@kernel.org>
 <caff362a-e208-3468-3688-63e1d093a9d3@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <caff362a-e208-3468-3688-63e1d093a9d3@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 09:31:35PM +0800, Jason Wang wrote:
> 
> On 2019/7/23 下午5:26, Michael S. Tsirkin wrote:
> > On Tue, Jul 23, 2019 at 04:49:01PM +0800, Jason Wang wrote:
> > > On 2019/7/23 下午4:10, Michael S. Tsirkin wrote:
> > > > On Tue, Jul 23, 2019 at 03:53:06PM +0800, Jason Wang wrote:
> > > > > On 2019/7/23 下午3:23, Michael S. Tsirkin wrote:
> > > > > > > > Really let's just use kfree_rcu. It's way cleaner: fire and forget.
> > > > > > > Looks not, you need rate limit the fire as you've figured out?
> > > > > > See the discussion that followed. Basically no, it's good enough
> > > > > > already and is only going to be better.
> > > > > > 
> > > > > > > And in fact,
> > > > > > > the synchronization is not even needed, does it help if I leave a comment to
> > > > > > > explain?
> > > > > > Let's try to figure it out in the mail first. I'm pretty sure the
> > > > > > current logic is wrong.
> > > > > Here is what the code what to achieve:
> > > > > 
> > > > > - The map was protected by RCU
> > > > > 
> > > > > - Writers are: MMU notifier invalidation callbacks, file operations (ioctls
> > > > > etc), meta_prefetch (datapath)
> > > > > 
> > > > > - Readers are: memory accessor
> > > > > 
> > > > > Writer are synchronized through mmu_lock. RCU is used to synchronized
> > > > > between writers and readers.
> > > > > 
> > > > > The synchronize_rcu() in vhost_reset_vq_maps() was used to synchronized it
> > > > > with readers (memory accessors) in the path of file operations. But in this
> > > > > case, vq->mutex was already held, this means it has been serialized with
> > > > > memory accessor. That's why I think it could be removed safely.
> > > > > 
> > > > > Anything I miss here?
> > > > > 
> > > > So invalidate callbacks need to reset the map, and they do
> > > > not have vq mutex. How can they do this and free
> > > > the map safely? They need synchronize_rcu or kfree_rcu right?
> > > Invalidation callbacks need but file operations (e.g ioctl) not.
> > > 
> > > 
> > > > And I worry somewhat that synchronize_rcu in an MMU notifier
> > > > is a problem, MMU notifiers are supposed to be quick:
> > > Looks not, since it can allow to be blocked and lots of driver depends on
> > > this. (E.g mmu_notifier_range_blockable()).
> > Right, they can block. So why don't we take a VQ mutex and be
> > done with it then? No RCU tricks.
> 
> 
> This is how I want to go with RFC and V1. But I end up with deadlock between
> vq locks and some MM internal locks. So I decide to use RCU which is 100%
> under the control of vhost.
> 
> Thanks

And I guess the deadlock is because GUP is taking mmu locks which are
taken on mmu notifier path, right?  How about we add a seqlock and take
that in invalidate callbacks?  We can then drop the VQ lock before GUP,
and take it again immediately after.

something like
	if (!vq_meta_mapped(vq)) {
		vq_meta_setup(&uaddrs);
		mutex_unlock(vq->mutex)
		vq_meta_map(&uaddrs);
		mutex_lock(vq->mutex)

		/* recheck both sock->private_data and seqlock count. */
		if changed - bail out
	}

And also requires that VQ uaddrs is defined like this:
- writers must have both vq mutex and dev mutex
- readers must have either vq mutex or dev mutex


That's a big change though. For now, how about switching to a per-vq SRCU?
That is only a little bit more expensive than RCU, and we
can use synchronize_srcu_expedited.

-- 
MST

