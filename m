Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 49E106B0292
	for <linux-mm@kvack.org>; Wed, 24 May 2017 16:36:24 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y65so204005960pff.13
        for <linux-mm@kvack.org>; Wed, 24 May 2017 13:36:24 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a71sor634504pfc.50.2017.05.24.13.36.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 May 2017 13:36:23 -0700 (PDT)
Date: Wed, 24 May 2017 13:36:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm/slub: Only define kmalloc_large_node_hook() for
 NUMA systems
In-Reply-To: <20170523165608.GN141096@google.com>
Message-ID: <alpine.DEB.2.10.1705241326200.49680@chino.kir.corp.google.com>
References: <20170519210036.146880-1-mka@chromium.org> <20170519210036.146880-2-mka@chromium.org> <alpine.DEB.2.10.1705221338100.30407@chino.kir.corp.google.com> <20170522205621.GL141096@google.com> <20170522144501.2d02b5799e07167dc5aecf3e@linux-foundation.org>
 <alpine.DEB.2.10.1705221834440.13805@chino.kir.corp.google.com> <20170523165608.GN141096@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Kaehlcke <mka@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Douglas Anderson <dianders@chromium.org>

On Tue, 23 May 2017, Matthias Kaehlcke wrote:

> > diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
> > index de179993e039..e1895ce6fa1b 100644
> > --- a/include/linux/compiler-clang.h
> > +++ b/include/linux/compiler-clang.h
> > @@ -15,3 +15,8 @@
> >   * with any version that can compile the kernel
> >   */
> >  #define __UNIQUE_ID(prefix) __PASTE(__PASTE(__UNIQUE_ID_, prefix), __COUNTER__)
> > +
> > +#ifdef inline
> > +#undef inline
> > +#define inline __attribute__((unused))
> > +#endif
> 
> Thanks for the suggestion!
> 
> Nothing breaks and the warnings are silenced. It seems we could use
> this if there is a stong opposition against having warnings on unused
> static inline functions in .c files.
> 

It would be slightly different, it would be:

#define inline inline __attribute__((unused))

to still inline the functions, I was just seeing if there was anything 
else that clang was warning about that was unrelated to a function's 
inlining.

> Still I am not convinced that gcc's behavior is preferable in this
> case. True, it saves us from adding a bunch of __maybe_unused or
> #ifdefs, on the other hand the warning is a useful tool to spot truly
> unused code. So far about 50% of the warnings I looked into fall into
> this category.
> 

I think gcc's behavior is a result of how it does preprocessing and is a 
clearly defined and long-standing semantic given in the gcc manual 
regarding -Wunused-function.

#define IS_PAGE_ALIGNED(__size)	(!(__size & ((size_t)PAGE_SIZE - 1)))
static inline int is_page_aligned(size_t size)
{
	return !(size & ((size_t)PAGE_SIZE - 1));
}

Gcc will not warn about either of these being unused, regardless of -Wall, 
-Wunused-function, or -pedantic.  Clang, correct me if I'm wrong, will 
only warn about is_page_aligned().

So the argument could be made that one of the additional benefits of 
static inline functions is that a subset of compilers, heavily in the 
minority, will detect whether it's unused and we'll get patches that 
remove them.  Functionally, it would only result in LOC reduction.  But, 
isn't adding #ifdef's to silence the warning just adding more LOC?

I have no preference either way, I think it would be up to the person who 
is maintaining the code and has to deal with the patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
