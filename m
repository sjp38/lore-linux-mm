Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB6DEC76190
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:38:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99E6721951
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 12:38:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99E6721951
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1545B6B0003; Fri, 26 Jul 2019 08:38:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1061A8E0002; Fri, 26 Jul 2019 08:38:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F37126B0008; Fri, 26 Jul 2019 08:38:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DCBF66B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 08:38:24 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id n190so45088810qkd.5
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 05:38:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=7AAahzA3S5OmAp3WHwhPen11x5qmdYBmT/Y66i6DKGs=;
        b=e1VGQRn/M3xGcQEUXS3L5iASLNaopzoU+JLR9HbGbF6Kxl1PQ1jm8JcveNyQqYmFgP
         HgvS192/0c3Qv5SHr0Ep3NvZ365YcVyBps31Vp/qX/5OvNCQkvrwE6d5sXJG0Ap+ccji
         R4HXyJvh55HfL81y8bHpsg37VVPMkd+ZQnAxU+D5Vcu2iJ4WYZaccdxlCl7mZygvgDkK
         9VntQDaVkA+mZAnb94rHJPnvItVYh3+wdpZPQn+reIsgXjGaaRv4sicWjtsEAnVy72h1
         xK61eYAOwhFXlTdUZkz33zjjoBaG7YwtCFXYV7T92n4sm5RMU69OB+ren0LHYveKPNOA
         g0jA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWfRg23S+NxEDvacEh6VMIMpx3a/aWpfstlWEA19GFIgesjw8bW
	90vwHSyxHUtKwH9oeCwLPv41K3zwTtP0aTuV/UcG7DN7Pv2EiP5isX3km0ViBM9rTrnILyewCrJ
	gTiVqdKHomTVvKYCrvNoj0xvIM1AkiAEoR7HXNYjj+kVnXKrOGKjm2ewx/S85OpFKqw==
X-Received: by 2002:a0c:c688:: with SMTP id d8mr67895738qvj.86.1564144704666;
        Fri, 26 Jul 2019 05:38:24 -0700 (PDT)
X-Received: by 2002:a0c:c688:: with SMTP id d8mr67895706qvj.86.1564144704075;
        Fri, 26 Jul 2019 05:38:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564144704; cv=none;
        d=google.com; s=arc-20160816;
        b=sj699GJmDp2oi8dmW0cyvWNdhjJZSsCR0INlO4WpPKt4YLrm3HTFyOpeZrCePhD/q+
         sgirk2pLCkKbpZd9lemXoKzwYAkkdeBsHR8ttjFT4MsssvNvDhByAqSBb+J38rPru/nN
         nu8xx37u2MErZ6CKCPKDipJXKtUPjakJHK3yBumhJ2RJX+yEGK2IrWLvgFaeNDVYKegQ
         kj/pHia0vHXoGVo4fS/phomBcP+n5N0pVooo8p80NEFRO0gvLdiWp1v+3QsTZdXcUgig
         m2jAk89MIymsnb4apAW9EpuyWqBoiYNSM4SRGRoOUWqQF7jvGpLCFWLtOBqcX3mrhaG4
         X+WQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=7AAahzA3S5OmAp3WHwhPen11x5qmdYBmT/Y66i6DKGs=;
        b=c0fllbFJrgndipy1kDnxyxfA8K2M3IyYS+a/0tMPNOGnMRfCNX6b3Qs4ifmLwf7CcR
         cb/ndkZ+smrtPBC5vgoXZu4JMDOHS04SZYe2PBwjcCu1UVza9Q+Mx8H35jckXJ+PJo6i
         KcAxXQk4Be1Hc4l7eVrKunFpJSXAmdvATcjYBMZICzVUWJPq1kMYhEZ4dgRVAnbEMnBM
         QfnDOpzRk2YEMUa2NKwat34b0mv5foneoQ4rCjlx7Y/cZB7wpotao9C1tf3h/agBoNtd
         SxGFVQEiDFgCRWCDo9F8hBSd1B9phX6vIe9C9ynDass1JEn/o4KRye7ldph+jnTJRBGg
         YnDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b15sor61208618qtt.9.2019.07.26.05.38.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Jul 2019 05:38:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzmq5+4vWxaDwMY+05UXlQp7huBRpq3YhuBZEQ2PajFPNo/CMYsaRV1rBY4ljt21ew7Zf/M7w==
X-Received: by 2002:ac8:37b8:: with SMTP id d53mr65290476qtc.227.1564144703827;
        Fri, 26 Jul 2019 05:38:23 -0700 (PDT)
Received: from redhat.com ([212.92.104.165])
        by smtp.gmail.com with ESMTPSA id v7sm25082729qte.86.2019.07.26.05.38.16
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 26 Jul 2019 05:38:23 -0700 (PDT)
Date: Fri, 26 Jul 2019 08:38:13 -0400
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
Message-ID: <20190726082837-mutt-send-email-mst@kernel.org>
References: <20190723051828-mutt-send-email-mst@kernel.org>
 <caff362a-e208-3468-3688-63e1d093a9d3@redhat.com>
 <20190725012149-mutt-send-email-mst@kernel.org>
 <55e8930c-2695-365f-a07b-3ad169654d28@redhat.com>
 <20190725042651-mutt-send-email-mst@kernel.org>
 <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 08:00:58PM +0800, Jason Wang wrote:
> 
> On 2019/7/26 下午7:49, Michael S. Tsirkin wrote:
> > On Thu, Jul 25, 2019 at 10:25:25PM +0800, Jason Wang wrote:
> > > On 2019/7/25 下午9:26, Michael S. Tsirkin wrote:
> > > > > Exactly, and that's the reason actually I use synchronize_rcu() there.
> > > > > 
> > > > > So the concern is still the possible synchronize_expedited()?
> > > > I think synchronize_srcu_expedited.
> > > > 
> > > > synchronize_expedited sends lots of IPI and is bad for realtime VMs.
> > > > 
> > > > > Can I do this
> > > > > on through another series on top of the incoming V2?
> > > > > 
> > > > > Thanks
> > > > > 
> > > > The question is this: is this still a gain if we switch to the
> > > > more expensive srcu? If yes then we can keep the feature on,
> > > 
> > > I think we only care about the cost on srcu_read_lock() which looks pretty
> > > tiny form my point of view. Which is basically a READ_ONCE() + WRITE_ONCE().
> > > 
> > > Of course I can benchmark to see the difference.
> > > 
> > > 
> > > > if not we'll put it off until next release and think
> > > > of better solutions. rcu->srcu is just a find and replace,
> > > > don't see why we need to defer that. can be a separate patch
> > > > for sure, but we need to know how well it works.
> > > 
> > > I think I get here, let me try to do that in V2 and let's see the numbers.
> > > 
> > > Thanks
> 
> 
> It looks to me for tree rcu, its srcu_read_lock() have a mb() which is too
> expensive for us.

I will try to ponder using vq lock in some way.
Maybe with trylock somehow ...


> If we just worry about the IPI,

With synchronize_rcu what I would worry about is that guest is stalled
because system is busy because of other guests.
With expedited it's the IPIs...


> can we do something like in
> vhost_invalidate_vq_start()?
> 
>         if (map) {
>                 /* In order to avoid possible IPIs with
>                  * synchronize_rcu_expedited() we use call_rcu() +
>                  * completion.
> */
> init_completion(&c.completion);
>                 call_rcu(&c.rcu_head, vhost_finish_vq_invalidation);
> wait_for_completion(&c.completion);
>                 vhost_set_map_dirty(vq, map, index);
> vhost_map_unprefetch(map);
>         }
> 
> ?

Why would that be faster than synchronize_rcu?



> 
> > There's one other thing that bothers me, and that is that
> > for large rings which are not physically contiguous
> > we don't implement the optimization.
> > 
> > For sure, that can wait, but I think eventually we should
> > vmap large rings.
> 
> 
> Yes, worth to try. But using direct map has its own advantage: it can use
> hugepage that vmap can't
> 
> Thanks

Sure, so we can do that for small rings.

-- 
MST

