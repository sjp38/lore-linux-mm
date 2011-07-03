Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 07F266B0012
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 15:24:49 -0400 (EDT)
Received: by bwd14 with SMTP id 14so5403787bwd.14
        for <linux-mm@kvack.org>; Sun, 03 Jul 2011 12:24:46 -0700 (PDT)
Date: Sun, 3 Jul 2011 23:24:42 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [kernel-hardening] Re: [RFC v1] implement SL*B and stack
 usercopy runtime checks
Message-ID: <20110703192442.GA9504@albatros>
References: <20110703111028.GA2862@albatros>
 <CA+55aFzXEoTyK0Sm-y=6xGmLMWzQiSQ7ELJ2-WL_PrP3r44MSg@mail.gmail.com>
 <20110703185709.GA7414@albatros>
 <CA+55aFwuvk7xifqCX=E3DtV=JCJEzyODcF4o6xLL0U1N_P-Rbg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwuvk7xifqCX=E3DtV=JCJEzyODcF4o6xLL0U1N_P-Rbg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Sun, Jul 03, 2011 at 12:10 -0700, Linus Torvalds wrote:
> On Sun, Jul 3, 2011 at 11:57 AM, Vasiliy Kulikov <segoon@openwall.com> wrote:
> >> If you seriously clean it up (that at a minimum includes things like
> >> making it configurable using some pretty helper function that just
> >> compiles away for all the normal cases,
> >
> > Hm, it is not as simple as it looks at the first glance - even if the
> > object size is known at the compile time (__compiletime_object_size), it
> > might be a field of a structure, which crosses the slab object
> > boundaries because of an overflow.
> 
> No, I was more talking about having something like
> 
>   #ifdef CONFIG_EXPENSIVE_CHECK_USERCOPY
>   extern int check_user_copy(const void *kptr, unsigned long size);
>   #else
>   static inline int check_user_copy(const void *kptr, unsigned long size)
>   { return 0; }
>   #endif

Sure, will do.  This is what I mean by kernel_access_ok() as it is a
weak equivalent of access_ok(), check_user_copy() is a bit confusing
name IMO.


> so that the actual user-copy routines end up being clean and not have
> #ifdefs in them or any implementation details like what you check
> (stack, slab, page cache - whatever)
> 
> If you can also make it automatically not generate any code for cases
> that are somehow obviously safe, then that's an added bonus.

OK, then let's stop on "checks for overflows" and remove the check if
__compiletime_object_size() says something or length is constant.  It
should remove most of the checks in fast pathes.


> But my concern is that performance is a real issue, and the strict
> user-copy checking sounds like mostly a "let's enable this for testing
> kernels when chasing some particular issue" feature, the way
> DEBUG_PAGEALLOC is.

I will measure the perfomance penalty tomorrow.


Btw, if the perfomance will be acceptable, what do you think about
logging/reacting on the spotted overflows?


Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
