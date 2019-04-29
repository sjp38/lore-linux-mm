Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03ACBC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 14:23:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA9D62084B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 14:23:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mXWeCrBW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA9D62084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 414E76B0007; Mon, 29 Apr 2019 10:23:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 39DE66B0008; Mon, 29 Apr 2019 10:23:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 217996B000A; Mon, 29 Apr 2019 10:23:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D687F6B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 10:23:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id a141so5608775pfa.13
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 07:23:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=qKPVtvBLmfJTI551qLHl53aFN3OBlNxxZnEj1HXg4SU=;
        b=N6IpNWk7ierg6Nj89xqhkeX3dQJqZbhQ59EPqKQ80W8ltMkJNGp8nQLRBamEA3bdEL
         /D+9YPpsIVyOB3CE0c6bKoKsRA0q5ENQJ6OBvCgRt4X+JxN/Tn1tSPiSaLTUJBGrE5uj
         UAi6Eg+dR/eGIi1VrH9kmxag/lDnxxKD0hjBd1oNaEOLaRe6cAKtVQWQJ4l+CUTknt3q
         ghhpHwDQyecG0C2mbPtqX41kRiCt2mkoHPlm/Hgh4eUDDALmeXvyk4P2wPqwFdeT3gzA
         pD5Dph+ZoTmOe71mdmK19+qSIZjvXQ/78I5YN8plCoyovFKBxA+gYWqxXwHjDhnuUl3w
         r+jQ==
X-Gm-Message-State: APjAAAW1HqhSOrlNovw/fpFSLVf9lNIiMCpL6YRQaP+ObqWOlxITkt+s
	Hf7w0bQGgjm0YUSL2xySDh0/Ao/kkN4/KMdiI5Dy65GQK+DMkeDKTRBxxRyMvuX8ChTIc2hJI71
	ZlspMv7aQpPZzWOAaETOXzOWUP36cF3MF4deTbLqFGXkiQZNl7XoKEu3uL7OGaKFP4g==
X-Received: by 2002:a63:8c7:: with SMTP id 190mr52331769pgi.447.1556547825562;
        Mon, 29 Apr 2019 07:23:45 -0700 (PDT)
X-Received: by 2002:a63:8c7:: with SMTP id 190mr52331718pgi.447.1556547824869;
        Mon, 29 Apr 2019 07:23:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556547824; cv=none;
        d=google.com; s=arc-20160816;
        b=C6svoTiZHQ2D0dh1ZI8NVEvFbqjGLmytSydUT5iGe/kcIg3zAMLjUylUJsbFAYXYYT
         RogEA9AOuvhHBo+4GAMHeVgYFCZWPHgtXg96IEv69mIYJt/gC5+DnLPognBulNHUzPGS
         LqFv1+fFk7Udr42Et04dlQD9VWecziuZxOmkZUF6EJEvaPSdtCuWzkIkHBwZFiCGgV9c
         GCbiZQ2rIUjeYGcLbZJ+3gMGGrR7IP5eoJYEMl3PpkJ0Zh5f+FluEVnOgeoTBuKzjIA2
         XhzRtf7tcXoSQVtvyRJPoq6AMeX4C1KuK15/G5kReBx6IzhGdpNK2WqItsOvL93+nrkM
         MAVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=qKPVtvBLmfJTI551qLHl53aFN3OBlNxxZnEj1HXg4SU=;
        b=YWINpPRHF2S79yl5a8/dvv2C+t+6/BLrBSNX+F/vABGYHxh0Wexb3a1OVQdJN8ijMR
         TsyP5PS+yUIVaxmz7FW5SWVYViVJGj8xTqYqSAK6zCK7NKg1Dllxf+KNqH1TK0qQOf+I
         7bvKwgchfAd67C8v1wRkxgUrIkD9boYZ8AiYC52qm2TeqTU6Jjqd0CSw5gEbX1roaqi6
         +/K90SZkJjA8e1sXvEjoazjrzYucE3Cb1Y5SEYYpvSMt1nRmtFCLekJOY2GGe6c6GDWE
         xNDu0mDpVM1Zr/R1SB1q0AHFn9vRu2vd288lbs8T4A9u7P+H/Zv7H2NlJoYXhm9mfgYX
         jGFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mXWeCrBW;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r18sor8782182pgk.12.2019.04.29.07.23.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 07:23:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mXWeCrBW;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=qKPVtvBLmfJTI551qLHl53aFN3OBlNxxZnEj1HXg4SU=;
        b=mXWeCrBWyjjnfCR+3xz3X8593mLELxvrtE9kbO3YLUgcV7Wqby69B/+ldDxq8f4xl4
         /tTrmdSEaTmiV+1Hdh7RcsYCdfKXkBJdbVh2fW+oGSbBNoeNmuIBUa+NsGp54/DhlLBA
         rz7gs1efJGn2cXXq0bcAjGjW/XyNdZhfUlH+/8EXiLGpfR49fVX7WDRYuAt2jCgbxK81
         24BD+f68rZAntAlkG8MIC8V/K+0hvA5aq3l657ckbvvPMyNmI/xfEZiisfgmyrZAt9Zl
         r3WPzCH+6LgqHMMuFnAFeU6QVVkYDfyerDreawMVW498T/ltPC8yuFhBMUXTK7Iu/rRz
         7uIg==
X-Google-Smtp-Source: APXvYqwNMvYFFeiINAACBgd15gIPA6I5dddxP32CV6EfFFyTAnzcwTm5aQToA3fIAOsP2G0SI3a10snMId1MJawTiS0=
X-Received: by 2002:a65:5148:: with SMTP id g8mr17015283pgq.168.1556547824181;
 Mon, 29 Apr 2019 07:23:44 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <76f96eb9162b3a7fa5949d71af38bf8fdf6924c4.1553093421.git.andreyknvl@google.com>
 <20190322154136.GP13384@arrakis.emea.arm.com> <CAAeHK+yHp27eT+wTE3Uy4DkN8XN3ZjHATE+=HgjgRjrHjiXs3Q@mail.gmail.com>
 <20190426145024.GC54863@arrakis.emea.arm.com>
In-Reply-To: <20190426145024.GC54863@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 29 Apr 2019 16:23:32 +0200
Message-ID: <CAAeHK+ww=6-fTnHN_33EEiKdMqXq5bNU4oW9oOMcfz1N_+Kisw@mail.gmail.com>
Subject: Re: [PATCH v13 10/20] kernel, arm64: untag user pointers in prctl_set_mm*
To: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, 
	Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Eric Dumazet <edumazet@google.com>, 
	"David S. Miller" <davem@davemloft.net>, Alexei Starovoitov <ast@kernel.org>, 
	Daniel Borkmann <daniel@iogearbox.net>, Steven Rostedt <rostedt@goodmis.org>, 
	Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, 
	Arnaldo Carvalho de Melo <acme@kernel.org>, Alex Deucher <alexander.deucher@amd.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
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

On Fri, Apr 26, 2019 at 4:50 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Mon, Apr 01, 2019 at 06:44:34PM +0200, Andrey Konovalov wrote:
> > On Fri, Mar 22, 2019 at 4:41 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > On Wed, Mar 20, 2019 at 03:51:24PM +0100, Andrey Konovalov wrote:
> > > > @@ -2120,13 +2135,14 @@ static int prctl_set_mm(int opt, unsigned long addr,
> > > >       if (opt == PR_SET_MM_AUXV)
> > > >               return prctl_set_auxv(mm, addr, arg4);
> > > >
> > > > -     if (addr >= TASK_SIZE || addr < mmap_min_addr)
> > > > +     if (untagged_addr(addr) >= TASK_SIZE ||
> > > > +                     untagged_addr(addr) < mmap_min_addr)
> > > >               return -EINVAL;
> > > >
> > > >       error = -EINVAL;
> > > >
> > > >       down_write(&mm->mmap_sem);
> > > > -     vma = find_vma(mm, addr);
> > > > +     vma = find_vma(mm, untagged_addr(addr));
> > > >
> > > >       prctl_map.start_code    = mm->start_code;
> > > >       prctl_map.end_code      = mm->end_code;
> > >
> > > Does this mean that we are left with tagged addresses for the
> > > mm->start_code etc. values? I really don't think we should allow this,
> > > I'm not sure what the implications are in other parts of the kernel.
> > >
> > > Arguably, these are not even pointer values but some address ranges. I
> > > know we decided to relax this notion for mmap/mprotect/madvise() since
> > > the user function prototypes take pointer as arguments but it feels like
> > > we are overdoing it here (struct prctl_mm_map doesn't even have
> > > pointers).
> > >
> > > What is the use-case for allowing tagged addresses here? Can user space
> > > handle untagging?
> >
> > I don't know any use cases for this. I did it because it seems to be
> > covered by the relaxed ABI. I'm not entirely sure what to do here,
> > should I just drop this patch?
>
> If we allow tagged addresses to be passed here, we'd have to untag them
> before they end up in the mm->start_code etc. members.
>
> I know we are trying to relax the ABI here w.r.t. address ranges but
> mostly because we couldn't figure out a way to document unambiguously
> the difference between a user pointer that may be dereferenced by the
> kernel (tags allowed) and an address typically used for managing the
> address space layout. Suggestions welcomed.
>
> I'd say just drop this patch and capture it in the ABI document.

OK, will do in v14.

Vincenzo, could you add a note about this into tour patchset?

>
> --
> Catalin

