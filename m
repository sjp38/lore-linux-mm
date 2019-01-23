Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51357C282C0
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:41:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D7C62184C
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 20:41:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="L8GygvYw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D7C62184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A800B8E004C; Wed, 23 Jan 2019 15:41:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0A058E0047; Wed, 23 Jan 2019 15:41:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8AACA8E004C; Wed, 23 Jan 2019 15:41:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f71.google.com (mail-vs1-f71.google.com [209.85.217.71])
	by kanga.kvack.org (Postfix) with ESMTP id 576E18E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:41:32 -0500 (EST)
Received: by mail-vs1-f71.google.com with SMTP id v199so1243497vsc.21
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:41:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rFCkOF2gK3wr1UB995eD+/CTWS4iazBBfFIZUEffwxc=;
        b=QZlH8OFXf/1pnXOws27R1sB3tZScrxaaBEJB3WJSYFjb13Ok5m3HkehJU28+i4RLSc
         4CIWro1uC/c2RC8NemKU1lop9/QVgpC9h3wVEOIw+koOJ6El4GFONH18WSh8byQmX6t4
         O8HeWWTY7cfRG91iyNatssf569l6KO5Gq09gyzUz/ErxX+3BdnWcyJCLcvbKXBMXzeTu
         ded2uA0GblXSsPIFU9wG7O3O8W8INkZnQucv3KFm1ALwCUEq73w2q+Fjew/EAYt8nWiL
         JVzgkKg4iAuWYF1EbbRRPdhDTnP+gKXNLcc6x1V3hT17N0MpnHmoexMHZ2c0zcqpzeKf
         SXSg==
X-Gm-Message-State: AJcUukd4PDAq8qBTk8WiCDwe600YHc/YanOcq5WZKKD2jRVT4oCCxyb+
	zLZVWVwsEWSZu+DlRZ7fBpUMngPnBBaOX5b4EVZPwozOd+Y04MJwNIGvj8ihxy/2dFP2TCl7ft9
	yrwP3M/cbox5OF6VDJst0jrDNfwkIRNoqR8YyjQNhwmMWuUNdUIVhjZDZU6iUGmkG53FiqefCAK
	tBkEYIi+BYzEDp3DeMKzuG3Js4EBcII7fspd02oKf2R1Lzs5Pd49t8mjfrLd/DWlSn6O2ePYEZB
	17E/JwaiA/YLrVHPspkhA8k6o7xmF5zVL72qZO6q0EL9eSQGowSJ/XAhKTU8QbLxvxmpr83+iVg
	QVlx9j/1+I55G/kExmeGkTyXAcYGBIuV4gGZAiZED46IPuMxE8QFSWgTNQRJsSCoCEL8jFya5hy
	X
X-Received: by 2002:a67:9853:: with SMTP id a80mr1603165vse.157.1548276092006;
        Wed, 23 Jan 2019 12:41:32 -0800 (PST)
X-Received: by 2002:a67:9853:: with SMTP id a80mr1603154vse.157.1548276091466;
        Wed, 23 Jan 2019 12:41:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548276091; cv=none;
        d=google.com; s=arc-20160816;
        b=e4ksRqrDRTGFQIKCJKJn0ma2kpfGPBAFJAFbtpmDwMvxWsEW6WInjfMZdmA9jGG4F9
         1TpDT4C+RX6CyAXVNVOIFzG4zFAMAsFGfBz2mGicZ6sO9pYBfpNvW5r3C/UJGtirXhVP
         T00AezCn4dgvZiSM1v/lcOvtyTVOLEJgATap/eppR5Hua2qWaxgWc7nckft7AjA3Gy1O
         d5xmfw/emu5QNyQ6zhvQwY57Tw5Z634P8aCfQUgoJL1T0a3/yTTHjYcNRxqcqglFtiOq
         K0rF8zB+kKlZ3jPIJ385dHPGLZ8UyToplV6O8vlYZ2o/dKdu9q4GIgeVa42heQe7nWNp
         39jw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rFCkOF2gK3wr1UB995eD+/CTWS4iazBBfFIZUEffwxc=;
        b=ugbPHga741VbR74hvbzsfDy8/ccx7XfxWdMY4/dvALIYE0vn8TU9+Dy7DZUl0J/ny4
         8qL4eN6I2NEhcq/ZoyyQF6EEIvX73C4psvpvD2wUIfV3dd3r9DCQCfQQt+91hTmcIHf0
         WqABQVAI8hPF2KyHs5eE6kJXjG9QL2H1/beU9lkray5n822H6FybRYf3Htwyn71bLD+E
         am3UIqi9KEDpZcClZK4Krp30lEzfWOh2iYnIq1G6qJ8vm3xO6O3DjDuca9bpwT4BGe1Z
         Yt+1X0kita4Tu7nskMFkoXLWYIKf1ke6xl++N8recy013Oi6AhPUxjhVJ4tvma0L39fm
         XsPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=L8GygvYw;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e72sor12499863vsg.124.2019.01.23.12.41.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 12:41:31 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=L8GygvYw;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rFCkOF2gK3wr1UB995eD+/CTWS4iazBBfFIZUEffwxc=;
        b=L8GygvYwk5FYD+Ce0ML1TRQbDfEIv0oR+ZZMDgwVJntrdffAzAT1EMjtnCS4Vm7kGF
         9dyJBTPuJm07cjZsS/xzizI42KQnMArMr2N3CLtPSslUeR/3lApJBdvCmKdyWI0HKF0C
         Vq7eIyo8gjyd5kPrv1YhbaPvpYIMVU0STBBf4=
X-Google-Smtp-Source: ALg8bN7CcN2sWFUCs1B+aYPKqs26J7TyMV9UDEellXvjb/7UGo7WsQmaBAlTz11UDDecXV9eFha5Fg==
X-Received: by 2002:a67:4541:: with SMTP id s62mr1601013vsa.25.1548276090699;
        Wed, 23 Jan 2019 12:41:30 -0800 (PST)
Received: from mail-vs1-f47.google.com (mail-vs1-f47.google.com. [209.85.217.47])
        by smtp.gmail.com with ESMTPSA id j95sm27481484uad.6.2019.01.23.12.41.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 12:41:30 -0800 (PST)
Received: by mail-vs1-f47.google.com with SMTP id n13so2173486vsk.4
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:41:30 -0800 (PST)
X-Received: by 2002:a67:e199:: with SMTP id e25mr1560245vsl.188.1548275782895;
 Wed, 23 Jan 2019 12:36:22 -0800 (PST)
MIME-Version: 1.0
References: <20190123110349.35882-1-keescook@chromium.org> <20190123110349.35882-2-keescook@chromium.org>
 <20190123115829.GA31385@kroah.com> <874l9z31c5.fsf@intel.com> <20190123191802.GB15311@bombadil.infradead.org>
In-Reply-To: <20190123191802.GB15311@bombadil.infradead.org>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 24 Jan 2019 09:36:11 +1300
X-Gmail-Original-Message-ID: <CAGXu5jLNvHVhbyr5Cbyoe8o0ARv52sU-NEpD+u2UYfESM3ofCw@mail.gmail.com>
Message-ID:
 <CAGXu5jLNvHVhbyr5Cbyoe8o0ARv52sU-NEpD+u2UYfESM3ofCw@mail.gmail.com>
Subject: Re: [Intel-gfx] [PATCH 1/3] treewide: Lift switch variables out of switches
To: Matthew Wilcox <willy@infradead.org>
Cc: Jani Nikula <jani.nikula@linux.intel.com>, Greg KH <gregkh@linuxfoundation.org>, 
	dev@openvswitch.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Network Development <netdev@vger.kernel.org>, intel-gfx@lists.freedesktop.org, 
	linux-usb@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Linux-MM <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, intel-wired-lan@lists.osuosl.org, 
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, xen-devel <xen-devel@lists.xenproject.org>, 
	Laura Abbott <labbott@redhat.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, 
	Alexander Popov <alex.popov@linux.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123203611.Q8wVggoIzwXWSbVBCtGutCs-iiIlcQtGvTB1wt4q5jk@z>

On Thu, Jan 24, 2019 at 8:18 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Wed, Jan 23, 2019 at 04:17:30PM +0200, Jani Nikula wrote:
> > Can't have:
> >
> >       switch (i) {
> >               int j;
> >       case 0:
> >               /* ... */
> >       }
> >
> > because it can't be turned into:
> >
> >       switch (i) {
> >               int j = 0; /* not valid C */
> >       case 0:
> >               /* ... */
> >       }
> >
> > but can have e.g.:
> >
> >       switch (i) {
> >       case 0:
> >               {
> >                       int j = 0;
> >                       /* ... */
> >               }
> >       }
> >
> > I think Kees' approach of moving such variable declarations to the
> > enclosing block scope is better than adding another nesting block.
>
> Another nesting level would be bad, but I think this is OK:
>
>         switch (i) {
>         case 0: {
>                 int j = 0;
>                 /* ... */
>         }
>         case 1: {
>                 void *p = q;
>                 /* ... */
>         }
>         }
>
> I can imagine Kees' patch might have a bad effect on stack consumption,
> unless GCC can be relied on to be smart enough to notice the
> non-overlapping liveness of the vriables and use the same stack slots
> for both.

GCC is reasonable at this. The main issue, though, was most of these
places were using the variables in multiple case statements, so they
couldn't be limited to a single block (or they'd need to be manually
repeated in each block, which is even more ugly, IMO).

Whatever the consensus, I'm happy to tweak the patch.

Thanks!

-- 
Kees Cook

