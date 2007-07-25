Subject: 2.6.23-rc1-mm1:  boot hang on ia64 with memoryless nodes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1185378322.5604.43.camel@localhost>
References: <20070711182219.234782227@sgi.com>
	 <20070713151431.GG10067@us.ibm.com>
	 <Pine.LNX.4.64.0707130942030.21777@schroedinger.engr.sgi.com>
	 <1185310277.5649.90.camel@localhost>
	 <Pine.LNX.4.64.0707241402010.4773@schroedinger.engr.sgi.com>
	 <1185372692.5604.22.camel@localhost>  <1185378322.5604.43.camel@localhost>
Content-Type: text/plain
Date: Wed, 25 Jul 2007 15:16:31 -0400
Message-Id: <1185390991.5604.87.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: kxr@sgi.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Bob Picco <bob.picco@hp.com>, Mel Gorman <mel@skynet.ie>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-07-25 at 11:45 -0400, Lee Schermerhorn wrote:
<snip>

> 2) fails to boot with:
> 
> Unable to handle kernel paging request at virtual address a000400002000020
> swapper[0]: Oops 11003706212352 [1]
> Modules linked in:
> 
> Pid: 0, CPU 0, comm:              swapper
> psr : 00001210084a2010 ifs : 8000000000000995 ip  : [<a0000001008a4df1>]    Not tainted
> ip is at memmap_init_zone+0x271/0x2a0
<snip>
> 
> ... then hard hang.

I tried Mel Gormans ia64 memmap corruption patches [the ones that aren't
already in 23-rc1-mm1--looks like the original one is?], and see the
same thing.

I tried to deselect SPARSEMEM_VMEMMAP.  Kconfig's "def_bool=y" wouldn't
let me :-(.  After hacking the Kconfig and mm/sparse.c to allow that,
boot hangs with no error messages shortly after "Built N zonelists..."
message.

Backed off to DISCONTIGMEM+VIRTUAL_MEMORY_MAP, and saw same hang as with
(SPARSMEM && !SPARSEMEM_VMEMMAP).   

I should mention that I have my test system in the "fully interleaved"
configuration for testing the memoryless node patches.  This means that
nodes 0-3 [the real nodes with the cpus attached] have no memory.  All
memory resides in a cpu-less pseudo-node.  I'm wondering if
SPARSEMEM_VMEMMAP can handle this?  22-rc6-mm1 booted OK on this config
w/ SPARSEMEM_EXTREME.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
