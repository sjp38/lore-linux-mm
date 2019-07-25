Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2FAA9C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:28:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E09F321871
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 08:28:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E09F321871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 733758E0053; Thu, 25 Jul 2019 04:28:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E2578E0031; Thu, 25 Jul 2019 04:28:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AAC48E0053; Thu, 25 Jul 2019 04:28:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4C88E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:28:50 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id z13so41744800qka.15
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 01:28:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=W9gVDQuWc00uLJaqP5LZiohnBPPDA5P8er6pMpADl+8=;
        b=aBKuBTW8Gn1XxeG93dXw299OmRABJuS8xur1v+5cqFwryINmlQ2ufn6yfDrynSUWku
         vn3sBG3Sg86slcV7tk+4qYjA4jFjxxdlCkVB5Oq6MjK2PP5HN4jg6vTLNGCsw6Jocz0r
         RfsFuJl3Co8ELuyT9ixDPEdpfGtl4CV67QjzOwvRGqdKzwu+03VCkEyNB5Gdxg/eZj5G
         l9UI6IxuSiCYCNgnGjAYGGdz+usrQEA53+zNjVuK1vudZZFJdaheDXWGHyba0NgIPdPN
         py8QHLQpCnDX6EdhWeN0FLI8ZSiz2OzREVG8CtoXWNSVrYu81V6vnK8I507FnyO2Qmxg
         AmTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWdVEgEeNx9mgrm2sd4B7ua+yLnuQQqM2oGwrtc1PJMYo0fQLbt
	duxtHyN5TPlq7kxTzurkrMozPYNCpORyAPWmaDPW36ioF6wMCm/m5ok6GH/HTluYcnOH9fJj1LM
	ozTlLi8oBGyTkprttkGBOLGv3wmye1FBCxrOix8arXorlOlP+07xvWjOu/oMP+zZtTg==
X-Received: by 2002:a05:620a:35e:: with SMTP id t30mr54511447qkm.1.1564043330004;
        Thu, 25 Jul 2019 01:28:50 -0700 (PDT)
X-Received: by 2002:a05:620a:35e:: with SMTP id t30mr54511421qkm.1.1564043329285;
        Thu, 25 Jul 2019 01:28:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564043329; cv=none;
        d=google.com; s=arc-20160816;
        b=IHfogieb72dGMKDhbFkivXqMmi+yLikUFkACPxiTcozyZYs8oXptrcL1ejIdGBAPbd
         0g5poLzKjaCGgmQKhC8y3wgGuirEY4D1984eir/dvJHYokGPiM/yPyam/GYlz/1DsRXj
         Zb6bKa561v/AZ97ivDYhiVseFUo9OcSXVVMIR1YJY9PFwh3eciL/E34c86+yZUNKRaVL
         qIEqWbggitlhszjVpeL3+qERrHlwKgvwtddahCWLbsGqv/TZRzNavr5wJ+VxbPMM6g+G
         KyQCFx9dQk2bc3ZwGXYwBJlGzpvXnqLGoBjHzSe6OQljgyjCRiOO81oze/h/cJPB8UkX
         C94w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=W9gVDQuWc00uLJaqP5LZiohnBPPDA5P8er6pMpADl+8=;
        b=aQ4LJvXoEdmMLZ1v2TGhVFjg79mQQnrBs5zyGs5xyw61NMBI+90X+qXgrF6b9dZprK
         FoYyYtBk2eGj4h4sC/QcOxEpRJ3avFDfgJIElwt38QCy5GIh8H7ba43TGYINrW7vpb0C
         y2ucSq3+ZUcZfiKiNvNoBLiUdfuiYj1FLJHS+i98BSqdU74X1eFFWv4uIbKUewVvOnPw
         TIvYYg5H49ZyTe4Tv86XBx+IvrBiXgQWjQYVLEL6lx5YYg8gC65/kPgjgTUdoWZqrGiU
         WzUsw79R+yrAOAmgIbYPU2iHUR6uuvnsWEmJOVz5Yg1AR0rbQMEPxY4dBU6XLAo2OMrn
         Alzg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 56sor64926421qtp.70.2019.07.25.01.28.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jul 2019 01:28:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqypxxYh1SBYrdx7sBULiRodWoRyZYhZUU0NIqTYlxg9WD9pqSvNPlHTYL+xZ+kptrKYhL64aw==
X-Received: by 2002:aed:3667:: with SMTP id e94mr55831866qtb.382.1564043329003;
        Thu, 25 Jul 2019 01:28:49 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id z21sm19762286qto.48.2019.07.25.01.28.41
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 25 Jul 2019 01:28:48 -0700 (PDT)
Date: Thu, 25 Jul 2019 04:28:39 -0400
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
Message-ID: <20190725042651-mutt-send-email-mst@kernel.org>
References: <20190723010019-mutt-send-email-mst@kernel.org>
 <b4696f2e-678a-bdb2-4b7c-fb4ce040ec2a@redhat.com>
 <20190723032024-mutt-send-email-mst@kernel.org>
 <1d14de4d-0133-1614-9f64-3ded381de04e@redhat.com>
 <20190723035725-mutt-send-email-mst@kernel.org>
 <3f4178f1-0d71-e032-0f1f-802428ceca59@redhat.com>
 <20190723051828-mutt-send-email-mst@kernel.org>
 <caff362a-e208-3468-3688-63e1d093a9d3@redhat.com>
 <20190725012149-mutt-send-email-mst@kernel.org>
 <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 03:43:41PM +0800, Jason Wang wrote:
> 
> On 2019/7/25 下午1:52, Michael S. Tsirkin wrote:
> > On Tue, Jul 23, 2019 at 09:31:35PM +0800, Jason Wang wrote:
> > > On 2019/7/23 下午5:26, Michael S. Tsirkin wrote:
> > > > On Tue, Jul 23, 2019 at 04:49:01PM +0800, Jason Wang wrote:
> > > > > On 2019/7/23 下午4:10, Michael S. Tsirkin wrote:
> > > > > > On Tue, Jul 23, 2019 at 03:53:06PM +0800, Jason Wang wrote:
> > > > > > > On 2019/7/23 下午3:23, Michael S. Tsirkin wrote:
> > > > > > > > > > Really let's just use kfree_rcu. It's way cleaner: fire and forget.
> > > > > > > > > Looks not, you need rate limit the fire as you've figured out?
> > > > > > > > See the discussion that followed. Basically no, it's good enough
> > > > > > > > already and is only going to be better.
> > > > > > > > 
> > > > > > > > > And in fact,
> > > > > > > > > the synchronization is not even needed, does it help if I leave a comment to
> > > > > > > > > explain?
> > > > > > > > Let's try to figure it out in the mail first. I'm pretty sure the
> > > > > > > > current logic is wrong.
> > > > > > > Here is what the code what to achieve:
> > > > > > > 
> > > > > > > - The map was protected by RCU
> > > > > > > 
> > > > > > > - Writers are: MMU notifier invalidation callbacks, file operations (ioctls
> > > > > > > etc), meta_prefetch (datapath)
> > > > > > > 
> > > > > > > - Readers are: memory accessor
> > > > > > > 
> > > > > > > Writer are synchronized through mmu_lock. RCU is used to synchronized
> > > > > > > between writers and readers.
> > > > > > > 
> > > > > > > The synchronize_rcu() in vhost_reset_vq_maps() was used to synchronized it
> > > > > > > with readers (memory accessors) in the path of file operations. But in this
> > > > > > > case, vq->mutex was already held, this means it has been serialized with
> > > > > > > memory accessor. That's why I think it could be removed safely.
> > > > > > > 
> > > > > > > Anything I miss here?
> > > > > > > 
> > > > > > So invalidate callbacks need to reset the map, and they do
> > > > > > not have vq mutex. How can they do this and free
> > > > > > the map safely? They need synchronize_rcu or kfree_rcu right?
> > > > > Invalidation callbacks need but file operations (e.g ioctl) not.
> > > > > 
> > > > > 
> > > > > > And I worry somewhat that synchronize_rcu in an MMU notifier
> > > > > > is a problem, MMU notifiers are supposed to be quick:
> > > > > Looks not, since it can allow to be blocked and lots of driver depends on
> > > > > this. (E.g mmu_notifier_range_blockable()).
> > > > Right, they can block. So why don't we take a VQ mutex and be
> > > > done with it then? No RCU tricks.
> > > 
> > > This is how I want to go with RFC and V1. But I end up with deadlock between
> > > vq locks and some MM internal locks. So I decide to use RCU which is 100%
> > > under the control of vhost.
> > > 
> > > Thanks
> > And I guess the deadlock is because GUP is taking mmu locks which are
> > taken on mmu notifier path, right?
> 
> 
> Yes, but it's not the only lock. I don't remember the details, but I can
> confirm I meet issues with one or two other locks.
> 
> 
> >    How about we add a seqlock and take
> > that in invalidate callbacks?  We can then drop the VQ lock before GUP,
> > and take it again immediately after.
> > 
> > something like
> > 	if (!vq_meta_mapped(vq)) {
> > 		vq_meta_setup(&uaddrs);
> > 		mutex_unlock(vq->mutex)
> > 		vq_meta_map(&uaddrs);
> 
> 
> The problem is the vq address could be changed at this time.
> 
> 
> > 		mutex_lock(vq->mutex)
> > 
> > 		/* recheck both sock->private_data and seqlock count. */
> > 		if changed - bail out
> > 	}
> > 
> > And also requires that VQ uaddrs is defined like this:
> > - writers must have both vq mutex and dev mutex
> > - readers must have either vq mutex or dev mutex
> > 
> > 
> > That's a big change though. For now, how about switching to a per-vq SRCU?
> > That is only a little bit more expensive than RCU, and we
> > can use synchronize_srcu_expedited.
> > 
> 
> Consider we switch to use kfree_rcu(), what's the advantage of per-vq SRCU?
> 
> Thanks


I thought we established that notifiers must wait for
all readers to finish before they mark page dirty, to
prevent page from becoming dirty after address
has been invalidated.
Right?

