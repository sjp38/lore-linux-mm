Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7231BC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:43:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2934A20675
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:43:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2934A20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD16E8E0003; Thu,  7 Mar 2019 22:43:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7EF38E0002; Thu,  7 Mar 2019 22:43:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 96F9B8E0003; Thu,  7 Mar 2019 22:43:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5068E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 22:43:16 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id z13so159563qkf.14
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 19:43:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=uekFqOVn98HGG4QuA6mGLQdwAoZwwLaY7YB1llaFMbo=;
        b=VgEyXlgTZRpW13xPlqBDcJn8R6nD4HB78HAw8oJRz7OxYnUOMxT7e7W92LXyi0g7Ep
         NsX+kEun0DLSo/dilf4+FSpqVYBA8VNjXQRmiYb0+KqRin0dfi3EPh33Lnn2hEgq8nE/
         bEcT3uTYVRGZajHbKpO6IILpuTDFjXOQ6HQFgIOLXjZT4srZpdTJn0sHu8N5UsCudDPM
         EYxlSDmerq4kDpyWKktCZDyHoH3HKR88L9/ZMMnIS8LkRGI9hBzKbL6S8U5Rtcy7VEl8
         mk/52lUCYZrpldQw5N/fMHqbPJZc4qyZGl415NbgvUgJeY1J7606qJElDw6AKYc6KLgg
         mxmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUn4HhHn0f4jKCieZpMFvwYmVkeORt2ltwKz3yjQHHZPfK1PhuK
	0N9LOkLVvmhzn9A47lcYbABw0PHhLm7x+VNv0eLvYkvK5JmIjzyLAIu/DqoADyXwm676ge1qlfW
	gS39DLYAwKBtUTICS8ZwaPmotx3Y3MLt9DeNzDLx3drp7ozqA9DQxtsjbFw05nss4tskNnJL4D9
	mr75T+XewrV3tSpIxhH6TBRRP0Z7jO0Ud5B2wRHMCfYZ6z5krh0WtBMrjjFnSnDF5rL+/+Z52zE
	2DgcxflFuTg42XoaRAafH8k5w8aJAl/mzfMmtbxPX5ggRjUvRGuWbZzodzBso49wYjM6HjOH5dX
	GQ/LNMdfbdcL+RgoQTH1Oz384Zixi7WoUdfFNpyzmbPTNqM9v2VPWtq5lG7aT5cDIxjwNLRDvGr
	j
X-Received: by 2002:a37:4701:: with SMTP id u1mr12210752qka.357.1552016596173;
        Thu, 07 Mar 2019 19:43:16 -0800 (PST)
X-Received: by 2002:a37:4701:: with SMTP id u1mr12210726qka.357.1552016595495;
        Thu, 07 Mar 2019 19:43:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552016595; cv=none;
        d=google.com; s=arc-20160816;
        b=wo++kHB/eV0EGtb+V5pzQLZ96+weH11b1QFRKuk7NXbZnf+cK+P9cKSVuv1GXkJXAK
         HF/nVCRkKX0rAN0mLaWzSgElI7hkJp3H91IcPciBkQuodSyd6B5Rb697uQ6vFK2IYxAN
         ymzE8TQLQdfbR1fhj0uledQoJB2jNvPrrrv81H/vpOEiYcRmWYHDjkVRRIJKIxUbQeFn
         yzWtRG5mlFPQ/XZwbhbiRFlQ07nUZeNZaRy3ZZzrGhilhMTCF7kSQYpX2usAzEjN67Dx
         FYZFAaEce6920YHz0DlLhF7zZwbN3jEOiQJqcQ+l8lg+prSBERr9DKtW/kV7gldg9Ahr
         YxzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=uekFqOVn98HGG4QuA6mGLQdwAoZwwLaY7YB1llaFMbo=;
        b=cHut1gvXnLwCVHK025zsWQuikofgOVzdLO/FXupLnQB5+zpiCuUoKTakNeJ6tCuUAH
         fVKXv5SupORWdRKKwF07zYl6X98fTr+D4eyBTjsDS9OIv2SERADD4rL5wGLqft/aEydq
         tf5SRCQuYqdYfCLMaaoDi104meoIrxT4JZ6CFIt2vF0LS5SAmxYbotjvO+4WD4mJMjkh
         laLWvDYqT4OfgEsR+HpAnosI/PRY8kVKBBpPjWvSEeYLH0buLJ7aoH4Yw7eufYKJe7/A
         dcsp9DxgjQ+h2JKcvctSf1BTG/6hZZ1QaKj471yIUFxTanZsGWV4NHE5YU6EkLlssMQz
         Fg5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i67sor4050874qkc.7.2019.03.07.19.43.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 19:43:15 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxwiO037BlKr1Hx0fgpjyhdP/Z//1503mLf6eF76BmFvCFeRbxKmNyncYFT2IfZGY6+Y3h8Uw==
X-Received: by 2002:a05:620a:13ad:: with SMTP id m13mr12607514qki.59.1552016595261;
        Thu, 07 Mar 2019 19:43:15 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id c2sm4825237qtc.41.2019.03.07.19.43.13
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 19:43:14 -0800 (PST)
Date: Thu, 7 Mar 2019 22:43:12 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	aarcange@redhat.com
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190307224143-mutt-send-email-mst@kernel.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191720.GF3835@redhat.com>
 <20190307211506-mutt-send-email-mst@kernel.org>
 <20190308025539.GA5562@redhat.com>
 <20190307221549-mutt-send-email-mst@kernel.org>
 <20190308034053.GB5562@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190308034053.GB5562@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 10:40:53PM -0500, Jerome Glisse wrote:
> On Thu, Mar 07, 2019 at 10:16:00PM -0500, Michael S. Tsirkin wrote:
> > On Thu, Mar 07, 2019 at 09:55:39PM -0500, Jerome Glisse wrote:
> > > On Thu, Mar 07, 2019 at 09:21:03PM -0500, Michael S. Tsirkin wrote:
> > > > On Thu, Mar 07, 2019 at 02:17:20PM -0500, Jerome Glisse wrote:
> > > > > > It's because of all these issues that I preferred just accessing
> > > > > > userspace memory and handling faults. Unfortunately there does not
> > > > > > appear to exist an API that whitelists a specific driver along the lines
> > > > > > of "I checked this code for speculative info leaks, don't add barriers
> > > > > > on data path please".
> > > > > 
> > > > > Maybe it would be better to explore adding such helper then remapping
> > > > > page into kernel address space ?
> > > > 
> > > > I explored it a bit (see e.g. thread around: "__get_user slower than
> > > > get_user") and I can tell you it's not trivial given the issue is around
> > > > security.  So in practice it does not seem fair to keep a significant
> > > > optimization out of kernel because *maybe* we can do it differently even
> > > > better :)
> > > 
> > > Maybe a slightly different approach between this patchset and other
> > > copy user API would work here. What you want really is something like
> > > a temporary mlock on a range of memory so that it is safe for the
> > > kernel to access range of userspace virtual address ie page are
> > > present and with proper permission hence there can be no page fault
> > > while you are accessing thing from kernel context.
> > > 
> > > So you can have like a range structure and mmu notifier. When you
> > > lock the range you block mmu notifier to allow your code to work on
> > > the userspace VA safely. Once you are done you unlock and let the
> > > mmu notifier go on. It is pretty much exactly this patchset except
> > > that you remove all the kernel vmap code. A nice thing about that
> > > is that you do not need to worry about calling set page dirty it
> > > will already be handle by the userspace VA pte. It also use less
> > > memory than when you have kernel vmap.
> > > 
> > > This idea might be defeated by security feature where the kernel is
> > > running in its own address space without the userspace address
> > > space present.
> > 
> > Like smap?
> 
> Yes like smap but also other newer changes, with similar effect, since
> the spectre drama.
> 
> Cheers,
> Jérôme

Sorry do you mean meltdown and kpti?

-- 
MST

