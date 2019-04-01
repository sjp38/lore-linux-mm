Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CD54C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 15:38:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D200620880
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 15:38:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="rz+eKGWd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D200620880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84CC06B0008; Mon,  1 Apr 2019 11:38:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FC9B6B000A; Mon,  1 Apr 2019 11:38:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 69E7B6B000C; Mon,  1 Apr 2019 11:38:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2B39B6B0008
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 11:38:54 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j18so7132751pfi.20
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 08:38:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HpLKq1u6zgG4u47m+oJy6q6/PWHFj2n1/o90qI1J+5Q=;
        b=K8Uexe9wcZtGyR6hkzv+3U1mwx+kF73wAk0RsiNR4T0J9QGKWCdZMWTos6IT0vJFEW
         iigdgxFerUcT4Ty5DRo64zQao0e4tkhgSGsJkQ+BmqUPeVH3i5s0C39rtzerTeDHVkXr
         ZHwAwUGmfAAIRLWf19ZtPsGiYZdiipZILa9sA0UuNzC3D7+5e5tBRC9WovLZF+GhOHUh
         YV0a1ftfcQ9+DQ3so7rYHFpDGjDlV9WPnB5Fw1lTvdEBTYKqH6udr5PDxeuHBgBWnZFR
         yEE6DICzUQH0+hkAY4wgdcQUP8NUIbMaEOHb1vt0mZi1Olkna8haGkUhKX7Xn6iNBXlU
         RRpQ==
X-Gm-Message-State: APjAAAWVbCGL83OjT7Wbx8uM3mGfrcWNZ6hbahx0sIgVmP3xOObGSeqe
	cGIFKyVauOJmbXvxnj6p42oKIZ7MaBP/xG6MiBGaleDtTsvutNGvMlA8YbC6I8DwKLxQ4KgN8Ue
	4Odjfqv8zaKGZRJJJEtMAJ9Owm5dnqh+2bCoZtHapGN5M+oCRWwhoL9x1kdKsHCX0Ig==
X-Received: by 2002:a17:902:7206:: with SMTP id ba6mr26568102plb.301.1554133133668;
        Mon, 01 Apr 2019 08:38:53 -0700 (PDT)
X-Received: by 2002:a17:902:7206:: with SMTP id ba6mr26568025plb.301.1554133132829;
        Mon, 01 Apr 2019 08:38:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554133132; cv=none;
        d=google.com; s=arc-20160816;
        b=VK9GyhHCswiAnlAjhTIpKR3Na50j2NzbamfumbJPXovPtiH0Q5gCG0uWhp3GalwvEB
         tr9Dea6Dzu5azKgbJLjes6R8vb+sAEy51fI+U6QzfgnR65m7K55Ua95Pmxm3cF+4OmWr
         n0xOuecWQHEQ4Tu9cFAs+FL23N3GiA8dLe/o2B4bajKZfzub9kBDARRbWBUCKucX57wT
         Ss0XHnW3gobty+t23reOMdLOcZm/ph7Ai/Rr3YPPLU/T4D/RupgHOP45/rZr4uvHtXsm
         13QwxA+NdowzTd6I2uTudJG8v9Xk2hM2uFBrKuusl+1vKZF+gUePSQV6pU6fd2QE2HSq
         nhRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HpLKq1u6zgG4u47m+oJy6q6/PWHFj2n1/o90qI1J+5Q=;
        b=M1udvKNKerNdMo0wj2p0tFE/VhkLxb2bxYYtt3X6elx1+T5hi8lj2faAdEmdjOSJ+3
         EgtXaqcZKObUrtzEcCHHEr9x59RdLK5sLc0C123q8ZEZnXKjURspufC46hNNeMDCDYb4
         59cVi1ki4LOd8Lkg0GshJicJk1Yq5C/sG4jhPQ6D5GWZt7KWUFFARv5StusyzgM1e4Kn
         stGzyqFE1YAKEYfg0drwZl2pyQcur2R8oBkGG45fQpjMTcrJZlE/RTFeEI7lGc3c73Hq
         3Rr1+q3sSSbBU3ebFdnheaP8J6erM9zcf5OZZW3gOQ4Bs7jVLMDUehb7RO7msVBYzLpg
         igLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rz+eKGWd;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h68sor10271630pfj.73.2019.04.01.08.38.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 08:38:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=rz+eKGWd;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HpLKq1u6zgG4u47m+oJy6q6/PWHFj2n1/o90qI1J+5Q=;
        b=rz+eKGWdIEAATVPKtPNa1Orgm+SbBpSOUItB/oKEP9YFvpyeRSiNTjebBofH85vmuv
         Ruo6xVKWsDadspv/HufxX8zlWaE2YfFITksk0W67DGyhwRPZzC7+gzZB1ALf/n+tyHvS
         D0yOd7NPpE0szXEAh4t1t4OxUCepvNGSbAokE8BiKS8d9NdDUhY7hSE5Ylh0xSoAv/R5
         /JqgbBqVDIITLjgEaRXeiJ5w48h29NLd5psds/vI1hvwGhFuRBI5pib3dyhgzrQc6NTv
         h+gs0qckSWse4iFFCLh5ue5/qaD/TT8WdpCkVjuCA/Dr/MnpB2rUzW08V20dFWPmm68Z
         sg0w==
X-Google-Smtp-Source: APXvYqwkizGwSG7ZyEmRuIQOd2nXeyJg5S4D8809WfJkrKIsV5+aD0+BiMFtb4gqUAAsYahc3/6PhBK4XlY5d3rLnhw=
X-Received: by 2002:a62:69c2:: with SMTP id e185mr21673086pfc.119.1554133132011;
 Mon, 01 Apr 2019 08:38:52 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <c9553c3a4850d43c8af0c00e97850d70428b7de7.1553093421.git.andreyknvl@google.com>
 <20190322154513.GQ13384@arrakis.emea.arm.com>
In-Reply-To: <20190322154513.GQ13384@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 1 Apr 2019 17:38:40 +0200
Message-ID: <CAAeHK+zxo4aY0qLzSmT8QDHFhas0_=hrXBo6dSamuVE+-VUyQQ@mail.gmail.com>
Subject: Re: [PATCH v13 11/20] tracing, arm64: untag user pointers in seq_print_user_ip
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, 
	Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>, Yishai Hadas <yishaih@mellanox.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	netdev <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
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

On Fri, Mar 22, 2019 at 4:45 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Wed, Mar 20, 2019 at 03:51:25PM +0100, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > seq_print_user_ip() uses provided user pointers for vma lookups, which
> > can only by done with untagged pointers.
> >
> > Untag user pointers in this function.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  kernel/trace/trace_output.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> >
> > diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
> > index 54373d93e251..6376bee93c84 100644
> > --- a/kernel/trace/trace_output.c
> > +++ b/kernel/trace/trace_output.c
> > @@ -370,6 +370,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
> >  {
> >       struct file *file = NULL;
> >       unsigned long vmstart = 0;
> > +     unsigned long untagged_ip = untagged_addr(ip);
> >       int ret = 1;
> >
> >       if (s->full)
> > @@ -379,7 +380,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
> >               const struct vm_area_struct *vma;
> >
> >               down_read(&mm->mmap_sem);
> > -             vma = find_vma(mm, ip);
> > +             vma = find_vma(mm, untagged_ip);
> >               if (vma) {
> >                       file = vma->vm_file;
> >                       vmstart = vma->vm_start;
> > @@ -388,7 +389,7 @@ static int seq_print_user_ip(struct trace_seq *s, struct mm_struct *mm,
> >                       ret = trace_seq_path(s, &file->f_path);
> >                       if (ret)
> >                               trace_seq_printf(s, "[+0x%lx]",
> > -                                              ip - vmstart);
> > +                                              untagged_ip - vmstart);
> >               }
> >               up_read(&mm->mmap_sem);
> >       }
>
> How would we end up with a tagged address here? Does "ip" here imply
> instruction pointer, which we wouldn't tag?

Yes, it's the instruction pointer. I think I got confused and decided
that it's OK to have instruction pointer tagged, but I guess it's not
a part of this ABI relaxation. I'll drop the patches that untag
instruction pointers.

