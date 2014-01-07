From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Date: Tue, 7 Jan 2014 12:19:39 +0800
Message-ID: <35322.3777645782$1389068670@news.gmane.org>
References: <20140107132100.5b5ad198@kryten>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20140107132100.5b5ad198@kryten>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
To: Anton Blanchard <anton@samba.org>
Cc: cl@linux-foundation.org, nacc@linux.vnet.ibm.com, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, mpm@selenic.com, linuxppc-dev@lists.ozlabs.org
List-Id: linux-mm.kvack.org

On Tue, Jan 07, 2014 at 01:21:00PM +1100, Anton Blanchard wrote:
>
>We noticed a huge amount of slab memory consumed on a large ppc64 box:
>
>Slab:            2094336 kB
>
>Almost 2GB. This box is not balanced and some nodes do not have local
>memory, causing slub to be very inefficient in its slab usage.
>
>Each time we call kmem_cache_alloc_node slub checks the per cpu slab,
>sees it isn't node local, deactivates it and tries to allocate a new
>slab. On empty nodes we will allocate a new remote slab and use the
>first slot, but as explained above when we get called a second time
>we will just deactivate that slab and retry.
>
>As such we end up only using 1 entry in each slab:
>
>slab                    mem  objects
>                       used   active
>------------------------------------
>kmalloc-16384       1404 MB    4.90%
>task_struct          668 MB    2.90%
>kmalloc-128          193 MB    3.61%
>kmalloc-192          152 MB    5.23%
>kmalloc-8192          72 MB   23.40%
>kmalloc-16            64 MB    7.43%
>kmalloc-512           33 MB   22.41%
>
>The patch below checks that a node is not empty before deactivating a
>slab and trying to allocate it again. With this patch applied we now
>use about 352MB:
>
>Slab:             360192 kB
>
>And our efficiency is much better:
>
>slab                    mem  objects
>                       used   active
>------------------------------------
>kmalloc-16384         92 MB   74.27%
>task_struct           23 MB   83.46%
>idr_layer_cache       18 MB  100.00%
>pgtable-2^12          17 MB  100.00%
>kmalloc-65536         15 MB  100.00%
>inode_cache           14 MB  100.00%
>kmalloc-256           14 MB   97.81%
>kmalloc-8192          14 MB   85.71%
>
>Signed-off-by: Anton Blanchard <anton@samba.org>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
>
>Thoughts? It seems like we could hit a similar situation if a machine
>is balanced but we run out of memory on a single node.
>
>Index: b/mm/slub.c
>===================================================================
>--- a/mm/slub.c
>+++ b/mm/slub.c
>@@ -2278,10 +2278,17 @@ redo:
>
> 	if (unlikely(!node_match(page, node))) {
> 		stat(s, ALLOC_NODE_MISMATCH);
>-		deactivate_slab(s, page, c->freelist);
>-		c->page = NULL;
>-		c->freelist = NULL;
>-		goto new_slab;
>+
>+		/*
>+		 * If the node contains no memory there is no point in trying
>+		 * to allocate a new node local slab
>+		 */
>+		if (node_spanned_pages(node)) {

s/node_spanned_pages/node_present_pages 

>+			deactivate_slab(s, page, c->freelist);
>+			c->page = NULL;
>+			c->freelist = NULL;
>+			goto new_slab;
>+		}
> 	}
>
> 	/*
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
