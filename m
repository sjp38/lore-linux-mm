Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id AF1DC6B0002
	for <linux-mm@kvack.org>; Mon, 22 Apr 2013 19:15:20 -0400 (EDT)
Message-ID: <1366672518.9609.142.camel@gandalf.local.home>
Subject: Re: [PATCH] slab: Remove unnecessary __builtin_constant_p()
From: Steven Rostedt <rostedt@goodmis.org>
Date: Mon, 22 Apr 2013 19:15:18 -0400
In-Reply-To: <20130422141621.384eb93a6a8f3d441cd1a991@linux-foundation.org>
References: <1366225776.8817.28.camel@pippen.local.home>
	 <alpine.DEB.2.02.1304171702380.24494@chino.kir.corp.google.com>
	 <20130422134415.32c7f2cac07c924bff3017a4@linux-foundation.org>
	 <1366664301.9609.140.camel@gandalf.local.home>
	 <20130422141621.384eb93a6a8f3d441cd1a991@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Behan Webster <behanw@converseincode.com>

On Mon, 2013-04-22 at 14:16 -0700, Andrew Morton wrote:
> On Mon, 22 Apr 2013 16:58:21 -0400 Steven Rostedt <rostedt@goodmis.org> wrote:

> > When looking into this, we found the only two users of the index_of()
> > static function that has this issue, passes in size_of(), which will
> > always be a constant, making the check redundant.
> 
> Looking at the current callers is cheating.  What happens if someone
> adds another caller which doesn't use sizeof?

Well, as it required a size of something, if it was dynamic then what
would the size be of?

> 
> > Note, this is a bug in Clang that will hopefully be fixed soon. But for
> > now, this strange redundant compile time check is preventing Clang from
> > even testing the Linux kernel build.
> > </little birdie voice>
> > 
> > And I still think the original change log has rational for the change,
> > as it does make it rather confusing to what is happening there.
> 
> The patch made index_of() weaker!
> 
> It's probably all a bit academic, given that linux-next does
> 
> -/*
> - * This function must be completely optimized away if a constant is passed to
> - * it.  Mostly the same as what is in linux/slab.h except it returns an index.
> - */
> -static __always_inline int index_of(const size_t size)
> -{
> -	extern void __bad_size(void);
> -
> -	if (__builtin_constant_p(size)) {
> -		int i = 0;
> -
> -#define CACHE(x) \
> -	if (size <=x) \
> -		return i; \
> -	else \
> -		i++;
> -#include <linux/kmalloc_sizes.h>
> -#undef CACHE
> -		__bad_size();
> -	} else
> -		__bad_size();
> -	return 0;
> -}
> -

Looks like someone just ate the bird.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
