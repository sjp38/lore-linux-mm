Date: Fri, 19 May 2000 09:17:18 -0700
From: Brian Pomerantz <bapper@piratehaven.org>
Subject: Re: PATCH: Enhance queueing/scsi-midlayer to handle kiobufs. [Re: Request splits]
Message-ID: <20000519091718.A4083@skull.piratehaven.org>
References: <00c201bfc0d7$56664db0$4d0310ac@fairfax.datafocus.com> <200005181955.MAA71492@getafix.engr.sgi.com> <20000519160958.C9961@redhat.com> <20000519084842.A3373@skull.piratehaven.org> <20000519165502.G9961@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000519165502.G9961@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Chaitanya Tumuluri <chait@getafix.engr.sgi.com>, Eric Youngdale <eric@andante.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Douglas Gilbert <dgilbert@interlog.com>, linux-scsi@vger.rutgers.edu, chait@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 19, 2000 at 04:55:02PM +0100, Stephen C. Tweedie wrote:
> Hi,
> 
> On Fri, May 19, 2000 at 08:48:42AM -0700, Brian Pomerantz wrote:
> 
> > > The real solution is probably not to increase the atomic I/O size, but
> > > rather to pipeline I/Os.  That is planned for the future, and now there
> > 
> > That really depends on the device characteristics.  This Ciprico
> > hardware I've been working with really only performs well if the
> > atomic I/O size is >= 1MB.  Once you introduce additional transactions
> > across the bus, your performance drops significantly.  I guess it is a
> > tradeoff between latency and bandwidth.  Unless you mean the low level
> > device would be handed a vector of kiobufs and it would build a single
> > SCSI request with that vector,
> 
> ll_rw_block can already do that, but...
> 
> > then I suppose it would work well but
> > the requests would have to make up a contiguous chunk of drive space.
> 
> ... a single request _must_, by definition, be contiguous.  There is
> simply no way for the kernel to deal with non-contiguous atomic I/Os.
> I'm not sure what you're talking about here --- how can an atomic I/O
> be anything else?  We can do scatter-gather, but only from scattered
> memory, not to scattered disk blocks.
> 

I may just be confused about how this whole thing works still.  I had
to go change the number of SG segments the QLogic driver allocates and
reports to the SCSI middle layer to a larger number otherwise the
transaction gets split up and I no longer have a single 1MB
transaction but four 256KB transactions.  The number of segments it
was set to was 32 (8KB * 32 = 256KB).  So the question I have is in
the end when you do this pipelining, if you don't increase the atomic
I/O size, will the device attached to the SCSI bus (or FC) still
receive a single request or will it quickly see a bunch of smaller
requests?  My point is, from my experiments with this RAID device, you
will run across situations where it is good to be able to make a
single SCSI request be quite large in order to achieve better
performance.


BAPper
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
