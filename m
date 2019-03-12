Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF2F2C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:25:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D4272054F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:25:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D4272054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 174EE8E0004; Tue, 12 Mar 2019 11:25:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FEA38E0002; Tue, 12 Mar 2019 11:25:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0A508E0004; Tue, 12 Mar 2019 11:25:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4C118E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:25:56 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id n16so2572681qtp.14
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:25:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=IrlENJIX9pPj6PzW8XRL+CiNpvhQPpIw154J81ylkEY=;
        b=egxsO2Izj58KEN96vW36crku8mEfxCUjFHia2slTrIYMw3W9jrZv2SabcA4Rw34kFj
         2rWJPFRRzW7rRf4qUdofsV42xl3Vxk40sAOmwlMWBuW/tZXVXDzy2Z3zFdUAVj6Mnwog
         f+Y66X8JnDoqI8ZrP8wLmLPz85UQS9BhjAmlBoRuVTiqrCIQRO2NDxQ5M80KR8Buujpy
         Ss3mg/t45P30lMEUjB79j3eW4fp/Q18C1Cmj7OXKrEzdm+/EyqMeq0e7z2sNXyu5GfTH
         /8P82+8BshPdbhAd++ikU40Sd2ntUAFu+TFYhGa0qIEdk5XY4P4ZZvrw4oCaiG/AxSWI
         SIpg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWGxmwBsTVTwSq3U8MTEw1S3Q0/Px94/muGXY83Cl2bB8ocEV15
	Uul/IPAGgEuLemotT/GcZpiXUy9/G5cHnwy1PImoIfUzF56f2vUXhkzLZ/Y9NBWN3oVxRCIybHF
	ZtxiJnF0RzBYyvv/W8owHKDuGYbHyadK2ryHgV+bYe/9HAdisChZR7skJ6W3DVY+5gQ==
X-Received: by 2002:a37:c44a:: with SMTP id h10mr6269331qkm.350.1552404356574;
        Tue, 12 Mar 2019 08:25:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3d+vBDD8vdn9g5VH8szvxUUiKZLe7vH8KSmuFX3adWWpFWwjSK7h7AKc5J2AtaaD8vsQJ
X-Received: by 2002:a37:c44a:: with SMTP id h10mr6269264qkm.350.1552404355478;
        Tue, 12 Mar 2019 08:25:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552404355; cv=none;
        d=google.com; s=arc-20160816;
        b=BGOs90bXZVmmTLOgxTUY670/zHwfg7dQzWvWL1b4kUxrdWSCuKAL2kBdLNWgyMkWVE
         a+SuwSCjShPVWTpwAY/yAodcyUYhSPEaxiF0lPjV9ol/afE2cK0pj36jBVKBxY/bwpCB
         xhUv9NbHrmSz1ZTjC63k8Jl30dxCCO/2U6Zk0WS8EEZ2cIO3dDNnVx9Yl3KHk7jkdCeD
         iXEWA4fSmLxfPFReInJkLZMMHOkxxaZH+pPdGabpAEp3FkscQvzzc2HBCZITulhTeHE6
         O4zODfzLhi85A5bdrjWf2b5NEQmC2UTVhICpXUxDYJezym1tmm3+ScsNQWogUND68VTE
         q6LQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=IrlENJIX9pPj6PzW8XRL+CiNpvhQPpIw154J81ylkEY=;
        b=yYQryVnwvh768NTNsdw1BLMd7mXKI4UW1bkdAZVELdry1Fg7SjH+FRiUFvNy9T+vC9
         xFq2GrnfA1dLYvuihp9E7JQDYdSUbjjeHEJ9WvhgCw0kjbumYOfV+X9f9iqEJD8VXiY7
         ekVfK/QXezHAbvtDA71/KzRp0ns3ifNNNd8oGzZA0nHk0NGN8sQyTv5ceFhQhjsOCmIf
         L05wRKKCdCWDQ7BEEvCMM7pQ++JURGpeVeC/dtOVP49bF5u0HYvr51MfnJpnJoPouWP0
         8hexwUNmGeghQBgPRK+9jIa4n9FANjPvEhGfjtvmrbei4hLkcF6ZYJsBNaG7c98U7vwz
         U1Ug==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z36si5361427qve.190.2019.03.12.08.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 08:25:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9322D7F6CE;
	Tue, 12 Mar 2019 15:25:54 +0000 (UTC)
Received: from redhat.com (ovpn-117-131.phx2.redhat.com [10.3.117.131])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B17ED5D706;
	Tue, 12 Mar 2019 15:25:53 +0000 (UTC)
Date: Tue, 12 Mar 2019 11:25:51 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-ID: <20190312152551.GA3233@redhat.com>
References: <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
 <20190130183616.GB5061@redhat.com>
 <CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
 <20190131041641.GK5061@redhat.com>
 <CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
 <20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
 <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
 <20190307094654.35391e0066396b204d133927@linux-foundation.org>
 <20190307185623.GD3835@redhat.com>
 <CAPcyv4gkxmmkB0nofVOvkmV7HcuBDb+1VLR9CSsp+m-QLX_mxA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4gkxmmkB0nofVOvkmV7HcuBDb+1VLR9CSsp+m-QLX_mxA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 12 Mar 2019 15:25:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 08:13:53PM -0700, Dan Williams wrote:
> On Thu, Mar 7, 2019 at 10:56 AM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Thu, Mar 07, 2019 at 09:46:54AM -0800, Andrew Morton wrote:
> > > On Tue, 5 Mar 2019 20:20:10 -0800 Dan Williams <dan.j.williams@intel.com> wrote:
> > >
> > > > My hesitation would be drastically reduced if there was a plan to
> > > > avoid dangling unconsumed symbols and functionality. Specifically one
> > > > or more of the following suggestions:
> > > >
> > > > * EXPORT_SYMBOL_GPL on all exports to avoid a growing liability
> > > > surface for out-of-tree consumers to come grumble at us when we
> > > > continue to refactor the kernel as we are wont to do.
> > >
> > > The existing patches use EXPORT_SYMBOL() so that's a sticking point.
> > > Jerome, what would happen is we made these EXPORT_SYMBOL_GPL()?
> >
> > So Dan argue that GPL export solve the problem of out of tree user and
> > my personnal experience is that it does not. The GPU sub-system has tons
> > of GPL drivers that are not upstream and we never felt that we were bound
> > to support them in anyway. We always were very clear that if you are not
> > upstream that you do not have any voice on changes we do.
> >
> > So my exeperience is that GPL does not help here. It is just about being
> > clear and ignoring anyone who does not have an upstream driver ie we have
> > free hands to update HMM in anyway as long as we keep supporting the
> > upstream user.
> >
> > That being said if the GPL aspect is that much important to some then
> > fine let switch all HMM symbol to GPL.
> 
> I should add that I would not be opposed to moving symbols to
> non-GPL-only over time, but that should be based on our experience
> with the stability and utility of the implementation. For brand new
> symbols there's just no data to argue that we can / should keep the
> interface stable, or that the interface exposes something fragile that
> we'd rather not export at all. That experience gathering and thrash is
> best constrained to upstream GPL-only drivers that are signing up to
> participate in that maturation process.
> 
> So I think it is important from a practical perspective and is a lower
> risk way to run this HMM experiment of "merge infrastructure way in
> advance of an upstream user".
> 
> > > > * A commitment to consume newly exported symbols in the same merge
> > > > window, or the following merge window. When that goal is missed revert
> > > > the functionality until such time that it can be consumed, or
> > > > otherwise abandoned.
> > >
> > > It sounds like we can tick this box.
> >
> > I wouldn't be too strick either, when adding something in release N
> > the driver change in N+1 can miss N+1 because of bug or regression
> > and be push to N+2.
> >
> > I think a better stance here is that if we do not get any sign-off
> > on the feature from driver maintainer for which the feature is intended
> > then we just do not merge.
> 
> Agree, no driver maintainer sign-off then no merge.
> 
> > If after few release we still can not get
> > the driver to use it then we revert.
> 
> As long as it is made clear to the driver maintainer that they have
> one cycle to consume it then we can have a conversation if it is too
> early to merge the infrastructure. If no one has time to consume the
> feature, why rush dead code into the kernel? Also, waiting 2 cycles
> means the infrastructure that was hard to review without a user is now
> even harder to review because any review momentum has been lost by the
> time the user show up, so we're better off keeping them close together
> in time.

Miss-understanding here, in first post the infrastructure and the driver
bit get posted just like have been doing lately. So that you know that
you have working user with the feature and what is left is pushing the
driver bits throught the appropriate tree. So driver maintainer support
is about knowing that they want the feature and have some confidence
that it looks ready.

It also means you can review the infrastructure along side user of it.

> 
> 
> > It just feels dumb to revert at N+1 just to get it back in N+2 as
> > the driver bit get fix.
> 
> No, I think it just means the infrastructure went in too early if a
> driver can't consume it in a development cycle. Lets revisit if it
> becomes a problem in practice.

Well that's just dumb to have hard guideline like that. Many things
can lead to missing deadline. For instance bug i am refering too might
have nothing to do with the feature, it can be something related to
integrating the feature an unforseen side effect. So i believe a better
guideline is that driver maintainer rejecting the feature rather than
just failure to meet one deadline.


> > > > * No new symbol exports and functionality while existing symbols go unconsumed.
> > >
> > > Unsure about this one?
> >
> > With nouveau upstream now everything is use. ODP will use some of the
> > symbol too. PPC has patchset posted to use lot of HMM too. I have been
> > working with other vendor that have patchset being work on to use HMM
> > too.
> >
> > I have not done all those function just for the fun of it :) They do
> > have real use and user. It took a longtime to get nouveau because of
> > userspace we had a lot of catchup to do in mesa and llvm and we are
> > still very rough there.
> 
> Sure, this one is less of a concern if we can stick to tighter
> timelines between infrastructure and driver consumer merge.

Issue is that consumer timeline can be hard to know, sometimes
the consumer go over few revision (like ppc for instance) and
not because of the infrastructure but for other reasons. So
reverting the infrastructure just because user had its timeline
change is not productive. User missing one cycle means they would
get delayed for 2 cycles ie reupstreaming the infrastructure in
next cycle and repushing the user the cycle after. This sounds
like a total wastage of everyone times. While keeping the infra-
structure would allow the timeline to slip by just one cycle.

Spirit of the rule is better than blind application of rule.

Cheers,
Jérôme

