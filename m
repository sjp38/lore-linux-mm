Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 9FC2C6B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 11:11:59 -0400 (EDT)
Date: Tue, 17 Jul 2012 10:11:56 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
In-Reply-To: <CAOJsxLECr7yj9cMs4oUJQjkjZe9x-6mvk76ArGsQzRWBi8_wVw@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207171005550.15061@router.home>
References: <1342221125.17464.8.camel@lorien2> <alpine.DEB.2.00.1207140216040.20297@chino.kir.corp.google.com> <CAOJsxLE3dDd01WaAp5UAHRb0AiXn_s43M=Gg4TgXzRji_HffEQ@mail.gmail.com> <1342407840.3190.5.camel@lorien2> <alpine.DEB.2.00.1207160257420.11472@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1207160915470.28952@router.home> <alpine.DEB.2.00.1207161253240.29012@chino.kir.corp.google.com> <alpine.DEB.2.00.1207161506390.32319@router.home> <alpine.DEB.2.00.1207161642420.18232@chino.kir.corp.google.com> <alpine.DEB.2.00.1207170929290.13599@router.home>
 <CAOJsxLECr7yj9cMs4oUJQjkjZe9x-6mvk76ArGsQzRWBi8_wVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Shuah Khan <shuah.khan@hp.com>, glommer@parallels.com, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shuahkhan@gmail.com

On Tue, 17 Jul 2012, Pekka Enberg wrote:

> Well, even SLUB checks for !name in mainline so that's definitely
> worth including unconditionally. Furthermore, the size related checks
> certainly make sense and I don't see any harm in having them as well.

There is a WARN_ON() there and then it returns NULL!!! Crazy. Causes a
NULL pointer dereference later in the caller?

> As for "in_interrupt()", I really don't see the point in keeping that
> around. We could push it down to mm/slab.c in "__kmem_cache_create()"
> if we wanted to.

Ok we could do that but I guess we are in the discussion of how much
checking should be done for a production kernel.

I think these checks are way out of hand. We cannot afford to
consistently check parameters to all kernel functions in production. We
will only do these checks in a select manner if these values could
result in serious difficult to debug problems. The checks in slab look
like debugging code that someone needed for a specific debugging scenario.

I can understand that we would keep that in for development but not for
production. Maybe I am a bit biased but my prod kernels need to have
minimal memory footprint due to excessive code size causing regressions.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
