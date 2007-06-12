Subject: Re: [PATCH] Add populated_map to account for memoryless nodes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0706121138050.30754@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
	 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
	 <1181657433.5592.11.camel@localhost> <20070612173521.GX3798@us.ibm.com>
	 <Pine.LNX.4.64.0706121138050.30754@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 12 Jun 2007 14:54:42 -0400
Message-Id: <1181674482.5592.98.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-06-12 at 11:39 -0700, Christoph Lameter wrote:
> On Tue, 12 Jun 2007, Nishanth Aravamudan wrote:
> 
> > > Mea culpa.  Our platforms have a [pseudo-]node with just O(1G) memory
> > > all in zone DMA.  That node can't look populated for allocating huge
> > > pages.
> > 
> > Because you don't want to use up any of the DMA pages, right? That seems
> > *very* platform specific. And it doesn't seem right to make common code
> > more complicated for one platform. Maybe there isn't a better solution,
> > but I'd like to mull it over.
> 
> Right. Please Lee be generic and avoid the exceptional cases.

I was trying to be generic.  But it broke for the exceptional case of an
x86_64 with all/mostly DMA32 in one node and higher zone memory in other
nodes.  

> 
> > > Maybe we can just exclude zone DMA from the populated map?
> > 
> > Maybe I don't know enough about NUMA and such, but I'm not sure I
> > understand how this would make it a populated map anymore?
> > 
> > Maybe we need two maps, really?
> 
> No need. If you want to exclude a node from huge pages then you need 
> to use the patch that allows per node huge page specifications and set 
> the number of huge pages for that node to zero.


Perhaps.  But, be aware that allocating pages via the 'hugepages' boot
parameter or the vm.nr_hugepages sysctl won't spread pages evenly--on
our platforms, anyway--if we don't get this right.  From what I've seen
in the mailing lists, this approach [fixing it up with the per node
attributes] runs counter to the general approach of having the kernel
figure it out.  

So, I'll wait for this to settle down.  Then I'll see how it works on
our platforms and propose whatever generic fixes I can to make it work.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
