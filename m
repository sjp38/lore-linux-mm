Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 282F26B0033
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 11:21:01 -0400 (EDT)
Date: Wed, 3 Jul 2013 17:20:58 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH next-20130703] net: sock: Add ifdef CONFIG_MEMCG_KMEM for
 mem_cgroup_sockets_{init,destroy}
Message-ID: <20130703152058.GA30267@dhcp22.suse.cz>
References: <1372853998-15353-1-git-send-email-sedat.dilek@gmail.com>
 <51D41E34.5010802@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51D41E34.5010802@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>, akpm@linux-foundation.org
Cc: Sedat Dilek <sedat.dilek@gmail.com>, davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, linux-mm@kvack.org

On Wed 03-07-13 20:51:00, Li Zefan wrote:
[...]
> [PATCH] memcg: fix build error if CONFIG_MEMCG_KMEM=n
> 
> Fix this build error:
> 
> mm/built-in.o: In function `mem_cgroup_css_free':
> memcontrol.c:(.text+0x5caa6): undefined reference to
> 'mem_cgroup_sockets_destroy'
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Li Zefan <lizefan@huawei.com>

I am seeing the same thing I just didn't get to reporting it.
The other approach is not bad as well but I find this tiny better
because mem_cgroup_css_free should care only about a single cleanup
function for whole kmem. If that one needs to do tcp kmem specific
cleanup then it should be done inside kmem_cgroup_css_offline.

Andrew could you add this as
memcg-use-css_get-put-when-charging-uncharging-kmem-fix.patch, please?

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks

> ---
>  mm/memcontrol.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 234f311..59ea6f9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5876,6 +5876,11 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>  	return mem_cgroup_sockets_init(memcg, ss);
>  }
>  
> +static void memcg_destroy_kmem(struct mem_cgroup *memcg)
> +{
> +	mem_cgroup_sockets_destroy(memcg);
> +}
> +
>  static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
>  {
>  	if (!memcg_kmem_is_active(memcg))
> @@ -5915,6 +5920,10 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>  	return 0;
>  }
>  
> +static void memcg_destroy_kmem(struct mem_cgroup *memcg)
> +{
> +}
> +
>  static void kmem_cgroup_css_offline(struct mem_cgroup *memcg)
>  {
>  }
> @@ -6312,8 +6321,7 @@ static void mem_cgroup_css_free(struct cgroup *cont)
>  {
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
>  
> -	mem_cgroup_sockets_destroy(memcg);
> -
> +	memcg_destroy_kmem(memcg);
>  	__mem_cgroup_free(memcg);
>  }
>  
> -- 
> 1.8.0.2
> 
> 
> > ---
> > [ v2: git dislikes lines beginning with hash ('#'). ]
> > 
> >  include/net/sock.h | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/include/net/sock.h b/include/net/sock.h
> > index ea6206c..ad4bf7f 100644
> > --- a/include/net/sock.h
> > +++ b/include/net/sock.h
> > @@ -71,6 +71,7 @@
> >  struct cgroup;
> >  struct cgroup_subsys;
> >  #ifdef CONFIG_NET
> > +#ifdef CONFIG_MEMCG_KMEM
> 
> #if defined(CONFIG_NET) && defined(CONFIG_MEMCG_KMEM)
> 
> >  int mem_cgroup_sockets_init(struct mem_cgroup *memcg, struct cgroup_subsys *ss);
> >  void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg);
> >  #else
> > @@ -83,7 +84,8 @@ static inline
> >  void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg)
> >  {
> >  }
> > -#endif
> > +#endif /* CONFIG_NET */
> > +#endif /* CONFIG_MEMCG_KMEM */
> >  /*
> >   * This structure really needs to be cleaned up.
> >   * Most of it is for TCP, and not used by any of
> > 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
