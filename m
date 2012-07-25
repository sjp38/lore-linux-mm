Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 5DE686B004D
	for <linux-mm@kvack.org>; Wed, 25 Jul 2012 11:28:35 -0400 (EDT)
Date: Wed, 25 Jul 2012 10:28:31 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH TRIVIAL] mm: Fix build warning in kmem_cache_create()
In-Reply-To: <500CF782.4060407@parallels.com>
Message-ID: <alpine.DEB.2.00.1207251024260.32678@router.home>
References: <1342221125.17464.8.camel@lorien2> <alpine.DEB.2.00.1207140216040.20297@chino.kir.corp.google.com> <CAOJsxLE3dDd01WaAp5UAHRb0AiXn_s43M=Gg4TgXzRji_HffEQ@mail.gmail.com> <1342407840.3190.5.camel@lorien2> <alpine.DEB.2.00.1207160257420.11472@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1207160915470.28952@router.home> <alpine.DEB.2.00.1207161253240.29012@chino.kir.corp.google.com> <alpine.DEB.2.00.1207161506390.32319@router.home> <alpine.DEB.2.00.1207161642420.18232@chino.kir.corp.google.com> <alpine.DEB.2.00.1207170929290.13599@router.home>
 <CAOJsxLECr7yj9cMs4oUJQjkjZe9x-6mvk76ArGsQzRWBi8_wVw@mail.gmail.com> <alpine.DEB.2.00.1207171005550.15061@router.home> <500CF782.4060407@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Shuah Khan <shuah.khan@hp.com>, js1304@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, shuahkhan@gmail.com

On Mon, 23 Jul 2012, Glauber Costa wrote:

> >> worth including unconditionally. Furthermore, the size related checks
> >> certainly make sense and I don't see any harm in having them as well.
> >
> > There is a WARN_ON() there and then it returns NULL!!! Crazy. Causes a
> > NULL pointer dereference later in the caller?
> >
>
> It obviously depends on the caller.

This is a violation of the calling convention to say the least. This means
if you have SLAB_PANIC set and accidentally set the name to NULL the
function will return despite the error and not panic!

> Although most of the calls to kmem_cache_create are made from static
> data, we can't assume that. Of course whoever is using static data
> should do those very same tests from the outside to be safe, but in case
> they do not, this seems to fall in the category of things that make
> debugging easier - even if we later on get to a NULL pointer dereference.
>
> Your mentioned bias towards minimum code size, however, is totally
> valid, IMHO. But I doubt those checks would introduce a huge footprint.
> I would imagine you being much more concerned about being able to wipe
> out entire subsystems like memcg, which will give you a lot more.

They are useless checks since any use of the name will also cause a NULL
pointer dereference. Same is true for interrupt checks. Checks like that
indicate a deterioration of the code base. People are afraid that
something goes wrong because they no longer understand the code so they
build a embroidery around it instead of relying on the already existing
checks at vital places. The embroidery can be useful for debugging thats
why I left it in for the CONFIG_DEBUG_VM but certainly should not be
included in production kernels.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
