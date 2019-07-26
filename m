Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEA7CC41517
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 14:11:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7471421850
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 14:11:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7471421850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC1696B0003; Fri, 26 Jul 2019 10:11:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E53AC8E0005; Fri, 26 Jul 2019 10:11:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D43A18E0003; Fri, 26 Jul 2019 10:11:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B3C6E6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 10:11:03 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d11so45246304qkb.20
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 07:11:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=BzrA0ys/IGuw6+s+YjNIxT2BTY3S5/AQ1t9rFuzqXxg=;
        b=J9yY0ldJuw51VkyZ+LgLqUYRnaUZLPY5XT71goRCy4hS/nP6s5gxoSxtu4frgGOA1v
         ncGoddddfi7SQYcaqf+jfWSsZ29/MSFNtpo2tHSX9ZsAoktUWUOqGdKNxGr3oXPKnNay
         tOJmchugKrcXQR2O1oIPYMZ/Ku3LgxK6LZsjTb18+HaMXQv4fAFjPVwl5gCkoYRwiSNi
         Vhi4Mc9OljkLnq3Bwj52R0DY8TiDdWLQKLcQuqfmLrlmZaasIKrRfxHVZa4LZhnRhR3g
         CNy5y9sNZmZOq0OCYnDiUFTlG/ZKwQGOhQGp47Df+rwJM7XQ4Xy/DRCWWchyd3iX/SMW
         U+gw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUPVRORziNKQQTngjcoQbWsulE+VUWKeD7HeFqBTVRtLqxn7lw1
	xnz22duBjCTvkBDEzTPfmZ7zgUfpcZ0zfLwmUhlytGEFj1xEEX8BkMwIQuPmaF1tRky5ITaJ/5V
	QdyAis/jDbRW4w4TY65vbVOSi13ieDz7u6KIGX++/P4bnLGQYjYg/kA1XWCaSrX/3Sg==
X-Received: by 2002:ac8:22ad:: with SMTP id f42mr66341033qta.271.1564150263477;
        Fri, 26 Jul 2019 07:11:03 -0700 (PDT)
X-Received: by 2002:ac8:22ad:: with SMTP id f42mr66340973qta.271.1564150262806;
        Fri, 26 Jul 2019 07:11:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564150262; cv=none;
        d=google.com; s=arc-20160816;
        b=aObj1NT1lgBaNM3aUmUPTCLDi56D4I7VgctTlZd+TWWWfJwqOHLJ33sAKs+t8wB/ZH
         VuNqfYxTIfhB+yL26UYBFMVJ1/GQYueQFiDxpvIPPBPN6ysjWE570bIjb2K5U7L2xfUf
         mqG4OhcBCqK/obmhloTd7z2VRLgLsX/hOInFOYDn2rcqclda0zstfuqEyCFiZaK46wZn
         c7RKW5a+GdgFNvBubaZFuVwH1GPfVmhv/mLyTSdRzAY5nPMpFf+blFBQicivbRcsf0K5
         ySSM7aDPSu/hROk5fZ49dg77r9Koso0RVkhfqs/PkFSuFA7JBwGUj8BfEijXvgTym7+C
         CZNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=BzrA0ys/IGuw6+s+YjNIxT2BTY3S5/AQ1t9rFuzqXxg=;
        b=ofY2UfhBryvNhNruJW5nx3kZi5PJL18F0/EnvphTnn+JX2avpImaK6fB31tOZcyhen
         Mg3CoplayN9RV5tEkxhrwjq5PXTFia6A21L1B+ZXs8QntfOVoSTAuZzrzT22GecdDXed
         WmFbRHMDK4TUSI2HSKAGAZC8Cr60Upaj6qE2pPT8+uLI8ihrjAj/YGHt9Iwfudm9hCLp
         wtYpovzOeCgiLA59VSQXTEZTZ005SSE+Pigh484VQfHx8HBuGqyi9AIMD9NkhySVAy0s
         LrDmMj8zQouVfJOMsaOulR7WFJhA119jdkJ4sHoUi84QokKG5ttHKwkRwqhjFSVAWXil
         +bqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l4sor29876900qkf.164.2019.07.26.07.11.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 07:11:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwObrpXH42ySj1xm6EAU0bUDulKJhDhMtupkS+wvVAcYf8qLK0833op+LhL9ss7CBOddhb+9A==
X-Received: by 2002:a37:6086:: with SMTP id u128mr63344232qkb.270.1564150262488;
        Fri, 26 Jul 2019 07:11:02 -0700 (PDT)
Received: from redhat.com ([212.92.104.165])
        by smtp.gmail.com with ESMTPSA id p32sm27054502qtb.67.2019.07.26.07.10.55
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 07:11:01 -0700 (PDT)
Date: Fri, 26 Jul 2019 10:10:52 -0400
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
Message-ID: <20190726100716-mutt-send-email-mst@kernel.org>
References: <20190725042651-mutt-send-email-mst@kernel.org>
 <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <20190726094353-mutt-send-email-mst@kernel.org>
 <63754251-a39a-1e0e-952d-658102682094@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <63754251-a39a-1e0e-952d-658102682094@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 10:00:20PM +0800, Jason Wang wrote:
> 
> On 2019/7/26 下午9:47, Michael S. Tsirkin wrote:
> > On Fri, Jul 26, 2019 at 08:53:18PM +0800, Jason Wang wrote:
> > > On 2019/7/26 下午8:38, Michael S. Tsirkin wrote:
> > > > On Fri, Jul 26, 2019 at 08:00:58PM +0800, Jason Wang wrote:
> > > > > On 2019/7/26 下午7:49, Michael S. Tsirkin wrote:
> > > > > > On Thu, Jul 25, 2019 at 10:25:25PM +0800, Jason Wang wrote:
> > > > > > > On 2019/7/25 下午9:26, Michael S. Tsirkin wrote:
> > > > > > > > > Exactly, and that's the reason actually I use synchronize_rcu() there.
> > > > > > > > > 
> > > > > > > > > So the concern is still the possible synchronize_expedited()?
> > > > > > > > I think synchronize_srcu_expedited.
> > > > > > > > 
> > > > > > > > synchronize_expedited sends lots of IPI and is bad for realtime VMs.
> > > > > > > > 
> > > > > > > > > Can I do this
> > > > > > > > > on through another series on top of the incoming V2?
> > > > > > > > > 
> > > > > > > > > Thanks
> > > > > > > > > 
> > > > > > > > The question is this: is this still a gain if we switch to the
> > > > > > > > more expensive srcu? If yes then we can keep the feature on,
> > > > > > > I think we only care about the cost on srcu_read_lock() which looks pretty
> > > > > > > tiny form my point of view. Which is basically a READ_ONCE() + WRITE_ONCE().
> > > > > > > 
> > > > > > > Of course I can benchmark to see the difference.
> > > > > > > 
> > > > > > > 
> > > > > > > > if not we'll put it off until next release and think
> > > > > > > > of better solutions. rcu->srcu is just a find and replace,
> > > > > > > > don't see why we need to defer that. can be a separate patch
> > > > > > > > for sure, but we need to know how well it works.
> > > > > > > I think I get here, let me try to do that in V2 and let's see the numbers.
> > > > > > > 
> > > > > > > Thanks
> > > > > It looks to me for tree rcu, its srcu_read_lock() have a mb() which is too
> > > > > expensive for us.
> > > > I will try to ponder using vq lock in some way.
> > > > Maybe with trylock somehow ...
> > > 
> > > Ok, let me retry if necessary (but I do remember I end up with deadlocks
> > > last try).
> > > 
> > > 
> > > > 
> > > > > If we just worry about the IPI,
> > > > With synchronize_rcu what I would worry about is that guest is stalled
> > > 
> > > Can this synchronize_rcu() be triggered by guest? If yes, there are several
> > > other MMU notifiers that can block. Is vhost something special here?
> > Sorry, let me explain: guests (and tasks in general)
> > can trigger activity that will
> > make synchronize_rcu take a long time.
> 
> 
> Yes, I get this.
> 
> 
> >   Thus blocking
> > an mmu notifier until synchronize_rcu finishes
> > is a bad idea.
> 
> 
> The question is, MMU notifier are allowed to be blocked on
> invalidate_range_start() which could be much slower than synchronize_rcu()
> to finish.
> 
> Looking at amdgpu_mn_invalidate_range_start_gfx() which calls
> amdgpu_mn_invalidate_node() which did:
> 
>                 r = reservation_object_wait_timeout_rcu(bo->tbo.resv,
>                         true, false, MAX_SCHEDULE_TIMEOUT);
> 
> ...
> 

Right. And the result will probably be VMs freezing/timing out, too.
It's just that we care about VMs more than the GPU guys :)


> > > > because system is busy because of other guests.
> > > > With expedited it's the IPIs...
> > > > 
> > > The current synchronize_rcu()  can force a expedited grace period:
> > > 
> > > void synchronize_rcu(void)
> > > {
> > >          ...
> > >          if (rcu_blocking_is_gp())
> > > return;
> > >          if (rcu_gp_is_expedited())
> > > synchronize_rcu_expedited();
> > > else
> > > wait_rcu_gp(call_rcu);
> > > }
> > > EXPORT_SYMBOL_GPL(synchronize_rcu);
> > 
> > An admin can force rcu to finish faster, trading
> > interrupts for responsiveness.
> 
> 
> Yes, so when set, all each synchronize_rcu() will go for
> synchronize_rcu_expedited().

And that's bad for realtime things. I understand what you are saying,
host admin can set this and VMs won't time-out.  What I'm saying is we
should not make admins choose between two types of bugs. Tuning for
performance is fine.

> 
> > 
> > > > > can we do something like in
> > > > > vhost_invalidate_vq_start()?
> > > > > 
> > > > >           if (map) {
> > > > >                   /* In order to avoid possible IPIs with
> > > > >                    * synchronize_rcu_expedited() we use call_rcu() +
> > > > >                    * completion.
> > > > > */
> > > > > init_completion(&c.completion);
> > > > >                   call_rcu(&c.rcu_head, vhost_finish_vq_invalidation);
> > > > > wait_for_completion(&c.completion);
> > > > >                   vhost_set_map_dirty(vq, map, index);
> > > > > vhost_map_unprefetch(map);
> > > > >           }
> > > > > 
> > > > > ?
> > > > Why would that be faster than synchronize_rcu?
> > > 
> > > No faster but no IPI.
> > > 
> > Sorry I still don't see the point.
> > synchronize_rcu doesn't normally do an IPI either.
> > 
> 
> Not the case of when rcu_expedited is set. This can just 100% make sure
> there's no IPI.

Right but then the latency can be pretty big.

> 
> > > > 
> > > > > > There's one other thing that bothers me, and that is that
> > > > > > for large rings which are not physically contiguous
> > > > > > we don't implement the optimization.
> > > > > > 
> > > > > > For sure, that can wait, but I think eventually we should
> > > > > > vmap large rings.
> > > > > Yes, worth to try. But using direct map has its own advantage: it can use
> > > > > hugepage that vmap can't
> > > > > 
> > > > > Thanks
> > > > Sure, so we can do that for small rings.
> > > 
> > > Yes, that's possible but should be done on top.
> > > 
> > > Thanks
> > Absolutely. Need to fix up the bugs first.
> > 
> 
> Yes.
> 
> Thanks

