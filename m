Subject: Re: MM patches against 2.5.31
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <3D699343.D5343AD4@zip.com.au>
References: <3D698F4E.93A3DDA2@zip.com.au>
	<17830228.1030302537@[10.10.2.3]>  <3D699343.D5343AD4@zip.com.au>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 25 Aug 2002 21:06:20 -0600
Message-Id: <1030331182.16525.16.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 2002-08-25 at 20:32, Andrew Morton wrote:
> "Martin J. Bligh" wrote:
> > 
> > >> > kjournald: page allocation failure. order:0, mode:0x0
> > >>
> > >> I've seen this before, but am curious how we ever passed
> > >> a gfpmask (aka mode) of 0 to __alloc_pages? Can't see anywhere
> > >> that does this?
> > >
> > > Could be anywhere, really.  A network interrupt doing GFP_ATOMIC
> > > while kjournald is executing.  A radix-tree node allocation
> > > on the add-to-swap path perhaps.  (The swapout failure messages
> > > aren't supposed to come out, but mempool_alloc() stomps on the
> > > caller's setting of PF_NOWARN.)
> > >
> > > Or:
> > >
> > > mnm:/usr/src/25> grep -r GFP_ATOMIC drivers/scsi/*.c | wc -l
> > >      89
> > 
> > No, GFP_ATOMIC is not 0:
> > 
> 
> It's mempool_alloc(GFP_NOIO) or such.  mempool_alloc() strips
> __GFP_WAIT|__GFP_IO on the first attempt.
> 
> It also disables the printk, so maybe I just dunno ;)  show_stack()
> would tell.
>
 
The "kjournald: page allocation failure. order:0, mode:0x0" message and
"pdflush: page allocation failure. order:0, mode:0x0" occurred only once
each on my dual p3 scsi ext3 test box running 2.5.31-mm1.  So, I added
something like this:
--- page_alloc.c.orig	Thu Aug 22 17:27:32 2002
+++ page_alloc.c	Thu Aug 22 17:29:24 2002
@@ -388,6 +388,8 @@
 			printk("%s: page allocation failure."
 				" order:%d, mode:0x%x\n",
 				current->comm, order, gfp_mask);
+			if (gfp_mask == 0)
+				BUG();
 		}
 		return NULL;
 	}

and continued testing on Friday with no repeats of the "page allocation failure"
messages.  I obtained a second dual p3 ext3 test box (ide this time) and left both
boxes running 2.5.31-mm1 and the dbench 1..128 stress test scripted to rerun many 
times over the weekend.  Due to a couple of firewalls, I can't look at those boxes
from here, but I'll let you know what happened in about 10 to 11 hours.

Cheers,
Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
