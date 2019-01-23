Return-Path: <SRS0=euUm=P7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86C36C282C0
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 18:56:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 41B5F21855
	for <linux-mm@archiver.kernel.org>; Wed, 23 Jan 2019 18:56:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="IquwkO95"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 41B5F21855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D41418E003F; Wed, 23 Jan 2019 13:56:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC8CB8E001A; Wed, 23 Jan 2019 13:56:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B90778E003F; Wed, 23 Jan 2019 13:56:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 85D658E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 13:56:09 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id o132so1119522vsd.11
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 10:56:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=Ireb14swxzh/kGO0PaPMQde96Q1mT+0FNq7POlr1RtA=;
        b=jNqg7unnmExMUSLHVGUJt6A6J8OC1z0ByNM5OQgu4Q7em45sTT18YiM25xIQQghV1O
         1N3kbUfHqxrLTY4fvg6+gF2H8z4w/B8+qUkeRee8SK0HuNGLcFshaMU7RWfh2vugKdsU
         IcpnFJe+q8tehM42bVjdJ2RtETAgujqf9xYj1uR07c8gkWj+WXR09xqSBhG7x0TtLQoP
         XyUgpsZ0p3bSnpT4NJXn2Mm5gNvA+JEbcHfRtQg+RCa94XwLjwnMK+BBxdqXzDYTvbGG
         GApgugHaDRuURbemNSSn2WnSkyytO/jAvnNqQXet6YhcXhxWbl5FWx9mS+2WglvSZURv
         8oSQ==
X-Gm-Message-State: AJcUukeD6ToQWXBdPndWuSljgLi7Ow+wUS55phjoBEkhUV/GGUMOny+W
	xS9kuc/ODFYh7oYA9X91dVJeXTUGcfLZMQQsowHL6x+3Tt8eQgtUA5Dc9KipgpZSuDvQ2mQAeFU
	Xr52x7BOP66bHFfE7zua0EX7JN7oGNR6tmtpkW1DY44R53kWpL0aKp/VzUcB9BX1m1AovNo204k
	gEax7QC2XASdAxWidKOfHh/2OVgPsIQ9bqj9j6k0/t8ffQfc1C2SROYmeL+C3kVeGtIodrW7CTi
	NT2egzlRYSVEmwNHc4RzCtpN8bsgrnqEPDwb9B14m+GZEUjUi4gXhHVH6DT/iAqmmRmHtnj8DEY
	OyluerW9wlNGuK0Ypn69g/thvLHgQMfSgNfKFEGmujjHNjXD+Mw8rG3GWy1tBjjFEtzqahfYHMP
	w
X-Received: by 2002:a67:6d42:: with SMTP id i63mr1425610vsc.158.1548269769137;
        Wed, 23 Jan 2019 10:56:09 -0800 (PST)
X-Received: by 2002:a67:6d42:: with SMTP id i63mr1425593vsc.158.1548269768586;
        Wed, 23 Jan 2019 10:56:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548269768; cv=none;
        d=google.com; s=arc-20160816;
        b=wTWninUw69VLdhdHVFzFDDMfcF01+GHPkREdDyEkDwa5j9Nv1r+gbyFkQsP3ZxG7LS
         3uvIG4YwElmQg9+3a6x095BgBB1R/B4o4ki7le3cDZ3GHfgkw5sIAXJGKC9JWPJEut2s
         SHK96WBE3BWM/LpG6gCWmm0ABrEE/LCpAf4JKzXlFsvtYMxd8FLrDFxe+g6ZQPh0t3uK
         UNunuN/TbdIpXJ/Hz1u1TxepPU9ObcGLgEQQTGRjLZlR1o9gGkLWwj33Ct3lXJTZJw02
         TRerO/7ohmCpqLYAP1ezPOlof7EFH7FhK2pBfjcHK6sfXVqwm9RNlRrtPRomV/11Q1jC
         Aq/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Ireb14swxzh/kGO0PaPMQde96Q1mT+0FNq7POlr1RtA=;
        b=Vl19IzhZiocUDmsnQ8lTrDs8cy6p3P9GJrAtyWV6fdZnUOQCyI2M/clbKALLc+L+ZZ
         RlNpPjvgsPlUR3LvpzocUWWPycT9gF0sQEM86vNp4jSceM69+BQsELbUNIj9FHZtLIdx
         kDfzmWc4r2z/3jz1th6lsRFtHpWBUqBpKtzH/ci1FAVuPH7o0L1twzCPH5QHRYK3iBrG
         QOm29SYTxCR4B2XnnnjsaTWH/+BFlcOkiRG7n1xdxv2j3J0LIb4WQckwKEBNC/Do2nc7
         3mV6kdnJOKv0JaY/opj//8qggKgUDSeJa2ZVNdXen90ChjSyZQoUq14xpF0BZpH2xhs/
         EAHg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=IquwkO95;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z17sor10222570uao.49.2019.01.23.10.56.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 10:56:08 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=IquwkO95;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Ireb14swxzh/kGO0PaPMQde96Q1mT+0FNq7POlr1RtA=;
        b=IquwkO95q/UwwPMizwgMyjj4ev3XxDyhR/G3JHGEMCF3sSBM1iMANjExCpcvgLzlnG
         c0k6jUJJgFMV5g0qmbSVJ021AH6TGBxq+8XWJcUoxP8kLv+OEHJYUwpGc+sctoUZRDos
         hIzip/irtCZpPPkUNHJdcUGvO4CqxO0BooUhg=
X-Google-Smtp-Source: ALg8bN7gv0zW9ipqO2Kec6fVvXxe8ESBS1M27sr/EElJ3QGtXVI3OfFcCk/PeJ/IeCzHpbN7GDIHMQ==
X-Received: by 2002:ab0:25ca:: with SMTP id y10mr1299553uan.21.1548269768065;
        Wed, 23 Jan 2019 10:56:08 -0800 (PST)
Received: from mail-ua1-f41.google.com (mail-ua1-f41.google.com. [209.85.222.41])
        by smtp.gmail.com with ESMTPSA id l13sm98292054vka.16.2019.01.23.10.56.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 10:56:05 -0800 (PST)
Received: by mail-ua1-f41.google.com with SMTP id v24so1072089uap.13
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 10:56:05 -0800 (PST)
X-Received: by 2002:ab0:470d:: with SMTP id h13mr1375354uac.122.1548269764744;
 Wed, 23 Jan 2019 10:56:04 -0800 (PST)
MIME-Version: 1.0
References: <20190123110349.35882-1-keescook@chromium.org> <20190123110349.35882-2-keescook@chromium.org>
 <20190123115829.GA31385@kroah.com> <874l9z31c5.fsf@intel.com>
 <000001d4b32a$845e06e0$8d1a14a0$@211mainstreet.net> <87va2f1int.fsf@intel.com>
In-Reply-To: <87va2f1int.fsf@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 24 Jan 2019 07:55:51 +1300
X-Gmail-Original-Message-ID: <CAGXu5jJUxHtFq0rBJ9FwzMcZDWnusPUauC_=MaOz7H0_PF25jQ@mail.gmail.com>
Message-ID:
 <CAGXu5jJUxHtFq0rBJ9FwzMcZDWnusPUauC_=MaOz7H0_PF25jQ@mail.gmail.com>
Subject: Re: [Intel-gfx] [PATCH 1/3] treewide: Lift switch variables out of switches
To: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Edwin Zimmerman <edwin@211mainstreet.net>, Greg KH <gregkh@linuxfoundation.org>, 
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
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190123185551.lU8b9vN-tbxBaxmMtfNL4LxVmjvOwTtok3q5-Qylo_k@z>

On Thu, Jan 24, 2019 at 4:44 AM Jani Nikula <jani.nikula@linux.intel.com> w=
rote:
>
> On Wed, 23 Jan 2019, Edwin Zimmerman <edwin@211mainstreet.net> wrote:
> > On Wed, 23 Jan 2019, Jani Nikula <jani.nikula@linux.intel.com> wrote:
> >> On Wed, 23 Jan 2019, Greg KH <gregkh@linuxfoundation.org> wrote:
> >> > On Wed, Jan 23, 2019 at 03:03:47AM -0800, Kees Cook wrote:
> >> >> Variables declared in a switch statement before any case statements
> >> >> cannot be initialized, so move all instances out of the switches.
> >> >> After this, future always-initialized stack variables will work
> >> >> and not throw warnings like this:
> >> >>
> >> >> fs/fcntl.c: In function =E2=80=98send_sigio_to_task=E2=80=99:
> >> >> fs/fcntl.c:738:13: warning: statement will never be executed [-Wswi=
tch-unreachable]
> >> >>    siginfo_t si;
> >> >>              ^~
> >> >
> >> > That's a pain, so this means we can't have any new variables in { }
> >> > scope except for at the top of a function?

Just in case this wasn't clear: no, it's just the switch statement
before the first "case". I cannot imagine how bad it would be if we
couldn't have block-scoped variables! Heh. :)

> >> >
> >> > That's going to be a hard thing to keep from happening over time, as
> >> > this is valid C :(
> >>
> >> Not all valid C is meant to be used! ;)
> >
> > Very true.  The other thing to keep in mind is the burden of enforcing
> > a prohibition on a valid C construct like this.  It seems to me that
> > patch reviewers and maintainers have enough to do without forcing them
> > to watch for variable declarations in switch statements.  Automating
> > this prohibition, should it be accepted, seems like a good idea to me.
>
> Considering that the treewide diffstat to fix this is:
>
>  18 files changed, 45 insertions(+), 46 deletions(-)
>
> and using the gcc plugin in question will trigger the switch-unreachable
> warning, I think we're good. There'll probably be the occasional
> declarations that pass through, and will get fixed afterwards.

Yeah, that was my thinking as well: it's a rare use, and we get a
warning when it comes up.

Thanks!

--=20
Kees Cook

