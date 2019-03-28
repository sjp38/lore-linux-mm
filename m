Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91095C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 18:10:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40EB72082F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 18:10:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WimfdOXD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40EB72082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F264B6B0269; Thu, 28 Mar 2019 14:10:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EAEFC6B026A; Thu, 28 Mar 2019 14:10:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9DFD6B026B; Thu, 28 Mar 2019 14:10:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA696B0269
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:10:20 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i23so16962936pfa.0
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:10:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=nzxjSg31IMgfFUQ8l0HID0xVlMev5O9yi4i0vq5xZ1A=;
        b=btk4JI3p4oyehAnxV3nrz4y18xeaoPx/50vkkoMvLti50Uhrlik70b/UTVqDq7xDdv
         NStkIDEBL2OgwVmz9a2ZHv1x+Bnz/xJZOsxuTCmE7d7ADXALQvloF4PuVwif7qz+1f2n
         vNXuE1jxpU/z3J7+UjgTTC7mjMZ/7BTS8tYnMtOUo/twbpa/6R9ijITKNLCUH8xW2d1Z
         b2NwK458EKOjH2b+JjJP4X5T7KHB/gYndVMH48qDgThPOeRD8qwAbdC/anw6SXldbA40
         AcI88fR0Yznw57WBann+H+wmy1T1r5BL0Vz2cPWVY1r8k7q/QZLrjRYjIUbYHVsEI2kj
         XTkQ==
X-Gm-Message-State: APjAAAXKpvDfQy+HumsTSphz1VdagMhTZK1oK5wL/+u7hX0DsBsE3iSo
	77U3/zPpicJGp+NWZ1FDGgnOPOmJTahKJN/VIjyGGE6qnUSHY9Tciea1/y0PhQs6KeGqU1EkLsL
	yw0pMHfiCCV4cYUFziseOFxZqeZ1q+F+dsWAW7+mGPf6j24p+VwmWW7g5y4XeOuOndg==
X-Received: by 2002:a63:4616:: with SMTP id t22mr40439359pga.217.1553796620319;
        Thu, 28 Mar 2019 11:10:20 -0700 (PDT)
X-Received: by 2002:a63:4616:: with SMTP id t22mr40439300pga.217.1553796619641;
        Thu, 28 Mar 2019 11:10:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553796619; cv=none;
        d=google.com; s=arc-20160816;
        b=Fg3+xmKLpDvSl3Yj8nsKKam8krzqwuPDfvjqPZ+bacm/XTc/k5hb5yc/R2NgaBD+9a
         thQr4woOjDXd+vysRXqOGe2+e0JC/NK16oPwKydE+0s3VZ8HJj7ig7VR6nxjAtb5/Cro
         rGThnTlV7mrSeGTlvdcA1/JxLc/l/2ueXzW4z92Eh4yQ1PbAMR+AlXnTObSmZfE9u/FC
         c03XD8tX4/gMMg17VCUcOJzI3AvYmg5DR0qBrOG9MGAyhsrBeP7ZAsi7JBz39jdLd1/Z
         8vEC16cMq2CaBwbkeY4fBkcAFYiYT1wHE97cxEbHpOktrOO47TcXHUSzXmp2S4q3BqGv
         yCOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=nzxjSg31IMgfFUQ8l0HID0xVlMev5O9yi4i0vq5xZ1A=;
        b=S7s5YsQFb1DVx7vQYqiRPCuuA2ZbTp10K5Ub4QZ8nkh8NbdQ+nbzAzYJQrVP3sXMcD
         z7SJHXjNLHe8SNu+4oy024f5eErHmeOLfgkq7vT0YF/FHdmht4Mm61bW0NieGmQ1kSSc
         BTj9ImFK22gnVT8pANKiVR5fFyVVTF6RsAhzt3uGbZFMitLas8WpJd8RcwMuT7Z/Zm3f
         Yq7TcSy40GIHzqdn5yMO2ToOUqBWx3oxIY3qJ7fP0v/lsBNGbHSRirTFlR9KkfKXPZWv
         UKaOpX/QX4Y2rw3B86JQ9319DgZAs+7KKo6E6PD7482pGOa2zZ8lSFrrHTsOQ+GxXoXv
         Xr4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WimfdOXD;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h82sor6113965pfd.0.2019.03.28.11.10.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Mar 2019 11:10:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WimfdOXD;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nzxjSg31IMgfFUQ8l0HID0xVlMev5O9yi4i0vq5xZ1A=;
        b=WimfdOXDpmaShGSBMcQLuKB53BkH6tzB8hJJY80McjiVMc24UhiE53emJHH9ruAnXP
         qITkYAFGoYPtrEdPvLLeHbds9C08ASJTWOwCi8Rknp1u/0cYiwDJvI+7ty2h8j8O2QAG
         SLpxbBGDCPNE233aCSkj5k046fv8+CH2DZQc9qlPJKgMXn0IRrUJFQQl3K1Zqaa3glct
         1ZOkO8hIRPAh9zngper4MvoJ3IlW/GQr2SNDX4URyY4m5R+IwIAXgy7WbisxiLi+xUxz
         36ZgPHzATOwPgngNtLBoAR5C8WJ1PCgUL23vn0K/mS5S5GTpyXavJjsC1/pJ2a10QRJz
         gryg==
X-Google-Smtp-Source: APXvYqwVzwa7Yi2B6AwxYRYIoL9rm6INemnW30MlbEQDwJJ+Fva2F45mc9/WPibU0ilc1KkOXtX/gNq2lbuJJez5/QY=
X-Received: by 2002:a62:e816:: with SMTP id c22mr13322308pfi.54.1553796618481;
 Thu, 28 Mar 2019 11:10:18 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <44ad2d0c55dbad449edac23ae46d151a04102a1d.1553093421.git.andreyknvl@google.com>
 <20190322114357.GC13384@arrakis.emea.arm.com>
In-Reply-To: <20190322114357.GC13384@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Thu, 28 Mar 2019 19:10:07 +0100
Message-ID: <CAAeHK+xE-ywfpVHRhBJVGiqOe0+BYW9awUa10ZP4P6Ggc8nxMg@mail.gmail.com>
Subject: Re: [PATCH v13 04/20] mm, arm64: untag user pointers passed to memory syscalls
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

On Fri, Mar 22, 2019 at 12:44 PM Catalin Marinas
<catalin.marinas@arm.com> wrote:
>
> On Wed, Mar 20, 2019 at 03:51:18PM +0100, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > This patch allows tagged pointers to be passed to the following memory
> > syscalls: madvise, mbind, get_mempolicy, mincore, mlock, mlock2, brk,
> > mmap_pgoff, old_mmap, munmap, remap_file_pages, mprotect, pkey_mprotect,
> > mremap, msync and shmdt.
> >
> > This is done by untagging pointers passed to these syscalls in the
> > prologues of their handlers.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  ipc/shm.c      | 2 ++
> >  mm/madvise.c   | 2 ++
> >  mm/mempolicy.c | 5 +++++
> >  mm/migrate.c   | 1 +
> >  mm/mincore.c   | 2 ++
> >  mm/mlock.c     | 5 +++++
> >  mm/mmap.c      | 7 +++++++
> >  mm/mprotect.c  | 1 +
> >  mm/mremap.c    | 2 ++
> >  mm/msync.c     | 2 ++
> >  10 files changed, 29 insertions(+)
>
> I wonder whether it's better to keep these as wrappers in the arm64
> code.

I don't think I understand what you propose, could you elaborate?

