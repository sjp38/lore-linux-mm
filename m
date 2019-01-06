Return-Path: <SRS0=q3d4=PO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC3CEC43612
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 00:23:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93233222BF
	for <linux-mm@archiver.kernel.org>; Sun,  6 Jan 2019 00:23:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="DrY0B8uo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93233222BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 314DC8E0138; Sat,  5 Jan 2019 19:23:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29C578E00F9; Sat,  5 Jan 2019 19:23:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 166EC8E0138; Sat,  5 Jan 2019 19:23:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 98FAF8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 19:23:07 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id t22-v6so10826700lji.14
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 16:23:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=kXpC9nTs/Gy04v0woM2MVm7mCFE7zuhC308r47ayVvI=;
        b=OLZUR0ZPac2XFdJjCLEujkWScH/O9IGyZcwUStx1RT5eruPPo+IS3snBvhi5O+t8XB
         2tRb9B2SpYm0D9fiKshRNZZC5o8yWFMN8tGmjueIFuodJYKPuE1NDqLgKBBIDi3cHuUy
         wU98gB2UGXDKplUOSWVqeMnRmdUhgj2P7HqTnDsHKJjjdhnjGuQ7s5Zipsl2nE+Q2WCx
         UFrXq0Jat68FEKiNE16a3l7nPJFEditAanaQZ1EOWIguCs0jEXDxtuObF2k1uwVUw4Bo
         5P6AZG771o/wZjThuBTNGavLYCWZ/CPw/EzOGUJb+pq10+aMgvkGeUfje/LzHKw1obIq
         Tm+Q==
X-Gm-Message-State: AA+aEWaX8uX9I6z/uAaOVUxKlHRt+6YiCN26UnI5YrLGzeWh9W1E7s57
	vYD3Kss//oq+Rer2WSSt4ucDROCtwDsnnCt82W+nZfoGgtjgwn/wFnoXzKApCK6iDf10VXLNH9l
	nGIC7SRYnncxplESWK0dPI/PrGck5hKFQIYItmn2kXbxb4+50eAVrGa6XT69Ur5PhXLa6YFihSb
	Uv+0p/ZkdlhimW0HmQhB/B/4RIuqN2OHJOn+nbSDGhCwA+My91cTNnrKQf6iLDSM2hfBahzc6Hs
	SQ1mzGE9DAXpzGiKp7l1KpKE2iV4wvrzhisGR1ZprStTampTB2UttOt1k8ZBK08MzNARQ166EHa
	8pnw431+Vt6O7LQda+9OpFDI5Nql8VI8HOWkHlBqQo9mlV5T1hxX4kMsKXbtCPty+d6qml355rS
	a
X-Received: by 2002:a19:910d:: with SMTP id t13mr26379964lfd.98.1546734186703;
        Sat, 05 Jan 2019 16:23:06 -0800 (PST)
X-Received: by 2002:a19:910d:: with SMTP id t13mr26379953lfd.98.1546734185745;
        Sat, 05 Jan 2019 16:23:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546734185; cv=none;
        d=google.com; s=arc-20160816;
        b=bN1/VMNJGbLNgVbm/vGIwcpWGzIzrCkLYHUleBoUnDUjikV2OZKl07Cfq8J5LoHi0f
         JAwDzJXXPmXlWQhBoqm+I1KTN9AYs2OzFdT/+H9wbIKLsN2+oIj8rQJqEi3oiS/o5CGg
         nrelLSnVihBM5P5G7si9U7zuRo4Qbv15znFw/0Fm0g1F+GnbBNju2IIHLHmAdJMlaXAd
         dODNCh4BcWt4ptyF/kLyzpJhF8HBDV16VBThV1fXQ9iFJP/moWVJNf25ZlfOSVyKttU+
         uqdn45/SM6Tiyj5cHlscybtGAbBVtkU7bl9N+j6oPGOFcQjMmysoNp6YUqvkXS+REbkW
         d9OQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=kXpC9nTs/Gy04v0woM2MVm7mCFE7zuhC308r47ayVvI=;
        b=FFIPKGwc/b0Au83xQaQSyLu2i2bATcZY9hgCHAztypPoR2Da7+roGkIeQ66l0o9ia7
         8DytkSKlEEpNImA0NEOzS5yNRnLV//rByYJuBg3pQEEdXDCwIoambFFMIT0N+OlRIj+n
         xjpUhNMdOU5KwOGlS5Q9KA8LbcTBs7Tdxtws3CUHNYGkE9/EfSqqFoz3VFkANCp8YX6z
         xIsXtkEvhNJSlD+18H8XmE9NtZn2nq/uezdWlwjM1d77HztYhkSZeW2gyvnZHck7DqK3
         VEMu9D5RvQJxTsr9GgiTj7oxkmKq/p4oSwDoMk0rDhYuR8DHtHcO8Ljphv9unR822Ztv
         xyuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=DrY0B8uo;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5-v6sor36579053lje.28.2019.01.05.16.23.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 05 Jan 2019 16:23:05 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=DrY0B8uo;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=kXpC9nTs/Gy04v0woM2MVm7mCFE7zuhC308r47ayVvI=;
        b=DrY0B8uoWPWa1RjKPnPb3r8ev+OuXLf3EnrQrWZahMYQCyQbAKLWGLn2KWWDqAEXra
         knZblOic5+lDI51aAoKR9myovivvtxrJVgamF860KwgWqLw4GasvfJyeM9V71Gqe0r5g
         PdmK2cJlGtOC5rpioE4BYhOVX6KAsN+xb79gw=
X-Google-Smtp-Source: ALg8bN5P96AT7ac5S2mAeB9fUsdUtG1aDbMnab4neMsaf6B8L2jGCzCb+CJXWoib5mNopmd/jf9DkQ==
X-Received: by 2002:a2e:9715:: with SMTP id r21-v6mr31464626lji.30.1546734184790;
        Sat, 05 Jan 2019 16:23:04 -0800 (PST)
Received: from mail-lf1-f44.google.com (mail-lf1-f44.google.com. [209.85.167.44])
        by smtp.gmail.com with ESMTPSA id r203sm7769221lff.13.2019.01.05.16.23.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 16:23:03 -0800 (PST)
Received: by mail-lf1-f44.google.com with SMTP id y11so27781068lfj.4
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 16:23:03 -0800 (PST)
X-Received: by 2002:a19:cbcc:: with SMTP id b195mr29443371lfg.117.1546734182916;
 Sat, 05 Jan 2019 16:23:02 -0800 (PST)
MIME-Version: 1.0
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
 <CAHk-=whL4sZiM=JcdQAYQvHm7h7xEtVUh+gYGYhoSk4vi38tXg@mail.gmail.com>
 <CAHk-=wg5Kk+r36=jcGBaLUj+gjopjgiW5eyvkdMqvn0jFkD_iQ@mail.gmail.com>
 <CAHk-=wiMQeCEKESWTmm15x79NjEjNwFvjZ=9XenxY7yH8zqa7A@mail.gmail.com> <20190106001138.GW6310@bombadil.infradead.org>
In-Reply-To: <20190106001138.GW6310@bombadil.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 5 Jan 2019 16:22:47 -0800
X-Gmail-Original-Message-ID: <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
Message-ID:
 <CAHk-=wiT=ov+6zYcnw_64ihYf74Amzqs67iVGtJMQq65PxiVYw@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Matthew Wilcox <willy@infradead.org>
Cc: Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190106002247.bAs7kEk8QOqp_m8x7CG3Av1ve4jMzyw1ILegHFDXHpg@z>

On Sat, Jan 5, 2019 at 4:11 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> FreeBSD claims to have a manpage from SunOS 4.1.3 with mincore (!)
>
> https://www.freebsd.org/cgi/man.cgi?query=mincore&apropos=0&sektion=0&manpath=SunOS+4.1.3&arch=default&format=html
>
> DESCRIPTION
>        mincore()  returns  the primary memory residency status of pages in the
>        address space covered by mappings in the range [addr, addr + len).

It's still not clear that "primary memory residency status" actually means.

Does it mean "mapped", or does it mean "exists in caches and doesn't need IO".

I don't even know what kind of caches SunOS 4.1.3 had. The Linux
implementation depends on the page cache, and wouldn't work (at least
not very well) in a system that has a traditional disk buffer cache.

Anyway, I guess it's mostly moot. From a "does this cause regressions"
standpoint, the only thing that matters is really whatever Linux
programs that have used this since it was introduced 18+ years ago.

But I think my patch to just rip out all that page lookup, and just
base it on the page table state has the fundamental advantage that it
gets rid of code. Maybe I should jst commit it, and see if anything
breaks? We do have options in case things break, and then we'd at
least know who cares (and perhaps a lot more information of _why_ they
care).

                     Linus

