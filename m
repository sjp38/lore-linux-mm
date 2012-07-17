Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 9EA2A6B0062
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 12:52:54 -0400 (EDT)
Message-ID: <1342543971.2539.18.camel@lorien2>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
From: Shuah Khan <shuah.khan@hp.com>
Reply-To: shuah.khan@hp.com
Date: Tue, 17 Jul 2012 10:52:51 -0600
In-Reply-To: <CAOJsxLECr7yj9cMs4oUJQjkjZe9x-6mvk76ArGsQzRWBi8_wVw@mail.gmail.com>
References: <1342221125.17464.8.camel@lorien2>
	 <alpine.DEB.2.00.1207140216040.20297@chino.kir.corp.google.com>
	 <CAOJsxLE3dDd01WaAp5UAHRb0AiXn_s43M=Gg4TgXzRji_HffEQ@mail.gmail.com>
	 <1342407840.3190.5.camel@lorien2>
	 <alpine.DEB.2.00.1207160257420.11472@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1207160915470.28952@router.home>
	 <alpine.DEB.2.00.1207161253240.29012@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1207161506390.32319@router.home>
	 <alpine.DEB.2.00.1207161642420.18232@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1207170929290.13599@router.home>
	 <CAOJsxLECr7yj9cMs4oUJQjkjZe9x-6mvk76ArGsQzRWBi8_wVw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, glommer@parallels.com, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shuahkhan@gmail.com

On Tue, 2012-07-17 at 17:46 +0300, Pekka Enberg wrote:
> On Mon, 16 Jul 2012, David Rientjes wrote:
> >> > The kernel cannot check everything and will blow up in unexpected ways if
> >> > someone codes something stupid. There are numerous debugging options that
> >> > need to be switched on to get better debugging information to investigate
> >> > deper. Adding special code to replicate these checks is bad.
> >>
> >> Disagree, CONFIG_SLAB does not blow up for a NULL name string and just
> >> corrupts userspace.
> 
> On Tue, Jul 17, 2012 at 5:36 PM, Christoph Lameter <cl@linux.com> wrote:
> > Ohh.. So far we only had science fiction. Now kernel fiction.... If you
> > could corrupt userspace using sysfs with a NULL string then you'd first
> > need to fix sysfs support.
> >
> > And if you really want to be totally safe then I guess you need to audit
> > the kernel and make sure that every core kernel function that takes a
> > string argument does check for it to be NULL just in case.
> 
> Well, even SLUB checks for !name in mainline so that's definitely
> worth including unconditionally. Furthermore, the size related checks
> certainly make sense and I don't see any harm in having them as well.
> 
> As for "in_interrupt()", I really don't see the point in keeping that
> around. We could push it down to mm/slab.c in "__kmem_cache_create()"
> if we wanted to.

Is it safe to hold slab_mutex when in interrupt context? Pushing
in_interrupt() check down to "__kmem_cache_create()" would mean, this
check is done while holding slab_mutex. If it is not safe to be in
interrupt context, then it would a bit late to do the check?

Also all of these checks (as I see it) will allow kmem_cache_create() to
fail gracefully. I understand that kernel doesn't do this type checking
consistently, guess that is larger scope issue. Does it make sense to do
these checks in this particular case?

I am working on two different restructuring options:

1. Move all of the debug code and the regular code into
kmem_cache_create_debug() which is called from kmem_cache_create() in
ifdef CONFIG_DEBUG block and push the regular code into #else case.

I don't like this a whole lot because of the duplication of normal code
path. However, this seems to be better than the second alternative,
because of the complexity involved in taking code paths based on where
the sanity checks failed.

2. Move just the debug code block that does sanity checks on slab_caches
list and have it return failure which will result in the 

       mutex_unlock(&slab_mutex);
        put_online_cpus();

        if (!s && (flags & SLAB_PANIC))
                panic("kmem_cache_create: Failed to create slab '%s'\n",
name):

get executed from the regular code path. I like this option because it
there is no duplication of regular code. However, if for any reason
debug code changes and results conditional code paths taken after
return, it will get very complex.

Any thoughts, should I send RFC patches so we can discuss the code.


-- Shuah

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
