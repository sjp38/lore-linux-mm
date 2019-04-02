Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF00FC10F00
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 12:47:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B2A32146E
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 12:47:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RvtPBpLv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B2A32146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBD6C6B027D; Tue,  2 Apr 2019 08:47:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D6C7A6B027E; Tue,  2 Apr 2019 08:47:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5CE66B027F; Tue,  2 Apr 2019 08:47:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A35E6B027D
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 08:47:48 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id h14so5929174pgn.23
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 05:47:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=u3PSOHs4we7+LgIG6ZQZir4Fy57VqCCMcbhzYXQWknQ=;
        b=GoTEi8Z67k8DEoGsnAMWd/mBGINeL0U80srE8dIMc+iGehtulpzhTSClyeB6sf1x/j
         /BMGlhCUeTBGjHaC+z+ouP85R8MF99Ko0jfi1+OeVETrQ3ozHFFPx2PFD//F69HHym85
         M0YHPWnr1rqf8rCfoiluBeIoTWhlLiNsl0TlMxhByH/OCUJRDxflBd5yZfrSlXzcWJ1o
         78h1aXQ7XEGLuK4g3t6i1OqB9ZfWrcEwi9V2bUfqHVvtP4Qm8k9Ig4ElzoClae9Q+3id
         SkIujLdwXuRdmdzUVNDD1OS2x/JBqFnCeSMVR7seEehKhEBQwXECtQOOqmshm9KaRUSe
         aknQ==
X-Gm-Message-State: APjAAAVublP4eWZGG0mNpifiSyDKt6inrmps6yUSDQz5wEMo2OYVdC26
	QFxvw9ZdwrOdcWTt7Bqfq3GCKQB4xRi9o8ZLtSfd9nWdyFnP2LOTT+/ZFRaiIQ3zLqlle+rik3d
	JBvDJqye0wOtUN9/xms0Z79kYTlnAv6K5JQjXnypoatxo3CzcNx6l43c1+ALyY3OOxA==
X-Received: by 2002:a63:7150:: with SMTP id b16mr56909936pgn.83.1554209268082;
        Tue, 02 Apr 2019 05:47:48 -0700 (PDT)
X-Received: by 2002:a63:7150:: with SMTP id b16mr56909847pgn.83.1554209266963;
        Tue, 02 Apr 2019 05:47:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554209266; cv=none;
        d=google.com; s=arc-20160816;
        b=yayH4rZGc+euooUaEfBoAhE57pKhMIMOCsJncZAZzOByNlY6zCS4xTjh40Mp50/jSQ
         gJUQhiOzlSgGdb0K2VOT5Dt0944ff4hxkz2pBOi1Y84ypJhvaTmpCTIDLSCi0UrVjFZr
         qcaC3HOlH3eqXGC8RwqAQil/ee551qVYXZ02wsBiWFUM5OAzY/Wp262KJOAB4XtpR8aG
         DOifc/O4fcVxu9ykS1pmtY2xTL3aaRqAIir4kv6DGDr+JowfOJCZVRECylay16pHnIi3
         6HLuSO7uF4NtTOp2XcWmJaByDHdaKHkx2xjPRbyK0WCW5NQ2ohoG+E6YW/aeOefzz8yd
         26JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=u3PSOHs4we7+LgIG6ZQZir4Fy57VqCCMcbhzYXQWknQ=;
        b=ZY2JNs2x6OZGmYHGvkLLvqhMrTrAI51Owtd7q6szgPBeY1dWhNfdJsgUXchH+u6IOS
         fkDSz10UaB2qKj5GN03S1WADoCcQOaB/f7lOTi2u2eLVsSZEJrrnnRhDK0xP4VYvqSni
         zbrEct23qZmcozWkRXI8RxUWGKhvi00VKzwY3CebiyAYCtriQt8a1yszE3YCYipiFT+0
         MIHbo38dyqcWmGuOE9Uv0OM9YrZl+PWVv2KSCDLhoW1ZAavO5CYGwSJpwZqWlrLFgKJP
         dgb+BIiO04+tcO60IZSGBKJkUeIJJSIqdXVS7Dw/PZ8B9ZcgRfkMUyja9n1BPMenAlMz
         4uFw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RvtPBpLv;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a15sor13898275pgw.83.2019.04.02.05.47.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 05:47:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RvtPBpLv;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=u3PSOHs4we7+LgIG6ZQZir4Fy57VqCCMcbhzYXQWknQ=;
        b=RvtPBpLvPglDtwnPF4yXUeK5oDlzVoAw9Ac/QiLLKSGbikn9e6229p73Q0tOoviq2D
         BavSCer7Dzqe0/C31mrVK/886gbUDYWuPnxHOlht2sOu/e62noERB05hR+v+Bbj+JICn
         Lb7g/8TOjfYKi5cKqi9tDj/4Gjl0w7oFGi+cz1GXwEAzmc5l0cphMO74o+wu5S8JjZik
         7AqeS2RJ0S+0J5+xNSxMiTjPOKYRkB2DaefRCT/WCl4ZMTNyy1aYXf9qwji/GQQh7uA6
         a4SkVWVDmZ28lLA5h47JmaNF3G6jNLy7QP3Ylvcw6DiwtS/xNNeagblhaZ/cgn7jvFfX
         OA/w==
X-Google-Smtp-Source: APXvYqwSO12tw5fRix4o6PstoDzeaM5ZQf6IJ2XlmsbVCqK/ZDPoD7HrCoDXID/J7Vmm+PM48eFxdwxASU4WIrz1GI4=
X-Received: by 2002:a65:6496:: with SMTP id e22mr52163844pgv.249.1554209265963;
 Tue, 02 Apr 2019 05:47:45 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <44ad2d0c55dbad449edac23ae46d151a04102a1d.1553093421.git.andreyknvl@google.com>
 <20190322114357.GC13384@arrakis.emea.arm.com> <CAAeHK+xE-ywfpVHRhBJVGiqOe0+BYW9awUa10ZP4P6Ggc8nxMg@mail.gmail.com>
 <20190328141934.38960af0@gandalf.local.home> <20190329103039.GA44339@arrakis.emea.arm.com>
In-Reply-To: <20190329103039.GA44339@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 2 Apr 2019 14:47:34 +0200
Message-ID: <CAAeHK+xe-zWn8WpCxUxBB2tXL8oiLkshkPi1J3Ly87mACaA4-A@mail.gmail.com>
Subject: Re: [PATCH v13 04/20] mm, arm64: untag user pointers passed to memory syscalls
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Kees Cook <keescook@chromium.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Eric Dumazet <edumazet@google.com>, 
	"David S. Miller" <davem@davemloft.net>, Alexei Starovoitov <ast@kernel.org>, 
	Daniel Borkmann <daniel@iogearbox.net>, Peter Zijlstra <peterz@infradead.org>, 
	Arnaldo Carvalho de Melo <acme@kernel.org>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 11:30 AM Catalin Marinas
<catalin.marinas@arm.com> wrote:
>
> (I trimmed down the cc list a bit since it's always bouncing)
>
> On Thu, Mar 28, 2019 at 02:19:34PM -0400, Steven Rostedt wrote:
> > On Thu, 28 Mar 2019 19:10:07 +0100
> > Andrey Konovalov <andreyknvl@google.com> wrote:
> >
> > > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > > > ---
> > > > >  ipc/shm.c      | 2 ++
> > > > >  mm/madvise.c   | 2 ++
> > > > >  mm/mempolicy.c | 5 +++++
> > > > >  mm/migrate.c   | 1 +
> > > > >  mm/mincore.c   | 2 ++
> > > > >  mm/mlock.c     | 5 +++++
> > > > >  mm/mmap.c      | 7 +++++++
> > > > >  mm/mprotect.c  | 1 +
> > > > >  mm/mremap.c    | 2 ++
> > > > >  mm/msync.c     | 2 ++
> > > > >  10 files changed, 29 insertions(+)
> > > >
> > > > I wonder whether it's better to keep these as wrappers in the arm64
> > > > code.
> > >
> > > I don't think I understand what you propose, could you elaborate?
> >
> > I believe Catalin is saying that instead of placing things like:
> >
> > @@ -1593,6 +1593,7 @@ SYSCALL_DEFINE3(shmat, int, shmid, char __user *, shmaddr, int, shmflg)
> >       unsigned long ret;
> >       long err;
> >
> > +     shmaddr = untagged_addr(shmaddr);
> >
> > To instead have the shmaddr set to the untagged_addr() before calling
> > the system call, and passing the untagged addr to the system call, as
> > that goes through the arm64 architecture specific code first.
>
> Indeed. For example, we already have a SYSCALL_DEFINE6(mmap, ...) in
> arch/arm64/kernel/sys.c, just add the untagging there. We could do
> something similar for the other syscalls. I don't mind doing this in the
> generic code but if it's only needed for arm64, I'd rather keep the
> generic changes to a minimum.

Do I understand correctly, that I'll need to add ksys_ wrappers for
each of the memory syscalls, and then redefine them in
arch/arm64/kernel/sys.c with arm64_ prefix, like it is done for the
personality syscall right now? This will require generic changes as
well.

>
> (I had a hack overriding __SC_CAST to do this automatically for pointer
> arguments but this wouldn't work on mmap() and friends as the argument
> is unsigned long)
>
> --
> Catalin

