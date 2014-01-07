From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Don't throw away partial remote slabs if there is
 no local memory
Date: Tue, 7 Jan 2014 17:49:44 +0800
Message-ID: <43341.3972649307$1389088226@news.gmane.org>
References: <20140107132100.5b5ad198@kryten> <20140107074136.GA4011@lge.com>
 <52cbbf7b.2792420a.571c.ffffd476SMTPIN_ADDED_BROKEN@mx.google.com>
 <20140107091016.GA21965@lge.com>
 <52cbc738.c727440a.5ead.27a3SMTPIN_ADDED_BROKEN@mx.google.com>
 <20140107093156.GA10157@lge.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
Content-Disposition: inline
In-Reply-To: <20140107093156.GA10157@lge.com>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: cl@linux-foundation.org, nacc@linux.vnet.ibm.com, penberg@kernel.org, linux-mm@kvack.org, paulus@samba.org, Anton Blanchard <anton@samba.org>, mpm@selenic.com, linuxppc-dev@lists.ozlabs.org
List-Id: linux-mm.kvack.org

On Tue, Jan 07, 2014 at 06:31:56PM +0900, Joonsoo Kim wrote:
>On Tue, Jan 07, 2014 at 05:21:45PM +0800, Wanpeng Li wrote:
>> On Tue, Jan 07, 2014 at 06:10:16PM +0900, Joonsoo Kim wrote:
>> >On Tue, Jan 07, 2014 at 04:48:40PM +0800, Wanpeng Li wrote:
>> >> Hi Joonsoo,
>> >> On Tue, Jan 07, 2014 at 04:41:36PM +0900, Joonsoo Kim wrote:
>> >> >On Tue, Jan 07, 2014 at 01:21:00PM +1100, Anton Blanchard wrote:
>> >> >> 
>> >> [...]
>> >> >Hello,
>> >> >
>> >> >I think that we need more efforts to solve unbalanced node problem.
>> >> >
>> >> >With this patch, even if node of current cpu slab is not favorable to
>> >> >unbalanced node, allocation would proceed and we would get the unintended memory.
>> >> >
>> >> 
>> >> We have a machine:
>> >> 
>> >> [    0.000000] Node 0 Memory:
>> >> [    0.000000] Node 4 Memory: 0x0-0x10000000 0x20000000-0x60000000 0x80000000-0xc0000000
>> >> [    0.000000] Node 6 Memory: 0x10000000-0x20000000 0x60000000-0x80000000
>> >> [    0.000000] Node 10 Memory: 0xc0000000-0x180000000
>> >> 
>> >> [    0.041486] Node 0 CPUs: 0-19
>> >> [    0.041490] Node 4 CPUs:
>> >> [    0.041492] Node 6 CPUs:
>> >> [    0.041495] Node 10 CPUs:
>> >> 
>> >> The pages of current cpu slab should be allocated from fallback zones/nodes 
>> >> of the memoryless node in buddy system, how can not favorable happen? 
>> >
>> >Hi, Wanpeng.
>> >
>> >IIRC, if we call kmem_cache_alloc_node() with certain node #, we try to
>> >allocate the page in fallback zones/node of that node #. So fallback list isn't
>> >related to fallback one of memoryless node #. Am I wrong?
>> >
>> 
>> Anton add node_spanned_pages(node) check, so current cpu slab mentioned
>> above is against memoryless node. If I miss something?
>
>I thought following scenario.
>
>memoryless node # : 1
>1's fallback node # : 0
>
>On node 1's cpu,
>
>1. kmem_cache_alloc_node (node 2)
>2. allocate the page on node 2 for the slab, now cpu slab is that one.
>3. kmem_cache_alloc_node (local node, that is, node 1)
>4. It check node_spanned_pages() and find it is memoryless node.
>So return node 2's memory.
>
>Is it impossible scenario?
>

Indeed, it can happen. 

Regards,
Wanpeng Li 

>Thanks.
