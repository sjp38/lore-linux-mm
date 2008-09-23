Received: from toip3.srvr.bell.ca ([209.226.175.86])
          by tomts16-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080923181815.CVT1723.tomts16-srv.bellnexxia.net@toip3.srvr.bell.ca>
          for <linux-mm@kvack.org>; Tue, 23 Sep 2008 14:18:15 -0400
Date: Tue, 23 Sep 2008 14:13:13 -0400
From: Mathieu Desnoyers <compudj@krystal.dyndns.org>
Subject: Re: Unified tracing buffer
Message-ID: <20080923181313.GA4947@Krystal>
References: <33307c790809191433w246c0283l55a57c196664ce77@mail.gmail.com> <1221869279.8359.31.camel@lappy.programming.kicks-ass.net> <20080922140740.GB5279@in.ibm.com> <1222094724.16700.11.camel@lappy.programming.kicks-ass.net> <1222147545.6875.135.camel@charm-linux> <1222162270.16700.57.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <1222162270.16700.57.camel@lappy.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Tom Zanussi <zanussi@comcast.net>, prasad@linux.vnet.ibm.com, Martin Bligh <mbligh@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Steven Rostedt <rostedt@goodmis.org>, od@novell.com, "Frank Ch. Eigler" <fche@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, hch@lst.de, David Wilder <dwilder@us.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra (a.p.zijlstra@chello.nl) wrote:
> On Tue, 2008-09-23 at 00:25 -0500, Tom Zanussi wrote:
> 
> > - get rid of anything having to do with padding, nobody needs it and its
> > only affect has been to horribly distort and complicate a lot of the
> > code
> > - get rid of sub-buffers, they just cause confusion
> > - get rid of mmap, nobody uses it
> > - no sub-buffers and no mmap support means we can get rid of most of the
> > callbacks, and a lot of API confusion along with them
> > - add relay flags - they probably should have been used from the
> > beginning and options made explicit instead of being shoehorned into the
> > callback functions.
> 
>  - get rid of the vmap buffers as they cause tlb pressure and eat up
> precious vspace on 32 bit platforms.
> 

Although I agree on the basic idea, namely to use a sane amount of TLB
entries for tracing, I disagree on the way proposed to reach this goal.
Such memory management concerns belong to the mm field and should not be
done "oh so cleverly" by a buffer management infrastructure in the back
of the kernel memory management infrastructure.

I think we should instead try to figure out what is currently missing in
the kernel vmap mechanism (probably the ability to vmap from large 4MB
pages after boot), and fix _that_ instead (if possible), which would not
only benefit to tracing, but also to module support.

Also, I would like to keep a contiguous address mapping within buffers
so we could keep the buffer read/write code as simple as possible,
leveraging the existing CPU MM unit.

I added Christoph Lameter to the CC list, he always comes with clever
ideas. :)

Mathieu



-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
