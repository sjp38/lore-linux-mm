Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3E2FC7618E
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 09:27:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43505223BA
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 09:27:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43505223BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A954F6B0003; Tue, 23 Jul 2019 05:27:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A48416B0005; Tue, 23 Jul 2019 05:27:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 95D448E0002; Tue, 23 Jul 2019 05:27:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 77FBB6B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 05:27:02 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q26so38069117qtr.3
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 02:27:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=w9+uTBVD5eL1yIizEhpB/pr3lxHAjPOpAJ2J7t/uPjY=;
        b=a5wYgkjfar1kQtCdS/LfHu/coYb/xlmIcx/HgSsDlbrhAx3WYgTPlm3GbLv7cGuZ6K
         GzWN5fg8jiJN3trE+2Qc83vu9gcumGISISJqm+HRLsne3GaqejGcKQ/A8hYPRAGA7zER
         O98uAOZoUYMmqyTQSFU9rxlMvKEXuRf320McqisHXg3NifRVo1xA6/Cpha+aPPj16Ekd
         Et3k/a8nIFeOBZMFuEYzEBVMKm5tqJ6Njpmze659O+Mmwo+fCy24dTZDGb/yDNL8pWab
         0zjqCud09ESulWor0iQuGNW5FlaWulaSn3Ue1pvmZBIyXGN2rCKFX9fsXsUPwRmNQ5iD
         15JA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUAWBkjjxKWMMhzQiBANsmqO0GDoUdwT0JgPVzuAkQx8nfbgGJ6
	BCw78uGqUDr1ONfKJT2K9i3CFh8Y2DgoVkIS4sMRqJlRL6XaRavuvEaPgRm39QvEXjTZZ1eARbp
	QJI77NykUXw/rLpuuNHn1uQ1K0EBZxBjLZE4YxVeVa/nTa3hMRDQdHeh0GuX3Ip1WcA==
X-Received: by 2002:a37:ad0:: with SMTP id 199mr49635062qkk.90.1563874022249;
        Tue, 23 Jul 2019 02:27:02 -0700 (PDT)
X-Received: by 2002:a37:ad0:: with SMTP id 199mr49635023qkk.90.1563874021038;
        Tue, 23 Jul 2019 02:27:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563874021; cv=none;
        d=google.com; s=arc-20160816;
        b=o9nn17d7suW963FUC4UNBHsDviQtSHBTK1PT1NGzHc5PNzGV5kjAHVyg3cPUMU7d1s
         VnaY6aQQdgIS7Q57Eqqkdxd8J96hCwbqMyxzaYCP8ooxPPCxZQfO3QQgVvjtvDQ6+yjG
         BCD46MWUqtryvfLpoP2EGNVcVsbhz1RB9Ne66gR3IzOZKn+Y2ZsYSOyu20f5rcuVIgTD
         n6OSG9TvlzqhB/9Yz4Y+8KSqG9KN/+2HHRmgNR4+y+gv3KTuBeog8RcfGwzFJrvlBWIf
         KZqFHAXgfYidpbPkNPAj1rWiyCGDIGXIomRmgdTzBQsy/sO1qjHl00ECyFfMxUcQz+MQ
         fOBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=w9+uTBVD5eL1yIizEhpB/pr3lxHAjPOpAJ2J7t/uPjY=;
        b=C7wUt9mObjWrWD+drQheZ3ORA9LvPv7NatR+KHY7zftxnzJsop8larC+naUkvhB5/i
         suVHWUYK3kBQu4iOBLOjq6O5l1BmGx9sbdzLwR70Vv/BjKWC7E/gKBkTkRDSyvDe2yU0
         T+7O+20cflGNw9P8bn7c2cb83V7Z2nf4nh27Z3QTTeWyi7s52uLdv7OKgyyf1qMSdfPo
         1gUp9npxh2aRUA8U3EeYyHQN+eGkRNKLmT417XY1aJ7zN6i7xP34kSYMzDSa2pzvusuW
         nYCWSKOf7FkHRZrlrTRM4XCdZ/Lyx3WQxkp53eKdnmF0QSuQpaZ/RK74qkjUwXSOaHWV
         AxLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e50sor56657675qte.22.2019.07.23.02.27.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 02:27:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqznQz1jb6/VqV6QAjRFsQRchbKNzzWw6vrke7ravYfqDHLLyPR0Ru5U5FkLQQwrSBJvjXKcDw==
X-Received: by 2002:ac8:2e5d:: with SMTP id s29mr52712693qta.70.1563874020622;
        Tue, 23 Jul 2019 02:27:00 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id r5sm19239957qkc.42.2019.07.23.02.26.53
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 02:26:59 -0700 (PDT)
Date: Tue, 23 Jul 2019 05:26:50 -0400
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
Message-ID: <20190723051828-mutt-send-email-mst@kernel.org>
References: <20190721081447-mutt-send-email-mst@kernel.org>
 <85dd00e2-37a6-72b7-5d5a-8bf46a3526cf@redhat.com>
 <20190722040230-mutt-send-email-mst@kernel.org>
 <4bd2ff78-6871-55f2-44dc-0982ffef3337@redhat.com>
 <20190723010019-mutt-send-email-mst@kernel.org>
 <b4696f2e-678a-bdb2-4b7c-fb4ce040ec2a@redhat.com>
 <20190723032024-mutt-send-email-mst@kernel.org>
 <1d14de4d-0133-1614-9f64-3ded381de04e@redhat.com>
 <20190723035725-mutt-send-email-mst@kernel.org>
 <3f4178f1-0d71-e032-0f1f-802428ceca59@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3f4178f1-0d71-e032-0f1f-802428ceca59@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 04:49:01PM +0800, Jason Wang wrote:
> 
> On 2019/7/23 下午4:10, Michael S. Tsirkin wrote:
> > On Tue, Jul 23, 2019 at 03:53:06PM +0800, Jason Wang wrote:
> > > On 2019/7/23 下午3:23, Michael S. Tsirkin wrote:
> > > > > > Really let's just use kfree_rcu. It's way cleaner: fire and forget.
> > > > > Looks not, you need rate limit the fire as you've figured out?
> > > > See the discussion that followed. Basically no, it's good enough
> > > > already and is only going to be better.
> > > > 
> > > > > And in fact,
> > > > > the synchronization is not even needed, does it help if I leave a comment to
> > > > > explain?
> > > > Let's try to figure it out in the mail first. I'm pretty sure the
> > > > current logic is wrong.
> > > 
> > > Here is what the code what to achieve:
> > > 
> > > - The map was protected by RCU
> > > 
> > > - Writers are: MMU notifier invalidation callbacks, file operations (ioctls
> > > etc), meta_prefetch (datapath)
> > > 
> > > - Readers are: memory accessor
> > > 
> > > Writer are synchronized through mmu_lock. RCU is used to synchronized
> > > between writers and readers.
> > > 
> > > The synchronize_rcu() in vhost_reset_vq_maps() was used to synchronized it
> > > with readers (memory accessors) in the path of file operations. But in this
> > > case, vq->mutex was already held, this means it has been serialized with
> > > memory accessor. That's why I think it could be removed safely.
> > > 
> > > Anything I miss here?
> > > 
> > So invalidate callbacks need to reset the map, and they do
> > not have vq mutex. How can they do this and free
> > the map safely? They need synchronize_rcu or kfree_rcu right?
> 
> 
> Invalidation callbacks need but file operations (e.g ioctl) not.
> 
> 
> > 
> > And I worry somewhat that synchronize_rcu in an MMU notifier
> > is a problem, MMU notifiers are supposed to be quick:
> 
> 
> Looks not, since it can allow to be blocked and lots of driver depends on
> this. (E.g mmu_notifier_range_blockable()).

Right, they can block. So why don't we take a VQ mutex and be
done with it then? No RCU tricks.

> 
> > they are on a read side critical section of SRCU.
> > 
> > If we could get rid of RCU that would be even better.
> > 
> > But now I wonder:
> > 	invalidate_start has to mark page as dirty
> > 	(this is what my patch added, current code misses this).
> 
> 
> Nope, current code did this but not the case when map need to be invalidated
> in the vhost control path (ioctl etc).
> 
> 
> > 
> > 	at that point kernel can come and make the page clean again.
> > 
> > 	At that point VQ handlers can keep a copy of the map
> > 	and change the page again.
> 
> 
> We will increase invalidate_count which prevent the page being used by map.
> 
> Thanks

OK I think I got it, thanks!


> 
> > 
> > 
> > At this point I don't understand how we can mark page dirty
> > safely.
> > 
> > > > > > > Btw, for kvm ioctl it still uses synchronize_rcu() in kvm_vcpu_ioctl(),
> > > > > > > (just a little bit more hard to trigger):
> > > > > > AFAIK these never run in response to guest events.
> > > > > > So they can take very long and guests still won't crash.
> > > > > What if guest manages to escape to qemu?
> > > > > 
> > > > > Thanks
> > > > Then it's going to be slow. Why do we care?
> > > > What we do not want is synchronize_rcu that guest is blocked on.
> > > > 
> > > Ok, this looks like that I have some misunderstanding here of the reason why
> > > synchronize_rcu() is not preferable in the path of ioctl. But in kvm case,
> > > if rcu_expedited is set, it can triggers IPIs AFAIK.
> > > 
> > > Thanks
> > > 
> > Yes, expedited is not good for something guest can trigger.
> > Let's just use kfree_rcu if we can. Paul said even though
> > documentation still says it needs to be rate-limited, that
> > part is basically stale and will get updated.
> > 

