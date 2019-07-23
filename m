Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8A1FC76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 10:28:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CC132251A
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 10:28:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CC132251A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F2426B0007; Tue, 23 Jul 2019 06:27:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A41C8E0003; Tue, 23 Jul 2019 06:27:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 86A5B8E0002; Tue, 23 Jul 2019 06:27:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 67F906B0007
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 06:27:59 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id r58so38170151qtb.5
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 03:27:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=BenoyznfTyLcx1/8jObFzEFhYgrS+1A5bA/DCD6z1+I=;
        b=ZnLKK26nDP1NtoD5ZBQSMrHRGSr8Xnt2ZuZ9pn8cIQF7oZpNBaMyr4LL+fc6PKgjOc
         WtMEAj4JLVDF2SyD8oGPfK1HXWhoXg3JTrSKbdVDkxpCQqcUluMUX4htBdnIcgR5wFXm
         GuOnGMsnnUsSWuJ0AJfeM/3RGi3ZvqUDHMQFVyU8NurAOemwGA5uKiIVIU4KvO6GJzW3
         ZS9fLJKNSB416roKeyx4SN8ug+JBOhr8+bBKZIag4VwrUPYsAVkkZIlcZeRaqerhXGd6
         SFVijcHk6Yr96gb0GDFa2JTGuqMC5LekLhrTDwN9sDu01T8brI3MUaLC1FwpACgYTvSd
         Bg9A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXCEDP+Iy7jouErJmNKONwbEZ+zyV2dhilr5RwFDnO7UoK1QGtb
	7ODQOTpaVfMYWbkDRMmk/OHGPSyGZid05H+ctpIpJ9RBRf2P9or9fPyEc5/iZyvuEADZ2Y5iD+a
	G8QdbmRoE07nNg92nfWNKLGCt4L1K0ujuOPKu7ExZm333TqxeROxrZifdrE31iowOEA==
X-Received: by 2002:a0c:d94e:: with SMTP id t14mr51944949qvj.18.1563877679175;
        Tue, 23 Jul 2019 03:27:59 -0700 (PDT)
X-Received: by 2002:a0c:d94e:: with SMTP id t14mr51944905qvj.18.1563877678416;
        Tue, 23 Jul 2019 03:27:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563877678; cv=none;
        d=google.com; s=arc-20160816;
        b=OxDMQVmE2LUkdPDbbTzns9v/ZICqZXdiIeam1kJxCoUT3Fbvrk83MXRENnCv7g4+wU
         ecpJf89XLHnsswIbur7qrsHspoRhjbJjm73xEwf46XbeeR22bU2lUSdslN8NDHxpziLt
         nRySVmHYhwjV+IkcmG1H2cqQpSbLkaMfJcGLS0l+hAMNlxKncPQ7RcSUzyCwFWxH+CIO
         aweMCSxiCY5eIbu0+QxC3g9q7J2Au0LWCofVkdY7OAfXviPEDWyNIec1togU3J5uHRh/
         6yGHMocSCCgD3FTUUjBN6FxVZHUcLUM0G1BzOp6ln/PARNkxkz5wYGSlsUcqp94zvsc8
         j3eg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=BenoyznfTyLcx1/8jObFzEFhYgrS+1A5bA/DCD6z1+I=;
        b=wpO/UlikWXvb4jo7qhvWWy/6pQB+7el/eARpjLwm+D5fq/hE9EmKyljxG74rPj3Nd9
         YgjAlQaP9QLHzUp2c/vsuJWaWXmpKYElCvdlk8cbjYgJzh46jT+dCOHkWRYrlNObcb0b
         +NE/HT/oYTlvU5L5BUFvYUngEZakV0sfDXXMCZChHlhjGyC8lNBdG8MB76fuuwbI2jtU
         7uW8BmZ2sL2Ow+zOyvDOrq1HEEPVDf4xXZZYIJK9zjNrgBFflUWKaRsAozkL9ofaSjFY
         0chGx899Uy3rA5J7YC1AN5n8mODCzRvjNdAwF3oy/AjlNQKtj8kNhYXSunDlczIKZ4hU
         F1Vw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3sor36955863qvc.37.2019.07.23.03.27.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 03:27:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwZ6OYsefBRjfzyywhyIbfQiowEEJG908kuZZQl/RMZTRF+2Kzuq3TqlfZM8y5m7uQqXQ3hzQ==
X-Received: by 2002:a0c:ae6d:: with SMTP id z42mr53764098qvc.8.1563877678094;
        Tue, 23 Jul 2019 03:27:58 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id l5sm19178166qte.9.2019.07.23.03.27.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 03:27:57 -0700 (PDT)
Date: Tue, 23 Jul 2019 06:27:48 -0400
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
Message-ID: <20190723062221-mutt-send-email-mst@kernel.org>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <75c43998-3a1c-676f-99ff-3d04663c3fcc@redhat.com>
 <20190722035657-mutt-send-email-mst@kernel.org>
 <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
 <20190723010156-mutt-send-email-mst@kernel.org>
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032800-mutt-send-email-mst@kernel.org>
 <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 04:42:19PM +0800, Jason Wang wrote:
> 
> On 2019/7/23 下午3:56, Michael S. Tsirkin wrote:
> > On Tue, Jul 23, 2019 at 01:48:52PM +0800, Jason Wang wrote:
> > > On 2019/7/23 下午1:02, Michael S. Tsirkin wrote:
> > > > On Tue, Jul 23, 2019 at 11:55:28AM +0800, Jason Wang wrote:
> > > > > On 2019/7/22 下午4:02, Michael S. Tsirkin wrote:
> > > > > > On Mon, Jul 22, 2019 at 01:21:59PM +0800, Jason Wang wrote:
> > > > > > > On 2019/7/21 下午6:02, Michael S. Tsirkin wrote:
> > > > > > > > On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
> > > > > > > > > syzbot has bisected this bug to:
> > > > > > > > > 
> > > > > > > > > commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
> > > > > > > > > Author: Jason Wang <jasowang@redhat.com>
> > > > > > > > > Date:   Fri May 24 08:12:18 2019 +0000
> > > > > > > > > 
> > > > > > > > >         vhost: access vq metadata through kernel virtual address
> > > > > > > > > 
> > > > > > > > > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
> > > > > > > > > start commit:   6d21a41b Add linux-next specific files for 20190718
> > > > > > > > > git tree:       linux-next
> > > > > > > > > final crash:    https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
> > > > > > > > > console output: https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
> > > > > > > > > kernel config:  https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
> > > > > > > > > dashboard link: https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
> > > > > > > > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
> > > > > > > > > 
> > > > > > > > > Reported-by: syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
> > > > > > > > > Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
> > > > > > > > > address")
> > > > > > > > > 
> > > > > > > > > For information about bisection process see: https://goo.gl/tpsmEJ#bisection
> > > > > > > > OK I poked at this for a bit, I see several things that
> > > > > > > > we need to fix, though I'm not yet sure it's the reason for
> > > > > > > > the failures:
> > > > > > > > 
> > > > > > > > 
> > > > > > > > 1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
> > > > > > > >        That's just a bad hack,
> > > > > > > This is used to avoid holding lock when checking whether the addresses are
> > > > > > > overlapped. Otherwise we need to take spinlock for each invalidation request
> > > > > > > even if it was the va range that is not interested for us. This will be very
> > > > > > > slow e.g during guest boot.
> > > > > > KVM seems to do exactly that.
> > > > > > I tried and guest does not seem to boot any slower.
> > > > > > Do you observe any slowdown?
> > > > > Yes I do.
> > > > > 
> > > > > 
> > > > > > Now I took a hard look at the uaddr hackery it really makes
> > > > > > me nervious. So I think for this release we want something
> > > > > > safe, and optimizations on top. As an alternative revert the
> > > > > > optimization and try again for next merge window.
> > > > > Will post a series of fixes, let me know if you're ok with that.
> > > > > 
> > > > > Thanks
> > > > I'd prefer you to take a hard look at the patch I posted
> > > > which makes code cleaner,
> > > 
> > > I did. But it looks to me a series that is only about 60 lines of code can
> > > fix all the issues we found without reverting the uaddr optimization.
> > Another thing I like about the patch I posted is that
> > it removes 60 lines of code, instead of adding more :)
> > Mostly because of unifying everything into
> > a single cleanup function and using kfree_rcu.
> 
> 
> Yes.
> 
> 
> > 
> > So how about this: do exactly what you propose but as a 2 patch series:
> > start with the slow safe patch, and add then return uaddr optimizations
> > on top. We can then more easily reason about whether they are safe.
> 
> 
> If you stick, I can do this.

Given I realized my patch is buggy in that
it does not wait for outstanding maps, I don't
insist.

> 
> > Basically you are saying this:
> > 	- notifiers are only needed to invalidate maps
> > 	- we make sure any uaddr change invalidates maps anyway
> > 	- thus it's ok not to have notifiers since we do
> > 	  not have maps
> > 
> > All this looks ok but the question is why do we
> > bother unregistering them. And the answer seems to
> > be that this is so we can start with a balanced
> > counter: otherwise we can be between _start and
> > _end calls.
> 
> 
> Yes, since there could be multiple co-current invalidation requests. We need
> count them to make sure we don't pin wrong pages.
> 
> 
> > 
> > I also wonder about ordering. kvm has this:
> >         /*
> >           * Used to check for invalidations in progress, of the pfn that is
> >           * returned by pfn_to_pfn_prot below.
> >           */
> >          mmu_seq = kvm->mmu_notifier_seq;
> >          /*
> >           * Ensure the read of mmu_notifier_seq isn't reordered with PTE reads in
> >           * gfn_to_pfn_prot() (which calls get_user_pages()), so that we don't
> >           * risk the page we get a reference to getting unmapped before we have a
> >           * chance to grab the mmu_lock without mmu_notifier_retry() noticing.
> >           *
> >           * This smp_rmb() pairs with the effective smp_wmb() of the combination
> >           * of the pte_unmap_unlock() after the PTE is zapped, and the
> >           * spin_lock() in kvm_mmu_notifier_invalidate_<page|range_end>() before
> >           * mmu_notifier_seq is incremented.
> >           */
> >          smp_rmb();
> > 
> > does this apply to us? Can't we use a seqlock instead so we do
> > not need to worry?
> 
> 
> I'm not familiar with kvm MMU internals, but we do everything under of
> mmu_lock.
> 
> Thanks

I don't think this helps at all.

There's no lock between checking the invalidate counter and
get user pages fast within vhost_map_prefetch. So it's possible
that get user pages fast reads PTEs speculatively before
invalidate is read.

-- 
MST

