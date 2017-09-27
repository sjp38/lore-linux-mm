From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 2/3] mm: oom: show unreclaimable slab info when kernel
 panic
Date: Wed, 27 Sep 2017 02:14:05 -0500 (CDT)
Message-ID: <alpine.DEB.2.20.1709270211010.30111@nuc-kabylake>
References: <1506473616-88120-1-git-send-email-yang.s@alibaba-inc.com> <1506473616-88120-3-git-send-email-yang.s@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506473616-88120-3-git-send-email-yang.s@alibaba-inc.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Wed, 27 Sep 2017, Yang Shi wrote:

> Print out unreclaimable slab info (used size and total size) which
> actual memory usage is not zero (num_objs * size != 0) when:
>   - unreclaimable slabs : all user memory > unreclaim_slabs_oom_ratio
>   - panic_on_oom is set or no killable process

Ok. I like this much more than the earlier releases.

> diff --git a/mm/slab.h b/mm/slab.h
> index 0733628..b0496d1 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -505,6 +505,14 @@ static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
>  void memcg_slab_stop(struct seq_file *m, void *p);
>  int memcg_slab_show(struct seq_file *m, void *p);
>
> +#ifdef CONFIG_SLABINFO
> +void dump_unreclaimable_slab(void);
> +#else
> +static inline void dump_unreclaimable_slab(void)
> +{
> +}
> +#endif

CONFIG_SLABINFO? How does this relate to the oom info? /proc/slabinfo
support is optional. Oom info could be included even if CONFIG_SLABINFO
goes away. Remove the #ifdef?
