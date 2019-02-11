Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1608C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:10:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BA2321B24
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:10:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BA2321B24
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2143E8E0120; Mon, 11 Feb 2019 13:10:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C31D8E0115; Mon, 11 Feb 2019 13:10:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08BB98E0120; Mon, 11 Feb 2019 13:10:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B680D8E0115
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:10:11 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f3so8923046pgq.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:10:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rLHPW8/CEDBrTRMQdcQdUEqjbPUOTmPZPivfj71OSVg=;
        b=YAtGdAuK9V9IsgcLme5kvH24dYcZ2CNfLvALrpqeSu1rRzq+R7wYx91kfdAwYIlvOv
         V8Mkl6wxIv0eoTw/Y2cJhXNIynEXkO2pHJjmZHhGxsoKV+nJ8jZ6ZLJmJ3PXWO1p7HKx
         FOwMFcC7jJZ8wuY8o8Mcy/fRS1dDkQdg9qfDNG8t3ziVIgOv/Mpf6NRvnFRJJN2CdxCl
         LGUeCwn/5J55K9fentb0ZFr0VyvD2rkMP5+OFJfNO9bmMyYVQiKg7x5Cgel9HX+4Iqmv
         h7MsK56yaSjuqfCEiXHQ2GDLms4YZghdWsgppZYlLY3Kzpn8UzAVg/imGe0H1Y8qXZEq
         u1Tg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYB87AAVfm0B4XbUmEWfm0FK6V1MUf4rAccbMXLGRQWDu6rg/y1
	lW+izsUFzm5vzVIkWuqhxiYP7J8DhiGo1/kSBZquJg9+AEMltwwzS2kmcMoTdcMe0fXmT3tcQem
	X/hqlWQKRbkyfxioD8E3FDB+ue5LbBIveUbO5feyvPY8iXTpxdYkLF9ErNXyAXldi6w==
X-Received: by 2002:a63:9c1a:: with SMTP id f26mr34841008pge.381.1549908611354;
        Mon, 11 Feb 2019 10:10:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbGoSBWxpcsaWaYCwj+/kpqwUpp84AGvCK8ohsQMYPaZLUE0ujvlgTaJBKtKi6XccgkBy2G
X-Received: by 2002:a63:9c1a:: with SMTP id f26mr34840944pge.381.1549908610367;
        Mon, 11 Feb 2019 10:10:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549908610; cv=none;
        d=google.com; s=arc-20160816;
        b=O6KFxw6has5jwZQs3bXgmq/RAUmStmPN91dwoMpOqVYQMA8qpmt8wV1Lwfjk7fzhIm
         Um4+laJrsX/A5U2V9SdiUNhPuk+FT76W7/Fanm84W+MNxVUOwZ4gid+NgxXMHhORn+Qz
         MKiiwZdm8sqUpoERlKuL/rZuDfznX2v29YTO77fSp6TI5JsC3iGbvKz6rP4VAQm6v7vp
         Kjz3eBFIEkSYRnzLszwo7et6HzFPjTMGgmCu3x6pOMnJGL0aJ7tG6J7edpnYW+wAoHQ3
         xlqxuEtH4YbHJ/Gkz9Mi9OqpACruuNQOvxhN1gbx9uNHAs54leGG9Trk32U7u4vRi8Ao
         8fOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=rLHPW8/CEDBrTRMQdcQdUEqjbPUOTmPZPivfj71OSVg=;
        b=H/CVEjVqaMyDkmyzsC7qfTG0lqvnttFhuNb4nsWW6uOiPPFyv3AX80B/ozCNPDAISp
         pblRsj5h+QYp+M/YqRmDIEJQZtE2jyMPr9zFJbXeyIrMKTgTL2yxNprX8sJf56o1BMfq
         oT74aXyECb/TOBqGfVvl3UPgcmOZ6qMh5+cKlO2epPtLYeWiBTUyRFqyaf7sejuqhcXQ
         LpqohlDt39vOxjwcG9c+fVHtiQAG6+EvGqY3TmROViJgRtMp47yuPyjvHvlSdIg4SF5b
         1I/xoHwzwwwlhc5ah2OxXNtz8j8s3euuagTvFDk54Qe6PwiP6lcIM2PaUgbbDn7d0V7A
         Wt6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id x22si9871232pgf.570.2019.02.11.10.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 10:10:10 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of alexander.h.duyck@linux.intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=alexander.h.duyck@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 10:10:07 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,359,1544515200"; 
   d="scan'208";a="137744035"
Received: from ahduyck-desk1.jf.intel.com ([10.7.198.76])
  by orsmga001.jf.intel.com with ESMTP; 11 Feb 2019 10:10:06 -0800
Message-ID: <44d0848e62f6d5237b60d209265dbcdf58ade1b9.camel@linux.intel.com>
Subject: Re: [RFC PATCH 3/4] kvm: Add guest side support for free memory
 hints
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org, 
 linux-kernel@vger.kernel.org, kvm@vger.kernel.org, rkrcmar@redhat.com, 
 x86@kernel.org, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
 pbonzini@redhat.com,  tglx@linutronix.de, akpm@linux-foundation.org
Date: Mon, 11 Feb 2019 10:10:06 -0800
In-Reply-To: <20190211122321-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
	 <20190204181552.12095.46287.stgit@localhost.localdomain>
	 <20190209194437-mutt-send-email-mst@kernel.org>
	 <869a170e9232ffbc8ddbcf3d15535e8c6daedbde.camel@linux.intel.com>
	 <20190211122321-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-2.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-02-11 at 12:36 -0500, Michael S. Tsirkin wrote:
> On Mon, Feb 11, 2019 at 08:31:34AM -0800, Alexander Duyck wrote:
> > On Sat, 2019-02-09 at 19:49 -0500, Michael S. Tsirkin wrote:
> > > On Mon, Feb 04, 2019 at 10:15:52AM -0800, Alexander Duyck wrote:
> > > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > > 
> > > > Add guest support for providing free memory hints to the KVM hypervisor for
> > > > freed pages huge TLB size or larger. I am restricting the size to
> > > > huge TLB order and larger because the hypercalls are too expensive to be
> > > > performing one per 4K page.
> > > 
> > > Even 2M pages start to get expensive with a TB guest.
> > 
> > Agreed.
> > 
> > > Really it seems we want a virtio ring so we can pass a batch of these.
> > > E.g. 256 entries, 2M each - that's more like it.
> > 
> > The only issue I see with doing that is that we then have to defer the
> > freeing. Doing that is going to introduce issues in the guest as we are
> > going to have pages going unused for some period of time while we wait
> > for the hint to complete, and we cannot just pull said pages back. I'm
> > not really a fan of the asynchronous nature of Nitesh's patches for
> > this reason.
> 
> Well nothing prevents us from doing an extra exit to the hypervisor if
> we want. The asynchronous nature is there as an optimization
> to allow hypervisor to do its thing on a separate CPU.
> Why not proceed doing other things meanwhile?
> And if the reason is that we are short on memory, then
> maybe we should be less aggressive in hinting?
> 
> E.g. if we just have 2 pages:
> 
> hint page 1
> page 1 hint processed?
> 	yes - proceed to page 2
> 	no - wait for interrupt
> 
> get interrupt that page 1 hint is processed
> hint page 2
> 
> 
> If hypervisor happens to be running on same CPU it
> can process things synchronously and we never enter
> the no branch.
> 

Another concern I would have about processing this asynchronously is
that we have the potential for multiple guest CPUs to become
bottlenecked by a single host CPU. I am not sure if that is something
that would be desirable.

> > > > Using the huge TLB order became the obvious
> > > > choice for the order to use as it allows us to avoid fragmentation of higher
> > > > order memory on the host.
> > > > 
> > > > I have limited the functionality so that it doesn't work when page
> > > > poisoning is enabled. I did this because a write to the page after doing an
> > > > MADV_DONTNEED would effectively negate the hint, so it would be wasting
> > > > cycles to do so.
> > > 
> > > Again that's leaking host implementation detail into guest interface.
> > > 
> > > We are giving guest page hints to host that makes sense,
> > > weird interactions with other features due to host
> > > implementation details should be handled by host.
> > 
> > I don't view this as a host implementation detail, this is guest
> > feature making use of all pages for debugging. If we are placing poison
> > values in the page then I wouldn't consider them an unused page, it is
> > being actively used to store the poison value.
> 
> Well I guess it's a valid point of view for a kernel hacker, but they are
> unused from application's point of view.
> However poisoning is transparent to users and most distro users
> are not aware of it going on. They just know that debug kernels
> are slower.
> User loading a debug kernel and immediately breaking overcommit
> is an unpleasant experience.

How would that be any different then a user loading an older kernel
that doesn't have this feature and breaking overcommit as a result?

I still think it would be better if we left the poisoning enabled in
such a case and just displayed a warning message if nothing else that
hinting is disabled because of page poisoning.

One other thought I had on this is that one side effect of page
poisoning is probably that KSM would be able to merge all of the poison
pages together into a single page since they are all set to the same
values. So even with the poisoned pages it would be possible to reduce
total memory overhead.

> > If we can achieve this
> > and free the page back to the host then even better, but until the
> > features can coexist we should not use the page hinting while page
> > poisoning is enabled.
> 
> Existing hinting in balloon allows them to coexist so I think we
> need to set the bar just as high for any new variant.

That is what I heard. I will have to look into this.

> > This is one of the reasons why I was opposed to just disabling page
> > poisoning when this feature was enabled in Nitesh's patches. If the
> > guest has page poisoning enabled it is doing something with the page.
> > It shouldn't be prevented from doing that because the host wants to
> > have the option to free the pages.
> 
> I agree but I think the decision belongs on the host. I.e.
> hint the page but tell the host it needs to be careful
> about the poison value. It might also mean we
> need to make sure poisoning happens after the hinting, not before.

The only issue with poisoning after instead of before is that the hint
is ignored and we end up triggering a page fault and zero as a result.
It might make more sense to have an architecture specific call that can
be paravirtualized to handle the case of poisoning the page for us if
we have the unused page hint enabled. Otherwise the write to the page
is a given to invalidate the hint.

