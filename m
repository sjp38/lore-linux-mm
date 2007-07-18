Date: Wed, 18 Jul 2007 10:04:33 -0700
From: Eugene Surovegin <ebs@ebshome.net>
Subject: Re: [Bugme-new] [Bug 8778] New: Ocotea board: kernel reports access of bad area during boot with DEBUG_SLAB=y
Message-ID: <20070718170433.GC29722@gate.ebshome.net>
References: <bug-8778-10286@http.bugzilla.kernel.org/> <20070718005253.942f0464.akpm@linux-foundation.org> <20070718083425.GA29722@gate.ebshome.net> <1184766070.3699.2.camel@zod.rchland.ibm.com> <20070718155940.GB29722@gate.ebshome.net> <20070718095537.d344dc0a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070718095537.d344dc0a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Josh Boyer <jwboyer@linux.vnet.ibm.com>, bart.vanassche@gmail.com, netdev@vger.kernel.org, "bugme-daemon@kernel-bugs.osdl.org" <bugme-daemon@bugzilla.kernel.org>, linuxppc-embedded@ozlabs.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 18, 2007 at 09:55:37AM -0700, Andrew Morton wrote:
> On Wed, 18 Jul 2007 08:59:40 -0700 Eugene Surovegin <ebs@ebshome.net> wrote:
> 
> > On Wed, Jul 18, 2007 at 08:41:10AM -0500, Josh Boyer wrote:
> > > On Wed, 2007-07-18 at 01:34 -0700, Eugene Surovegin wrote:
> > > > On Wed, Jul 18, 2007 at 12:52:53AM -0700, Andrew Morton wrote:
> > > > > On Wed, 18 Jul 2007 00:07:50 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> > > > > 
> > > > > > http://bugzilla.kernel.org/show_bug.cgi?id=8778
> > > > > > 
> > > > > >            Summary: Ocotea board: kernel reports access of bad area during
> > > > > >                     boot with DEBUG_SLAB=y
> > > > 
> > > > Slab debugging is probably the culprit here. I had similar problem 
> > > > couple of years ago, not sure something has changed since then, 
> > > > haven't checked.
> > > > 
> > > > When slab debugging was enabled it made memory allocations non L1 
> > > > cache line aligned. This is very bad for DMA on non-coherent cache 
> > > > arches (PPC440 is one of those archs).
> > > > 
> > > > I have a hack for EMAC which tries to "workaround" this problem:
> > > > 	http://kernel.ebshome.net/emac_slab_debug.diff
> > > > which might help.
> > > 
> > > Would you be opposed to including that patch in mainline?
> > 
> > Yes. I don't think it's the right way to fix this issue. IMO, the 
> > right one is to fix slab allocator. You cannot change all drivers to 
> > do this kind of cache flushing, and yes, I saw the same problem with 
> > PCI based NIC I tried on Ocotea at the time.
> > 
> 
> hm.  It should be the case that providing SLAB_HWCACHE_ALIGN at
> kmem_cache_create() time will override slab-debugging's offsetting
> of the returned addresses.
> 
> Or is the problem occurring with memory which is returned from kmalloc(),
> rather than from kmem_cache_alloc()?

It's kmalloc, at least this is how I think skbs are allocated.

Andrew, I don't have access to PPC hw right now (doing MIPS 
development these days), so I cannot quickly check that my theory is 
still correct for the latest kernel. I'd wait for the reporter to try 
my hack and then we can decide what to do. IIRC there was some 
provision in slab allocator to enforce alignment, when I was debugging 
this problem more then a year ago, that option didn't work.

BTW, I think slob allocator had the same issue with alignment as slab 
with enabled debugging (at least at the time I looked at it).

-- 
Eugene

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
