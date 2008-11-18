Date: Tue, 18 Nov 2008 19:21:35 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH mmotm] memcg: unmap KM_USER0 at shmem_map_and_free_swp
 if do_swap_account
Message-Id: <20081118192135.300803ec.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081118182637.97ae0e48.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081118180721.cb2fe744.nishimura@mxp.nes.nec.co.jp>
	<20081118182637.97ae0e48.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Nov 2008 18:26:37 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 18 Nov 2008 18:07:21 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > memswap controller uses KM_USER0 at swap_cgroup_record and lookup_swap_cgroup.
> > 
> > But delete_from_swap_cache, which eventually calls swap_cgroup_record, can be
> > called with KM_USER0 mapped in case of shmem.
> > 
> > So it should be unmapped before calling it.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Nice Catch!
> 
> Thank you for tests and patches.
> brief comment below.
> 
> > ---
> > After this patch, I think memswap controller of x86_32 will be
> > on the same level with that of x86_64.
> > 
> >  mm/shmem.c |   23 +++++++++++++++++++++++
> >  1 files changed, 23 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index bee8612..7aebc1b 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -171,6 +171,28 @@ static inline void shmem_unacct_size(unsigned long flags, loff_t size)
> >  		vm_unacct_memory(VM_ACCT(size));
> >  }
> >  
> > +#if defined(CONFIG_CGROUP_MEM_RES_CTLR_SWAP) && defined(CONFIG_HIGHMEM)
> > +/*
> > + * memswap controller uses KM_USER0, so dir should be unmapped
> > + * before calling delete_from_swap_cache.
> > + */
> > +static inline void swap_cgroup_map_prepare(struct page ***dir)
> > +{
> > +	if (!do_swap_account)
> > +		return;
> > +
> > +	if (*dir) {
> > +		shmem_dir_unmap(*dir);
> > +		*dir = NULL;
> > +	}
> > +}
> > +#else
> > +static inline void swap_cgroup_map_prepare(struct page ***dir)
> > +{
> > +	return;
> > +}
> > +#endif
> > +
> >  /*
> >   * ... whereas tmpfs objects are accounted incrementally as
> >   * pages are allocated, in order to allow huge sparse files.
> > @@ -479,6 +501,7 @@ static int shmem_map_and_free_swp(struct page *subdir, int offset,
> >  		int size = limit - offset;
> >  		if (size > LATENCY_LIMIT)
> >  			size = LATENCY_LIMIT;
> > +		swap_cgroup_map_prepare(dir);
> I think put this before "for() loop" is better.
> 
Make sense.

I'll post updated version later.


Thanks,
Dasiuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
