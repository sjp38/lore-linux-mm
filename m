Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B390C76196
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 10:03:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3CE8204FD
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 10:03:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3CE8204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 839088E0003; Sun, 21 Jul 2019 06:03:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E8886B000A; Sun, 21 Jul 2019 06:03:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D6AB8E0003; Sun, 21 Jul 2019 06:03:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 46B156B0008
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 06:03:05 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id o11so23958538qtq.10
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 03:03:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=wjOKSVDiw+XcwusxZhkGrJyvZDcfcxwJuCojXRRMth8=;
        b=S3I+2gIS9rhP4865l1oj9jm508xQEgpnTMPYV9Hg1XxK3jxecc2ar20Bju9vy/7AZw
         vGUj4reSY3AcrKlXObe84xrT9dco5gbg38IaB8BPk2VdTa7y5nxB8jFg77vGXnFf06sU
         MPQjAMkyFE7pxsZEhi2wYeH2ebWfsdCJHCDE8+/tXtoG8asxnb7xwJOTIBifvYxgYOAf
         DJr1R5TtaHUQPlvtR7GsqrQNcuZTQkWZI4iJaAFQcXQ1rk5XRdxn5cHqGxMFvJZ3i952
         Q3peRjtywwWNB9p3qEw1RiWXvNRhkmnn8EomrU7JIyr5S0CBP0ZLTMIbIgIlsoV1c/kZ
         yh+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXpAqwjOJsm0cm7Bv01/4gwESYnPUDGNd9ZoV5foDvD4MzhDimJ
	3hcBLMv+tIlZqVUJVtzVCqFSzhNPf6sjd38smixsCBX4uZhXgSryUdxo7LsLymNNDvuEzuyePNM
	VbZW+jV+o5vgSVNhG4ZYlEYtMHpX5ILmvlGvCysvRDF6NshrbxzUAYlN5xodTtxJAog==
X-Received: by 2002:ac8:2e14:: with SMTP id r20mr46054898qta.241.1563703385055;
        Sun, 21 Jul 2019 03:03:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUeXmHFozwS9wMAhhzhz/FmgrLYmkzvHw44cqICUj4deQfd4R9LsA6OIGj1dp/y9o5FC70
X-Received: by 2002:ac8:2e14:: with SMTP id r20mr46054846qta.241.1563703384306;
        Sun, 21 Jul 2019 03:03:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563703384; cv=none;
        d=google.com; s=arc-20160816;
        b=X+8+UVr7j46RanBRyALpFCpjwR1p6UxdVMY2BVai3Yw6ekuD56dknOhVuUsP3W9n4d
         tgNLbzT5ie8sdYvoUJPC2eiZ4s9iQuByDtDfl+XO/18dVvrUmb0HCEmWqf0apTCVj0/a
         zxQ5MYNtxAHRek1t1RBNNpOVvNHG0LX+4WLriCUWNgMiXekr+fVxXUWabEft+UwwMWL4
         JjhW/1WyVXZXr6yKehSlhlHltsmyNBC3fMr2S/jg0yUWxk/k7GHczHLjO1ZbGwNf0cA5
         a2uNxVh6o/MsX/OWrCb1uX0HUM+kRNcZkeJFZarqM9hpL7kjWUfNIkOW9Nk2g8mWOsxX
         gWTQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=wjOKSVDiw+XcwusxZhkGrJyvZDcfcxwJuCojXRRMth8=;
        b=e37/nEVIAbCUz0/A+6UDigd/5oxbPb7yv6H6FUEWO3N4/2Q8beVBGAQkvPfw1g0DSV
         yWN2tOYwaCp0lIyheaH8dAa8NjxKz1pkl1gfc9DX9UhwtW5sUGaS3AnV8JjOy9fFjvA1
         01NGp3itN2n/NpqB96mwvipnhs3xPy7qDnIW8tT2gkLu5Ciki9K1g9+Fcq7cELAHE6cQ
         NEAKbNcx35C9lgQ2T5HkiBbdUz95hPiuvdEvEAwU8HoG6wF8h3/ANG/+1pEHQ8JqOvfq
         ZGY3drZNJgoptoJdAznyw2OSwJK3zNw9xPQeTKGUFOww9XIbRk40nB9L/moViZ6y0TVo
         Htdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o8si24976372qtm.263.2019.07.21.03.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 03:03:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 30E3F4E908;
	Sun, 21 Jul 2019 10:03:03 +0000 (UTC)
Received: from redhat.com (ovpn-120-23.rdu2.redhat.com [10.10.120.23])
	by smtp.corp.redhat.com (Postfix) with SMTP id 69DA95F7C0;
	Sun, 21 Jul 2019 10:02:54 +0000 (UTC)
Date: Sun, 21 Jul 2019 06:02:52 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
	davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jasowang@redhat.com,
	jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: WARNING in __mmdrop
Message-ID: <20190721044615-mutt-send-email-mst@kernel.org>
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <000000000000964b0d058e1a0483@google.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Sun, 21 Jul 2019 10:03:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jul 20, 2019 at 03:08:00AM -0700, syzbot wrote:
> syzbot has bisected this bug to:
> 
> commit 7f466032dc9e5a61217f22ea34b2df932786bbfc
> Author: Jason Wang <jasowang@redhat.com>
> Date:   Fri May 24 08:12:18 2019 +0000
> 
>     vhost: access vq metadata through kernel virtual address
> 
> bisection log:  https://syzkaller.appspot.com/x/bisect.txt?x=149a8a20600000
> start commit:   6d21a41b Add linux-next specific files for 20190718
> git tree:       linux-next
> final crash:    https://syzkaller.appspot.com/x/report.txt?x=169a8a20600000
> console output: https://syzkaller.appspot.com/x/log.txt?x=129a8a20600000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=3430a151e1452331
> dashboard link: https://syzkaller.appspot.com/bug?extid=e58112d71f77113ddb7b
> syz repro:      https://syzkaller.appspot.com/x/repro.syz?x=10139e68600000
> 
> Reported-by: syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com
> Fixes: 7f466032dc9e ("vhost: access vq metadata through kernel virtual
> address")
> 
> For information about bisection process see: https://goo.gl/tpsmEJ#bisection


OK I poked at this for a bit, I see several things that
we need to fix, though I'm not yet sure it's the reason for
the failures:


1. mmu_notifier_register shouldn't be called from vhost_vring_set_num_addr
   That's just a bad hack, in particular I don't think device
   mutex is taken and so poking at two VQs will corrupt
   memory.
   So what to do? How about a per vq notifier?
   Of course we also have synchronize_rcu
   in the notifier which is slow and is now going to be called twice.
   I think call_rcu would be more appropriate here.
   We then need rcu_barrier on module unload.
   OTOH if we make pages linear with map then we are good
   with kfree_rcu which is even nicer.

2. Doesn't map leak after vhost_map_unprefetch?
   And why does it poke at contents of the map?
   No one should use it right?

3. notifier unregister happens last in vhost_dev_cleanup,
   but register happens first. This looks wrong to me.

4. OK so we use the invalidate count to try and detect that
   some invalidate is in progress.
   I am not 100% sure why do we care.
   Assuming we do, uaddr can change between start and end
   and then the counter can get negative, or generally
   out of sync.

So what to do about all this?
I am inclined to say let's just drop the uaddr optimization
for now. E.g. kvm invalidates unconditionally.
3 should be fixed independently.


-- 
MST

