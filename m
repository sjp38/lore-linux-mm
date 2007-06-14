Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706140913530.29612@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
	 <1181677473.5592.149.camel@localhost>
	 <Pine.LNX.4.64.0706121245200.7983@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0706121257290.7983@schroedinger.engr.sgi.com>
	 <20070612200125.GG3798@us.ibm.com> <1181748606.6148.19.camel@localhost>
	 <20070613175802.GP3798@us.ibm.com> <1181758874.6148.73.camel@localhost>
	 <Pine.LNX.4.64.0706131550520.32399@schroedinger.engr.sgi.com>
	 <1181836247.5410.85.camel@localhost> <20070614160913.GF7469@us.ibm.com>
	 <Pine.LNX.4.64.0706140913530.29612@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 14 Jun 2007 13:07:52 -0400
Message-Id: <1181840872.5410.159.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-06-14 at 09:15 -0700, Christoph Lameter wrote:
> On Thu, 14 Jun 2007, Nishanth Aravamudan wrote:
> 
> > > The point of all this is that, as you've pointed out, the original
> > > NUMA and memory policy designs assumed a fairly symmetric system
> > > configuration with all nodes populated with [similar amounts?] of
> > > roughly equivalent memory.  That probably describes a majority of NUMA
> > > systems, so the system should handle this well, as a default.  We
> > > still need to be able to handle the less symmetric configs--with boot
> > > parameters, sysctls, cpusets, ...--that specify non-default behavior,
> > > and cause the generic code to do the right thing.  Certainly, the
> > > generic code can't "fall over and die" in the presence of memoryless
> > > nodes or other "interesting" configurations.
> > 
> > Agreed,
> > Nish
> 
> The generic code currently does not fail. It (slab allocators etc) simply 
> gets memory that it thinks comes from a memoryless node but it came from a 
> neighboring node.
> 

If it (slab allocators etc) wants and/or can use memory from a different
node from what it requested, then, it shouldn't be calling with
GFP_THISNODE, right?  I mean what's the point?  If GFP_THISNODE never
returned off-node memory, then one couldn't use it without checking for
and dealing with failure.  And, 'THISNODE allocations CAN fail, when the
first zone in the selected zonelist is empty and subsequent zones are
off-node.  __alloc_pages() et al WILL fail this case and return NULL, so
callers must be prepared to deal with it--even [especially?] early boot
code, IMO, anyway.

Again, I'll try your latest stack with Nish's patches and see what
happens.

Lee




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
