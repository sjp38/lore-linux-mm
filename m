Message-ID: <3926568D.5AA78920@sangate.com>
Date: Sat, 20 May 2000 11:10:37 +0200
From: Mark Mokryn <mark@sangate.com>
MIME-Version: 1.0
Subject: Change direct I/O memory model? [Was Re: PATCH: Enhance
 queueing/scsi-midlayer to handle kiobufs]
References: <Pine.LNX.4.10.10005192210530.868-100000@linux.local>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-scsi@vger.rutgers.edu
Cc: Brian Pomerantz <bapper@piratehaven.org>, "Stephen C. Tweedie" <sct@redhat.com>, Chaitanya Tumuluri <chait@getafix.engr.sgi.com>, Eric Youngdale <eric@andante.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Douglas Gilbert <dgilbert@interlog.com>, chait@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

One comment about direct I/O: Applications performing direct I/O usually know
what they're doing...And if they don't, well, it's their problem: that's what
direct I/O is all about. Therefore, perhaps the correct approach would be to
allow these apps to manipulate the memory as they see fit (with the standard
memory manipulation routines - mmap, mlock, whatever).  I don't see a logical
reason for the direct I/O stuff to be intricately tied in with memory management
(i.e. limiting atomic I/O size, etc.). Direct I/O should receive a nicely aligned
physical buffer (or a sg list of such buffers) which has already been locked in
memory by the application, and perform the direct I/O. That's it - very simple.
Note that in this case, the memory in question could be a user buffer, or it may
even be a mapping to PCI memory sitting on another device, thus allowing adapter
to adapter data transfers. Note that in NT, when performing unbuffered I/O, it is
up to the user to lock the memory in question to sector-sized boundaries. This is
the correct way to go...

Mark

Gerard Roudier wrote:

> On Fri, 19 May 2000, Brian Pomerantz wrote:
>
> > On Fri, May 19, 2000 at 08:11:10PM +0200, Gerard Roudier wrote:
> > >
> > > Low-level drivers have limits on number of scatter entries. They can do
> > > large transfers if scatter entries point to large data area. Rather than
> > > hacking low-level drivers that are very critical piece of code that
> > > require specific knowledge and documentation about the hardware, I
> > > recommend you to hack the peripheral driver used for the Ciprico and let
> > > it use large contiguous buffers (If obviously you want to spend your time
> > > for this device that should go to compost, IMO).
> > >
> > > Wanting to provide best support for shitty designed hardware does not
> > > encourage hardware vendors to provide us with well designed hardware. In
> > > others words, the more we want to support crap, the more we will have to
> > > support crap.
> > >
> >
> > I really don't want to get into a pissing match but it is obvious to
> > me that you haven't had any experience with high performance external
> > RAID solutions.  You will see this sort of performance characteristic
> > with a lot of these devices.  They are used to put together very large
> > storage systems (we are looking at building petabtye systems within
> > two years).
> >
> > There is no way I'm going to hack on the proprietary RAID controller
> > in this system and even if I wanted to or could, I'm quite certain
> > there is a reason for needing the large transaction size.  When you
> > take into account the maximum transaction unit on each drive (usually
> > 64KB), the fact that there are 8 data drives, then you have parity
> > calculation, latency of the transfer, and various points at which data
> > is cached and queued up before there is a complete transaction, then
> > you come up with the magic number.  These things were designed for
> > large streaming data and they do it VERY well.
> >
> > If you have a hardware RAID 3 or RAID 5 solution that will give me
> > this kind of performance for the price point and size that these
> > Ciprico units have, then I would LOVE to hear it because I'm in the
> > market for buying several of them.  If you can find me a way of
> > getting >= 150MB/s streaming I/O on a single I/O server for my cluster
> > and fill an order for 2 I/O servers for under $100K, then I may
> > consider something other than the Ciprico 7000.  They deliver this
> > performance for a very attractive price.  And in a year, I'll come
> > back and buy a fifty more.
>
> The SCSI BUS is transaction based and shared. I donnot care of affordable
> stuff that moves needless burden to other parts. If they need specific
> support for their hardware they must pay for that, and in this situation
> these products would probably not really be so affordable.
>
> Note that the same pathology happens to PCI technology. Some PCI devices,
> notably Video boards, IDE controllers, brigdes, Network boards, have
> abused a LOT of this BUS too. These hardware are/were also probably for an
> interesting price but made shit in that place too.
>
> The 36 bit adress extension from Intel is of the same idiomania that
> costed a lot for a pathetic result, it seems. It adds complexity to VM
> handling on Intel 32 bit systems when 64 bit have been proven to be
> feasible 10 years ago and works fine.
>
> I am only interested in technical issues but, in my opinion, it is the
> ones that induce costs that must pay for these costs and not others. A
> device that requires special handling because it abuses of technologies it
> uses should be discarded unless vendor want to pay for the additionnal
> effort that such offending stuff requires. But, if such vendors have
> interested customers that are ready to pay for the effort or to spend time
> implementing specific stuff for these products, I donnot see any problems.
>
> A low-latency BUS does not require huge transactions in order to allow to
> use efficiently its bandwitch. If a device requires so, then it can only
> be badly designed. Given you description of the Capricio, it seems that it
> is based on some kind of stupid batch mode that looks extremally poor
> design to me.
>
> Gerard.
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
> the body of a message to majordomo@vger.rutgers.edu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
