Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8AE536B006A
	for <linux-mm@kvack.org>; Mon, 18 Jan 2010 09:19:48 -0500 (EST)
Date: Mon, 18 Jan 2010 16:19:38 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100118141938.GI30698@redhat.com>
References: <20100118133755.GG30698@redhat.com>
 <84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 18, 2010 at 04:09:35PM +0200, Pekka Enberg wrote:
> Hi Gleb,
> 
> On Mon, Jan 18, 2010 at 3:37 PM, Gleb Natapov <gleb@redhat.com> wrote:
> > The current interaction between mlockall(MCL_FUTURE) and mmap has a
> > deficiency. In 'normal' mode, without MCL_FUTURE in force, the default
> > is that new memory mappings are not locked, but mmap provides MAP_LOCKED
> > specifically to override that default. However, with MCL_FUTURE toggled
> > to on, there is no analogous way to tell mmap to override the default. The
> > proposed MAP_UNLOCKED flag would resolve this deficiency.
> >
> > The benefit of the patch is that it makes it possible for an application
> > which has previously called mlockall(MCL_FUTURE) to selectively exempt
> > new memory mappings from memory locking, on a per-mmap-call basis. There
> > is currently no thread-safe way for an application to do this as
> > toggling MCL_FUTURE around calls to mmap is racy in a multi-threaded
> > context. Other threads may manipulate the address space during the
> > window where MCL_FUTURE is off, subverting the programmers intended
> > memory locking semantics.
> >
> > The ability to exempt specific memory mappings from memory locking is
> > necessary when the region to be mapped is larger than physical memory.
> > In such cases a call to mmap the region cannot succeed, unless
> > MAP_UNLOCKED is available.
> 
> The changelog doesn't mention what kind of applications would want to
> use this. Are there some? Using mlockall(MCL_FUTURE) but then having
> some memory regions MAP_UNLOCKED sounds like a strange combination to
> me.
The specific use cases were discussed in the thread following previous
version of the patch. I can describe my specific use case in a change log
and I can copy what Andrew said about his case, but is it really needed in
a commit message itself? It boils down to greater control over when and
where application can get major fault. There are applications that need
this kind of control. As of use of mlockall(MCL_FUTURE) how can I make
sure that all memory allocated behind my application's back (by dynamic
linker, libraries, stack) will be locked otherwise?


--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
