Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A73F0C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:37:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 707D7218A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:37:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 707D7218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 140BA8E010F; Mon, 11 Feb 2019 12:37:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 117F58E0108; Mon, 11 Feb 2019 12:37:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02F4D8E010F; Mon, 11 Feb 2019 12:36:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id CB5548E0108
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:36:59 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id s65so12850168qke.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:36:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=xsVA54csTuR8kUgnep2f50/Cfe6srgvDXnj+9MFvwNQ=;
        b=JPOQ5WFq3nG/AHNqUwwrQKBCNPpZIwFaVsyyncCDd0g4F5MMdkH48dmOGC/mo1nwg3
         GI022mZScTr49xqujq708kZVXeSXoZa1IM8DmNYgTvDuTQglS0Qdw+baqCm2pxymrbmb
         U0h+SlXvUX8LI0GeTvzi9utVMGNInSesLy4WPmo8SLXOj9+wr7u2ZRJvovMKYCPXQc+b
         DYp3BYNC+xb5Kn1qrfLH3zhGKaQYFGIlUsmYycl+QuyMXp6RcbQj/IKUDLkfkhcJ1q1F
         9i6Qewtt6xmQCgFuIfSG60qQHJilKEQHl3UD2/dPWF58FKor8t6O8IaFHxW0GsVMFT7c
         rNvQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZC55PLeDe9twjGwsosVtD/5vsbsQpqFPoAFbuWF3EJsTTL8U33
	vpgs9tQRr5faDWakffmhUS5nOO4zk1TFlYncAaxU5W+sI4XpnhrNJVqR+HabsoboeBLhYpLRzi1
	IAvCtdP8M5iPX47JfNuPD2nLWt00r/g3QIFKo0Bd5oNo+BXm7KoSqVSHcJPFcgIpCOQ==
X-Received: by 2002:ac8:191b:: with SMTP id t27mr15969978qtj.163.1549906619625;
        Mon, 11 Feb 2019 09:36:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYl5Yj5yEFWV4zKcr7mosoYJPwvP5nr7127OQlERWx1sYJodQT+Si4zg7FaD8D1x430IndY
X-Received: by 2002:ac8:191b:: with SMTP id t27mr15969951qtj.163.1549906619200;
        Mon, 11 Feb 2019 09:36:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549906619; cv=none;
        d=google.com; s=arc-20160816;
        b=Yh9e+T0JuRnr0ijSYA5JSF4TlBkU5b6py8jHEPvIQtGM5uC0w8/dJb0U/w4NnRhXd/
         xjI36kff3nqVlvO/A3ErNPm28TocdWQYpnbZuKBL8EAucvmr1xM1DVjBeKylT/h0ztUG
         8AcDNLgWij3QWAuhx57YDmdwbJ8CKrWPml05LuyOn1gS2ygYyEOU/GODjqYm9N7azxs8
         V3cP/9HJ5vI6+zDQ7GQ+ZiP87hhqrW24ihnNp9Fxc5paruuC81L7YqTRuH2N6YZggabH
         owyHTSNTHxra7l8xfWKE7Zz9vOdleIOfSaPbsq3AD6FKyUBsfn4osVs82N1xgnpBZcwx
         qodw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=xsVA54csTuR8kUgnep2f50/Cfe6srgvDXnj+9MFvwNQ=;
        b=IDzzxi41YEKy5qt9uSfad6LGGcJOUyiRZLoVcchBkU2On5J94yZWrAn4L/7nCyA/D2
         8Z/5Hf08iiN77Uu/mFOKm5FG8G16E+/vyPmgGmsV4h0w8qk9IioLbE6i5nVTPbHPXGkj
         EyHdZi7SPAN0T6LlOcASkwQornGme3194Ijex0u1cztmNIIMocxYN/6bh3i0Fs34Imsh
         vx6i0j9YsV9bJV7jXkTfzGfL11g0/1FxUHWtL+2z7jZmRrxipcuStHxQsFcIJur4ndsU
         CED0LReCA9j0VAA8ry9aXl05TNOQkL2/RdxTG486vayF3ZujTu6hYKkYv5O/YF5O/cBC
         dhnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b51si3181576qtb.279.2019.02.11.09.36.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 09:36:59 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2159DB650;
	Mon, 11 Feb 2019 17:36:58 +0000 (UTC)
Received: from redhat.com (ovpn-120-40.rdu2.redhat.com [10.10.120.40])
	by smtp.corp.redhat.com (Postfix) with SMTP id 163AE1850E;
	Mon, 11 Feb 2019 17:36:55 +0000 (UTC)
Date: Mon, 11 Feb 2019 12:36:55 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	rkrcmar@redhat.com, x86@kernel.org, mingo@redhat.com, bp@alien8.de,
	hpa@zytor.com, pbonzini@redhat.com, tglx@linutronix.de,
	akpm@linux-foundation.org
Subject: Re: [RFC PATCH 2/4] kvm: Add host side support for free memory hints
Message-ID: <20190211123638-mutt-send-email-mst@kernel.org>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
 <20190204181546.12095.81356.stgit@localhost.localdomain>
 <20190209194108-mutt-send-email-mst@kernel.org>
 <96285ed154dbb92686ca0068e21f5e0500bb1ce7.camel@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <96285ed154dbb92686ca0068e21f5e0500bb1ce7.camel@linux.intel.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Mon, 11 Feb 2019 17:36:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 09:34:25AM -0800, Alexander Duyck wrote:
> On Sat, 2019-02-09 at 19:44 -0500, Michael S. Tsirkin wrote:
> > On Mon, Feb 04, 2019 at 10:15:46AM -0800, Alexander Duyck wrote:
> > > From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> > > 
> > > Add the host side of the KVM memory hinting support. With this we expose a
> > > feature bit indicating that the host will pass the messages along to the
> > > new madvise function.
> > > 
> > > This functionality is mutually exclusive with device assignment. If a
> > > device is assigned we will disable the functionality as it could lead to a
> > > potential memory corruption if a device writes to a page after KVM has
> > > flagged it as not being used.
> > 
> > I really dislike this kind of tie-in.
> > 
> > Yes right now assignment is not smart enough but generally
> > you can protect the unused page in the IOMMU and that's it,
> > it's safe.
> > 
> > So the policy should not leak into host/guest interface.
> > Instead it is better to just keep the pages pinned and
> > ignore the hint for now.
> 
> Okay, I can do that. It also gives me a means of benchmarking just the
> hypercall cost versus the extra page faults and zeroing.

Good point. Same goes for poisoning :)

