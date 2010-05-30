Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 710706B01BD
	for <linux-mm@kvack.org>; Sat, 29 May 2010 23:43:39 -0400 (EDT)
Date: Sat, 29 May 2010 20:42:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Make kunmap_atomic() harder to misuse
Message-Id: <20100529204256.b92b1ff6.akpm@linux-foundation.org>
In-Reply-To: <1275043993-26557-1-git-send-email-cesarb@cesarb.net>
References: <1275043993-26557-1-git-send-email-cesarb@cesarb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Fri, 28 May 2010 07:53:13 -0300 Cesar Eduardo Barros <cesarb@cesarb.net> wrote:

> kunmap_atomic() is currently at level -4 on Rusty's "Hard To Misuse"
> list[1] ("Follow common convention and you'll get it wrong"), except in
> some architectures when CONFIG_DEBUG_HIGHMEM is set[2][3].
> 
> kunmap() takes a pointer to a struct page; kunmap_atomic(), however,
> takes takes a pointer to within the page itself. This seems to once in a
> while trip people up (the convention they are following is the one from
> kunmap()).
> 
> Make it much harder to misuse, by moving it to level 9 on Rusty's
> list[4] ("The compiler/linker won't let you get it wrong"). This is done
> by refusing to build if the pointer passed to it is convertible to a
> struct page * but it is not a void * (verified by trying to convert it
> to a pointer to a dummy struct).
> 
> The real kunmap_atomic() is renamed to kunmap_atomic_notypecheck()
> (which is what you would call in case for some strange reason calling it
> with a pointer to a struct page is not incorrect in your code).
> 

Fair enough, that's a 99% fix.  A long time ago I made kmap_atomic()
return a char * (iirc) and kunmap_atomic() is passed a char*.  It
worked, but I ended up throwing it away.  I don't precisely remember
why - I think it was intrusiveness and general hassle rather than
anything fundamental.

>
> ...
>
> +/* Prevent people trying to call kunmap_atomic() as if it were kunmap() */
> +struct __kunmap_atomic_dummy {};
> +#define kunmap_atomic(addr, idx) do { \
> +		BUILD_BUG_ON( \
> +			__builtin_types_compatible_p(typeof(addr), struct page *) && \
> +			!__builtin_types_compatible_p(typeof(addr), struct __kunmap_atomic_dummy *)); \
> +		kunmap_atomic_notypecheck((addr), (idx)); \
> +	} while (0)

<looks around>

OK, it seems that __builtin_types_compatible_p() is supported on all
approved gcc versions.

We have a little __same_type() helper for this.  __must_be_array()
should be using it, too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
