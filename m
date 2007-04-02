Date: Mon, 2 Apr 2007 13:11:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
In-Reply-To: <1175543696.22373.51.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0704021258500.31698@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
  <200704011246.52238.ak@suse.de>  <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
  <200704021744.39880.ak@suse.de>  <Pine.LNX.4.64.0704020851300.30394@schroedinger.engr.sgi.com>
 <1175543696.22373.51.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Apr 2007, Dave Hansen wrote:

> MAX_ORDER, and the section size is at least MAX_ORDER.  If we *did* have
> this, then the page allocator would already be broken for these
> nodes. ;)

Ahh... Ok.
 
> So, this SPARSE_VIRTUAL does introduce a new dependency, which Andi
> calculated above.  But, in reality, I don't think it's a big deal.  Just
> to spell it out a bit more, if this:
> 
> 	VMEMMAP_MAPPING_SIZE/sizeof(struct page) * PAGE_SIZE
> 
> (where VMEMMAP_MAPPING_SIZE is PMD_SIZE in your case) is any larger than
> the granularity on which your NUMA nodes are divided, then you might
> have a problem with mem_map for one NUMA node getting allocated on
> another.  

This is only a problem if

1. We are not on NUMA emulation. In that case: Who cares. The SPARSEMEM
   sections make sure that the MAX_ORDER blocks do not overlap.

2. There is a hole less than 128 MB between the nodes.

3. The maximum overlap can then be theoretically less than 2M in terms of
   page structs. That is less than 128MB can overlap at the beginning of a 
   node. Typically the start of a node gets used for allocation system
   control areas. I.e. node data, vmemmap 2M blocks etc. For those we
   only use the page structs during bootstrap. They are not performance
   critical. We can just ignore the problem for those.

   In order for this to become a problem the overlap would need to
   more than the management data at the front of a node. The larger 
   the zone is the more 2M blocks will be allocated from the beginning a 
   node and the less we can actually get into this situation.

If this is an actual problem then we could take out this particular
2M page and replace it with single 4K pages that can be individually
placed. Yaw.... Too complex.

I think we can ignore this. The only problem could be reduced performance
accessing page structs of some small portion of a node.

> It might be worth a comment, or at least some kind of WARN_ON().
> Perhaps we can stick something in online_page() to check if:
> 
> 	page_to_nid(page) == page_to_nid(virt_to_page(page))

Could do that but the check is going to be too agressive. Check would 
have to be done after all control information has been allocated. WARN_ON 
would be sufficient since this is not going to impact functionality.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
