Received: from toip4.srvr.bell.ca ([209.226.175.87])
          by tomts43-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20071204200559.ZBDB26794.tomts43-srv.bellnexxia.net@toip4.srvr.bell.ca>
          for <linux-mm@kvack.org>; Tue, 4 Dec 2007 15:05:59 -0500
Date: Tue, 4 Dec 2007 15:05:58 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [RFC PATCH] LTTng instrumentation mm (updated)
Message-ID: <20071204200558.GB1988@Krystal>
References: <20071129023421.GA711@Krystal> <1196317552.18851.47.camel@localhost> <20071130161155.GA29634@Krystal> <1196444801.18851.127.camel@localhost> <20071130170516.GA31586@Krystal> <1196448122.19681.16.camel@localhost> <20071130191006.GB3955@Krystal> <y0mve7ez2y3.fsf@ton.toronto.redhat.com> <20071204192537.GC31752@Krystal> <1196797259.6073.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <1196797259.6073.17.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: "Frank Ch. Eigler" <fche@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

* Dave Hansen (haveblue@us.ibm.com) wrote:
> On Tue, 2007-12-04 at 14:25 -0500, Mathieu Desnoyers wrote:
> > 
> > - I also dump the equivalent of /proc/swaps (with kernel internal
> >   information) at trace start to know what swap files are currently
> >   used.
> 
> What about just enhancing /proc/swaps so that this information can be
> useful to people other than those doing traces?
> 

It includes an in-kernel struct file pointer, exporting it to userspace
would be somewhat ugly.

> Now that we have /proc/$pid/pagemap, we expose some of the same
> information about which userspace virtual addresses are stored where and
> in which swapfile.  
> 

The problems with /proc :

- It exports all the data in formatted text. What I need for my traces
  is pure binary, compact representation.
- It's not very neat to export in-kernel pointer information like a
  kernel tracer would need.
- The locking is very often wrong. I started correcting /proc/modules a
  while ago, but I fear there are quite a few cases where a procfile
  reader could release the locks between two consecutive reads of the
  same list and therefore cause missing information or corruption. While
  being manageable for a proc text file, this is _highly_ unwanted in a
  trace. See my previous "seq file sorted" and "module.c sort module
  list" patches about this. My tracer deals with addition/removal of
  elements to a list between dumps done by "chunks" by tracing the
  modifications done to the list at the same time. However, /proc seq
  files will just get corrupted or forget about an element not touched
  by the modification, which my tracer cannot cope with.

Mathieu


> -- Dave
> 

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
