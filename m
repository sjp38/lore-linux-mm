Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBB06C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:16:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4C962081B
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:16:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4C962081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D0268E0004; Thu,  7 Mar 2019 22:16:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27BC18E0002; Thu,  7 Mar 2019 22:16:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16CA38E0004; Thu,  7 Mar 2019 22:16:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id DD1B28E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 22:16:04 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id s8so17216842qth.18
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 19:16:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=+aYmiB1WgFEgCfJKnHZaWgzaN6cLqOY1VulRCFSIq7o=;
        b=Sx4oPrChVeRWJfVhTymlyMxTMZWgp+TjnT/X2fQcOxKqwNz5bOWeWJKC3RXeCRs3Zo
         w13hKz9VcF6rWSYwY9d8zdjfizXmbTNNh9XeB8MUkJWTGBD2pI/lA6X/t4G1wmNAd1B9
         aCpLURcuzkr/ciSRj1EQeOgr9LQs1WRV4eNPQOPfURJufRhhLY4w7RGHLfgsXBTQgwCc
         rACKj3WyDq2j9jlcA14T7AenGtj+1LzwQgWbR++wZmWmf1acnz1W/Prj3RjLqA/OBNTL
         M56k83GTQjHr11vEKZ655kaaXpC5m1/bTvua/F5OS9cal1bvgORF1dQ7MA3xSAZfXkxz
         gEQg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWKfmmj99PLvzw6WCz5QklETAiL9dUGSOmxcFSc79y5kVZEN6bp
	soqs7yGM6bIpSthsD33ceCnAyCvX/u28frKr+zm56W+a3jdZJAekyC7Fxu7e217yGobjq6bfV0P
	emijh9qM9EAcxPTxpGHQmRLAx/c6wnXS3X+tD2KEei8YFqoAmTbfu/a3mA+E7tVMCSj7QGr2sJQ
	3INYEQgr3RBtYX/tjAlTEE1NnW3m4Tzqc+5kr2AVusQq30vpOvtaJkQlhuPjhITyOM7eQ8Sn8Yv
	m/k8TVd8hX6Q/rGElYogXyP+0C3AUj9YjGJanPiMpwHBRzIn6DNN/6u8n8m2UC61mw+686RCTlm
	4Cz4OH4eLlvTBC8XrDfDbvTM9MxhcNs0KF1dAM92f91VlvW6S5B/5m1oA36bfJN5RCAXfQm8V2Q
	R
X-Received: by 2002:a0c:b5ca:: with SMTP id o10mr13378650qvf.147.1552014964647;
        Thu, 07 Mar 2019 19:16:04 -0800 (PST)
X-Received: by 2002:a0c:b5ca:: with SMTP id o10mr13378629qvf.147.1552014964058;
        Thu, 07 Mar 2019 19:16:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552014964; cv=none;
        d=google.com; s=arc-20160816;
        b=u+ZCExYUEf4RlZXB2Rm6TyfloN1N5/VLOh6rRbq/2G/lbQvksbhcrnrUrXSu2uWzeU
         /jnzgv7JFPMoQMdxexfinfljOme0cw9Nb6Xb0b2Tr9DtH9elq4S36H2qXfi9aaFUqHJp
         e18fTXESJPecrZ7iWqFP6LBEz5ts64gWBjdTSk+cknN9rBKz+b7ypSOP7CaIldnNbIjT
         XABcWIYpwPzooJz8tXfpluDwhl+iJ0AL6eblP1QyFyskQZ1Lj3/kPd27ZwouPgxXmvPy
         ivwT7GHUQ2TTrKgO4ijL/mQC8V5GyhUAMpaAiJmN4GxBnqUXR4s1xNFBxzVfFXbRWlKz
         cdoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=+aYmiB1WgFEgCfJKnHZaWgzaN6cLqOY1VulRCFSIq7o=;
        b=PAotme8XtaNcosUfJWsyWzOHAULmFC9hk8Zp++RTmXsUOcrbYOn0rhNL8cHvgD599j
         LyCTdM+LYxvVM+tljd4PLkS77gF04zVuroLNBx/Ty6/ScMDtN1aHUAHgLFcEvWGbpYOr
         BvZUWxJT/0ZSyx5ORuhjJApogVFTTHFyIYryX7p0/n+CGYCtoJ8g8dw1FIsCvepUMDUP
         XgmYyPuKhkKX8Sj1w4Fr/MAP+6WRgCyIlenhpnPhB73pZ9yvuO799koBu8n6+4PqLwCt
         8HZB5jN7wq2iXQG+Oe46r1shFDPJNfAo2ae1cdbmKJbU2V1qE+LsKb1Y7XWHgAQUlc4E
         j6KA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c24sor8198290qtb.48.2019.03.07.19.16.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 19:16:04 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqw6sRfZNl5pFoX22KuCtq3MTNly4SABQV/PC1XDvyoNf7RBNjxftnQqGuu1O6fUQh9dwZEKMA==
X-Received: by 2002:ac8:3f3b:: with SMTP id c56mr12702567qtk.81.1552014963812;
        Thu, 07 Mar 2019 19:16:03 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id i141sm3482629qke.7.2019.03.07.19.16.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 19:16:02 -0800 (PST)
Date: Thu, 7 Mar 2019 22:16:00 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	aarcange@redhat.com
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190307221549-mutt-send-email-mst@kernel.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191720.GF3835@redhat.com>
 <20190307211506-mutt-send-email-mst@kernel.org>
 <20190308025539.GA5562@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190308025539.GA5562@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 09:55:39PM -0500, Jerome Glisse wrote:
> On Thu, Mar 07, 2019 at 09:21:03PM -0500, Michael S. Tsirkin wrote:
> > On Thu, Mar 07, 2019 at 02:17:20PM -0500, Jerome Glisse wrote:
> > > > It's because of all these issues that I preferred just accessing
> > > > userspace memory and handling faults. Unfortunately there does not
> > > > appear to exist an API that whitelists a specific driver along the lines
> > > > of "I checked this code for speculative info leaks, don't add barriers
> > > > on data path please".
> > > 
> > > Maybe it would be better to explore adding such helper then remapping
> > > page into kernel address space ?
> > 
> > I explored it a bit (see e.g. thread around: "__get_user slower than
> > get_user") and I can tell you it's not trivial given the issue is around
> > security.  So in practice it does not seem fair to keep a significant
> > optimization out of kernel because *maybe* we can do it differently even
> > better :)
> 
> Maybe a slightly different approach between this patchset and other
> copy user API would work here. What you want really is something like
> a temporary mlock on a range of memory so that it is safe for the
> kernel to access range of userspace virtual address ie page are
> present and with proper permission hence there can be no page fault
> while you are accessing thing from kernel context.
> 
> So you can have like a range structure and mmu notifier. When you
> lock the range you block mmu notifier to allow your code to work on
> the userspace VA safely. Once you are done you unlock and let the
> mmu notifier go on. It is pretty much exactly this patchset except
> that you remove all the kernel vmap code. A nice thing about that
> is that you do not need to worry about calling set page dirty it
> will already be handle by the userspace VA pte. It also use less
> memory than when you have kernel vmap.
> 
> This idea might be defeated by security feature where the kernel is
> running in its own address space without the userspace address
> space present.

Like smap?

> Anyway just wanted to put the idea forward.
> 
> Cheers,
> Jérôme

