From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC] [PATCH 9/9] memcg: percpu page cgroup lookup cache
Date: Thu, 11 Sep 2008 21:31:34 +1000
References: <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com> <20080911202407.752b5731.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080911202407.752b5731.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200809112131.34414.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com
List-ID: <linux-mm.kvack.org>

On Thursday 11 September 2008 21:24, KAMEZAWA Hiroyuki wrote:
> Use per-cpu cache for fast access to page_cgroup.
> This patch is for making fastpath faster.
>
> Because page_cgroup is accessed when the page is allocated/freed,
> we can assume several of continuous page_cgroup will be accessed soon.
> (If not interleaved on NUMA...but in such case, alloc/free itself is slow.)
>
> We cache some set of page_cgroup's base pointer on per-cpu area and
> use it when we hit.
>
> TODO:
>  - memory/cpu hotplug support.

How much does this help?


>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> ---
>  mm/page_cgroup.c |   47 +++++++++++++++++++++++++++++++++++++++++++++--
>  1 file changed, 45 insertions(+), 2 deletions(-)
>
> Index: mmtom-2.6.27-rc5+/mm/page_cgroup.c
> ===================================================================
> --- mmtom-2.6.27-rc5+.orig/mm/page_cgroup.c
> +++ mmtom-2.6.27-rc5+/mm/page_cgroup.c
> @@ -57,14 +57,26 @@ static int pcg_hashmask  __read_mostly;
>  #define PCG_HASHMASK		(pcg_hashmask)
>  #define PCG_HASHSIZE		(1 << pcg_hashshift)
>
> +#define PCG_CACHE_MAX_SLOT	(32)
> +#define PCG_CACHE_MASK		(PCG_CACHE_MAX_SLOT - 1)
> +struct percpu_page_cgroup_cache {
> +	struct {
> +		unsigned long	index;
> +		struct page_cgroup *base;
> +	} slots[PCG_CACHE_MAX_SLOT];
> +};
> +DEFINE_PER_CPU(struct percpu_page_cgroup_cache, pcg_cache);
> +
>  int pcg_hashfun(unsigned long index)
>  {
>  	return hash_long(index, pcg_hashshift);
>  }
>
> -struct page_cgroup *lookup_page_cgroup(unsigned long pfn)
> +noinline static struct page_cgroup *
> +__lookup_page_cgroup(struct percpu_page_cgroup_cache *pcc,unsigned long
> pfn) {
>  	unsigned long index = pfn >> ENTS_PER_CHUNK_SHIFT;
> +	int s = index & PCG_CACHE_MASK;
>  	struct pcg_hash *ent;
>  	struct pcg_hash_head *head;
>  	struct hlist_node *node;
> @@ -77,6 +89,8 @@ struct page_cgroup *lookup_page_cgroup(u
>  	hlist_for_each_entry(ent, node, &head->head, node) {
>  		if (ent->index == index) {
>  			pc = ent->map + pfn;
> +			pcc->slots[s].index = ent->index;
> +			pcc->slots[s].base = ent->map;
>  			break;
>  		}
>  	}
> @@ -84,6 +98,22 @@ struct page_cgroup *lookup_page_cgroup(u
>  	return pc;
>  }
>
> +struct page_cgroup *lookup_page_cgroup(unsigned long pfn)
> +{
> +	unsigned long index = pfn >> ENTS_PER_CHUNK_SHIFT;
> +	int hnum = (pfn >> ENTS_PER_CHUNK_SHIFT) & PCG_CACHE_MASK;
> +	struct percpu_page_cgroup_cache *pcc;
> +	struct page_cgroup *ret;
> +
> +	pcc = &get_cpu_var(pcg_cache);
> +	if (likely(pcc->slots[hnum].index == index))
> +		ret = pcc->slots[hnum].base + pfn;
> +	else
> +		ret = __lookup_page_cgroup(pcc, pfn);
> +	put_cpu_var(pcg_cache);
> +	return ret;
> +}
> +
>  static void __meminit alloc_page_cgroup(int node, unsigned long index)
>  {
>  	struct pcg_hash *ent;
> @@ -124,12 +154,23 @@ static void __meminit alloc_page_cgroup(
>  	return;
>  }
>
> +void clear_page_cgroup_cache_pcg(int cpu)
> +{
> +	struct percpu_page_cgroup_cache *pcc;
> +	int i;
> +
> +	pcc = &per_cpu(pcg_cache, cpu);
> +	for (i = 0; i <  PCG_CACHE_MAX_SLOT; i++) {
> +		pcc->slots[i].index = -1;
> +		pcc->slots[i].base = NULL;
> +	}
> +}
>
>  /* Called From mem_cgroup's initilization */
>  void __init page_cgroup_init(void)
>  {
>  	struct pcg_hash_head *head;
> -	int node, i;
> +	int node, cpu, i;
>  	unsigned long start, pfn, end, index, offset;
>  	long default_pcg_hash_size;
>
> @@ -174,5 +215,7 @@ void __init page_cgroup_init(void)
>  			}
>  		}
>  	}
> +	for_each_possible_cpu(cpu)
> +		clear_page_cgroup_cache_pcg(cpu);
>  	return;
>  }
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
