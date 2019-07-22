Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FDD7C76196
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 08:08:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E983A21E70
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 08:08:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E983A21E70
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A1016B0006; Mon, 22 Jul 2019 04:08:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 652688E0001; Mon, 22 Jul 2019 04:08:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 540CE6B0008; Mon, 22 Jul 2019 04:08:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 367686B0006
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 04:08:56 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e32so34867484qtc.7
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 01:08:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=9ph329mhgFKR2DbhvqVmkbtraggSC9iB5CzrL71TaBw=;
        b=U5wn5uFV1Upow9NgFweEflvJqClm1k/y67v7nIcrCjEPgidmSB/X3frPN/NVq++eFk
         0y1E1dohnDDV59FC3Qh+7ZR4wGNmP6hsQM5fFuZ+Icpzs2lQnaDL5AeMhC0jFmPTrV40
         38Pio2/htr/R/sE3ChRO0/YSflnM7GNQiMuh/KUKu4VjOeMjSULbGXPR0scVpLkR2Hrf
         BeH01mK8BXRnGzaUobWJJC4H+7g487+80e7MNqmrMfTwy1KDFoJoWWf8YMUf4fQcIAnb
         wkGoBb+2BYctiKffG6ut8+Ge8M0cVR9TduN+FIf2mbQLLpLSRammD/wp6wHcqgCkTZMS
         PErA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUHfuBLX4M01WvE6ieYejI9/rViBp4sDfjIz9hIZ3nSZ9qNVGUp
	i/xFvBSCW1adFA7iqz2Wi+vAWTl8xOM0pkOWvkLuW0P78u15zMUMkdc0PrxWAqRCTe5Gwwr8boS
	hlRxHUFsk5u//EPg0nPOR+eEMYsJN4rcORdhiO7eT06zZEM8+7mXeoBRA+CsCY+CSoQ==
X-Received: by 2002:a0c:ad07:: with SMTP id u7mr48043532qvc.2.1563782935968;
        Mon, 22 Jul 2019 01:08:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlb5bYhPGx/ybRtVqDY4bWUBfQW4L8gHV4yURgMGKYNbDq5sQgF7p0tOyh4pPCxsTmS1L8
X-Received: by 2002:a0c:ad07:: with SMTP id u7mr48043497qvc.2.1563782935275;
        Mon, 22 Jul 2019 01:08:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563782935; cv=none;
        d=google.com; s=arc-20160816;
        b=TdeVS9Jp3Nx2eAiL9ScO/8vDWxXft4L2xA099d6+LBD2okWNx+Emb+ElJ5zOijfAD3
         TDqfFGButCNRQZsxh1gUq3CzHZBIybN/xd4+tqyHvv5JhEyu6+gx7C0YvNU9HIXTZieg
         t15bsSdCOFuhz+kpTGrC57XmxynaEBSwajFXOKKhu8jL4IDOBCyJ0WklqwzuLX4F9LeW
         p7OPN7/U5BUmLtVrstp7qCgc+0spTM9m0wnGcpJlSQLPUu0GJojw6sYsUsvT65xpk4aa
         HeNXgGv7dllsfQXHhlqO1QgrxxNF7Wwl8cf3XjWkC2q8FnzuOBpmrSKc45FCE20V+/kD
         XBsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=9ph329mhgFKR2DbhvqVmkbtraggSC9iB5CzrL71TaBw=;
        b=S3Hr0KHjJwxN1SS9jCbZ9p1CepojMSQjnC+wQtrOer+pQk+mz9dbGBhitwkXIxho7Z
         SrV9mD9Jti4gT/dActlFec2K/89mK6jLBjzFL2u8YtcBGRtbCkm2bujj/hzLmYYLBweU
         EzDbVBmrKxLyoogGQ6eL2BR4ChBcAxYO0cCh2CDvov6xi9Z0fiz6mRibu92ZIn9+2/we
         YOef84vCUUGcl3dv/NnA7GkZGoJleivtLf5Ez9CATXk0OCNkL6pT8m0sQHFpnoATxnK0
         YmNLPtP7rO4hArXfrLVLaHWQ9peK2maYTHG2tnP0x17isiZadeH55RIlmKADTgDvKJ71
         /SwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k55si5066894qtb.327.2019.07.22.01.08.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 01:08:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 10D6B2F8BC9;
	Mon, 22 Jul 2019 08:08:54 +0000 (UTC)
Received: from redhat.com (ovpn-120-233.rdu2.redhat.com [10.10.120.233])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 41D3F5FCA3;
	Mon, 22 Jul 2019 08:08:46 +0000 (UTC)
Date: Mon, 22 Jul 2019 04:08:44 -0400
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
Message-ID: <20190722040230-mutt-send-email-mst@kernel.org>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081447-mutt-send-email-mst@kernel.org>
 <85dd00e2-37a6-72b7-5d5a-8bf46a3526cf@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <85dd00e2-37a6-72b7-5d5a-8bf46a3526cf@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 22 Jul 2019 08:08:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 01:24:24PM +0800, Jason Wang wrote:
> 
> On 2019/7/21 下午8:18, Michael S. Tsirkin wrote:
> > On Sun, Jul 21, 2019 at 06:02:52AM -0400, Michael S. Tsirkin wrote:
> > > On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
> > > > syzbot has bisected this bug to:
> > > > 
> > > > commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
> > > > Author: Jason Wang<jasowang@redhat.com>
> > > > Date:   Fri May 24 08:12:18 2019 +0000
> > > > 
> > > >      vhost: access vq metadata through kernel virtual address
> > > > 
> > > > bisection log:https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
> > > > start commit:   6d21a41b Add linux-next specific files for 20190718
> > > > git tree:       linux-next
> > > > final crash:https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
> > > > console output:https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
> > > > kernel config:https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
> > > > dashboard link:https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
> > > > syz repro:https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
> > > > 
> > > > Reported-by:syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
> > > > Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
> > > > address")
> > > > 
> > > > For information about bisection process see:https://goo.gl/tpsmEJ#bisection
> > > OK I poked at this for a bit, I see several things that
> > > we need to fix, though I'm not yet sure it's the reason for
> > > the failures:
> > > 
> > > 
> > > 1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
> > >     That's just a bad hack, in particular I don't think device
> > >     mutex is taken and so poking at two VQs will corrupt
> > >     memory.
> > >     So what to do? How about a per vq notifier?
> > >     Of course we also have synchronize_rcu
> > >     in the notifier which is slow and is now going to be called twice.
> > >     I think call_rcu would be more appropriate here.
> > >     We then need rcu_barrier on module unload.
> > >     OTOH if we make pages linear with map then we are good
> > >     with kfree_rcu which is even nicer.
> > > 
> > > 2. Doesn't map leak after vhost_map_unprefetch?
> > >     And why does it poke at contents of the map?
> > >     No one should use it right?
> > > 
> > > 3. notifier unregister happens last in vhost_dev_cleanup,
> > >     but register happens first. This looks wrong to me.
> > > 
> > > 4. OK so we use the invalidate count to try and detect that
> > >     some invalidate is in progress.
> > >     I am not 100% sure why do we care.
> > >     Assuming we do, uaddr can change between start and end
> > >     and then the counter can get negative, or generally
> > >     out of sync.
> > > 
> > > So what to do about all this?
> > > I am inclined to say let's just drop the uaddr optimization
> > > for now. E.g. kvm invalidates unconditionally.
> > > 3 should be fixed independently.
> > Above implements this but is only build-tested.
> > Jason, pls take a look. If you like the approach feel
> > free to take it from here.
> > 
> > One thing the below does not have is any kind of rate-limiting.
> > Given it's so easy to restart I'm thinking it makes sense
> > to add a generic infrastructure for this.
> > Can be a separate patch I guess.
> 
> 
> I don't get why must use kfree_rcu() instead of synchronize_rcu() here.

synchronize_rcu has very high latency on busy systems.
It is not something that should be used on a syscall path.
KVM had to switch to SRCU to keep it sane.
Otherwise one guest can trivially slow down another one.

> 
> > 
> > Signed-off-by: Michael S. Tsirkin<mst@redhat.com>
> 
> 
> Let me try to figure out the root cause then decide whether or not to go for
> this way.
> 
> Thanks

The root cause of the crash is relevant, but we still need
to fix issues 1-4.

More issues (my patch tries to fix them too):

5. page not dirtied when mappings are torn down outside
   of invalidate callback

6. potential cross-VM DOS by one guest keeping system busy
   and increasing synchronize_rcu latency to the point where
   another guest stars timing out and crashes



-- 
MST

