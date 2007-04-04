From: "Bob Picco" <bob.picco@hp.com>
Date: Wed, 4 Apr 2007 17:27:36 -0400
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
Message-ID: <20070404212736.GI10084@localhost>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com> <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com> <200704011246.52238.ak@suse.de> <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com> <1175544797.22373.62.camel@localhost.localdomain> <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com> <1175548086.22373.99.camel@localhost.localdomain> <Pine.LNX.4.64.0704021422040.2272@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0704021422040.2272@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Dave Hansen <hansendc@us.ibm.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:	[Mon Apr 02 2007, 05:28:30PM EDT]
> On Mon, 2 Apr 2007, Dave Hansen wrote:
> 
> > On Mon, 2007-04-02 at 13:30 -0700, Christoph Lameter wrote:
> > > On Mon, 2 Apr 2007, Dave Hansen wrote:
> > > > I completely agree, it looks like it should be faster.  The code
> > > > certainly has potential benefits.  But, to add this neato, apparently
> > > > more performant feature, we unfortunately have to add code.  Adding the
> > > > code has a cost: code maintenance.  This isn't a runtime cost, but it is
> > > > a real, honest to goodness tradeoff.
> > > 
> > > Its just the opposite. The vmemmap code is so efficient that we can remove 
> > > lots of other code and gops of these alternate implementations.
> > 
> > We do want to make sure that there isn't anyone relying on these.  Are
> > you thinking of simple sparsemem vs. extreme vs. sparsemem vmemmap?  Or,
> > are you thinking of sparsemem vs. discontig?
> 
> I am thinking sparsemem default and then get rid discontig, flatmem etc.
> On many platforms this will work. Flatmem for embedded could just be a 
> variation on sparse_virtual.
> 
> > Amen, brother.  I'd love to see DISCONTIG die, with sufficient testing,
> > of course.  Andi, do you have any ideas on how to get sparsemem out of
> > the 'experimental' phase?
> 
> Note that these arguments on DISCONTIG are flame bait for many SGIers. 
> We usually see this as an attack on DISCONTIG/VMEMMAP which is the 
> existing best performing implementation for page_to_pfn and vice 
> versa. Please lets stop the polarization. We want one consistent scheme 
> to manage memory everywhere. I do not care what its called as long as it 
> covers all the bases and is not a glaring performance regresssion (like 
> SPARSEMEM so far).
Well you must have forgotten about these two postings in regards to
performance numbers:
http://marc.info/?l=linux-ia64&m=111990276501051&w=2
and
http://marc.info/?l=linux-kernel&m=116664638611634&w=2
.

I took your first patchset and ran some numbers on an amd64 machine with
two dual core sockets and 4Gb of memory. More iterations should be done
and perhaps larger number of tasks. The aim7 numbers are below.

bob

2.6.21-rc5+sparsemem
Benchmark	Version	Machine	Run Date
AIM Multiuser Benchmark - Suite VII	"1.1"	rcc5	Apr  2 05:04:33 2007

Tasks	Jobs/Min	JTI	Real	CPU	Jobs/sec/task
1	13.8		100	421.3	2.2	0.2303
101	527.8		97	1113.8	111.5	0.0871
201	565.0		97	2070.6	222.7	0.0468
301	570.9		96	3068.7	334.7	0.0316
401	573.0		97	4072.7	445.6	0.0238
501	583.3		99	4998.5	558.6	0.0194
601	583.8		99	5991.1	672.9	0.0162

2.6.21-rc5+sparsemem+patchset
Benchmark	Version	Machine	Run Date
AIM Multiuser Benchmark - Suite VII	"1.1"	vmem	Apr  4 02:22:24 2007

Tasks	Jobs/Min	JTI	Real	CPU	Jobs/sec/task
1	13.7		100	424.0	2.1	0.2288
101	500.3		97	1175.0	112.0	0.0826
201	554.2		97	2111.0	223.6	0.0460
301	578.5		97	3028.3	334.9	0.0320
401	586.2		97	3981.3	448.1	0.0244
501	584.2		99	4990.8	561.8	0.0194
601	584.4		98	5985.2	675.5	0.0162

> 
> > I have noticed before that sparsemem should be able to cover the flatmem
> > case if we make MAX_PHYSMEM_BITS == SECTION_SIZE_BITS and massage from
> > there.  
> 
> Right. But for embedded the memorymap base cannot be constant because 
> they may not be able to have a fixed address in memory. So memory map 
> needs to become a variable.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
