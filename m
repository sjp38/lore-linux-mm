Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_MED,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC32DC28CC3
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:24:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A66F526BFC
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:24:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WkbNgEwA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A66F526BFC
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 522616B026B; Fri, 31 May 2019 12:24:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F9986B026C; Fri, 31 May 2019 12:24:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40F6A6B0274; Fri, 31 May 2019 12:24:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B9306B026B
	for <linux-mm@kvack.org>; Fri, 31 May 2019 12:24:21 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s3so5036167pgv.12
        for <linux-mm@kvack.org>; Fri, 31 May 2019 09:24:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=h/x2RsdaGEeomdfj9zckwm1ZuXHc7ti1LUsxVKWauDI=;
        b=Q30TtQAq2k3Zep/uAS6yAKuiDDpM6MK6Yu+puc8T0TViuaXzOrl2Rdey6aCDzybEmU
         fV54btrrX1rP43yjjwU0lnD1P5G9HgSH14ccKtFKc1wgotqq6Od/CU5B2xnt2wqSzKYh
         0PQXROo8/RIrdDpLcdfcuwKfYcrz7R/o561U3eE8OXQoGkO3U6mEgURK96MVAFFBYThG
         bgAq6EmWeTefsDA0vb/6zfSnpArvmtvYPiz0ai/xEdigL6VmmapJgMXFOKRq86/6yCs/
         AUx5TRrVIF//UVBaK0tagFk2XNQRGolB5XcaBRUEEUq8hY6EbW70A1VDHMAVV9gTWJPs
         xZxQ==
X-Gm-Message-State: APjAAAUy2AqogCFx5zeegI7L/uJfZ+cXS2KKpyLZ+1VRR9Okq2eL7Pf0
	eHsy6qLl3zTgdTIKqdweN8A/8OUfzu+XXDJMjBT3Q9h5Bp85UkOtimen5M3CNMkLxRnBE4hJKMV
	/Qvpj7k3P5OLNDlv+9dVqWUKtny1fHA/MGPYADvamRT5SaaKSqnXCWCSGWlAkt2GRZQ==
X-Received: by 2002:a63:c24c:: with SMTP id l12mr10346887pgg.173.1559319860611;
        Fri, 31 May 2019 09:24:20 -0700 (PDT)
X-Received: by 2002:a63:c24c:: with SMTP id l12mr10346811pgg.173.1559319859850;
        Fri, 31 May 2019 09:24:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559319859; cv=none;
        d=google.com; s=arc-20160816;
        b=nvINYKQ3Ophs10Y2J8tlopZGnOWwic53F5ltA9abB6NFYwhn03gpOTj7W1FhtARJSa
         Lx81uTqT+SnFcP2y0kffvzk9eoRmMrRSJ0ol+EZDmWIDl47lRW26m39kkkjRtlYDmahQ
         F/h06lxDqc9QxeQLRyBPUpHBBPT5ZA7CQmEbG3LVkqKz1UFdOQ7uLyNY4kHKnU+LNN3a
         xTPtFqr4UQZ4v829WOmCa430M2c6BKgBujvnoIIrUKC+6/rJh/fPiWtqKp6uh3sSxO4o
         jxkBPZWVUILunHzBOgCTayoJiUAd2PUttyu7GSkOBrWwhqvCERsnmLSFjGBPkxcvGvbC
         yJJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=h/x2RsdaGEeomdfj9zckwm1ZuXHc7ti1LUsxVKWauDI=;
        b=Mv38uoyByKY++gci0rgZJjiGgOAIoIqna2A3UjqkKH8lRyEVNkUYTtWfvDfda+9aNX
         zFR/1CEniBxaQiZSSIrys8vyDZOZN6xcwexg8WhgPpWIj8O3PIOzg3aOLVDmfqA+GabU
         TfN0ig6FYc2S6MSOdx1AxeIZhQdvb5WJTeC/DBYrmc32fzKAvomWO6I/yOqeU4/2EUlU
         EPIun+w2j+UgRXbdu+Pa6by5iDg0+xSNX0+6l67aTn40NOTN47l2Hez1AP4AzA4R68Z2
         i+AbbkXXcUEHlJoYSBWO9ji9F2RORe0+Q1BunjpImaaMH2qvZ++3AvQjWf+Ic5G8F2k6
         svhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WkbNgEwA;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a12sor1846496pff.63.2019.05.31.09.24.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 May 2019 09:24:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WkbNgEwA;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=h/x2RsdaGEeomdfj9zckwm1ZuXHc7ti1LUsxVKWauDI=;
        b=WkbNgEwAtHoOpsgf2n/OOj9tvUzmqxkk0wFQPqMbZDhKXrycKmph8DKGky42GC+koN
         LJDEln958wkwnmRH28ZEap3NrGgf1V1D0g9IZCcP3z1+J4jMqALHLTOUy5KwiFNCWFFp
         J5Vof1T/5pKxOH0N8kkgt3VneNxkghx7TLiVO3NO5Dfw0XE9zLDEnv4oejnEpiTXZOeJ
         tDxDbRBsv0ZCYRogl5V2uwQD8iTi3aUBJXQrVEho7perE1vFrdRi0BvQ0ve9Pq7qowuL
         FRZuY21tQBRvNHvnsPyF6is+8mWCTar820ssvKvNtiwoTjNWK3ZyaVAaR6TMz/HMowZi
         esrQ==
X-Google-Smtp-Source: APXvYqxuY1CYuxd04Kewq/lINHwhx4xTvJLFZIhJ6+qsHKD7HtPQ0W1vOSTfUsi9VyOoypjJcb2qINRGGNrlijbQeNg=
X-Received: by 2002:a62:2c17:: with SMTP id s23mr11223321pfs.51.1559319859023;
 Fri, 31 May 2019 09:24:19 -0700 (PDT)
MIME-Version: 1.0
References: <20190521182932.sm4vxweuwo5ermyd@mbp> <201905211633.6C0BF0C2@keescook>
 <6049844a-65f5-f513-5b58-7141588fef2b@oracle.com> <20190523201105.oifkksus4rzcwqt4@mbp>
 <ffe58af3-7c70-d559-69f6-1f6ebcb0fec6@oracle.com> <20190524101139.36yre4af22bkvatx@mbp>
 <c6dd53d8-142b-3d8d-6a40-d21c5ee9d272@oracle.com> <CAAeHK+yAUsZWhp6xPAbWewX5Nbw+-G3svUyPmhXu5MVeEDKYvA@mail.gmail.com>
 <20190530171540.GD35418@arrakis.emea.arm.com> <CAAeHK+y34+SNz3Vf+_378bOxrPaj_3GaLCeC2Y2rHAczuaSz1A@mail.gmail.com>
 <20190531161954.GA3568@arrakis.emea.arm.com>
In-Reply-To: <20190531161954.GA3568@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 31 May 2019 18:24:06 +0200
Message-ID: <CAAeHK+zRDD7ZPPUA9cpwHOdgTRrJLWAby8Wg9oPgmhqMpHwvFw@mail.gmail.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Kees Cook <keescook@chromium.org>, Evgenii Stepanov <eugenis@google.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, 
	Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Elliott Hughes <enh@google.com>, 
	Khalid Aziz <khalid.aziz@oracle.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 31, 2019 at 6:20 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Fri, May 31, 2019 at 04:29:10PM +0200, Andrey Konovalov wrote:
> > On Thu, May 30, 2019 at 7:15 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
> > > On Tue, May 28, 2019 at 04:14:45PM +0200, Andrey Konovalov wrote:
> > > > Thanks for a lot of valuable input! I've read through all the replies
> > > > and got somewhat lost. What are the changes I need to do to this
> > > > series?
> > > >
> > > > 1. Should I move untagging for memory syscalls back to the generic
> > > > code so other arches would make use of it as well, or should I keep
> > > > the arm64 specific memory syscalls wrappers and address the comments
> > > > on that patch?
> > >
> > > Keep them generic again but make sure we get agreement with Khalid on
> > > the actual ABI implications for sparc.
> >
> > OK, will do. I find it hard to understand what the ABI implications
> > are. I'll post the next version without untagging in brk, mmap,
> > munmap, mremap (for new_address), mmap_pgoff, remap_file_pages, shmat
> > and shmdt.
>
> It's more about not relaxing the ABI to accept non-zero top-byte unless
> we have a use-case for it. For mmap() etc., I don't think that's needed
> but if you think otherwise, please raise it.
>
> > > > 2. Should I make untagging opt-in and controlled by a command line argument?
> > >
> > > Opt-in, yes, but per task rather than kernel command line option.
> > > prctl() is a possibility of opting in.
> >
> > OK. Should I store a flag somewhere in task_struct? Should it be
> > inheritable on clone?
>
> A TIF flag would do but I'd say leave it out for now (default opted in)
> until we figure out the best way to do this (can be a patch on top of
> this series).

You mean leave the whole opt-in/prctl part out? So the only change
would be to move untagging for memory syscalls into generic code?

>
> Thanks.
>
> --
> Catalin

