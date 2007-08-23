Date: Thu, 23 Aug 2007 14:21:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] 2.6.23-rc3-mm1 Kernel panic - not syncing: DMA: Memory
 would be corrupted
Message-Id: <20070823142133.9359a1ce.akpm@linux-foundation.org>
In-Reply-To: <617E1C2C70743745A92448908E030B2A023EB020@scsmsx411.amr.corp.intel.com>
References: <617E1C2C70743745A92448908E030B2A023B2FD5@scsmsx411.amr.corp.intel.com>
	<20070823091556.GA18456@skynet.ie>
	<20070823221005.0D76.Y-GOTO@jp.fujitsu.com>
	<617E1C2C70743745A92448908E030B2A023EB020@scsmsx411.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, Mel Gorman <mel@skynet.ie>, Jeremy Higdon <jeremy@sgi.com>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-ia64@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 23 Aug 2007 10:22:26 -0700
"Luck, Tony" <tony.luck@intel.com> wrote:

> > __get_free_pages() of swiotlb_alloc_coherent() fails in rc3-mm1.
> > But, it doesn't fail on rc2-mm2, and kernel can boot up.
> 
> That looks to be part of the problem here ... failing an order=3
> allocation during boot on a system that just a few lines earlier
> in the boot log reported "Memory: 37474000k/37680640k available"
> looks bad ... but perhaps having *more* memory is part of your problem.
> You may have run low on GFP_DMA memory because some allocation
> scaled by memory size has chewed up a lot of your memory.  To check
> this try booting with a "mem=4G" parameter and see if that helps
> you.
> 
> But it is also bad that the swiotlb() code failed to handle this.
> Can you check whether the problem is related to the size of the
> allocation being just over 256K (a magic number for swiotlb since
> IO_TLB_SEGSIZE is 128 times a slab size of 2k).  Try changing
> lib/swiotlb.c to set IO_TLB_SEGSIZE to 256 instead.
> 

Others are reporting machines which fail int he memory allcoator much
earlier, and which claim to have four CPUs and 16 nodes.  So something is
very wonky in the rc3-mm1 page allocator.

I guess suspicion has to be directed at the memoryless-nodes patches, but
until that's cleared up I don't think there's much to be gained from
chasing this iommu problem, now that you've worked out that it's a bogus
memory allocation failure (thanks).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
