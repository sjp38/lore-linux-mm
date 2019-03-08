Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F32EC10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:45:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4EC320675
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:45:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4EC320675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 80F0C8E0003; Thu,  7 Mar 2019 22:45:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BE428E0002; Thu,  7 Mar 2019 22:45:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AF448E0004; Thu,  7 Mar 2019 22:45:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4336F8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 22:45:49 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id s65so14918215qke.16
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 19:45:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=oNTtiF+hrkLpsvw7f4dRXrLixWTSG0zB1RYyJEtcVgk=;
        b=QxouilrMp7r62dKJ6xGJcJzgnMMRLYH8mrw6RZDnhvVqiOHpdmnRfL6A+OtyWQ2ozZ
         3rLcqpdX28XZq1I3D1X3gIW8bK/RiHmBW1bnHlFfq5/5fR6grlDzyzt49huqsURN7vvB
         lrIdJ2Mk65nvP4x5i7u83S81RnRE5j7Pmu8i/KZmMDAMmcMsj/UyfbTzJH8ePVJ+VLSH
         EILOFDDI0XwUpBqRhQwlVp7CK9KvBPsLfFFVhZiUSGU20S+SlLrqXZMEaCorTZnVNqvN
         EAfne6ABugb+xqjwZGW5UK/twpheTgzWgmCYOZ7eey+FFRWj0doXNKAMhq18Ymr+g3Py
         oy6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVKWD6Le+8Xw1/8PqLXBsk8HnipIQWACQC/ZupOKva8ksiEWzfU
	FSLGQW9rjQj2APJSXOnIbHV4rBgQNlHj0zcN7A+S3Djl7PTDdEHA8LM6csWUlvoREK8VqDYHy8o
	yCdOaAGleS8yVGnXEgn716bRl7ZllSxHpgh5cWqrQhRLA/bbOb0+PhH9sfDpp9T+uMw==
X-Received: by 2002:a37:32d4:: with SMTP id y203mr12313149qky.282.1552016749018;
        Thu, 07 Mar 2019 19:45:49 -0800 (PST)
X-Google-Smtp-Source: APXvYqz1y6Wjts0NEjcDsUgW7x77Y7Z7hLj4ZP33zbXZEJ4oQ4htxLwoBjzC7PskcwH+05oh/qoT
X-Received: by 2002:a37:32d4:: with SMTP id y203mr12313128qky.282.1552016748355;
        Thu, 07 Mar 2019 19:45:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552016748; cv=none;
        d=google.com; s=arc-20160816;
        b=AAiy1aUMwyWn2/nxxT4f6+54erU9DWjLY7o/xWqyMpmwHfyTvEOgdnsLO75QucuT4B
         Hqa6bJ/mnnWVxERUjEfGTsPDPdnK87n+4awZ7zYSHQlL9+UunY+eYfYu1D4HGRarOaFF
         RQxgOSQ7G7XmfXGL9iw9EnhxvGrPpP2HR08GGOSOX3iPbepFGZglSzjph/7J5BmnZIi6
         lPT9Kxp0hRnnk5YYWpo3Jwd3+GagFoc+dXDRExjdC5ocRinwNZgvanUK/IBniZdsmBSv
         b2yCeBA1oYHSVNRz6g7WHvWtcwFJavnFfhc7hypCOqkYDj2a2aiM/LPykFCLVDQyOdCr
         +GFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=oNTtiF+hrkLpsvw7f4dRXrLixWTSG0zB1RYyJEtcVgk=;
        b=oMSsljPNH6q7Jj9iLAAmxuRXaEyLN2URh+gNQjsca4eEMf1LkC5n579K7TD8ekajeX
         Vs4vf5WiHdP+ET4+yGGi3N2xGMKErnWonuuKbi7X2u6GXiyKzN1MVvF9i2YFpagLF7R9
         8kO+mh4/ftrObLtWGqIDuPcEMuQeM8QDT6gudOKX5DtlpB8Ut1JgZdtQRzogVu1R4XxB
         ZX5IcKbkou7NqmIo8LKdxs/j/bIsxBy7xz5QQ1f9LFhDgGNfPEFAYta6N3U2lYb4aBZT
         6kQDbMXSpXJzmhDjxaQlS35n8skOFGlGAYAFC/NahOV4vXLtsxFABkHgkXW4YCUCAYCh
         rR+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p31si60121qta.179.2019.03.07.19.45.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 19:45:48 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8894930EBE93;
	Fri,  8 Mar 2019 03:45:47 +0000 (UTC)
Received: from redhat.com (ovpn-125-54.rdu2.redhat.com [10.10.125.54])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 6EBC15D9D5;
	Fri,  8 Mar 2019 03:45:42 +0000 (UTC)
Date: Thu, 7 Mar 2019 22:45:40 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	aarcange@redhat.com
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190308034540.GC5562@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191720.GF3835@redhat.com>
 <20190307211506-mutt-send-email-mst@kernel.org>
 <20190308025539.GA5562@redhat.com>
 <20190307221549-mutt-send-email-mst@kernel.org>
 <20190308034053.GB5562@redhat.com>
 <20190307224143-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190307224143-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Fri, 08 Mar 2019 03:45:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 10:43:12PM -0500, Michael S. Tsirkin wrote:
> On Thu, Mar 07, 2019 at 10:40:53PM -0500, Jerome Glisse wrote:
> > On Thu, Mar 07, 2019 at 10:16:00PM -0500, Michael S. Tsirkin wrote:
> > > On Thu, Mar 07, 2019 at 09:55:39PM -0500, Jerome Glisse wrote:
> > > > On Thu, Mar 07, 2019 at 09:21:03PM -0500, Michael S. Tsirkin wrote:
> > > > > On Thu, Mar 07, 2019 at 02:17:20PM -0500, Jerome Glisse wrote:
> > > > > > > It's because of all these issues that I preferred just accessing
> > > > > > > userspace memory and handling faults. Unfortunately there does not
> > > > > > > appear to exist an API that whitelists a specific driver along the lines
> > > > > > > of "I checked this code for speculative info leaks, don't add barriers
> > > > > > > on data path please".
> > > > > > 
> > > > > > Maybe it would be better to explore adding such helper then remapping
> > > > > > page into kernel address space ?
> > > > > 
> > > > > I explored it a bit (see e.g. thread around: "__get_user slower than
> > > > > get_user") and I can tell you it's not trivial given the issue is around
> > > > > security.  So in practice it does not seem fair to keep a significant
> > > > > optimization out of kernel because *maybe* we can do it differently even
> > > > > better :)
> > > > 
> > > > Maybe a slightly different approach between this patchset and other
> > > > copy user API would work here. What you want really is something like
> > > > a temporary mlock on a range of memory so that it is safe for the
> > > > kernel to access range of userspace virtual address ie page are
> > > > present and with proper permission hence there can be no page fault
> > > > while you are accessing thing from kernel context.
> > > > 
> > > > So you can have like a range structure and mmu notifier. When you
> > > > lock the range you block mmu notifier to allow your code to work on
> > > > the userspace VA safely. Once you are done you unlock and let the
> > > > mmu notifier go on. It is pretty much exactly this patchset except
> > > > that you remove all the kernel vmap code. A nice thing about that
> > > > is that you do not need to worry about calling set page dirty it
> > > > will already be handle by the userspace VA pte. It also use less
> > > > memory than when you have kernel vmap.
> > > > 
> > > > This idea might be defeated by security feature where the kernel is
> > > > running in its own address space without the userspace address
> > > > space present.
> > > 
> > > Like smap?
> > 
> > Yes like smap but also other newer changes, with similar effect, since
> > the spectre drama.
> > 
> > Cheers,
> > Jérôme
> 
> Sorry do you mean meltdown and kpti?

Yes all that and similar thing. I do not have the full list in my head.

Cheers,
Jérôme

