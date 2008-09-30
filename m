Date: Tue, 30 Sep 2008 17:06:08 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] mm: show node to memory section relationship with symlinks in sysfs
In-Reply-To: <20080929200509.GC21255@us.ibm.com>
References: <20080929200509.GC21255@us.ibm.com>
Message-Id: <20080930163324.44A7.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gary Hade <garyhade@us.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Badari Pulavarty <pbadari@us.ibm.com>, Mel Gorman <mel@csn.ul.ie>, Chris McDermott <lcm@us.ibm.com>, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Greg KH <greg@kroah.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Nish Aravamudan <nish.aravamudan@gmail.com>
List-ID: <linux-mm.kvack.org>

> +#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
> +int register_mem_sect_under_node(struct memory_block *mem_blk)
        :

I think this patch is convenience even when memory hotplug is disabled.
CONFIG_SPARSEMEM seems better than CONFIG_MEMORY_HOTPLUG_SPARSE.


> +int register_mem_sect_under_node(struct memory_block *mem_blk)
> +{
> +	unsigned int nid;
> +
> +	if (!mem_blk)
> +		return -EFAULT;
> +	nid = section_nr_to_nid(mem_blk->phys_index);

(snip)

> +#define section_nr_to_nid(section_nr) pfn_to_nid(section_nr_to_pfn(section_nr))
>  #endif /* CONFIG_MEMORY_HOTPLUG_SPARSE */

If the first page of the section is not valid, then this section_nr_to_nid()
doesn't return correct value.

I tested this patch. In my box, the start_pfn of node 1 is 1200400, but 
section_nr_to_pfn(mem_blk->phys_index) returns 1200000. As a result,
the section is linked to node 0.

Bye.
-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
