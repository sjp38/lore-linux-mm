Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42C08C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:54:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB3EA2133D
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:54:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="qL2sbyGF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB3EA2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 820D06B0006; Mon, 18 Mar 2019 12:54:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D0CC6B0007; Mon, 18 Mar 2019 12:54:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69D446B0008; Mon, 18 Mar 2019 12:54:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 27E7B6B0006
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:54:09 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f1so9212738pgv.12
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:54:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=oTTTDsmzZRxE0P4UD+1ikNPbtlS4Dyc6/3yBg27ixDQ=;
        b=U0OikXvLBqXlcd69pGVCBAqQOsFd9RSwrUvOVB3aHMq2f4oycbv+yDCuZiBH3vKTx7
         099AXcM5n4n2ewj/PlGeWhUwX8j4YPYGwKiUdp7ZnxvqLIgdTKMORr4nLyFWxveBHk7J
         IJ6fB0Dk91/KMszMcseyGkpeuaO6un7JaI+AKcAMBldUVGKWT1aMCrarM8L2DzBxckzk
         FBtsDoeJFO4wju28g1kRcH8wEmF215NNedamyolGCpu1GHex83ikkjyFEscDr2bw4xZr
         0kbOv8i6gOCc1lCp13Ue/wD7P9RhISVf+v4O63Yq4Xv2/IzjujNLTmy5TqFVTSqUTD6L
         Lprw==
X-Gm-Message-State: APjAAAXujvC84OGbzQr8jz6s8zsKW+vgGo+wD7wTTPr4gQMrjRpaqw+R
	fOBBBSbDlk4KorSLilyQAt7spMjsiYrF09XWDzjpyHKSMsqzPUXfOnLXFyoPGg3l3zGcUr9qp/w
	Tf69dwWazJISZ3exrtl4MZOV0PvNvwxSU5nG15zg++UWEVEJT+DZaVTZpnmLzpWk6pg==
X-Received: by 2002:a17:902:6b81:: with SMTP id p1mr21063821plk.106.1552928048834;
        Mon, 18 Mar 2019 09:54:08 -0700 (PDT)
X-Received: by 2002:a17:902:6b81:: with SMTP id p1mr21063762plk.106.1552928048005;
        Mon, 18 Mar 2019 09:54:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552928048; cv=none;
        d=google.com; s=arc-20160816;
        b=Fx9fhGTRR/fEoI/irOfmGjfwiqlLjQEuME1+Qpc76JXXC1UKzWl2opcuSKAW7lSDgl
         AR8ESH/FVHd3N45OV/QPAGh7z/G4HGm2wBQHbNJT4S0YpxTmZnJIN1uL+nl9PvGWbp+k
         rUIYFZ8+lOdI5Rv5MNeXt67JybzmB0SmhEI382pDES2Vlx/PLUR+DGQcRGATjLrftU4C
         rvkkDd7rSVK3l2ZhSF7kr8Ze87z85rkJHfcpEmobURCXs/9/FzzAPxb21FfkzYyWdZoN
         4ZZmcM7n+32+2NsKpBwaOsnNpg1sEt7/7qL6YRn9yuim61M0I5VadPyis3CxKUnvC78T
         zOnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=oTTTDsmzZRxE0P4UD+1ikNPbtlS4Dyc6/3yBg27ixDQ=;
        b=Mhrp+15pXEcH/XlRiu/8EGnHEbk6oooVmoGrai8yBkzbXlz+3RFfGLNi/X5MDlQ5wW
         JyO8y1cgeML1OHG3MFAGaiWUrxZEWZOwNawM2+vupIsxjHlQIuQGo7qw0+59BxZcsKjM
         HzqgNI4ZD5wLSPMLwsIqHD+22eATY3zGQjP9NsI2JO5EanMexH2GB6ZqWMlth7voojkF
         dpW81TUHDMGgYr5uOrH4YUWmVgSta7m3wcIuZKePOxXGTP+hq9finL47yGWCmAMT1bHJ
         jYRzxaNm25FxR2h5F4lfa6buNvrJGT3XK4MQ+Z30HC4D/XM4Kzk0/LYtYk0dqRL22tYo
         fyRw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qL2sbyGF;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 38sor15908114pln.23.2019.03.18.09.54.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 09:54:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=qL2sbyGF;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=oTTTDsmzZRxE0P4UD+1ikNPbtlS4Dyc6/3yBg27ixDQ=;
        b=qL2sbyGFEclrtQPUA6LVmMhwOgE9ZrDgMW6Yf0szQXcjCN8uVFclD6Agav2oG/HaIH
         tt+Y2mHDCoddFKSu8Zy4+3UpfZZ7SmbEpgE0cwANONzfIFjpTwwIM+e92N9XMSRRWHoH
         PxF+RlzsqmGVQHybjhaImaimN17+872PGPB3vCwmBpKws2yHzSmXHY74ILhBEtFUAPZC
         ZvI5cWjIE/Xp9Y+h7052jpM79vanjEebGQOinpddGY5fyw7tCnhdUPSnrMHlG9O0r3NS
         7j+QGp+4xtUxFT/lBj7jefQ9mZPAHUuw6v1QjZFT5Vjqdwgm4b+IedSWlUu5f+FbiQK2
         9n2w==
X-Google-Smtp-Source: APXvYqwtoSENSqe0flkUh8DZSgYEqtIQ0XKdJGpbQGPZjtv967mBGLrNb/wGEHW2f3Co8+OtTDYgx1PZKLh949N1HIQ=
X-Received: by 2002:a17:902:d24:: with SMTP id 33mr13090976plu.246.1552928047514;
 Mon, 18 Mar 2019 09:54:07 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com> <c4d65de9867cb3349af6800242da0de751260c6c.1552679409.git.andreyknvl@google.com>
 <96675b72-d325-0682-4864-b6a96f63f8fd@arm.com>
In-Reply-To: <96675b72-d325-0682-4864-b6a96f63f8fd@arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 18 Mar 2019 17:53:56 +0100
Message-ID: <CAAeHK+wwpDX5pc2P++7noGU0b8qWWYVP5=O5Vr5Fqm6NRQJmFA@mail.gmail.com>
Subject: Re: [PATCH v11 09/14] kernel, arm64: untag user pointers in prctl_set_mm*
To: Kevin Brodsky <kevin.brodsky@arm.com>
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
	netdev <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 18, 2019 at 12:47 PM Kevin Brodsky <kevin.brodsky@arm.com> wrote:
>
> On 15/03/2019 19:51, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > prctl_set_mm() and prctl_set_mm_map() use provided user pointers for vma
> > lookups, which can only by done with untagged pointers.
> >
> > Untag user pointers in these functions.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >   kernel/sys.c | 14 ++++++++++++++
> >   1 file changed, 14 insertions(+)
> >
> > diff --git a/kernel/sys.c b/kernel/sys.c
> > index 12df0e5434b8..8e56d87cc6db 100644
> > --- a/kernel/sys.c
> > +++ b/kernel/sys.c
> > @@ -1993,6 +1993,18 @@ static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data
> >       if (copy_from_user(&prctl_map, addr, sizeof(prctl_map)))
> >               return -EFAULT;
> >
> > +     prctl_map->start_code   = untagged_addr(prctl_map.start_code);
> > +     prctl_map->end_code     = untagged_addr(prctl_map.end_code);
> > +     prctl_map->start_data   = untagged_addr(prctl_map.start_data);
> > +     prctl_map->end_data     = untagged_addr(prctl_map.end_data);
> > +     prctl_map->start_brk    = untagged_addr(prctl_map.start_brk);
> > +     prctl_map->brk          = untagged_addr(prctl_map.brk);
> > +     prctl_map->start_stack  = untagged_addr(prctl_map.start_stack);
> > +     prctl_map->arg_start    = untagged_addr(prctl_map.arg_start);
> > +     prctl_map->arg_end      = untagged_addr(prctl_map.arg_end);
> > +     prctl_map->env_start    = untagged_addr(prctl_map.env_start);
> > +     prctl_map->env_end      = untagged_addr(prctl_map.env_end);
>
> As the buildbot suggests, those -> should be . instead :) You might want to check
> your local build with CONFIG_CHECKPOINT_RESTORE=y.

Oops :)

>
> > +
> >       error = validate_prctl_map(&prctl_map);
> >       if (error)
> >               return error;
> > @@ -2106,6 +2118,8 @@ static int prctl_set_mm(int opt, unsigned long addr,
> >                             opt != PR_SET_MM_MAP_SIZE)))
> >               return -EINVAL;
> >
> > +     addr = untagged_addr(addr);
>
> This is a bit too coarse, addr is indeed used for find_vma() later on, but it is also
> used to access memory, by prctl_set_mm_mmap() and prctl_set_auxv().

Yes, I wrote this patch before our Friday discussion and forgot about
it. I'll fix it in v12, thanks!

>
> Kevin
>
> > +
> >   #ifdef CONFIG_CHECKPOINT_RESTORE
> >       if (opt == PR_SET_MM_MAP || opt == PR_SET_MM_MAP_SIZE)
> >               return prctl_set_mm_map(opt, (const void __user *)addr, arg4);
>

