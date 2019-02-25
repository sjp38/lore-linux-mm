Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E109C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 23:58:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD41020578
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 23:58:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="KX6+mdqi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD41020578
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 748558E000C; Mon, 25 Feb 2019 18:58:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D0748E000A; Mon, 25 Feb 2019 18:58:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 521468E000C; Mon, 25 Feb 2019 18:58:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id DB4A28E000A
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 18:58:55 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id c20so1779107lji.9
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:58:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=JdMBJp49ET+JbqiN0APUDRxceNUGJT3yhKuE4Z6Bj6M=;
        b=uOnqz7n5bAbyhxYSYQ4S4g13mBOsjbz5q6qpQS36m5GzhWU0YYSd80qGnZUyqotrsE
         SNqNZqa0ivyOP36+wUsY7wmxuHJogvCNZGzPKwoTeoQmVVOrl0pLXKI+MCvKiS+Sf9Vd
         91XuGS8FAKEFlJULirbgkxP0veA87qfkKZE2n4+QWWcBGXAg5jId9KVNGQ8cxNe6pGSc
         cGzGestbUcXqWsVgKXefTeiCXKUizXa8M3089EPhDJ8IkhXjM8N3cHt1yJOovG/bf8Hm
         TyJuLJ/Hor6v9MdhPs95SHh83bjJfhnh1keT3ZZeOeIte53HkJmlqr0C9Jm273VKP3Pp
         ao0A==
X-Gm-Message-State: AHQUAubChTKEWebFiXM/KBzT9MMBCiW8sn0EWBd5b2b8i+C8qd6WeXBC
	KPBgppEkMehRWQtRjlXEXZmzGdgL8peaEewF7cXwIuaB80KWjYo9LZjtoQAj7Xql64VCSYxXeDA
	Gpov88EFt2m5BfxC+rdnGBovQN1OrS2yRa7e7HSVKHlnX7EaBiqqPK2ySk01rLJN4mDvGTRYVeW
	10Vs2oZ5D6DLNnhFBUbfvyjiYcebjJJ229BhSlGz+8otp5AxCSnXbXhnWyl8nYTrjoIFhDqUTgv
	fZUGKpMoNm/a62+T6XjbJYubypuvhY6/dgrLFzaUAzDZpfIH/IkAglu6rqHod+F5IErR4LjY7DX
	NFCIOsxb4nHo7oc4DFsf1sCXvaS+LGMDuVsHXhlU/z3QAeL8GEo/elxd4IwIG0CYPOpBr8HciUx
	G
X-Received: by 2002:a19:aacc:: with SMTP id t195mr897231lfe.153.1551139135166;
        Mon, 25 Feb 2019 15:58:55 -0800 (PST)
X-Received: by 2002:a19:aacc:: with SMTP id t195mr897185lfe.153.1551139134074;
        Mon, 25 Feb 2019 15:58:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551139134; cv=none;
        d=google.com; s=arc-20160816;
        b=iQaaoZO+Toxa9pDemcWxyRjr7PxuY0OJxEduw/BC2uiziGJI471k4fEa2aDU8lWJSb
         W4gzgV1aityuK2NbBxpOWVDzMyDguPWDxJoiS5txrCHH6Eo+EE3aM0RvRT9aIidO46Cs
         LzCS+FofRIyZYclnqrmu9rVYqAUFe/5s41C/DHCstngnKegHxX5nzsR4wH6krWaR/JJp
         k2z830A4MPDuFVfoC0V6rqKO9CdACC3Q9EiirwSsrFyM6pAayBrrgb4dRf5738ShEgdV
         4SKqxdZDnBp9l0PU0cN46BAcZJhwTcxON3vWgl+FGuXCZUi5Wd8+b6ubSQGNO5U4ZE8f
         sXMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=JdMBJp49ET+JbqiN0APUDRxceNUGJT3yhKuE4Z6Bj6M=;
        b=OoQ6KaHq39rqwYOBBxapjVvbIvTykU6JaBMLxcK3aYopu4HW4CC6Tn7UAp8tDxyo29
         qf51ZxCxObCgcbuPS48r7Ctv+FA6FPEN9pTaklPkJXpwSYJX4SS7cpsZ/b6e74UoMQVW
         QCVUM/vhWHaAiDs7GBlNMPx4ElMQwbJeRNUe8fLbp69rNc9vl7yJpgsf6qboOGbpRksk
         6M5YwPlXbPX72mPAisptEjzFL6s2pbiIWFkyfBUIdpRzDryjHIHt0Md60uMRqtKUDGJo
         KX+ZRxy7Hqm5j+T4tfXACf27pZnmm7W6GFJu95rJhrrNPEkxxoPam8oZkn23XrckwH16
         vM6g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=KX6+mdqi;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a84sor177189ljf.0.2019.02.25.15.58.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 15:58:53 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=KX6+mdqi;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=JdMBJp49ET+JbqiN0APUDRxceNUGJT3yhKuE4Z6Bj6M=;
        b=KX6+mdqixHQDHTf6Nn4nwti+VpkJ3ZTXMVx73uY5MalHv6i7kUYR1TMoDqUitpuwPH
         gNQFROKAnk3ioJiU2gWEckCWAVq6RahdpbjaCFuqnNoRwE/gvsSOzcP8jDPJ6cjq4Hts
         tNEk4tomZ+hmt0bjRBrF1Ybldwex65nwY0qek=
X-Google-Smtp-Source: AHgI3IbD/ilcp7TUK7hhqYRXquoY8dB8gSAjynTIe1GmC0GrR5rfpPSZQvPAlH1rSY4pokep6pOxrw==
X-Received: by 2002:a2e:934a:: with SMTP id m10mr3510717ljh.164.1551139132842;
        Mon, 25 Feb 2019 15:58:52 -0800 (PST)
Received: from mail-lj1-f169.google.com (mail-lj1-f169.google.com. [209.85.208.169])
        by smtp.gmail.com with ESMTPSA id z26sm2486304lja.33.2019.02.25.15.58.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 15:58:51 -0800 (PST)
Received: by mail-lj1-f169.google.com with SMTP id v16so9072253ljg.13
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 15:58:51 -0800 (PST)
X-Received: by 2002:a2e:8510:: with SMTP id j16mr11347039lji.2.1551139130909;
 Mon, 25 Feb 2019 15:58:50 -0800 (PST)
MIME-Version: 1.0
References: <20190221222123.GC6474@magnolia> <alpine.LSU.2.11.1902222222570.1594@eggly.anvils>
 <CAHk-=wgO3MPjPpf_ARyW6zpwwPZtxXYQgMLbmj2bnbOLnR+6Cg@mail.gmail.com>
 <alpine.LSU.2.11.1902251214220.8973@eggly.anvils> <CAHk-=whP-9yPAWuJDwA6+rQ-9owuYZgmrMA9AqO3EGJVefe8vg@mail.gmail.com>
In-Reply-To: <CAHk-=whP-9yPAWuJDwA6+rQ-9owuYZgmrMA9AqO3EGJVefe8vg@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 25 Feb 2019 15:58:34 -0800
X-Gmail-Original-Message-ID: <CAHk-=wiwAXaRXjHxasNMy5DHEMiui5XBTL3aO1i6Ja04qhY4gA@mail.gmail.com>
Message-ID: <CAHk-=wiwAXaRXjHxasNMy5DHEMiui5XBTL3aO1i6Ja04qhY4gA@mail.gmail.com>
Subject: Re: [PATCH] tmpfs: fix uninitialized return value in shmem_link
To: Hugh Dickins <hughd@google.com>
Cc: "Darrick J. Wong" <darrick.wong@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Matej Kupljen <matej.kupljen@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, 
	Dan Carpenter <dan.carpenter@oracle.com>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 2:34 PM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> On Mon, Feb 25, 2019 at 12:34 PM Hugh Dickins <hughd@google.com> wrote:
> >
> > Seems like a gcc bug? But I don't have a decent recent gcc to hand
> > to submit a proper report, hope someone else can shed light on it.
>
> I don't have a _very_ recent gcc either [..]

Well, that was quick. Yup, it's considered a gcc bug.

Sadly, it's just a different version of a really old bug:

    https://gcc.gnu.org/bugzilla/show_bug.cgi?id=18501

which goes back to 2004.

Which I guess means we should not expect this to be fixed in gcc any time soon.

The *good* news (I guess) is that if we have other situations with
that pattern, and that lack of warning, it really is because gcc will
have generated code as if it was initialized (to the value that we
tested it must have been in the one basic block where it *was*
initialized).

So it won't leak random kernel data, and with the common error
condition case (like in this example - checking that we didn't have an
error) it will actually end up doing the right thing.

Entirely by mistake, and without a warniing, but still.. It could have
been much worse. Basically at least for this pattern, "lack of
warning" ends up meaning "it got initialized to the expected value".

Of course, that's just gcc. I have no idea what llvm ends up doing.

               Linus

