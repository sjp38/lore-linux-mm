Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id C7B4C6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 17:04:21 -0400 (EDT)
Date: Tue, 6 Aug 2013 01:01:28 +0400
From: Andrew Vagin <avagin@parallels.com>
Subject: Re: [PATCH] memcg: don't initialize kmem-cache destroying work for
 root caches
Message-ID: <20130805210128.GA2772@paralelels.com>
References: <1375718980-22154-1-git-send-email-avagin@openvz.org>
 <20130805130530.fd38ec4866ba7f1d9a400218@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Content-Disposition: inline
In-Reply-To: <20130805130530.fd38ec4866ba7f1d9a400218@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Vagin <avagin@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Glauber Costa <glommer@openvz.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, stable@vger.kernel.org

On Mon, Aug 05, 2013 at 01:05:30PM -0700, Andrew Morton wrote:
> On Mon,  5 Aug 2013 20:09:40 +0400 Andrey Vagin <avagin@openvz.org> wrote:
> 
> > struct memcg_cache_params has a union. Different parts of this union
> > are used for root and non-root caches. A part with destroying work is
> > used only for non-root caches.
> > 
> > I fixed the same problem in another place v3.9-rc1-16204-gf101a94, but
> > didn't notice this one.
> > 
> > Cc: <stable@vger.kernel.org>    [3.9.x]
> 
> hm, why the cc:stable?

Because this patch fixes the kernel panic:

[   46.848187] BUG: unable to handle kernel paging request at 000000fffffffeb8
[   46.849026] IP: [<ffffffff811a484c>] kmem_cache_destroy_memcg_children+0x6c/0xc0
[   46.849092] PGD 0
[   46.849092] Oops: 0000 [#1] SMP
[   46.849092] Modules linked in: vzethdev vznetdev pio_direct pfmt_raw pfmt_ploop1 ploop simfs ipt_MASQUERADE nf_conntrack_netbios_ns nf_conntrack_broadcast ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables vzevent microcode joydev pcspkr virtio_balloon i2c_piix4 i2c_core virtio_net virtio_blk floppy
[   46.849092] CPU 0
[   46.849092] Pid: 6, comm: kworker/u:0 ve: 0 Not tainted 3.9.4+ #42 ovz.2.4 Red Hat KVM
[   46.849092] RIP: 0010:[<ffffffff811a484c>]  [<ffffffff811a484c>] kmem_cache_destroy_memcg_children+0x6c/0xc0
[   46.849092] RSP: 0018:ffff88007c7dfcd8  EFLAGS: 00010206
[   46.849092] RAX: ffff88007b65f180 RBX: 000000fffffffe00 RCX: 0000000000000004
[   46.849092] RDX: 0000000000000005 RSI: ffff88007fc17cc8 RDI: ffffffff81c5e5a0
[   46.849092] RBP: ffff88007c7dfcf8 R08: ffffea0001ee1b20 R09: 0000000000000000
[   46.849092] R10: ffff88007fbe5fe0 R11: 0000000000000000 R12: 0000000000000005
[   46.849092] R13: ffff88007b8c2400 R14: 0000000000000000 R15: ffff88007c008005
[   46.849092] FS:  0000000000000000(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000
[   46.849092] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   46.849092] CR2: 000000fffffffeb8 CR3: 00000000375a3000 CR4: 00000000000006f0
[   46.849092] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   46.849092] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   46.849092] Process kworker/u:0 (pid: 6, ve: 0, threadinfo ffff88007c7de000, task ffff88007c7e8000)
[   46.849092] Stack:
[   46.849092]  ffff88007bc90870 ffff88007b8c2400 ffff88007bc90000 ffff88007bc90870
[   46.849092]  ffff88007c7dfd18 ffffffff81166a14 0000000080000003 ffff88007bc90000
[   46.849092]  ffff88007c7dfd48 ffffffffa007b3c8 ffff88007c7dfd48 ffff88007bc90000
[   46.849092] Call Trace:
[   46.849092]  [<ffffffff81166a14>] kmem_cache_destroy+0x14/0xf0
[   46.849092]  [<ffffffffa007b3c8>] nf_conntrack_cleanup_net+0xf8/0x120 [nf_conntrack]
[   46.849092]  [<ffffffffa007d221>] nf_conntrack_pernet_exit+0x41/0x50 [nf_conntrack]
[   46.849092]  [<ffffffff81536779>] ops_exit_list+0x39/0x60
[   46.849092]  [<ffffffff81536cfb>] cleanup_net+0xfb/0x200
[   46.849092]  [<ffffffff8107f43b>] process_one_work+0x17b/0x3d0
[   46.849092]  [<ffffffff81082639>] worker_thread+0x119/0x380
[   46.849092]  [<ffffffff81082520>] ? manage_workers+0x350/0x350
[   46.849092]  [<ffffffff8108796e>] kthread+0xce/0xe0
[   46.849092]  [<ffffffff810878a0>] ? kthread_freezable_should_stop+0x70/0x70
[   46.849092]  [<ffffffff8163faec>] ret_from_fork+0x7c/0xb0
[   46.849092]  [<ffffffff810878a0>] ? kthread_freezable_should_stop+0x70/0x70
[   46.849092] Code: fb 48 00 8b 1d 6e f0 1d 01 85 db 7e 4e 45 31 e4 0f 1f 80 00 00 00 00 49 8b 85 b8 00 00 00 49 63 d4 48 8b 5c d0 08 48 85 db 74 23 <48> 8b 83 b8 00 00 00 c6 40 28 00 48 8b bb b8 00 00 00 48 83 c7

This bug was added by v3.9-rc1-221-g15cf17d

> 
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -3195,11 +3195,11 @@ int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
> >  	if (!s->memcg_params)
> >  		return -ENOMEM;
> >  
> > -	INIT_WORK(&s->memcg_params->destroy,
> > -			kmem_cache_destroy_work_func);
> >  	if (memcg) {
> >  		s->memcg_params->memcg = memcg;
> >  		s->memcg_params->root_cache = root_cache;
> > +		INIT_WORK(&s->memcg_params->destroy,
> > +				kmem_cache_destroy_work_func);
> >  	} else
> >  		s->memcg_params->is_root_cache = true;
> 
> So the bug here is that we'll scribble on some entries in
> memcg_caches[].  Those scribbles may or may not be within the part of
> that array which is actually used.  If there's code which expects
> memcg_caches[] entries to be zeroed at initialisation then yes, we have
> a problem.

INIT_WORK() sets s->memcg_params->memcg_caches[5] to 0xfffffffe00.

Look at kmem_cache_destroy_memcg_children()

        for (i = 0; i < memcg_limited_groups_array_size; i++) {
                c = s->memcg_params->memcg_caches[i];
                if (!c)
                        continue;
...
		c->memcg_params->dead = false;

This code tries dereference 0xfffffffe00->dead and the kernel panics

> 
> But I rather doubt whether this bug was causing runtime problems?
> 
> 
> Presently memcg_register_cache() allocates too much memory for the
> memcg_caches[] array.  If that was fixed then this INIT_WORK() might
> scribble into unknown memory, which is of course serious.

Looks like you find another bug:

struct memcg_cache_params {
        bool is_root_cache;
        union {
                struct kmem_cache *memcg_caches[0];
                struct {
                        struct mem_cgroup *memcg;
                        struct list_head list;
                        struct kmem_cache *root_cache;
                        bool dead;
                        atomic_t nr_pages;
                        struct work_struct destroy;
                };
        };
};

The size of this strcture is 80 bytes, then look at memcg_register_cache()

size_t size = sizeof(struct memcg_cache_params);

if (!memcg_kmem_enabled())
        return 0;

if (!memcg)
        size += memcg_limited_groups_array_size * sizeof(void *);

s->memcg_params = kzalloc(size, GFP_KERNEL);

Actually it allocates too much memory. It allocates memory as if struct
memcg_cache_params would have been written without union.

Actually you already suggested to rework this code
https://lkml.org/lkml/2013/5/28/585

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
