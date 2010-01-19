Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id BCD556001DA
	for <linux-mm@kvack.org>; Tue, 19 Jan 2010 02:17:47 -0500 (EST)
Date: Tue, 19 Jan 2010 09:17:34 +0200
From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [PATCH v6] add MAP_UNLOCKED mmap flag
Message-ID: <20100119071734.GG14345@redhat.com>
References: <20100118133755.GG30698@redhat.com>
 <84144f021001180609r4d7fbbd0p972d5bc0e227d09a@mail.gmail.com>
 <20100118141938.GI30698@redhat.com>
 <84144f021001180805q4d1203b8qab8ccb1de87b2866@mail.gmail.com>
 <20100118170816.GA22111@redhat.com>
 <84144f021001181009m52f7eaebp2bd746f92de08da9@mail.gmail.com>
 <20100118181942.GD22111@redhat.com>
 <20100118191031.0088f49a@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100118191031.0088f49a@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, akpm@linux-foundation.org, andrew.c.morrow@gmail.com, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 18, 2010 at 07:10:31PM +0000, Alan Cox wrote:
> > I can't realistically chase every address space mapping changes and mlock
> > new areas. The only way other then mlockall() is to use custom memory
> > allocator that allocates mlocked memory.
> 
> Which keeps all the special cases in your app rather than in every single
> users kernel. That seems to be the right way up, especially as you can
> make a library of it !
> 
Are you advocating rewriting mlockall() in userspace? It may be possible,
but will require rewriting half of libc. Everything that changes process
address space should support mlocking (memory allocation functions, dynamic
loading, strdup). Allocations can be done only with mmap() since brk()
can allocate mlocked memory atomically. And of course if third party library
uses mmap syscall directly instead of using libc one you are SOL. Been
there already, worked on project that replaced libc memory allocations functions
because it had to track when memory is returned to OS, not just internal
libc pool (MPI). This is pain in the arse and on top of that it doesn't work
reliably. Some things are better be done on OS level.

The thread took a direction of bashing mlockall(). This is especially
strange since proposed patch actually makes mlockall() more fine
grained and thus more useful.

--
			Gleb.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
