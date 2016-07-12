Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E2AEC6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:14:27 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id c52so31992399qte.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:14:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 49si1847096qtm.41.2016.07.12.07.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 07:14:27 -0700 (PDT)
Date: Tue, 12 Jul 2016 16:14:46 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCHv2 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
Message-ID: <20160712141446.GB28837@redhat.com>
References: <20160629105736.15017-1-dsafonov@virtuozzo.com> <20160629105736.15017-4-dsafonov@virtuozzo.com> <CALCETrW+xWp-xVDjOyPkB5P3-zAubt4U65R4tVNsY34+406tTg@mail.gmail.com> <b451bdf2-3ce9-dc86-6f9c-fe3bd665d1d8@virtuozzo.com> <CALCETrUEP-q-Be1i=L7hxX-nf4OpBv7edq2Mg0gi5TRX73FTsA@mail.gmail.com> <20160711182654.GA19160@redhat.com> <CALCETrVaO_E923KY2bKGfG1tH75JBtEns4nKc+GWsYAx9NT0hQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVaO_E923KY2bKGfG1tH75JBtEns4nKc+GWsYAx9NT0hQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dmitry Safonov <dsafonov@virtuozzo.com>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Safonov <0x7f454c46@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, xemul@virtuozzo.com, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>

On 07/11, Andy Lutomirski wrote:
>
> On Mon, Jul 11, 2016 at 11:26 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> >
> > Do we really care? I mean, the kernel can't crash or something like this,
> > just the old vdso mapping can faultin the "wrong" page from the new
> > vdso_image, right?
>
> That makes me nervous.  IMO a mapping should have well-defined
> semantics.

Perhaps. but map_vdso() will be special anyway, it also changes ->vdso.

For example, if a 32-bit application calls prctl(ARCH_MAP_VDSO) from a
signal handler and we unmap the old vdso mapping, it will crash later
trying to call the (unmapped) restorer == kernel_rt_sigreturn.

> If nothing else, could be really messy if the list of
> pages were wrong.

I do not see anything really wrong, but I can easily miss something.

And don't get me wrong, I agree that any cleanup (say, associate vdso
image with vma) makes sense.

> My real concern is DoS: I doubt that __install_special_mapping gets
> all the accounting right.

Yes, and if it was not clear I fully agree. Even if we forget about the
accounting, I feel that special mappings must not be abused by userspace.

> > So it seems that we should do this by hand somehow. But in fact, what
> > I actually think right now is that I am totally confused and got lost ;)
>
> I'm starting to wonder if we should finally suck it up and give
> special mappings a non-NULL vm_file so we can track them properly.
> Oleg, weren't you thinking of doing that for some other reason?

Yes, uprobes. Currently we can't probe vdso page(s).

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
