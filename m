Date: Fri, 19 May 2000 20:11:10 +0200 (CEST)
From: =?ISO-8859-1?Q?G=E9rard_Roudier?= <groudier@club-internet.fr>
Subject: Re: PATCH: Enhance queueing/scsi-midlayer to handle kiobufs. [Re:
 Request splits]
In-Reply-To: <20000519091718.A4083@skull.piratehaven.org>
Message-ID: <Pine.LNX.4.10.10005191936160.631-100000@linux.local>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Brian Pomerantz <bapper@piratehaven.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Chaitanya Tumuluri <chait@getafix.engr.sgi.com>, Eric Youngdale <eric@andante.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Douglas Gilbert <dgilbert@interlog.com>, linux-scsi@vger.rutgers.edu, chait@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 19 May 2000, Brian Pomerantz wrote:

> On Fri, May 19, 2000 at 04:55:02PM +0100, Stephen C. Tweedie wrote:
> > Hi,
> > 
> > On Fri, May 19, 2000 at 08:48:42AM -0700, Brian Pomerantz wrote:
> > 
> > > > The real solution is probably not to increase the atomic I/O size, but
> > > > rather to pipeline I/Os.  That is planned for the future, and now there
> > > 
> > > That really depends on the device characteristics.  This Ciprico
> > > hardware I've been working with really only performs well if the
> > > atomic I/O size is >= 1MB.  Once you introduce additional transactions

Hmmm... SCSI allows up to 30,000 transactions per second and 15,000 T/s is
observed with current technology. This allows to be comfortable with
Ultra-320 even with using not too large transactions.

This let me claim that this 'Ciprico' should be damned shitty design or
implementation of a SCSI device.

Using very large scatterlists may complexify a lot SCSI sub-system and
drivers or let them oger memory for their memory pool. This Ciprico does
not deserve that we add penalty and bloatage in our software, in my
opinion.  The only reasonnable approach could be to use some peripheral
driver that can try to allocate a huge mostly contiguous chunk of memory
for the Ciprico, but to leave quiet our software that does fit nicely the
needs of reasonnably designed and implemented SCSI devices.

> > > across the bus, your performance drops significantly.  I guess it is a
> > > tradeoff between latency and bandwidth.  Unless you mean the low level
> > > device would be handed a vector of kiobufs and it would build a single
> > > SCSI request with that vector,
> > 
> > ll_rw_block can already do that, but...
> > 
> > > then I suppose it would work well but
> > > the requests would have to make up a contiguous chunk of drive space.
> > 
> > ... a single request _must_, by definition, be contiguous.  There is
> > simply no way for the kernel to deal with non-contiguous atomic I/Os.
> > I'm not sure what you're talking about here --- how can an atomic I/O
> > be anything else?  We can do scatter-gather, but only from scattered
> > memory, not to scattered disk blocks.
> > 
> 
> I may just be confused about how this whole thing works still.  I had
> to go change the number of SG segments the QLogic driver allocates and
> reports to the SCSI middle layer to a larger number otherwise the
> transaction gets split up and I no longer have a single 1MB
> transaction but four 256KB transactions.  The number of segments it
> was set to was 32 (8KB * 32 = 256KB).  So the question I have is in
> the end when you do this pipelining, if you don't increase the atomic
> I/O size, will the device attached to the SCSI bus (or FC) still
> receive a single request or will it quickly see a bunch of smaller
> requests?  My point is, from my experiments with this RAID device, you
> will run across situations where it is good to be able to make a
> single SCSI request be quite large in order to achieve better
> performance.

Low-level drivers have limits on number of scatter entries. They can do
large transfers if scatter entries point to large data area. Rather than
hacking low-level drivers that are very critical piece of code that
require specific knowledge and documentation about the hardware, I
recommend you to hack the peripheral driver used for the Ciprico and let
it use large contiguous buffers (If obviously you want to spend your time
for this device that should go to compost, IMO).

Wanting to provide best support for shitty designed hardware does not
encourage hardware vendors to provide us with well designed hardware. In
others words, the more we want to support crap, the more we will have to
support crap.

Gerard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
