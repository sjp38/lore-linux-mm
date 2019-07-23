Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6395BC7618B
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:10:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31465223A1
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 08:10:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31465223A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7BCD6B0005; Tue, 23 Jul 2019 04:10:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C057E6B0007; Tue, 23 Jul 2019 04:10:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF4F98E0002; Tue, 23 Jul 2019 04:10:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 60DE66B0005
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 04:10:38 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id r4so20513530wrt.13
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 01:10:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=6iDuqxmKcASOOFXh75MkQ8KIrlMWj9tNOgqU0O447i0=;
        b=MNzIuoVX4zFtOP5gj9JAoHJWsVwSlX5+Cb58EzGbc0dAoqzIvul+SWik13i9jVsOzi
         EvayRnfgvTjAKR99Ubgx2/xpuaNx9v/OyPdjabfn7tLeOrhHOiNVJO3EJtwzEhlB2YHO
         Z+HE55fgeOLyx57dA6DrRNkwnolYSgmsjnHnWpElTedqIsRvS8qU3vkMxVpyb8FxGSbN
         Lh78r4kyejx9Idbl2s/jC69OFXJkyThXv6crXOPudCWXT3mR8P0bnTD/LRZvOy1P5HhA
         IRDMWzzQEk3fVc3mFRw5VUlNWZvx/0cUBNTHxC23UUfQ/1tV+Vn1pSjsL6dn+dpeNcWc
         f+Cw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAURScWB8JZUTX5OLMV7/wV7q1tETOyRblL/xfH0KDo9TfvmmsY9
	3gQLS5kC2Jw4Jujp813YJdWHDktTzpxvpnodw3H57lvryyDFnOqo64nYeqk9i6HIIRuQLkeTkIL
	CBL8kIayzv2kKIZ67mpE3vj+iKEY6+wG4aQ/qiLZsTljfHuxOUAATa/wYClbdAEzr6A==
X-Received: by 2002:a05:6000:14b:: with SMTP id r11mr5681061wrx.196.1563869437975;
        Tue, 23 Jul 2019 01:10:37 -0700 (PDT)
X-Received: by 2002:a05:6000:14b:: with SMTP id r11mr5680942wrx.196.1563869437150;
        Tue, 23 Jul 2019 01:10:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563869437; cv=none;
        d=google.com; s=arc-20160816;
        b=wauE9E+xvKSUKzdypPfAFQsJIadyZ091rcQ5z2XhIRvL+49JQEKZJZO0VGdMyJWuu0
         EWixYEXRTGnjYwaFdOm4YZNEl+BYph8vWkDUMAVrwaRsNy+w+pI8USIL9AbI3atALdwx
         yRkR6JVFMxYELBX/c3yGxas5HWEXu/oRg1AMWj2GkrcdEHVDRI6bR5Os0gjFL/Tm31QI
         V0J9XBfI9tgAPYKGr3S5MuExkq68ixg5qD5IwYNoL3EPfdcZwxmB2+RA5CU3j0sWc3hK
         1erbqehIPTW7y9RAiuC0mpd2NtcwNhfnEAZXredZQIgdwEEMyQoUXTajUQm7k6s7mi04
         8ivw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=6iDuqxmKcASOOFXh75MkQ8KIrlMWj9tNOgqU0O447i0=;
        b=LQZQoey3ZAJckEY3YCB2rt4Hqx1KvI7PuBXjiPCYPHwxkxWSJIluhEH1mwd37ybtdY
         9R4nCdLlexHSAzW2CKno92b+Azf6pny8C1Lkxm2cCGi8EPbEg68TkMU3onljhabz8dHZ
         EZNsEHOTOy+OJFasS1i1qrC+XZi3ICaIhSwlsDbCTu02LB6W2iJTqi+zR8UFnT1o/9BQ
         ps6PhYKzjPQO20j9GPgT0MO0GeqdmuJD+YBL4WqJyZRgVUTz9zcBbXhtlQim2TX8H3PZ
         uRAEHrmvjDa86e3A59A4qurCz+Fw//xyUE3CbX/EemLj8iLd9H7D/l00x0fH70xyPbpp
         wEAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h11sor23963735wmc.3.2019.07.23.01.10.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 01:10:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxscCG5zV7WA3DgTwEOV7g+JI81JPQ3KtiJr3uwJoC6TgABoTfwOxAcc4Y8uQvIaAafGVRR6A==
X-Received: by 2002:a1c:a1c5:: with SMTP id k188mr67874643wme.102.1563869436805;
        Tue, 23 Jul 2019 01:10:36 -0700 (PDT)
Received: from redhat.com ([185.120.125.30])
        by smtp.gmail.com with ESMTPSA id y12sm36236469wrm.79.2019.07.23.01.10.33
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 01:10:36 -0700 (PDT)
Date: Tue, 23 Jul 2019 04:10:31 -0400
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
Message-ID: <20190723035725-mutt-send-email-mst@kernel.org>
References: <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <20190721081447-mutt-send-email-mst@kernel.org>
 <85dd00e2-37a6-72b7-5d5a-8bf46a3526cf@redhat.com>
 <20190722040230-mutt-send-email-mst@kernel.org>
 <4bd2ff78-6871-55f2-44dc-0982ffef3337@redhat.com>
 <20190723010019-mutt-send-email-mst@kernel.org>
 <b4696f2e-678a-bdb2-4b7c-fb4ce040ec2a@redhat.com>
 <20190723032024-mutt-send-email-mst@kernel.org>
 <1d14de4d-0133-1614-9f64-3ded381de04e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1d14de4d-0133-1614-9f64-3ded381de04e@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 03:53:06PM +0800, Jason Wang wrote:
> 
> On 2019/7/23 下午3:23, Michael S. Tsirkin wrote:
> > > > Really let's just use kfree_rcu. It's way cleaner: fire and forget.
> > > Looks not, you need rate limit the fire as you've figured out?
> > See the discussion that followed. Basically no, it's good enough
> > already and is only going to be better.
> > 
> > > And in fact,
> > > the synchronization is not even needed, does it help if I leave a comment to
> > > explain?
> > Let's try to figure it out in the mail first. I'm pretty sure the
> > current logic is wrong.
> 
> 
> Here is what the code what to achieve:
> 
> - The map was protected by RCU
> 
> - Writers are: MMU notifier invalidation callbacks, file operations (ioctls
> etc), meta_prefetch (datapath)
> 
> - Readers are: memory accessor
> 
> Writer are synchronized through mmu_lock. RCU is used to synchronized
> between writers and readers.
> 
> The synchronize_rcu() in vhost_reset_vq_maps() was used to synchronized it
> with readers (memory accessors) in the path of file operations. But in this
> case, vq->mutex was already held, this means it has been serialized with
> memory accessor. That's why I think it could be removed safely.
> 
> Anything I miss here?
> 

So invalidate callbacks need to reset the map, and they do
not have vq mutex. How can they do this and free
the map safely? They need synchronize_rcu or kfree_rcu right?

And I worry somewhat that synchronize_rcu in an MMU notifier
is a problem, MMU notifiers are supposed to be quick:
they are on a read side critical section of SRCU.

If we could get rid of RCU that would be even better.

But now I wonder:
	invalidate_start has to mark page as dirty
	(this is what my patch added, current code misses this).

	at that point kernel can come and make the page clean again.

	At that point VQ handlers can keep a copy of the map
	and change the page again.


At this point I don't understand how we can mark page dirty
safely.

> > 
> > > > > Btw, for kvm ioctl it still uses synchronize_rcu() in kvm_vcpu_ioctl(),
> > > > > (just a little bit more hard to trigger):
> > > > AFAIK these never run in response to guest events.
> > > > So they can take very long and guests still won't crash.
> > > What if guest manages to escape to qemu?
> > > 
> > > Thanks
> > Then it's going to be slow. Why do we care?
> > What we do not want is synchronize_rcu that guest is blocked on.
> > 
> 
> Ok, this looks like that I have some misunderstanding here of the reason why
> synchronize_rcu() is not preferable in the path of ioctl. But in kvm case,
> if rcu_expedited is set, it can triggers IPIs AFAIK.
> 
> Thanks
>

Yes, expedited is not good for something guest can trigger.
Let's just use kfree_rcu if we can. Paul said even though
documentation still says it needs to be rate-limited, that
part is basically stale and will get updated.

-- 
MST 

