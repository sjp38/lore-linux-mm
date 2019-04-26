Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4658EC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:17:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02A6F206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:17:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02A6F206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7E62E6B0003; Fri, 26 Apr 2019 10:17:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76E6A6B0005; Fri, 26 Apr 2019 10:17:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 638326B0006; Fri, 26 Apr 2019 10:17:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1113C6B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:17:53 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x21so1586567edx.23
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 07:17:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZgdVh7jED4wTy2p8ZjKGVfYa1W7KTRIlFUaAyI4gHzk=;
        b=n1OHkz9J22CA4cjUsD0cUn9U9p+cyHTthEUqEGNPyMTXSRDoAeSmysNbzfkPA/pnv0
         H5+BRfmaet/yJbok6mlqHjNJ86iFPfHY2YkgZs3+DZuNoYd1A3SbkL9uaYpjtA7EA4EE
         HYelTF+rVThrFIlvfEams58GDGDnj1n8dOndKy3UgBkd2tFO65EOzFqUo84U4z3JsYr7
         xuxhBVW6qKly4C8dvCp7mCn7xufMHpIt55b1iuZnYqrHNmyGVq7+qPgWwsd7BJh/2sn1
         n8WVep3rWoDcex4rHFStHhm6MFlYi7rEL68o2A1lqNn02bIuepfRj/+/mgJbCj/PoIIM
         2+9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAWFB7SAnCqYDwvUBtheKB9KD/zM63AByQ0PYe7ErVxWLOvga6xH
	DiZJvMBB8/oL57c/noS3LkuV1Oyo5JPf6xtWipOJHvLPGTYOJw9Fd9wJJxVBnTpgtPocxPJLji8
	9MgmlUrKgC6K3DQ9nQNwAzq6mwl40TUbbYxxMgMLXovfkcSsmJk5+BJshxu6l03M+NQ==
X-Received: by 2002:a50:b7e4:: with SMTP id i33mr14119746ede.32.1556288272646;
        Fri, 26 Apr 2019 07:17:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAotYXKhhTopl3ajEY23w3dKSdA6ZNd7Q47gorGdf2gxY7JyzcBKKo/43Yi4eGUO3wl/bM
X-Received: by 2002:a50:b7e4:: with SMTP id i33mr14119708ede.32.1556288271880;
        Fri, 26 Apr 2019 07:17:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556288271; cv=none;
        d=google.com; s=arc-20160816;
        b=yK+cqRmTSahnTKlbpC4SlsNSD9wzf/TnGliVUDXxHMvbl8/PQSNPDgagkXqWcy5VT7
         xDb1WH76+sRZ4oI7eI3HKtdG0xxIeILcXElSC8IkXBe7FMPkiD0gaHnpylKXBqaxdNNn
         W8pD9x2+KS0qEgp8OqLiEQ0fXFFhigxbc+rdD15Oi/ye/KCKcUBk6GgEOSeLs2UmPfv4
         eCnrmmScKvCezm2Dq4uOThKc5RVcSR9Q6hHZVV9nslPHHBDFsUxmHDt3OexLQ9j58oK1
         G/oj6Cr/rfp5xVt51nZXYYwThbdsRrQiNH2AkTD7OGoKeVHwUUvqeGdBMVihtyrnexu6
         cqMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZgdVh7jED4wTy2p8ZjKGVfYa1W7KTRIlFUaAyI4gHzk=;
        b=gFYnIzv5ZytVglKU9ZDgSBZLHoLiJ0/uigtApdf0FRxCoJeizwHsOW01Pmeh/CxXUi
         LiH7lJNufqPdGQjP0Ebwj+sidnsH9wo7eJQjBAe0m6ZFcFxTOah0r81IdmGH84mpqNXq
         s+chyuuQu8yKY9RsJtJp+1NtW3L0BQAwSLcpOJGhnTq/dkx/CN2vICWCn2Bl8eZ4v0Dm
         DnOEkwE2VesqezAikUGW5lq7srAOuG26zvMvu69bX+JP7z403w2GhM8JJzP7Aj2c2PRX
         gh2mN1vhELaqhS1Cyx0FWdTrAb1PzEN4FtSk28OehYZi7tcMLP8C0RNv4w6eWtKhS/Wr
         B8Eg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j11si2177329edj.412.2019.04.26.07.17.51
        for <linux-mm@kvack.org>;
        Fri, 26 Apr 2019 07:17:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 84F23A78;
	Fri, 26 Apr 2019 07:17:50 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2A5FE3F5C1;
	Fri, 26 Apr 2019 07:17:45 -0700 (PDT)
Date: Fri, 26 Apr 2019 15:17:42 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ingo Molnar <mingo@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <peterz@infradead.org>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-arch <linux-arch@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 04/20] mm, arm64: untag user pointers passed to
 memory syscalls
Message-ID: <20190426141742.GB54863@arrakis.emea.arm.com>
References: <cover.1553093420.git.andreyknvl@google.com>
 <44ad2d0c55dbad449edac23ae46d151a04102a1d.1553093421.git.andreyknvl@google.com>
 <20190322114357.GC13384@arrakis.emea.arm.com>
 <CAAeHK+xE-ywfpVHRhBJVGiqOe0+BYW9awUa10ZP4P6Ggc8nxMg@mail.gmail.com>
 <20190328141934.38960af0@gandalf.local.home>
 <20190329103039.GA44339@arrakis.emea.arm.com>
 <CAAeHK+xe-zWn8WpCxUxBB2tXL8oiLkshkPi1J3Ly87mACaA4-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xe-zWn8WpCxUxBB2tXL8oiLkshkPi1J3Ly87mACaA4-A@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 02:47:34PM +0200, Andrey Konovalov wrote:
> On Fri, Mar 29, 2019 at 11:30 AM Catalin Marinas
> <catalin.marinas@arm.com> wrote:
> > On Thu, Mar 28, 2019 at 02:19:34PM -0400, Steven Rostedt wrote:
> > > On Thu, 28 Mar 2019 19:10:07 +0100
> > > Andrey Konovalov <andreyknvl@google.com> wrote:
> > >
> > > > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > > > > ---
> > > > > >  ipc/shm.c      | 2 ++
> > > > > >  mm/madvise.c   | 2 ++
> > > > > >  mm/mempolicy.c | 5 +++++
> > > > > >  mm/migrate.c   | 1 +
> > > > > >  mm/mincore.c   | 2 ++
> > > > > >  mm/mlock.c     | 5 +++++
> > > > > >  mm/mmap.c      | 7 +++++++
> > > > > >  mm/mprotect.c  | 1 +
> > > > > >  mm/mremap.c    | 2 ++
> > > > > >  mm/msync.c     | 2 ++
> > > > > >  10 files changed, 29 insertions(+)
> > > > >
> > > > > I wonder whether it's better to keep these as wrappers in the arm64
> > > > > code.
> > > >
> > > > I don't think I understand what you propose, could you elaborate?
> > >
> > > I believe Catalin is saying that instead of placing things like:
> > >
> > > @@ -1593,6 +1593,7 @@ SYSCALL_DEFINE3(shmat, int, shmid, char __user *, shmaddr, int, shmflg)
> > >       unsigned long ret;
> > >       long err;
> > >
> > > +     shmaddr = untagged_addr(shmaddr);
> > >
> > > To instead have the shmaddr set to the untagged_addr() before calling
> > > the system call, and passing the untagged addr to the system call, as
> > > that goes through the arm64 architecture specific code first.
> >
> > Indeed. For example, we already have a SYSCALL_DEFINE6(mmap, ...) in
> > arch/arm64/kernel/sys.c, just add the untagging there. We could do
> > something similar for the other syscalls. I don't mind doing this in the
> > generic code but if it's only needed for arm64, I'd rather keep the
> > generic changes to a minimum.
> 
> Do I understand correctly, that I'll need to add ksys_ wrappers for
> each of the memory syscalls, and then redefine them in
> arch/arm64/kernel/sys.c with arm64_ prefix, like it is done for the
> personality syscall right now? This will require generic changes as
> well.

Yes. My aim is to keep the number of untagged_addr() calls in the
generic code to a minimum (rather than just keeping the generic code
changes small).

-- 
Catalin

