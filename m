Date: Thu, 23 Jun 2005 03:51:21 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH 2.6.12-rc5 5/10] mm: manual page migration-rc3 -- sys_migrate_pages-mempolicy-migration-rc3.patch
Message-ID: <20050623015121.GI14251@wotan.suse.de>
References: <20050622163908.25515.49944.65860@tomahawk.engr.sgi.com> <20050622163941.25515.38103.92916@tomahawk.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050622163941.25515.38103.92916@tomahawk.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, lhms-devel@lists.sourceforge.net, Paul Jackson <pj@sgi.com>, Nathan Scott <nathans@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 22, 2005 at 09:39:41AM -0700, Ray Bryant wrote:
> This patch adds code that translates the memory policy structures
> as they are encountered so that they continue to represent where
> memory should be allocated after the page migration has completed.


That won't work for shared memory objects though (which store
their mempolicies separately). Is that intended?

> +
> +	if (task->mempolicy->policy == MPOL_INTERLEAVE) {
> +		/*
> +		 * If the task is still running and allocating storage, this
> +		 * is racy, but there is not much that can be done about it.
> +		 */
> +		tmp = task->il_next;
> +		if (node_map[tmp] >= 0)
> +			task->il_next = node_map[tmp];

RCU (synchronize_kernel) could do better, but that might be slow. However the 
code might BUG when il_next ends up in a node that is not part of 
the policy anymore. Have you checked that?  

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
