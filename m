Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FD64C43612
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 21:54:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1765222C7
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 21:54:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="aLv2aXvu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1765222C7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C6D08E012E; Sat,  5 Jan 2019 16:54:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 574DE8E00F9; Sat,  5 Jan 2019 16:54:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4169C8E012E; Sat,  5 Jan 2019 16:54:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id C35048E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 16:54:25 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id x2so3799001lfg.16
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 13:54:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+1ou9Ablj7aPz54GczAfBZDoTjLzri1LRQMpX+g56pk=;
        b=D+P0PxYRtXHKLiGfsxCxmAK0WMMmidB+hTSSk1yKSnetWfHOuQ4QcHwadI8Sl+02mR
         hfdXzS+Li+uWQtr/m6HpiF6X1nlHvXtN/7BvqWU+mJdoTftjrbz9tEhroMLABUS+l8M4
         NQ7gmi4obxnpTG6L6q1MIx65tff9s3FNp9WfXZjW5DXyCxtxWKnoLQfSL+JprQCK5Be/
         LkunIKnBpjZhgIr3kC4TO9mmDMc8ELM4sHS4J09voRhY1qPbXZ+tG/Fyec0L3ELVeK2Z
         pKoxkqaStIooyLfVOi3rC4Y7s/jjx+Z0u5t/ZZBOoiFvaPkwjTAXA8HdEDHXxV7dQuqT
         1M9g==
X-Gm-Message-State: AJcUukfOEJ3IM72lkRqIFtfYf0kG+U/LvkSUKM3CFy1/pg4mZSUNVt1r
	SbkT0fd/iPuJmoJVM4xRdbbcdlBunUF0VhNXj/zXI6EXyQ6x7URZfTWobtcaMomgoVPFO41I+HK
	xmgxuUfMXNN4uQdmnNFS2JcfymZ/kXXIVY4XZz8R8OSa+mM0DrYweRZvOiyDpCFqRnW1BVWVft7
	cfXqnMEEcIlZJbvd/r/v4bRaunEA1vKPg576ixG64Tu7QikEQtOaJSUaMy8YilEtMNlrMvd/PfG
	0Kp/HVpVFau/txYdxr9HQkwe45hPSMfhq58XfyUc3B89pYbCJmh78hzwxXruYl1U9FRiGwNHt5o
	aAIl8JsDXXXzEB6BBFSkPfIABBwy09HeNmktFGpytUhQ9XWbzn1M2Httlwr0MF1JCP3tRYatONS
	m
X-Received: by 2002:a2e:5d12:: with SMTP id r18-v6mr35372252ljb.89.1546725264705;
        Sat, 05 Jan 2019 13:54:24 -0800 (PST)
X-Received: by 2002:a2e:5d12:: with SMTP id r18-v6mr35372239ljb.89.1546725263678;
        Sat, 05 Jan 2019 13:54:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546725263; cv=none;
        d=google.com; s=arc-20160816;
        b=Ly+Nc+C9yQTNl09YfV+g6x0gzWoMgS3sjeOssB1AeDyIp6P4Hb/t+Yh949iiO34grx
         V6xYsuTN0V/dvB+UJXYnGjYVuoeEj9B0W5X8URBz1PmDvu2m+mDrP9evGu+lXLVapZyX
         xrnvzDTAz1bqDsiKSfMYFfrvMnyvmIWtn+EJr5nK8u8bdeiLTDFj0+LLsRjN9/XLqqJY
         BsyFEHgPKrCo7tqapqdsuoiAHYTOKUhv/Ha55dk5463SVtuGw+roQWYdnHJEQ36bhkkC
         11Kut01DF97ux6Qt6ZRcqZedIxOUDR4gFY7ZMH/odyIaqSgxi4CRk+m3lWXddiEOZ+1t
         mlNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+1ou9Ablj7aPz54GczAfBZDoTjLzri1LRQMpX+g56pk=;
        b=yj3tSWx/biZFuywweoRqZQSWi8dTcUIHhgBkuuDVTd5bNC44M+sudCOW6tQ4/Zo9Le
         Y6WuV46n4apGo+tufesymUeG3JO4NkRTq7Fu70heb3u7kvC8Cv0CfjlvM8uf3GjKTmHK
         FQ+i60xvM3gn1NLn3xbc71rOdnMJztrKEgAwUxSO/+YcHl1SI4ot55Hlf+F9Oy2fmXpf
         UnVwFsy0AU4V5iYHl8LIoOMYrSMSaLCOXPeeh1l3vD/h0IIJisMBIaeR+cub0IrSk9j8
         v+WdKBRgta6kDWHywvHqPZyMvPxDYKBliZ6d+hWzp2imhILOYfLGADPehnupTqAP1AST
         Ny3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=aLv2aXvu;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g7-v6sor36327694ljk.19.2019.01.05.13.54.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 13:54:23 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=aLv2aXvu;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+1ou9Ablj7aPz54GczAfBZDoTjLzri1LRQMpX+g56pk=;
        b=aLv2aXvuQ2PcnOES4bn3an92ZWFwet2D8xWSCbWkNHh0ScTlLJjUThLCdtqbEwdzdq
         KwMAljejKSH453sW9kRjuoDOKAO+SJ9pEZzB2L0igqHXwWwGHe0+QdjWIuFF/3H43T1S
         OQj3p5p+5O3bs8MJLbC8JhX9XV5Puwstpxp0E=
X-Google-Smtp-Source: AFSGD/XMNmFPvUxcCOdulWh3n9Oz/AirA6IMN8Xhw/u0Jm7+jUGM8qI4F43XU8k+u1EMztT182mo+A==
X-Received: by 2002:a2e:458b:: with SMTP id s133-v6mr30652625lja.170.1546725262215;
        Sat, 05 Jan 2019 13:54:22 -0800 (PST)
Received: from mail-lj1-f176.google.com (mail-lj1-f176.google.com. [209.85.208.176])
        by smtp.gmail.com with ESMTPSA id q6sm11702689lfh.52.2019.01.05.13.54.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 13:54:20 -0800 (PST)
Received: by mail-lj1-f176.google.com with SMTP id v15-v6so35178110ljh.13
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 13:54:20 -0800 (PST)
X-Received: by 2002:a2e:9c7:: with SMTP id 190-v6mr24066633ljj.120.1546725259853;
 Sat, 05 Jan 2019 13:54:19 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAHk-=wicks2BEwm1BhdvEj_P3yawmvQuG3NOnjhdrUDEtTGizw@mail.gmail.com>
 <nycvar.YFH.7.76.1901052108390.16954@cbobk.fhfr.pm> <CAHk-=whGmE4QVr6NbgHnrVGVENfM3s1y6GNbsfh8PcOg=6bpqw@mail.gmail.com>
 <nycvar.YFH.7.76.1901052131480.16954@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1901052131480.16954@cbobk.fhfr.pm>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 13:54:03 -0800
X-Gmail-Original-Message-ID: <CAHk-=wgrSKyN23yp-npq6+J-4pGqbzxb3mJ183PryjHw7PWDyA@mail.gmail.com>
Message-ID:
 <CAHk-=wgrSKyN23yp-npq6+J-4pGqbzxb3mJ183PryjHw7PWDyA@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Jiri Kosina <jikos@kernel.org>, Masatake YAMATO <yamato@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105215403.mUw4qYhNovfebhjEdYRHswNDpHWK4t3-NyX-FxT8C7E@z>

On Sat, Jan 5, 2019 at 12:43 PM Jiri Kosina <jikos@kernel.org> wrote:
>
> > Who actually _uses_ mincore()? That's probably the best guide to what
> > we should do. Maybe they open the file read-only even if they are the
> > owner, and we really should look at file ownership instead.
>
> Yeah, well
>
>         https://codesearch.debian.net/search?q=mincore
>
> is a bit too much mess to get some idea quickly I am afraid.

Yeah, heh.

And the first hit is 'fincore', which probably nobody cares about
anyway, but it does

    fd = open (name, O_RDONLY)
    ..
    mmap(window, len, PROT_NONE, MAP_PRIVATE, ..

so if we want to keep that working, we'd really need to actually check
file ownership rather than just looking at f_mode.

But I don't know if anybody *uses* and cares about fincore, and it's
particularly questionable for non-root users.

And the Android go runtime code seems to oddly use mincore to figure
out page size:

  // try using mincore to detect the physical page size.
  // mincore should return EINVAL when address is not a multiple of
system page size.

which is all kinds of odd, but whatever.. Why mincore, rather than
something sane and obvious like mmap? Don't ask me...

Anyway, the Debian code search just results in mostly non-present
stuff. It's sad that google code search is no more. It was great for
exactly these kinds of questions.

The mono runtime seems to have some mono_pages_not_faulted() function,
but I don't know if people use it for file mappings, and I couldn't
find any interesting users of it.

I didn't find anything that seems to really care, but I gave up after
a few pages of really boring stuff.

                    Linus

