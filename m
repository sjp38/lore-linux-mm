Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 113836B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 12:18:19 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id l2so6630533wml.5
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 09:18:19 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a84si2437001wme.88.2017.01.12.09.18.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 09:18:17 -0800 (PST)
Date: Thu, 12 Jan 2017 18:18:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
Message-ID: <20170112171802.GA31509@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
 <CAOi1vP9AixEr0R7GYTse+=RW9SiPPdZao5A78L3WarM+zq61VA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOi1vP9AixEr0R7GYTse+=RW9SiPPdZao5A78L3WarM+zq61VA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Dryomov <idryomov@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Yishai Hadas <yishaih@mellanox.com>, Dan Williams <dan.j.williams@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev <netdev@vger.kernel.org>

On Thu 12-01-17 17:54:34, Ilya Dryomov wrote:
> On Thu, Jan 12, 2017 at 4:37 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > From: Michal Hocko <mhocko@suse.com>
> >
> > There are many code paths opencoding kvmalloc. Let's use the helper
> > instead. The main difference to kvmalloc is that those users are usually
> > not considering all the aspects of the memory allocator. E.g. allocation
> > requests < 64kB are basically never failing and invoke OOM killer to
> > satisfy the allocation. This sounds too disruptive for something that
> > has a reasonable fallback - the vmalloc. On the other hand those
> > requests might fallback to vmalloc even when the memory allocator would
> > succeed after several more reclaim/compaction attempts previously. There
> > is no guarantee something like that happens though.
> >
> > This patch converts many of those places to kv[mz]alloc* helpers because
> > they are more conservative.
> >
> > Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> > Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> > Cc: Anton Vorontsov <anton@enomsg.org>
> > Cc: Colin Cross <ccross@android.com>
> > Cc: Kees Cook <keescook@chromium.org>
> > Cc: Tony Luck <tony.luck@intel.com>
> > Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> > Cc: Ben Skeggs <bskeggs@redhat.com>
> > Cc: Kent Overstreet <kent.overstreet@gmail.com>
> > Cc: Santosh Raspatur <santosh@chelsio.com>
> > Cc: Hariprasad S <hariprasad@chelsio.com>
> > Cc: Tariq Toukan <tariqt@mellanox.com>
> > Cc: Yishai Hadas <yishaih@mellanox.com>
> > Cc: Dan Williams <dan.j.williams@intel.com>
> > Cc: Oleg Drokin <oleg.drokin@intel.com>
> > Cc: Andreas Dilger <andreas.dilger@intel.com>
> > Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> > Cc: David Sterba <dsterba@suse.com>
> > Cc: "Yan, Zheng" <zyan@redhat.com>
> > Cc: Ilya Dryomov <idryomov@gmail.com>
> > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > Cc: Alexei Starovoitov <ast@kernel.org>
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> > Cc: netdev@vger.kernel.org
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  arch/s390/kvm/kvm-s390.c                           | 10 ++-----
> >  crypto/lzo.c                                       |  4 +--
> >  drivers/acpi/apei/erst.c                           |  8 ++---
> >  drivers/char/agp/generic.c                         |  8 +----
> >  drivers/gpu/drm/nouveau/nouveau_gem.c              |  4 +--
> >  drivers/md/bcache/util.h                           | 12 ++------
> >  drivers/net/ethernet/chelsio/cxgb3/cxgb3_defs.h    |  3 --
> >  drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c | 25 ++--------------
> >  drivers/net/ethernet/chelsio/cxgb3/l2t.c           |  2 +-
> >  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 31 ++++----------------
> >  drivers/net/ethernet/mellanox/mlx4/en_tx.c         |  9 ++----
> >  drivers/net/ethernet/mellanox/mlx4/mr.c            |  9 ++----
> >  drivers/nvdimm/dimm_devs.c                         |  5 +---
> >  .../staging/lustre/lnet/libcfs/linux/linux-mem.c   | 11 +------
> >  drivers/xen/evtchn.c                               | 14 +--------
> >  fs/btrfs/ctree.c                                   |  9 ++----
> >  fs/btrfs/ioctl.c                                   |  9 ++----
> >  fs/btrfs/send.c                                    | 27 ++++++-----------
> >  fs/ceph/file.c                                     |  9 ++----
> >  fs/select.c                                        |  5 +---
> >  fs/xattr.c                                         | 27 ++++++-----------
> >  kernel/bpf/hashtab.c                               | 11 ++-----
> >  lib/iov_iter.c                                     |  5 +---
> >  mm/frame_vector.c                                  |  5 +---
> >  net/ipv4/inet_hashtables.c                         |  6 +---
> >  net/ipv4/tcp_metrics.c                             |  5 +---
> >  net/mpls/af_mpls.c                                 |  5 +---
> >  net/netfilter/x_tables.c                           | 34 ++++++----------------
> >  net/netfilter/xt_recent.c                          |  5 +---
> >  net/sched/sch_choke.c                              |  5 +---
> >  net/sched/sch_fq_codel.c                           | 26 ++++-------------
> >  net/sched/sch_hhf.c                                | 33 ++++++---------------
> >  net/sched/sch_netem.c                              |  6 +---
> >  net/sched/sch_sfq.c                                |  6 +---
> >  security/keys/keyctl.c                             | 22 ++++----------
> >  35 files changed, 96 insertions(+), 319 deletions(-)
> >
> > diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
> > index 4f74511015b8..e6bbb33d2956 100644
> > --- a/arch/s390/kvm/kvm-s390.c
> > +++ b/arch/s390/kvm/kvm-s390.c
> > @@ -1126,10 +1126,7 @@ static long kvm_s390_get_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
> >         if (args->count < 1 || args->count > KVM_S390_SKEYS_MAX)
> >                 return -EINVAL;
> >
> > -       keys = kmalloc_array(args->count, sizeof(uint8_t),
> > -                            GFP_KERNEL | __GFP_NOWARN);
> > -       if (!keys)
> > -               keys = vmalloc(sizeof(uint8_t) * args->count);
> > +       keys = kvmalloc(args->count * sizeof(uint8_t), GFP_KERNEL);
> >         if (!keys)
> >                 return -ENOMEM;
> >
> > @@ -1171,10 +1168,7 @@ static long kvm_s390_set_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
> >         if (args->count < 1 || args->count > KVM_S390_SKEYS_MAX)
> >                 return -EINVAL;
> >
> > -       keys = kmalloc_array(args->count, sizeof(uint8_t),
> > -                            GFP_KERNEL | __GFP_NOWARN);
> > -       if (!keys)
> > -               keys = vmalloc(sizeof(uint8_t) * args->count);
> > +       keys = kvmalloc(sizeof(uint8_t) * args->count, GFP_KERNEL);
> >         if (!keys)
> >                 return -ENOMEM;
> >
> > diff --git a/crypto/lzo.c b/crypto/lzo.c
> > index 168df784da84..218567d717d6 100644
> > --- a/crypto/lzo.c
> > +++ b/crypto/lzo.c
> > @@ -32,9 +32,7 @@ static void *lzo_alloc_ctx(struct crypto_scomp *tfm)
> >  {
> >         void *ctx;
> >
> > -       ctx = kmalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL | __GFP_NOWARN);
> > -       if (!ctx)
> > -               ctx = vmalloc(LZO1X_MEM_COMPRESS);
> > +       ctx = kvmalloc(LZO1X_MEM_COMPRESS, GFP_KERNEL);
> >         if (!ctx)
> >                 return ERR_PTR(-ENOMEM);
> >
> > diff --git a/drivers/acpi/apei/erst.c b/drivers/acpi/apei/erst.c
> > index ec4f507b524f..a2898df61744 100644
> > --- a/drivers/acpi/apei/erst.c
> > +++ b/drivers/acpi/apei/erst.c
> > @@ -513,7 +513,7 @@ static int __erst_record_id_cache_add_one(void)
> >         if (i < erst_record_id_cache.len)
> >                 goto retry;
> >         if (erst_record_id_cache.len >= erst_record_id_cache.size) {
> > -               int new_size, alloc_size;
> > +               int new_size;
> >                 u64 *new_entries;
> >
> >                 new_size = erst_record_id_cache.size * 2;
> > @@ -524,11 +524,7 @@ static int __erst_record_id_cache_add_one(void)
> >                                 pr_warn(FW_WARN "too many record IDs!\n");
> >                         return 0;
> >                 }
> > -               alloc_size = new_size * sizeof(entries[0]);
> > -               if (alloc_size < PAGE_SIZE)
> > -                       new_entries = kmalloc(alloc_size, GFP_KERNEL);
> > -               else
> > -                       new_entries = vmalloc(alloc_size);
> > +               new_entries = kvmalloc(new_size * sizeof(entries[0]), GFP_KERNEL);
> >                 if (!new_entries)
> >                         return -ENOMEM;
> >                 memcpy(new_entries, entries,
> > diff --git a/drivers/char/agp/generic.c b/drivers/char/agp/generic.c
> > index f002fa5d1887..bdf418cac8ef 100644
> > --- a/drivers/char/agp/generic.c
> > +++ b/drivers/char/agp/generic.c
> > @@ -88,13 +88,7 @@ static int agp_get_key(void)
> >
> >  void agp_alloc_page_array(size_t size, struct agp_memory *mem)
> >  {
> > -       mem->pages = NULL;
> > -
> > -       if (size <= 2*PAGE_SIZE)
> > -               mem->pages = kmalloc(size, GFP_KERNEL | __GFP_NOWARN);
> > -       if (mem->pages == NULL) {
> > -               mem->pages = vmalloc(size);
> > -       }
> > +       mem->pages = kvmalloc(size, GFP_KERNEL);
> >  }
> >  EXPORT_SYMBOL(agp_alloc_page_array);
> >
> > diff --git a/drivers/gpu/drm/nouveau/nouveau_gem.c b/drivers/gpu/drm/nouveau/nouveau_gem.c
> > index 201b52b750dd..77dd73ff126f 100644
> > --- a/drivers/gpu/drm/nouveau/nouveau_gem.c
> > +++ b/drivers/gpu/drm/nouveau/nouveau_gem.c
> > @@ -568,9 +568,7 @@ u_memcpya(uint64_t user, unsigned nmemb, unsigned size)
> >
> >         size *= nmemb;
> >
> > -       mem = kmalloc(size, GFP_KERNEL | __GFP_NOWARN);
> > -       if (!mem)
> > -               mem = vmalloc(size);
> > +       mem = kvmalloc(size, GFP_KERNEL);
> >         if (!mem)
> >                 return ERR_PTR(-ENOMEM);
> >
> > diff --git a/drivers/md/bcache/util.h b/drivers/md/bcache/util.h
> > index cf2cbc211d83..d00bcb64d3a8 100644
> > --- a/drivers/md/bcache/util.h
> > +++ b/drivers/md/bcache/util.h
> > @@ -43,11 +43,7 @@ struct closure;
> >         (heap)->used = 0;                                               \
> >         (heap)->size = (_size);                                         \
> >         _bytes = (heap)->size * sizeof(*(heap)->data);                  \
> > -       (heap)->data = NULL;                                            \
> > -       if (_bytes < KMALLOC_MAX_SIZE)                                  \
> > -               (heap)->data = kmalloc(_bytes, (gfp));                  \
> > -       if ((!(heap)->data) && ((gfp) & GFP_KERNEL))                    \
> > -               (heap)->data = vmalloc(_bytes);                         \
> > +       (heap)->data = kvmalloc(_bytes, (gfp) & GFP_KERNEL);            \
> >         (heap)->data;                                                   \
> >  })
> >
> > @@ -136,12 +132,8 @@ do {                                                                       \
> >                                                                         \
> >         (fifo)->mask = _allocated_size - 1;                             \
> >         (fifo)->front = (fifo)->back = 0;                               \
> > -       (fifo)->data = NULL;                                            \
> >                                                                         \
> > -       if (_bytes < KMALLOC_MAX_SIZE)                                  \
> > -               (fifo)->data = kmalloc(_bytes, (gfp));                  \
> > -       if ((!(fifo)->data) && ((gfp) & GFP_KERNEL))                    \
> > -               (fifo)->data = vmalloc(_bytes);                         \
> > +       (fifo)->data = kvmalloc(_bytes, (gfp) & GFP_KERNEL);            \
> >         (fifo)->data;                                                   \
> >  })
> >
> > diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_defs.h b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_defs.h
> > index 920d918ed193..f04e81f33795 100644
> > --- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_defs.h
> > +++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_defs.h
> > @@ -41,9 +41,6 @@
> >
> >  #define VALIDATE_TID 1
> >
> > -void *cxgb_alloc_mem(unsigned long size);
> > -void cxgb_free_mem(void *addr);
> > -
> >  /*
> >   * Map an ATID or STID to their entries in the corresponding TID tables.
> >   */
> > diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
> > index 76684dcb874c..606d4a3ade04 100644
> > --- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
> > +++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
> > @@ -1152,27 +1152,6 @@ static void cxgb_redirect(struct dst_entry *old, struct dst_entry *new,
> >  }
> >
> >  /*
> > - * Allocate a chunk of memory using kmalloc or, if that fails, vmalloc.
> > - * The allocated memory is cleared.
> > - */
> > -void *cxgb_alloc_mem(unsigned long size)
> > -{
> > -       void *p = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
> > -
> > -       if (!p)
> > -               p = vzalloc(size);
> > -       return p;
> > -}
> > -
> > -/*
> > - * Free memory allocated through t3_alloc_mem().
> > - */
> > -void cxgb_free_mem(void *addr)
> > -{
> > -       kvfree(addr);
> > -}
> > -
> > -/*
> >   * Allocate and initialize the TID tables.  Returns 0 on success.
> >   */
> >  static int init_tid_tabs(struct tid_info *t, unsigned int ntids,
> > @@ -1182,7 +1161,7 @@ static int init_tid_tabs(struct tid_info *t, unsigned int ntids,
> >         unsigned long size = ntids * sizeof(*t->tid_tab) +
> >             natids * sizeof(*t->atid_tab) + nstids * sizeof(*t->stid_tab);
> >
> > -       t->tid_tab = cxgb_alloc_mem(size);
> > +       t->tid_tab = kvmalloc(size, GFP_KERNEL);
> >         if (!t->tid_tab)
> >                 return -ENOMEM;
> >
> > @@ -1218,7 +1197,7 @@ static int init_tid_tabs(struct tid_info *t, unsigned int ntids,
> >
> >  static void free_tid_maps(struct tid_info *t)
> >  {
> > -       cxgb_free_mem(t->tid_tab);
> > +       kvfree(t->tid_tab);
> >  }
> >
> >  static inline void add_adapter(struct adapter *adap)
> > diff --git a/drivers/net/ethernet/chelsio/cxgb3/l2t.c b/drivers/net/ethernet/chelsio/cxgb3/l2t.c
> > index 5f226eda8cd6..c9b06501ee0c 100644
> > --- a/drivers/net/ethernet/chelsio/cxgb3/l2t.c
> > +++ b/drivers/net/ethernet/chelsio/cxgb3/l2t.c
> > @@ -444,7 +444,7 @@ struct l2t_data *t3_init_l2t(unsigned int l2t_capacity)
> >         struct l2t_data *d;
> >         int i, size = sizeof(*d) + l2t_capacity * sizeof(struct l2t_entry);
> >
> > -       d = cxgb_alloc_mem(size);
> > +       d = kvmalloc(size, GFP_KERNEL);
> >         if (!d)
> >                 return NULL;
> >
> > diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > index 6f951877430b..671695cb3c15 100644
> > --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
> > @@ -881,27 +881,6 @@ static int setup_sge_queues(struct adapter *adap)
> >         return err;
> >  }
> >
> > -/*
> > - * Allocate a chunk of memory using kmalloc or, if that fails, vmalloc.
> > - * The allocated memory is cleared.
> > - */
> > -void *t4_alloc_mem(size_t size)
> > -{
> > -       void *p = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
> > -
> > -       if (!p)
> > -               p = vzalloc(size);
> > -       return p;
> > -}
> > -
> > -/*
> > - * Free memory allocated through alloc_mem().
> > - */
> > -void t4_free_mem(void *addr)
> > -{
> > -       kvfree(addr);
> > -}
> > -
> >  static u16 cxgb_select_queue(struct net_device *dev, struct sk_buff *skb,
> >                              void *accel_priv, select_queue_fallback_t fallback)
> >  {
> > @@ -1300,7 +1279,7 @@ static int tid_init(struct tid_info *t)
> >                max_ftids * sizeof(*t->ftid_tab) +
> >                ftid_bmap_size * sizeof(long);
> >
> > -       t->tid_tab = t4_alloc_mem(size);
> > +       t->tid_tab = kvmalloc(size, GFP_KERNEL);
> >         if (!t->tid_tab)
> >                 return -ENOMEM;
> >
> > @@ -3416,7 +3395,7 @@ static int adap_init0(struct adapter *adap)
> >                 /* allocate memory to read the header of the firmware on the
> >                  * card
> >                  */
> > -               card_fw = t4_alloc_mem(sizeof(*card_fw));
> > +               card_fw = kvmalloc(sizeof(*card_fw), GFP_KERNEL);
> >
> >                 /* Get FW from from /lib/firmware/ */
> >                 ret = request_firmware(&fw, fw_info->fw_mod_name,
> > @@ -3436,7 +3415,7 @@ static int adap_init0(struct adapter *adap)
> >
> >                 /* Cleaning up */
> >                 release_firmware(fw);
> > -               t4_free_mem(card_fw);
> > +               kvfree(card_fw);
> >
> >                 if (ret < 0)
> >                         goto bye;
> > @@ -4432,9 +4411,9 @@ static void free_some_resources(struct adapter *adapter)
> >  {
> >         unsigned int i;
> >
> > -       t4_free_mem(adapter->l2t);
> > +       kvfree(adapter->l2t);
> >         t4_cleanup_sched(adapter);
> > -       t4_free_mem(adapter->tids.tid_tab);
> > +       kvfree(adapter->tids.tid_tab);
> >         cxgb4_cleanup_tc_u32(adapter);
> >         kfree(adapter->sge.egr_map);
> >         kfree(adapter->sge.ingr_map);
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > index 5886ad78058f..a5c1b815145e 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > @@ -70,13 +70,10 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
> >         ring->full_size = ring->size - HEADROOM - MAX_DESC_TXBBS;
> >
> >         tmp = size * sizeof(struct mlx4_en_tx_info);
> > -       ring->tx_info = kmalloc_node(tmp, GFP_KERNEL | __GFP_NOWARN, node);
> > +       ring->tx_info = kvmalloc_node(tmp, GFP_KERNEL, node);
> >         if (!ring->tx_info) {
> > -               ring->tx_info = vmalloc(tmp);
> > -               if (!ring->tx_info) {
> > -                       err = -ENOMEM;
> > -                       goto err_ring;
> > -               }
> > +               err = -ENOMEM;
> > +               goto err_ring;
> >         }
> >
> >         en_dbg(DRV, priv, "Allocated tx_info ring at addr:%p size:%d\n",
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
> > index 395b5463cfd9..82354fd0a87e 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/mr.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
> > @@ -115,12 +115,9 @@ static int mlx4_buddy_init(struct mlx4_buddy *buddy, int max_order)
> >
> >         for (i = 0; i <= buddy->max_order; ++i) {
> >                 s = BITS_TO_LONGS(1 << (buddy->max_order - i));
> > -               buddy->bits[i] = kcalloc(s, sizeof (long), GFP_KERNEL | __GFP_NOWARN);
> > -               if (!buddy->bits[i]) {
> > -                       buddy->bits[i] = vzalloc(s * sizeof(long));
> > -                       if (!buddy->bits[i])
> > -                               goto err_out_free;
> > -               }
> > +               buddy->bits[i] = kvzalloc(s * sizeof(long), GFP_KERNEL);
> > +               if (!buddy->bits[i])
> > +                       goto err_out_free;
> >         }
> >
> >         set_bit(0, buddy->bits[buddy->max_order]);
> > diff --git a/drivers/nvdimm/dimm_devs.c b/drivers/nvdimm/dimm_devs.c
> > index 0eedc49e0d47..3bd332b167d9 100644
> > --- a/drivers/nvdimm/dimm_devs.c
> > +++ b/drivers/nvdimm/dimm_devs.c
> > @@ -102,10 +102,7 @@ int nvdimm_init_config_data(struct nvdimm_drvdata *ndd)
> >                 return -ENXIO;
> >         }
> >
> > -       ndd->data = kmalloc(ndd->nsarea.config_size, GFP_KERNEL);
> > -       if (!ndd->data)
> > -               ndd->data = vmalloc(ndd->nsarea.config_size);
> > -
> > +       ndd->data = kvmalloc(ndd->nsarea.config_size, GFP_KERNEL);
> >         if (!ndd->data)
> >                 return -ENOMEM;
> >
> > diff --git a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c b/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
> > index a6a76a681ea9..8f638267e704 100644
> > --- a/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
> > +++ b/drivers/staging/lustre/lnet/libcfs/linux/linux-mem.c
> > @@ -45,15 +45,6 @@ EXPORT_SYMBOL(libcfs_kvzalloc);
> >  void *libcfs_kvzalloc_cpt(struct cfs_cpt_table *cptab, int cpt, size_t size,
> >                           gfp_t flags)
> >  {
> > -       void *ret;
> > -
> > -       ret = kzalloc_node(size, flags | __GFP_NOWARN,
> > -                          cfs_cpt_spread_node(cptab, cpt));
> > -       if (!ret) {
> > -               WARN_ON(!(flags & (__GFP_FS | __GFP_HIGH)));
> > -               ret = vmalloc_node(size, cfs_cpt_spread_node(cptab, cpt));
> > -       }
> > -
> > -       return ret;
> > +       return kvzalloc_node(size, flags, cfs_cpt_spread_node(cptab, cpt));
> >  }
> >  EXPORT_SYMBOL(libcfs_kvzalloc_cpt);
> > diff --git a/drivers/xen/evtchn.c b/drivers/xen/evtchn.c
> > index 6890897a6f30..10f1ef582659 100644
> > --- a/drivers/xen/evtchn.c
> > +++ b/drivers/xen/evtchn.c
> > @@ -87,18 +87,6 @@ struct user_evtchn {
> >         bool enabled;
> >  };
> >
> > -static evtchn_port_t *evtchn_alloc_ring(unsigned int size)
> > -{
> > -       evtchn_port_t *ring;
> > -       size_t s = size * sizeof(*ring);
> > -
> > -       ring = kmalloc(s, GFP_KERNEL);
> > -       if (!ring)
> > -               ring = vmalloc(s);
> > -
> > -       return ring;
> > -}
> > -
> >  static void evtchn_free_ring(evtchn_port_t *ring)
> >  {
> >         kvfree(ring);
> > @@ -334,7 +322,7 @@ static int evtchn_resize_ring(struct per_user_data *u)
> >         else
> >                 new_size = 2 * u->ring_size;
> >
> > -       new_ring = evtchn_alloc_ring(new_size);
> > +       new_ring = kvmalloc(new_size * sizeof(*new_ring), GFP_KERNEL);
> >         if (!new_ring)
> >                 return -ENOMEM;
> >
> > diff --git a/fs/btrfs/ctree.c b/fs/btrfs/ctree.c
> > index 146b2dc0d2cf..4fc9712d927d 100644
> > --- a/fs/btrfs/ctree.c
> > +++ b/fs/btrfs/ctree.c
> > @@ -5391,13 +5391,10 @@ int btrfs_compare_trees(struct btrfs_root *left_root,
> >                 goto out;
> >         }
> >
> > -       tmp_buf = kmalloc(fs_info->nodesize, GFP_KERNEL | __GFP_NOWARN);
> > +       tmp_buf = kvmalloc(fs_info->nodesize, GFP_KERNEL);
> >         if (!tmp_buf) {
> > -               tmp_buf = vmalloc(fs_info->nodesize);
> > -               if (!tmp_buf) {
> > -                       ret = -ENOMEM;
> > -                       goto out;
> > -               }
> > +               ret = -ENOMEM;
> > +               goto out;
> >         }
> >
> >         left_path->search_commit_root = 1;
> > diff --git a/fs/btrfs/ioctl.c b/fs/btrfs/ioctl.c
> > index 77dabfed3a5d..6f0b488c7428 100644
> > --- a/fs/btrfs/ioctl.c
> > +++ b/fs/btrfs/ioctl.c
> > @@ -3547,12 +3547,9 @@ static int btrfs_clone(struct inode *src, struct inode *inode,
> >         u64 last_dest_end = destoff;
> >
> >         ret = -ENOMEM;
> > -       buf = kmalloc(fs_info->nodesize, GFP_KERNEL | __GFP_NOWARN);
> > -       if (!buf) {
> > -               buf = vmalloc(fs_info->nodesize);
> > -               if (!buf)
> > -                       return ret;
> > -       }
> > +       buf = kvmalloc(fs_info->nodesize, GFP_KERNEL);
> > +       if (!buf)
> > +               return ret;
> >
> >         path = btrfs_alloc_path();
> >         if (!path) {
> > diff --git a/fs/btrfs/send.c b/fs/btrfs/send.c
> > index d145ce804620..0621ca2a7b5d 100644
> > --- a/fs/btrfs/send.c
> > +++ b/fs/btrfs/send.c
> > @@ -6242,22 +6242,16 @@ long btrfs_ioctl_send(struct file *mnt_file, void __user *arg_)
> >         sctx->clone_roots_cnt = arg->clone_sources_count;
> >
> >         sctx->send_max_size = BTRFS_SEND_BUF_SIZE;
> > -       sctx->send_buf = kmalloc(sctx->send_max_size, GFP_KERNEL | __GFP_NOWARN);
> > +       sctx->send_buf = kvmalloc(sctx->send_max_size, GFP_KERNEL);
> >         if (!sctx->send_buf) {
> > -               sctx->send_buf = vmalloc(sctx->send_max_size);
> > -               if (!sctx->send_buf) {
> > -                       ret = -ENOMEM;
> > -                       goto out;
> > -               }
> > +               ret = -ENOMEM;
> > +               goto out;
> >         }
> >
> > -       sctx->read_buf = kmalloc(BTRFS_SEND_READ_SIZE, GFP_KERNEL | __GFP_NOWARN);
> > +       sctx->read_buf = kvmalloc(BTRFS_SEND_READ_SIZE, GFP_KERNEL);
> >         if (!sctx->read_buf) {
> > -               sctx->read_buf = vmalloc(BTRFS_SEND_READ_SIZE);
> > -               if (!sctx->read_buf) {
> > -                       ret = -ENOMEM;
> > -                       goto out;
> > -               }
> > +               ret = -ENOMEM;
> > +               goto out;
> >         }
> >
> >         sctx->pending_dir_moves = RB_ROOT;
> > @@ -6278,13 +6272,10 @@ long btrfs_ioctl_send(struct file *mnt_file, void __user *arg_)
> >         alloc_size = arg->clone_sources_count * sizeof(*arg->clone_sources);
> >
> >         if (arg->clone_sources_count) {
> > -               clone_sources_tmp = kmalloc(alloc_size, GFP_KERNEL | __GFP_NOWARN);
> > +               clone_sources_tmp = kvmalloc(alloc_size, GFP_KERNEL);
> >                 if (!clone_sources_tmp) {
> > -                       clone_sources_tmp = vmalloc(alloc_size);
> > -                       if (!clone_sources_tmp) {
> > -                               ret = -ENOMEM;
> > -                               goto out;
> > -                       }
> > +                       ret = -ENOMEM;
> > +                       goto out;
> >                 }
> >
> >                 ret = copy_from_user(clone_sources_tmp, arg->clone_sources,
> > diff --git a/fs/ceph/file.c b/fs/ceph/file.c
> > index 045d30d26624..78b18acf33ba 100644
> > --- a/fs/ceph/file.c
> > +++ b/fs/ceph/file.c
> > @@ -74,12 +74,9 @@ dio_get_pages_alloc(const struct iov_iter *it, size_t nbytes,
> >         align = (unsigned long)(it->iov->iov_base + it->iov_offset) &
> >                 (PAGE_SIZE - 1);
> >         npages = calc_pages_for(align, nbytes);
> > -       pages = kmalloc(sizeof(*pages) * npages, GFP_KERNEL);
> > -       if (!pages) {
> > -               pages = vmalloc(sizeof(*pages) * npages);
> > -               if (!pages)
> > -                       return ERR_PTR(-ENOMEM);
> > -       }
> > +       pages = kvmalloc(sizeof(*pages) * npages, GFP_KERNEL);
> > +       if (!pages)
> > +               return ERR_PTR(-ENOMEM);
> 
> ceph hunk looks fine:
> 
> Acked-by: Ilya Dryomov <idryomov@gmail.com>

thanks!

[...]

> However I noticed that in some cases you've dropped the zeroing part:
> fq_codel_init() and hhf_zalloc() zeroed both k and v, and some others
> were inconsistent and zeroed only k.  Given that the fallback branch
> was probably dead, I'd keep the k behaviour.  Was that intentional?

No, that is an omission. Thanks for noticing. I will send the updated
patch.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
