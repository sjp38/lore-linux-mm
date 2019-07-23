Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 992ACC76188
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 07:23:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A37121911
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 07:23:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A37121911
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3B516B0003; Tue, 23 Jul 2019 03:23:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CEDE88E0003; Tue, 23 Jul 2019 03:23:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB3468E0001; Tue, 23 Jul 2019 03:23:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 70D536B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 03:23:29 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v7so20353546wrt.6
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 00:23:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=oy5KGqrsqT4B9H/f34qwXCnVMYFxOh3uTjd2Vo0pdtA=;
        b=G7ZdMREPxTDTNC3XX4S/gvJE1+bOTXGGaTZAYjp+V/+oi+1RqLrkB8AXXQx/1mHDgu
         9hS6rH8Y6eQuvdFOB9xn36bjsJby9PEEErG7hdLFqg6E+z/D+cjlUDWRcf+6Adkn2BSy
         voJcOtOu6fUkQUEhLKqb7B/ewLX8VZwJ6YxtH3j0HKCzEhLjKe6XO9av1AdAU2KaaYrF
         Jz93ErysAr+4P5KbjCvKxuTzcKYd2wfn4t0DeRlvDabMequt12lq21FUgVt+WcS05RNO
         Bn7qE5l2aQnwj8z9HiJL5pFdhdyr8osDuW+tYUo9LmSDqOb4u4oSG2c1sCxMhYSyjO2M
         bTmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXu5tOUT3ImBckvgyfwtBSD+ewJMZBo1VolntlALpD8kSCVGzz9
	qW2C2cQr7+Rsy5UCeJeWsv8rWqzziN0j82iF3LTTdJkQp95OUQgaTEnIE9j4zwMHE2snQnx3jvZ
	TTtM21NoZ9Zp1b8TNOgX7QWKrDa/hEcV+VafOtEEjgRBI+5EyA0RFyfSRr7GpurHHwQ==
X-Received: by 2002:adf:cf02:: with SMTP id o2mr60010675wrj.352.1563866608845;
        Tue, 23 Jul 2019 00:23:28 -0700 (PDT)
X-Received: by 2002:adf:cf02:: with SMTP id o2mr60010516wrj.352.1563866607703;
        Tue, 23 Jul 2019 00:23:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563866607; cv=none;
        d=google.com; s=arc-20160816;
        b=NAdPzJTwNB1CuA//P9mtIOOkEwyLNrzC/lZbfzt+w8vq0UbweqXHdV615WOVoCTud7
         bKtnhV6EleegkPBy9kwRpDK4L+38O5QDXDvYdHeuU8F7uhw+aiPwXspPGXgMYIF7D1L1
         cMl3LmXqaD9Wu493loU4pFz6ocII3jtHlSOB+mb2LMgUqgiIiJ61itkkAdYQ6pCY/2gH
         4LDNn0CJdzDZhUt5xkJv9xV27duxqMDuw4CTpE0qbRr5aUT7EJHTtfHIwL5Qm761ojgB
         npTbyJo6RtM3UvJBmfmAXr6RSYj8zkSLMsLEO8cdDAElazz/RRsbCJApx52Wm6LazrvA
         vGUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=oy5KGqrsqT4B9H/f34qwXCnVMYFxOh3uTjd2Vo0pdtA=;
        b=uUXYB2gH1cA1O+gP0lxR9rYtfa7Vzz2U1xLLVfQyB+Ir/SbSBDUK2fJrbqA+YN6gOt
         QoCtOsRTPNWZohKh4CZmmgXNSYAAw1Fg39IbrFVDO4XOM50Gp39R+ZREAc9OZwTxrF+f
         2pWOaqi6MSX5unryqVl6cIZvczpRPDdELs0DqPno8UPJFZZ2Ts0Sy4diJqBLQLDUrcb6
         S3ltTIqFcAyb0PHrgOdDkiciPZaHAUxmL4pCQV9ZFQNqgXX1BxkT0Chan6bxDHXECat1
         AMsrUbXJ75AZV5kUFrQA0ydnIkFJZQ/l2DW6CPPkX1PW4rhadljD5fIRXJ0nOuVSNV/e
         U82g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 131sor23511538wmd.1.2019.07.23.00.23.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 00:23:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxWldJbxq1K+XIwuoZA5QjggN18UavMMzAAJR8lSW8vn9fsDUnMI2/5vRNFf2W6MAv/+2bbtg==
X-Received: by 2002:a1c:ed09:: with SMTP id l9mr15886118wmh.58.1563866607208;
        Tue, 23 Jul 2019 00:23:27 -0700 (PDT)
Received: from redhat.com ([185.120.125.30])
        by smtp.gmail.com with ESMTPSA id f204sm61496509wme.18.2019.07.23.00.23.22
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 00:23:26 -0700 (PDT)
Date: Tue, 23 Jul 2019 03:23:20 -0400
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
Message-ID: <20190723032024-mutt-send-email-mst@kernel.org>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081447-mutt-send-email-mst@kernel.org>
 <85dd00e2-37a6-72b7-5d5a-8bf46a3526cf@redhat.com>
 <20190722040230-mutt-send-email-mst@kernel.org>
 <4bd2ff78-6871-55f2-44dc-0982ffef3337@redhat.com>
 <20190723010019-mutt-send-email-mst@kernel.org>
 <b4696f2e-678a-bdb2-4b7c-fb4ce040ec2a@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b4696f2e-678a-bdb2-4b7c-fb4ce040ec2a@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 01:47:04PM +0800, Jason Wang wrote:
> 
> On 2019/7/23 下午1:01, Michael S. Tsirkin wrote:
> > On Tue, Jul 23, 2019 at 12:01:40PM +0800, Jason Wang wrote:
> > > On 2019/7/22 下午4:08, Michael S. Tsirkin wrote:
> > > > On Mon, Jul 22, 2019 at 01:24:24PM +0800, Jason Wang wrote:
> > > > > On 2019/7/21 下午8:18, Michael S. Tsirkin wrote:
> > > > > > On Sun, Jul 21, 2019 at 06:02:52AM -0400, Michael S. Tsirkin wrote:
> > > > > > > On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
> > > > > > > > syzbot has bisected this bug to:
> > > > > > > > 
> > > > > > > > commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
> > > > > > > > Author: Jason Wang<jasowang@redhat.com>
> > > > > > > > Date:   Fri May 24 08:12:18 2019 +0000
> > > > > > > > 
> > > > > > > >        vhost: access vq metadata through kernel virtual address
> > > > > > > > 
> > > > > > > > bisection log:https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
> > > > > > > > start commit:   6d21a41b Add linux-next specific files for 20190718
> > > > > > > > git tree:       linux-next
> > > > > > > > final crash:https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
> > > > > > > > console output:https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
> > > > > > > > kernel config:https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
> > > > > > > > dashboard link:https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
> > > > > > > > syz repro:https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
> > > > > > > > 
> > > > > > > > Reported-by:syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
> > > > > > > > Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
> > > > > > > > address")
> > > > > > > > 
> > > > > > > > For information about bisection process see:https://goo.gl/tpsmEJ#bisection
> > > > > > > OK I poked at this for a bit, I see several things that
> > > > > > > we need to fix, though I'm not yet sure it's the reason for
> > > > > > > the failures:
> > > > > > > 
> > > > > > > 
> > > > > > > 1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
> > > > > > >       That's just a bad hack, in particular I don't think device
> > > > > > >       mutex is taken and so poking at two VQs will corrupt
> > > > > > >       memory.
> > > > > > >       So what to do? How about a per vq notifier?
> > > > > > >       Of course we also have synchronize_rcu
> > > > > > >       in the notifier which is slow and is now going to be called twice.
> > > > > > >       I think call_rcu would be more appropriate here.
> > > > > > >       We then need rcu_barrier on module unload.
> > > > > > >       OTOH if we make pages linear with map then we are good
> > > > > > >       with kfree_rcu which is even nicer.
> > > > > > > 
> > > > > > > 2. Doesn't map leak after vhost_map_unprefetch?
> > > > > > >       And why does it poke at contents of the map?
> > > > > > >       No one should use it right?
> > > > > > > 
> > > > > > > 3. notifier unregister happens last in vhost_dev_cleanup,
> > > > > > >       but register happens first. This looks wrong to me.
> > > > > > > 
> > > > > > > 4. OK so we use the invalidate count to try and detect that
> > > > > > >       some invalidate is in progress.
> > > > > > >       I am not 100% sure why do we care.
> > > > > > >       Assuming we do, uaddr can change between start and end
> > > > > > >       and then the counter can get negative, or generally
> > > > > > >       out of sync.
> > > > > > > 
> > > > > > > So what to do about all this?
> > > > > > > I am inclined to say let's just drop the uaddr optimization
> > > > > > > for now. E.g. kvm invalidates unconditionally.
> > > > > > > 3 should be fixed independently.
> > > > > > Above implements this but is only build-tested.
> > > > > > Jason, pls take a look. If you like the approach feel
> > > > > > free to take it from here.
> > > > > > 
> > > > > > One thing the below does not have is any kind of rate-limiting.
> > > > > > Given it's so easy to restart I'm thinking it makes sense
> > > > > > to add a generic infrastructure for this.
> > > > > > Can be a separate patch I guess.
> > > > > I don't get why must use kfree_rcu() instead of synchronize_rcu() here.
> > > > synchronize_rcu has very high latency on busy systems.
> > > > It is not something that should be used on a syscall path.
> > > > KVM had to switch to SRCU to keep it sane.
> > > > Otherwise one guest can trivially slow down another one.
> > > 
> > > I think you mean the synchronize_rcu_expedited()? Rethink of the code, the
> > > synchronize_rcu() in ioctl() could be removed, since it was serialized with
> > > memory accessor.
> > 
> > Really let's just use kfree_rcu. It's way cleaner: fire and forget.
> 
> 
> Looks not, you need rate limit the fire as you've figured out?

See the discussion that followed. Basically no, it's good enough
already and is only going to be better.

> And in fact,
> the synchronization is not even needed, does it help if I leave a comment to
> explain?

Let's try to figure it out in the mail first. I'm pretty sure the
current logic is wrong.

> 
> > 
> > > Btw, for kvm ioctl it still uses synchronize_rcu() in kvm_vcpu_ioctl(),
> > > (just a little bit more hard to trigger):
> > 
> > AFAIK these never run in response to guest events.
> > So they can take very long and guests still won't crash.
> 
> 
> What if guest manages to escape to qemu?
> 
> Thanks

Then it's going to be slow. Why do we care?
What we do not want is synchronize_rcu that guest is blocked on.

> 
> > 
> > 
> > >      case KVM_RUN: {
> > > ...
> > >          if (unlikely(oldpid != task_pid(current))) {
> > >              /* The thread running this VCPU changed. */
> > >              struct pid *newpid;
> > > 
> > >              r = kvm_arch_vcpu_run_pid_change(vcpu);
> > >              if (r)
> > >                  break;
> > > 
> > >              newpid = get_task_pid(current, PIDTYPE_PID);
> > >              rcu_assign_pointer(vcpu->pid, newpid);
> > >              if (oldpid)
> > >                  synchronize_rcu();
> > >              put_pid(oldpid);
> > >          }
> > > ...
> > >          break;
> > > 
> > > 
> > > > > > Signed-off-by: Michael S. Tsirkin<mst@redhat.com>
> > > > > Let me try to figure out the root cause then decide whether or not to go for
> > > > > this way.
> > > > > 
> > > > > Thanks
> > > > The root cause of the crash is relevant, but we still need
> > > > to fix issues 1-4.
> > > > 
> > > > More issues (my patch tries to fix them too):
> > > > 
> > > > 5. page not dirtied when mappings are torn down outside
> > > >      of invalidate callback
> > > 
> > > Yes.
> > > 
> > > 
> > > > 6. potential cross-VM DOS by one guest keeping system busy
> > > >      and increasing synchronize_rcu latency to the point where
> > > >      another guest stars timing out and crashes
> > > > 
> > > > 
> > > > 
> > > This will be addressed after I remove the synchronize_rcu() from ioctl path.
> > > 
> > > Thanks

