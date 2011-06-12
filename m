Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 84AD46B0012
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 19:07:20 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5CMjiYp028072
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 18:45:44 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5CN7CPw1425614
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 19:07:12 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5CN7AOR001081
	for <linux-mm@kvack.org>; Sun, 12 Jun 2011 19:07:12 -0400
Date: Sun, 12 Jun 2011 16:07:07 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110612230707.GE2212@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20110610171939.GE2230@linux.vnet.ibm.com>
 <20110610172307.GA27630@srcf.ucam.org>
 <20110610175248.GF2230@linux.vnet.ibm.com>
 <20110610180807.GB28500@srcf.ucam.org>
 <20110610184738.GG2230@linux.vnet.ibm.com>
 <20110610192329.GA30496@srcf.ucam.org>
 <20110610193713.GJ2230@linux.vnet.ibm.com>
 <20110610200233.5ddd5a31@infradead.org>
 <20110611170610.GA2212@linux.vnet.ibm.com>
 <20110611102654.01e5cea9@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110611102654.01e5cea9@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Matthew Garrett <mjg59@srcf.ucam.org>, Kyungmin Park <kmpark@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

On Sat, Jun 11, 2011 at 10:26:54AM -0700, Arjan van de Ven wrote:
> On Sat, 11 Jun 2011 10:06:10 -0700
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> 
> > On Fri, Jun 10, 2011 at 08:02:33PM -0700, Arjan van de Ven wrote:
> > > On Fri, 10 Jun 2011 12:37:13 -0700
> > > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> > > 
> > > > On Fri, Jun 10, 2011 at 08:23:29PM +0100, Matthew Garrett wrote:
> > > > > On Fri, Jun 10, 2011 at 11:47:38AM -0700, Paul E. McKenney
> > > > > wrote:
> > > > > 
> > > > > > And if I understand you correctly, then the patches that
> > > > > > Ankita posted should help your self-refresh case, along with
> > > > > > the originally intended the power-down case and
> > > > > > special-purpose use of memory case.
> > > > > 
> > > > > Yeah, I'd hope so once we actually have capable hardware.
> > > > 
> > > > Cool!!!
> > > > 
> > > > So Ankita's patchset might be useful to you at some point, then.
> > > > 
> > > > Does it look like a reasonable implementation?
> > > 
> > > as someone who is working on hardware that is PASR capable right
> > > now, I have to admit that our plan was to just hook into the buddy
> > > allocator, and use PASR on the top level of buddy (eg PASR off
> > > blocks that are free there, and PASR them back on once an
> > > allocation required the block to be broken up)..... that looked the
> > > very most simple to me.
> > > 
> > > Maybe something much more elaborate is needed, but I didn't see why
> > > so far.
> > 
> > If I understand correctly, you face the same issue that affects
> > transparent huge pages, but on a much larger scale.  If you have even
> > one non-moveable allocation in a given top-level buddy block, you
> > won't be able to PASR that block.
> 
> yep we'd use a non-kernel zone for that; not too big a deal.
> (the much larger scale you can debate, if your memory controller is
> configured correctly the PASR regions are not all that much bigger than
> hugepages)

Ah, OK, so you have a very large number of top-level buddy allocations,
then.  Either that or very large hugepages.

> > In addition, one of the things that Ankita's patchset is looking to do
> > is to control allocations in a given region, so that the region can be
> > easily evacuated.  One use for this is to power off regions of memory,
> > another is to PASR off regions of memory, and a third is to ensure
> > that large regions of memory are available for when needed by media
> > codecs (e.g., cameras), but can be used for other purposes when the
> > media codecs don't need them (e.g., when viewing photos rather than
> > taking them).
> 
> the codec issue seems to be solved in time; a previous generation
> silicon on our (Intel) side had ARM ecosystem blocks that did not do
> scatter gather, however the current generation ARM ecosystem blocks all
> seem to have added S/G to them....
> (in part this is coming from the strong desire to get camera/etc blocks
> to all use "GPU texture" class memory, so that the camera can directly
> deposit its information into a gpu texture, and similar for media
> encode/decode blocks... this avoids copies as well as duplicate memory).

That is indeed a clever approach!

Of course, if the GPU textures are in main memory, there will still
be memory consumption gains to be had as the image size varies (e.g.,
displaying image on one hand vs. menus and UI on the other).  In addition,
I would expect that for quite some time there will continue to be a lot
of systems with display hardware a bit too simple to qualify as "GPU".

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
