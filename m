Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23FBCC10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:17:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C815320850
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 13:17:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Mz1wBwJj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C815320850
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 651476B0005; Mon, 18 Mar 2019 09:17:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 600A26B0006; Mon, 18 Mar 2019 09:17:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A17A6B0007; Mon, 18 Mar 2019 09:17:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 059126B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:17:07 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c15so19070783pfn.11
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 06:17:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XMsQCnO3d2N5DODeaXx9kIQiZQAAX2gcah3MrcQIGq4=;
        b=RjqR1jw/AIltb4a8qB4ulgpoRRrlcNjgIC39hEhU737A56XTZbZg5mED//7bGnnSlr
         LnELcCFK6ukE/fOLSM9PNYFTqsRPwKe4MYQJtIU677BiWtCjfJHaWxwuqLbRm/5G4Rrn
         Xt5cKe+Sr5FK9U+YtR00scTVhwIQadrbMQuL9Qr+WAu4exeUuXndwOpgyhQW0//zQnrJ
         teV/bqNnXk6uVSIlfcbP0Gk3E7xC45FXNmdU0xN1qeP5vv8+G5aStixhsac6TJ1l4TbX
         2B/hhcSKtb1kNn+o7FiiggBexzN1x8GUmHBcn/b2kIdZZmI7I3OJR8ffih/S3kmsZYLm
         0D+A==
X-Gm-Message-State: APjAAAXp12Ja7kwlNspw/eFZR9bm9Ygm9MHzMM1f+AJkQc6v/PmCvHUC
	JVlO1Smz0L+1HRWxRM2laD9OQ4QVq2M+KytgXQzPWL8uI60iyEqI5uxNid96G+lvptqCsv9wxPn
	UWcKV0BFRyzsMquNpFJQqqZCdq2miht0v6lX7tctQ3KgFYbQ7AnL8RJUT73skZ9rD8Q==
X-Received: by 2002:a17:902:848c:: with SMTP id c12mr19343394plo.207.1552915026643;
        Mon, 18 Mar 2019 06:17:06 -0700 (PDT)
X-Received: by 2002:a17:902:848c:: with SMTP id c12mr19343328plo.207.1552915025797;
        Mon, 18 Mar 2019 06:17:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552915025; cv=none;
        d=google.com; s=arc-20160816;
        b=q4l7DHD5DRONSVnm22uJg2v9AtCtsNOaaImvyFFOT4I+jUgxWUtbSaXn4NyJycvNz6
         QZSxGwCRgJotkZTJxxXboQYV9JXxufXqZ3IUgs+663SCYL7oU2DkuYVZbLB00Y0oyoMg
         cZ2YygXmDXjbg972jZqKUwJvpdqVElTHjCLCXJ+ndQicAagMsCKalsiOkaLp1Q+ICdSY
         HyS9TrNyIiDXZYIMEKgv8KAqLpWYJ0ARxHO5FLCus9AAS1WeFks5Hxv7+eRg+Dd+Xf/Z
         Uc0DhBaZjEP0Xocmsvqn9U4cTaFxw7+G5DFxhdAu7C0rj7CfqMpJToES9L35CQmokjHS
         z6vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XMsQCnO3d2N5DODeaXx9kIQiZQAAX2gcah3MrcQIGq4=;
        b=BIcuhWhMqO1azsCVOnEsO9xw+g6e9k76SerEvO0cJ+7fZEy4fRQIsnXYmJZsJN3LkT
         8ZTzJIvUfdh1Bm5lH1pY/AMx2c1hT05uyQs8FrVXQifMBz/GUlG8ySnoSABuBhFMJ8JP
         63UrHH4Y2sXfnNMdSv+5JuYKYG3bvyWH5hRvLxrFWCc/0asGWqPNv5pv30Di/pimjocs
         sIMvLeRgHcWpBif7dQtQT+3gTUr1sQFniZHfCCrPZH2kfgwmNC4enmuxq4OpM7btAPIb
         eUUzop2jLX78zl/JCKzf56bs8zpKbzy+u83pwgInv8mMHJols0/dCrToytskQ/vD+7QK
         2ycg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Mz1wBwJj;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a9sor15412065pff.11.2019.03.18.06.17.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 06:17:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Mz1wBwJj;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XMsQCnO3d2N5DODeaXx9kIQiZQAAX2gcah3MrcQIGq4=;
        b=Mz1wBwJj6aCIZctfrRgE6qXPvX+DxKzIewaAWG2rsnRyqxyHSntUGvgMk83TJr4D9R
         vQY040rQcugdz84sOkhKoPh+5b61cRyUPyZHiun1V7TlGA4yTVG73h6PtP07QDgLiuwE
         n+Y726W4fhoevokV4KYe1eN7kRnGOw2ACjkFgmQCINLKKX731h86aGsk7vt7KFXu5VD/
         IvAIbnkhPmKhNvITYDEkPKJcLWmUjR47kAvs4vZgz0S2NXlFkFNzVMsgyzV5Se0Oxdq4
         +rOKDCv24NM7YvtykGdF3O1VGaaySN2ax6qOyIngXLA9yS4tWIS96p9YD5FbV0UfdUAj
         Rnpg==
X-Google-Smtp-Source: APXvYqznUx/0uvWyFAaioSmzSqQCdEUiA7lTMwL0ocTN2RjTJ+d/Q8++zm5Ul1FUymXrEWoCrhT4qzyR9aFgyliP2CQ=
X-Received: by 2002:a62:6383:: with SMTP id x125mr18765188pfb.239.1552915025400;
 Mon, 18 Mar 2019 06:17:05 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com> <56d3373c1c5007d776fcd5de4523f4b9da341fb6.1552679409.git.andreyknvl@google.com>
 <04c5b2de-7fde-7625-9d42-228160879ea0@gmail.com> <CAAeHK+xXLypBpF1EE73KuzQAo0E6Y=apS46wo+swo2AB6cy3YA@mail.gmail.com>
In-Reply-To: <CAAeHK+xXLypBpF1EE73KuzQAo0E6Y=apS46wo+swo2AB6cy3YA@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 18 Mar 2019 14:16:54 +0100
Message-ID: <CAAeHK+yxcG=KBjG0A5BicBA7Zwu6LR6t=g5b-9EAPXA8_Dfm2g@mail.gmail.com>
Subject: Re: [PATCH v11 08/14] net, arm64: untag user pointers in tcp_zerocopy_receive
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	netdev <netdev@vger.kernel.org>, bpf@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 2:14 PM Andrey Konovalov <andreyknvl@google.com> wrote:
>
> On Fri, Mar 15, 2019 at 9:03 PM Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> >
> >
> > On 03/15/2019 12:51 PM, Andrey Konovalov wrote:
> > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > pass tagged user pointers (with the top byte set to something else other
> > > than 0x00) as syscall arguments.
> > >
> > > tcp_zerocopy_receive() uses provided user pointers for vma lookups, which
> > > can only by done with untagged pointers.
> > >
> > > Untag user pointers in this function.
> > >
> > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > ---
> > >  net/ipv4/tcp.c | 2 ++
> > >  1 file changed, 2 insertions(+)
> > >
> > > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > > index 6baa6dc1b13b..89db3b4fc753 100644
> > > --- a/net/ipv4/tcp.c
> > > +++ b/net/ipv4/tcp.c
> > > @@ -1758,6 +1758,8 @@ static int tcp_zerocopy_receive(struct sock *sk,
> > >       int inq;
> > >       int ret;
> > >
> > > +     address = untagged_addr(address);
> > > +
> > >       if (address & (PAGE_SIZE - 1) || address != zc->address)
> >
> > The second test will fail, if the top bits are changed in address but not in zc->address
>
> Will fix in v12, thanks Eric!

Looking at the code, what's the point of this address != zc->address
check? Should I just remove it?

>
> >
> > >               return -EINVAL;
> > >
> > >
> >

