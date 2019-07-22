Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12A79C76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 08:02:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBAB021E6D
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 08:02:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBAB021E6D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6800A8E0001; Mon, 22 Jul 2019 04:02:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6300F6B0007; Mon, 22 Jul 2019 04:02:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 51E4A8E0001; Mon, 22 Jul 2019 04:02:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 219CF6B0006
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 04:02:26 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id o16so34880130qtj.6
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 01:02:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=bByVe0wHX2Fq2XabjZI/aT6yvPdN/tyRaOwnK8KYNiY=;
        b=Wae7DgbyVwB31tmJPbFVoPogNfG+OnlkrWFSB8ZA9YFYgEgWHNIUfLm37hmoTunXgB
         aGfFxsZkuX0OuR5PB+AI2avyqfURB7wbDR5yGUwLyxuyQQXJDEz/qquc3ZcxKr37MyvN
         SSpAPjugDvgTckjjkFgxhuKbF+/sVSTwTUBKuyFGp7EeCcrdNPSE7rMP1k87dXGhkeG8
         jD9PY/88hEDIhNBF1uunz/KiYe63DhG19zCIoUIoBBykrLzyCJbj+93KXE01+1/ow3eo
         pvf9dIig0h5ikN/4QjCjhxu6aolPBSBRQf2wPsSygYHJYzqyp+NQiDViPqtfprJmJLnW
         N8Yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUcYNCd1/LTnea7T2sZO7M5MUTEZpMvYER74va6i9y81P0MVXzJ
	tNScOXBjqqZNvwv4Av6e6yXS5MZsYoK0Oct4QZHpkc/syJ4cWiQI43gHnCZjTHUV0E8VTHTrnqv
	hwUdNOJgAob9TA0e4XsKG1eMPa+U6KnOQQtqH7lK/PfFRLvNNip3B4Yy3BeoK0HR2tg==
X-Received: by 2002:ae9:f409:: with SMTP id y9mr26471721qkl.244.1563782545897;
        Mon, 22 Jul 2019 01:02:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpMURPXQ/DHtpeRNBMmVLGY6gz/haApkxkvYovTLggaEWSXId/F8vokgoUvWws2l5VVgHW
X-Received: by 2002:ae9:f409:: with SMTP id y9mr26471690qkl.244.1563782545182;
        Mon, 22 Jul 2019 01:02:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563782545; cv=none;
        d=google.com; s=arc-20160816;
        b=DkokUCAVYqo6xWMyRCuGL6vU3s0lmC+6sh5mQxuumF5mgZeXMta7g23uXwKanOzXGG
         hR/aOwCYBkhH8V9/jrjPgJgWkgwrRBzh7OqOqwJi8tz4D6EVg5B03o4b/T9DWlRMhbIi
         skmEliDrRwnxlwP5dsc/o0WhCKGWugzm67UG5wAX5GKJdPsxEDOCxsAP/8fJG89rmc1L
         Hc7MRmJGJz44t4kgRnK924gZD3ZG5CaHg1GiGCG+FzrnOg7gDmppW84feKIFUJ3K8MSQ
         PVKOXFURDo+pHG4rLVOHHXRbtqTQov3hxzd+T18qvm3cJoli2Aoinfz9yTk+qmGLCDCt
         My7A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=bByVe0wHX2Fq2XabjZI/aT6yvPdN/tyRaOwnK8KYNiY=;
        b=LDyc451rG+y5nBVa1d9QPlFiNcxIZSujSoh2MVa2BkYxbKvqoMRT4XS1gLny5n+MSl
         55JB+3tMGjlbDZT+zfEzdiOXBOzWjhbXi9iD3SDlDHuOQmP4H4Mu6kZbZU/fkOAeo5yc
         zYtCjP2MghiEfMXecMzA5qvWlQ8BWmFR4RJgVhQovHZyPjLRE1zhtSpRFchQv6uciA8V
         4L89T1fBMXBBFHRUyQKLOEMx0tt5PtgnZ3we4uqRpomIKDuL3EdXX5dMiZAIFEZn0JuA
         hbTc93fVElGuvoY4wA++8yl0yPzpVicBwz8Su8eEr3QW96WfDHBZr3kT+qYW+sBXyxol
         ln+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e12si24391972qve.144.2019.07.22.01.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 01:02:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 269F7308424C;
	Mon, 22 Jul 2019 08:02:24 +0000 (UTC)
Received: from redhat.com (ovpn-120-233.rdu2.redhat.com [10.10.120.233])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D54DC610A6;
	Mon, 22 Jul 2019 08:02:14 +0000 (UTC)
Date: Mon, 22 Jul 2019 04:02:13 -0400
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
Message-ID: <20190722035657-mutt-send-email-mst@kernel.org>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <75c43998-3a1c-676f-99ff-3d04663c3fcc@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <75c43998-3a1c-676f-99ff-3d04663c3fcc@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 22 Jul 2019 08:02:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 22, 2019 at 01:21:59PM +0800, Jason Wang wrote:
> 
> On 2019/7/21 下午6:02, Michael S. Tsirkin wrote:
> > On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
> > > syzbot has bisected this bug to:
> > > 
> > > commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
> > > Author: Jason Wang <jasowang@redhat.com>
> > > Date:   Fri May 24 08:12:18 2019 +0000
> > > 
> > >      vhost: access vq metadata through kernel virtual address
> > > 
> > > bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
> > > start commit:   6d21a41b Add linux-next specific files for 20190718
> > > git tree:       linux-next
> > > final crash:    https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
> > > console output: https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
> > > kernel config:  https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
> > > dashboard link: https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
> > > syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
> > > 
> > > Reported-by: syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
> > > Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
> > > address")
> > > 
> > > For information about bisection process see: https://goo.gl/tpsmEJ#bisection
> > 
> > OK I poked at this for a bit, I see several things that
> > we need to fix, though I'm not yet sure it's the reason for
> > the failures:
> > 
> > 
> > 1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
> >     That's just a bad hack,
> 
> 
> This is used to avoid holding lock when checking whether the addresses are
> overlapped. Otherwise we need to take spinlock for each invalidation request
> even if it was the va range that is not interested for us. This will be very
> slow e.g during guest boot.

KVM seems to do exactly that.
I tried and guest does not seem to boot any slower.
Do you observe any slowdown?

Now I took a hard look at the uaddr hackery it really makes
me nervious. So I think for this release we want something
safe, and optimizations on top. As an alternative revert the
optimization and try again for next merge window.


-- 
MST

