Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 73AF06B0253
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 10:52:38 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e20so56675898itc.0
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 07:52:38 -0700 (PDT)
Received: from gateway33.websitewelcome.com (gateway33.websitewelcome.com. [192.185.145.33])
        by mx.google.com with ESMTPS id m30si12343000oik.179.2016.09.14.07.52.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 07:52:20 -0700 (PDT)
Received: from cm7.websitewelcome.com (cm7.websitewelcome.com [108.167.139.20])
	by gateway33.websitewelcome.com (Postfix) with ESMTP id 246848EE667A0
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 09:52:20 -0500 (CDT)
Received: from mail-it0-f47.google.com ([209.85.214.47]:38516)
	by gator3309.hostgator.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128)
	(Exim 4.86_1)
	(envelope-from <trapexit@spawn.link>)
	id 1bkBXt-000KSN-Vb
	for linux-mm@kvack.org; Wed, 14 Sep 2016 09:52:18 -0500
Received: by mail-it0-f47.google.com with SMTP id n143so27648681ita.1
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 07:52:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160914143102.GA1445@cmpxchg.org>
References: <CAB3-ZyQ4Mbj2g6b6Zt4pGLhE7ew9O==rNbUgAaPLYSwdRK3Czw@mail.gmail.com>
 <CAJfpeguMfoK+foKxUeSLOw0aD=U+ya6BgpRm2XnFfKx3w2Nfpg@mail.gmail.com>
 <20160909194239.GA16056@cmpxchg.org> <CAJfpegv3Hk3WtGG0gQ+TGpyoH0CoTf=um8gUdV8KA-ZneQ8+JA@mail.gmail.com>
 <20160914143102.GA1445@cmpxchg.org>
From: Antonio SJ Musumeci <trapexit@spawn.link>
Date: Wed, 14 Sep 2016 10:51:36 -0400
Message-ID: <CAB3-ZyR=V2fPYVGOs=j=O_-zTh45KAXXdxQ-LO9Q9qAnUR-_-w@mail.gmail.com>
Subject: Re: [fuse-devel] Kernel panic under load
Content-Type: multipart/alternative; boundary=001a113eb96c19e271053c78e0c5
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, fuse-devel <fuse-devel@lists.sourceforge.net>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

--001a113eb96c19e271053c78e0c5
Content-Type: text/plain; charset=UTF-8

I was unable to reproduce the problem but I'll forward this on to my user
and see if they can test it.

I imagine the users would prefer it backported though they have worked
around the problem by turning off splicing.

On Wed, Sep 14, 2016 at 10:31 AM, Johannes Weiner <hannes@cmpxchg.org>
wrote:

> Hi Miklos,
>
> On Tue, Sep 13, 2016 at 10:42:17AM +0200, Miklos Szeredi wrote:
> > Fuse allows pages to be spliced into the page cache when reading the
> > file.  It does this with replace_page_cache_page(), which is an atomic
> > version of delete_from_page_cache()+add_to_page_cache().
> >
> > Fuse is the only user of replace_page_cache_page(), so I imagine bugs
> > can more easily escape notice than the more commonly used variants.
> >
> > Could you please take a look at this function.  "git blame" shows that
> > it's older than the add/remove variants, but I haven't gone into the
> > details.
>
> Indeed, replace_page_cache_page() uses a properly accounted deletion
> of the old page followed by a raw, untracked radix_tree_insert(). It
> would lead to an underflow that triggers the page counter assertion.
>
> Thanks for the pointer, Miklos. This has been broken for a while.
>
> Antonio, does the following patch resolve the issue for you? It
> applies to the head of Linus's tree, let me know if you need it
> backported to a different base.
>
> ---
>
> From 3a2bb511f5e04019ccc487ef995b94700db172e7 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Wed, 14 Sep 2016 09:50:42 -0400
> Subject: [PATCH] mm: workingset: fix shadow node leak in
>  replace_page_cache_page()
>
> Antonio reports the following crash when using fuse under memory
> pressure:
>
> [25192.515454] kernel BUG at /build/linux-a2WvEb/linux-4.4.
> 0/mm/workingset.c:346!
> [25192.517521] invalid opcode: 0000 [#1] SMP
> [25192.519602] Modules linked in: netconsole ip6t_REJECT nf_reject_ipv6
> ipt_REJECT nf_reject_ipv4 configfs binfmt_misc veth bridge stp llc
> nf_conntrack_ipv6 nf_defrag_ipv6 xt_conntrack ip6table_filter ip6_tables
> xt_multiport iptable_filter ipt_MASQUERADE nf_nat_masquerade_ipv4
> xt_comment xt_nat iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4
> nf_nat nf_conntrack xt_CHECKSUM xt_tcpudp iptable_mangle ip_tables x_tables
> intel_rapl x86_pkg_temp_thermal intel_powerclamp eeepc_wmi asus_wmi
> coretemp sparse_keymap kvm_intel ppdev kvm irqbypass mei_me 8250_fintek
> input_leds serio_raw parport_pc tpm_infineon mei shpchp mac_hid parport
> lpc_ich autofs4 drbg ansi_cprng dm_crypt algif_skcipher af_alg btrfs
> raid456 async_raid6_recov async_memcpy async_pq async_xor async_tx xor
> raid6_pq libcrc32c raid0 multipath linear raid10 raid1 i915
> crct10dif_pclmul crc32_pclmul aesni_intel i2c_algo_bit aes_x86_64
> drm_kms_helper lrw gf128mul glue_helper ablk_helper syscopyarea cryptd
> sysfillrect sysimgblt fb_sys_fops drm ahci r8169 libahci mii wmi fjes video
> [last unloaded: netconsole]
> [25192.540910] CPU: 2 PID: 63 Comm: kswapd0 Not tainted 4.4.0-36-generic
> #55-Ubuntu
> [25192.543411] Hardware name: System manufacturer System Product
> Name/P8H67-M PRO, BIOS 3904 04/27/2013
> [25192.545840] task: ffff88040cae6040 ti: ffff880407488000 task.ti:
> ffff880407488000
> [25192.548277] RIP: 0010:[<ffffffff811ba501>]  [<ffffffff811ba501>]
> shadow_lru_isolate+0x181/0x190
> [25192.550706] RSP: 0018:ffff88040748bbe0  EFLAGS: 00010002
> [25192.553127] RAX: 0000000000001c81 RBX: ffff8802f91ee928 RCX:
> ffff8802f91eeb38
> [25192.555544] RDX: ffff8802f91ee938 RSI: ffff8802f91ee928 RDI:
> ffff8804099ba2c0
> [25192.557914] RBP: ffff88040748bc08 R08: 000000000001a7b6 R09:
> 000000000000003f
> [25192.560237] R10: 000000000001a750 R11: 0000000000000000 R12:
> ffff8804099ba2c0
> [25192.562512] R13: ffff8803157e9680 R14: ffff8803157e9668 R15:
> ffff8804099ba2c8
> [25192.564724] FS:  0000000000000000(0000) GS:ffff88041f280000(0000)
> knlGS:0000000000000000
> [25192.566990] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [25192.569201] CR2: 00007ffabb690000 CR3: 0000000001e0a000 CR4:
> 00000000000406e0
> [25192.571419] Stack:
> [25192.573550]  ffff8804099ba2c0 ffff88039e4f86f0 ffff8802f91ee928
> ffff8804099ba2c8
> [25192.575695]  ffff88040748bd08 ffff88040748bc58 ffffffff811b99bf
> 0000000000000052
> [25192.577814]  0000000000000000 ffffffff811ba380 000000000000008a
> 0000000000000080
> [25192.579947] Call Trace:
> [25192.582022]  [<ffffffff811b99bf>] __list_lru_walk_one.isra.3+0x8f/0x130
> [25192.584137]  [<ffffffff811ba380>] ? memcg_drain_all_list_lrus+
> 0x190/0x190
> [25192.586165]  [<ffffffff811b9a83>] list_lru_walk_one+0x23/0x30
> [25192.588145]  [<ffffffff811ba544>] scan_shadow_nodes+0x34/0x50
> [25192.590074]  [<ffffffff811a0e9d>] shrink_slab.part.40+0x1ed/0x3d0
> [25192.591985]  [<ffffffff811a53da>] shrink_zone+0x2ca/0x2e0
> [25192.593863]  [<ffffffff811a64ce>] kswapd+0x51e/0x990
> [25192.595737]  [<ffffffff811a5fb0>] ? mem_cgroup_shrink_node_zone+
> 0x1c0/0x1c0
> [25192.597613]  [<ffffffff810a0808>] kthread+0xd8/0xf0
> [25192.599495]  [<ffffffff810a0730>] ? kthread_create_on_node+0x1e0/0x1e0
> [25192.601335]  [<ffffffff8182e34f>] ret_from_fork+0x3f/0x70
> [25192.603193]  [<ffffffff810a0730>] ? kthread_create_on_node+0x1e0/0x1e0
> [25192.605083] Code: 8d 7e 08 4c 89 fe e8 4f cc 23 00 84 c0 74 20 4c 89 ef
> c6 07 00 66 66 66 90 bb 01 00 00 00 e9 c5 fe ff ff 0f 0b 0f 0b 0f 0b 0f 0b
> <0f> 0b 0f 0b 0f 0b 66 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55
> [25192.609252] RIP  [<ffffffff811ba501>] shadow_lru_isolate+0x181/0x190
> [25192.611304]  RSP <ffff88040748bbe0>
>
> which corresponds to the following sanity check in the shadow node
> tracking:
>
>   BUG_ON(node->count & RADIX_TREE_COUNT_MASK);
>
> The workingset code tracks radix tree nodes that exclusively contain
> shadow entries of evicted pages in them, and this (somewhat obscure)
> checks if there are real pages left that would interfere with reclaim
> of the radix tree node under memory pressure.
>
> Discussing ways of how fuse might sneak pages into the radix tree past
> the workingset code, Miklos pointed to replace_page_cache_page(), and
> indeed there is a problem there: it properly accounts for the old page
> being removed (__delete_from_page_cache() does that), but then does a
> raw raw radix_tree_insert(), not accounting for the replacement page;
> the page counter bits in node->count eventually underflow.
>
> To address this, make sure replace_page_cache_page() uses the tracked
> page insertion code, page_cache_tree_insert().
>
> Also, make the sanity checks a bit less obscure by using the helpers
> for checking the number of pages and shadows in a radix tree node.
>
> Fixes: 449dd6984d0e ("mm: keep page cache radix tree nodes in check")
> Cc: stable@vger.kernel.org # 3.15+
> Reported-by: Antonio SJ Musumeci <trapexit@spawn.link>
> Debugged-by: Miklos Szeredi <miklos@szeredi.hu>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  include/linux/swap.h |   2 +
>  mm/filemap.c         | 114 +++++++++++++++++++++++++-----
> ---------------------
>  mm/workingset.c      |  10 ++---
>  3 files changed, 63 insertions(+), 63 deletions(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index b17cc4830fa6..4a529c984a3f 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -257,6 +257,7 @@ static inline void workingset_node_pages_inc(struct
> radix_tree_node *node)
>
>  static inline void workingset_node_pages_dec(struct radix_tree_node
> *node)
>  {
> +       VM_BUG_ON(!workingset_node_pages(node));
>         node->count--;
>  }
>
> @@ -272,6 +273,7 @@ static inline void workingset_node_shadows_inc(struct
> radix_tree_node *node)
>
>  static inline void workingset_node_shadows_dec(struct radix_tree_node
> *node)
>  {
> +       VM_BUG_ON(!workingset_node_shadows(node));
>         node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
>  }
>
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 8a287dfc5372..2d0986a64f1f 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -110,6 +110,62 @@
>   *   ->tasklist_lock            (memory_failure, collect_procs_ao)
>   */
>
> +static int page_cache_tree_insert(struct address_space *mapping,
> +                                 struct page *page, void **shadowp)
> +{
> +       struct radix_tree_node *node;
> +       void **slot;
> +       int error;
> +
> +       error = __radix_tree_create(&mapping->page_tree, page->index, 0,
> +                                   &node, &slot);
> +       if (error)
> +               return error;
> +       if (*slot) {
> +               void *p;
> +
> +               p = radix_tree_deref_slot_protected(slot,
> &mapping->tree_lock);
> +               if (!radix_tree_exceptional_entry(p))
> +                       return -EEXIST;
> +
> +               mapping->nrexceptional--;
> +               if (!dax_mapping(mapping)) {
> +                       if (shadowp)
> +                               *shadowp = p;
> +                       if (node)
> +                               workingset_node_shadows_dec(node);
> +               } else {
> +                       /* DAX can replace empty locked entry with a hole
> */
> +                       WARN_ON_ONCE(p !=
> +                               (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
> +                                        RADIX_DAX_ENTRY_LOCK));
> +                       /* DAX accounts exceptional entries as normal
> pages */
> +                       if (node)
> +                               workingset_node_pages_dec(node);
> +                       /* Wakeup waiters for exceptional entry lock */
> +                       dax_wake_mapping_entry_waiter(mapping,
> page->index,
> +                                                     false);
> +               }
> +       }
> +       radix_tree_replace_slot(slot, page);
> +       mapping->nrpages++;
> +       if (node) {
> +               workingset_node_pages_inc(node);
> +               /*
> +                * Don't track node that contains actual pages.
> +                *
> +                * Avoid acquiring the list_lru lock if already
> +                * untracked.  The list_empty() test is safe as
> +                * node->private_list is protected by
> +                * mapping->tree_lock.
> +                */
> +               if (!list_empty(&node->private_list))
> +                       list_lru_del(&workingset_shadow_nodes,
> +                                    &node->private_list);
> +       }
> +       return 0;
> +}
> +
>  static void page_cache_tree_delete(struct address_space *mapping,
>                                    struct page *page, void *shadow)
>  {
> @@ -561,7 +617,7 @@ int replace_page_cache_page(struct page *old, struct
> page *new, gfp_t gfp_mask)
>
>                 spin_lock_irqsave(&mapping->tree_lock, flags);
>                 __delete_from_page_cache(old, NULL);
> -               error = radix_tree_insert(&mapping->page_tree, offset,
> new);
> +               error = page_cache_tree_insert(mapping, new, NULL);
>                 BUG_ON(error);
>                 mapping->nrpages++;
>
> @@ -584,62 +640,6 @@ int replace_page_cache_page(struct page *old, struct
> page *new, gfp_t gfp_mask)
>  }
>  EXPORT_SYMBOL_GPL(replace_page_cache_page);
>
> -static int page_cache_tree_insert(struct address_space *mapping,
> -                                 struct page *page, void **shadowp)
> -{
> -       struct radix_tree_node *node;
> -       void **slot;
> -       int error;
> -
> -       error = __radix_tree_create(&mapping->page_tree, page->index, 0,
> -                                   &node, &slot);
> -       if (error)
> -               return error;
> -       if (*slot) {
> -               void *p;
> -
> -               p = radix_tree_deref_slot_protected(slot,
> &mapping->tree_lock);
> -               if (!radix_tree_exceptional_entry(p))
> -                       return -EEXIST;
> -
> -               mapping->nrexceptional--;
> -               if (!dax_mapping(mapping)) {
> -                       if (shadowp)
> -                               *shadowp = p;
> -                       if (node)
> -                               workingset_node_shadows_dec(node);
> -               } else {
> -                       /* DAX can replace empty locked entry with a hole
> */
> -                       WARN_ON_ONCE(p !=
> -                               (void *)(RADIX_TREE_EXCEPTIONAL_ENTRY |
> -                                        RADIX_DAX_ENTRY_LOCK));
> -                       /* DAX accounts exceptional entries as normal
> pages */
> -                       if (node)
> -                               workingset_node_pages_dec(node);
> -                       /* Wakeup waiters for exceptional entry lock */
> -                       dax_wake_mapping_entry_waiter(mapping,
> page->index,
> -                                                     false);
> -               }
> -       }
> -       radix_tree_replace_slot(slot, page);
> -       mapping->nrpages++;
> -       if (node) {
> -               workingset_node_pages_inc(node);
> -               /*
> -                * Don't track node that contains actual pages.
> -                *
> -                * Avoid acquiring the list_lru lock if already
> -                * untracked.  The list_empty() test is safe as
> -                * node->private_list is protected by
> -                * mapping->tree_lock.
> -                */
> -               if (!list_empty(&node->private_list))
> -                       list_lru_del(&workingset_shadow_nodes,
> -                                    &node->private_list);
> -       }
> -       return 0;
> -}
> -
>  static int __add_to_page_cache_locked(struct page *page,
>                                       struct address_space *mapping,
>                                       pgoff_t offset, gfp_t gfp_mask,
> diff --git a/mm/workingset.c b/mm/workingset.c
> index 69551cfae97b..617475f529f4 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -418,21 +418,19 @@ static enum lru_status shadow_lru_isolate(struct
> list_head *item,
>          * no pages, so we expect to be able to remove them all and
>          * delete and free the empty node afterwards.
>          */
> -
> -       BUG_ON(!node->count);
> -       BUG_ON(node->count & RADIX_TREE_COUNT_MASK);
> +       BUG_ON(!workingset_node_shadows(node));
> +       BUG_ON(workingset_node_pages(node));
>
>         for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
>                 if (node->slots[i]) {
>                         BUG_ON(!radix_tree_exceptional_entry(node->slots[
> i]));
>                         node->slots[i] = NULL;
> -                       BUG_ON(node->count < (1U <<
> RADIX_TREE_COUNT_SHIFT));
> -                       node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
> +                       workingset_node_shadows_dec(node);
>                         BUG_ON(!mapping->nrexceptional);
>                         mapping->nrexceptional--;
>                 }
>         }
> -       BUG_ON(node->count);
> +       BUG_ON(workingset_node_shadows(node));
>         inc_node_state(page_pgdat(virt_to_page(node)),
> WORKINGSET_NODERECLAIM);
>         if (!__radix_tree_delete_node(&mapping->page_tree, node))
>                 BUG();
> --
> 2.9.3
>

--001a113eb96c19e271053c78e0c5
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">I was unable to reproduce the problem but I&#39;ll forward=
 this on to my user and see if they can test it.<div><br></div><div>I imagi=
ne the users would prefer it backported though they have worked around the =
problem by turning off splicing.</div></div><div class=3D"gmail_extra"><br>=
<div class=3D"gmail_quote">On Wed, Sep 14, 2016 at 10:31 AM, Johannes Weine=
r <span dir=3D"ltr">&lt;<a href=3D"mailto:hannes@cmpxchg.org" target=3D"_bl=
ank">hannes@cmpxchg.org</a>&gt;</span> wrote:<br><blockquote class=3D"gmail=
_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:=
1ex">Hi Miklos,<br>
<br>
On Tue, Sep 13, 2016 at 10:42:17AM +0200, Miklos Szeredi wrote:<br>
&gt; Fuse allows pages to be spliced into the page cache when reading the<b=
r>
&gt; file.=C2=A0 It does this with replace_page_cache_page(), which is an a=
tomic<br>
&gt; version of delete_from_page_cache()+add_<wbr>to_page_cache().<br>
&gt;<br>
&gt; Fuse is the only user of replace_page_cache_page(), so I imagine bugs<=
br>
&gt; can more easily escape notice than the more commonly used variants.<br=
>
&gt;<br>
&gt; Could you please take a look at this function.=C2=A0 &quot;git blame&q=
uot; shows that<br>
&gt; it&#39;s older than the add/remove variants, but I haven&#39;t gone in=
to the<br>
&gt; details.<br>
<br>
Indeed, replace_page_cache_page() uses a properly accounted deletion<br>
of the old page followed by a raw, untracked radix_tree_insert(). It<br>
would lead to an underflow that triggers the page counter assertion.<br>
<br>
Thanks for the pointer, Miklos. This has been broken for a while.<br>
<br>
Antonio, does the following patch resolve the issue for you? It<br>
applies to the head of Linus&#39;s tree, let me know if you need it<br>
backported to a different base.<br>
<br>
---<br>
<br>
>From 3a2bb511f5e04019ccc487ef995b94<wbr>700db172e7 Mon Sep 17 00:00:00 2001=
<br>
From: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">hannes@cmpx=
chg.org</a>&gt;<br>
Date: Wed, 14 Sep 2016 09:50:42 -0400<br>
Subject: [PATCH] mm: workingset: fix shadow node leak in<br>
=C2=A0replace_page_cache_page()<br>
<br>
Antonio reports the following crash when using fuse under memory<br>
pressure:<br>
<br>
[25192.515454] kernel BUG at /build/linux-a2WvEb/linux-4.4.<wbr>0/mm/workin=
gset.c:346!<br>
[25192.517521] invalid opcode: 0000 [#1] SMP<br>
[25192.519602] Modules linked in: netconsole ip6t_REJECT nf_reject_ipv6 ipt=
_REJECT nf_reject_ipv4 configfs binfmt_misc veth bridge stp llc nf_conntrac=
k_ipv6 nf_defrag_ipv6 xt_conntrack ip6table_filter ip6_tables xt_multiport =
iptable_filter ipt_MASQUERADE nf_nat_masquerade_ipv4 xt_comment xt_nat ipta=
ble_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack xt=
_CHECKSUM xt_tcpudp iptable_mangle ip_tables x_tables intel_rapl x86_pkg_te=
mp_thermal intel_powerclamp eeepc_wmi asus_wmi coretemp sparse_keymap kvm_i=
ntel ppdev kvm irqbypass mei_me 8250_fintek input_leds serio_raw parport_pc=
 tpm_infineon mei shpchp mac_hid parport lpc_ich autofs4 drbg ansi_cprng dm=
_crypt algif_skcipher af_alg btrfs raid456 async_raid6_recov async_memcpy a=
sync_pq async_xor async_tx xor raid6_pq libcrc32c raid0 multipath linear ra=
id10 raid1 i915 crct10dif_pclmul crc32_pclmul aesni_intel i2c_algo_bit aes_=
x86_64 drm_kms_helper lrw gf128mul glue_helper ablk_helper syscopyarea cryp=
td sysfillrect sysimgblt fb_sys_fops drm ahci r8169 libahci mii wmi fjes vi=
deo [last unloaded: netconsole]<br>
[25192.540910] CPU: 2 PID: 63 Comm: kswapd0 Not tainted 4.4.0-36-generic #5=
5-Ubuntu<br>
[25192.543411] Hardware name: System manufacturer System Product Name/P8H67=
-M PRO, BIOS 3904 04/27/2013<br>
[25192.545840] task: ffff88040cae6040 ti: ffff880407488000 task.ti: ffff880=
407488000<br>
[25192.548277] RIP: 0010:[&lt;ffffffff811ba501&gt;]=C2=A0 [&lt;ffffffff811b=
a501&gt;] shadow_lru_isolate+0x181/0x190<br>
[25192.550706] RSP: 0018:ffff88040748bbe0=C2=A0 EFLAGS: 00010002<br>
[25192.553127] RAX: 0000000000001c81 RBX: ffff8802f91ee928 RCX: ffff8802f91=
eeb38<br>
[25192.555544] RDX: ffff8802f91ee938 RSI: ffff8802f91ee928 RDI: ffff8804099=
ba2c0<br>
[25192.557914] RBP: ffff88040748bc08 R08: 000000000001a7b6 R09: 00000000000=
0003f<br>
[25192.560237] R10: 000000000001a750 R11: 0000000000000000 R12: ffff8804099=
ba2c0<br>
[25192.562512] R13: ffff8803157e9680 R14: ffff8803157e9668 R15: ffff8804099=
ba2c8<br>
[25192.564724] FS:=C2=A0 0000000000000000(0000) GS:ffff88041f280000(0000) k=
nlGS:0000000000000000<br>
[25192.566990] CS:=C2=A0 0010 DS: 0000 ES: 0000 CR0: 0000000080050033<br>
[25192.569201] CR2: 00007ffabb690000 CR3: 0000000001e0a000 CR4: 00000000000=
406e0<br>
[25192.571419] Stack:<br>
[25192.573550]=C2=A0 ffff8804099ba2c0 ffff88039e4f86f0 ffff8802f91ee928 fff=
f8804099ba2c8<br>
[25192.575695]=C2=A0 ffff88040748bd08 ffff88040748bc58 ffffffff811b99bf 000=
0000000000052<br>
[25192.577814]=C2=A0 0000000000000000 ffffffff811ba380 000000000000008a 000=
0000000000080<br>
[25192.579947] Call Trace:<br>
[25192.582022]=C2=A0 [&lt;ffffffff811b99bf&gt;] __list_lru_walk_one.isra.3+=
<wbr>0x8f/0x130<br>
[25192.584137]=C2=A0 [&lt;ffffffff811ba380&gt;] ? memcg_drain_all_list_lrus=
+<wbr>0x190/0x190<br>
[25192.586165]=C2=A0 [&lt;ffffffff811b9a83&gt;] list_lru_walk_one+0x23/0x30=
<br>
[25192.588145]=C2=A0 [&lt;ffffffff811ba544&gt;] scan_shadow_nodes+0x34/0x50=
<br>
[25192.590074]=C2=A0 [&lt;ffffffff811a0e9d&gt;] shrink_slab.part.40+0x1ed/<=
wbr>0x3d0<br>
[25192.591985]=C2=A0 [&lt;ffffffff811a53da&gt;] shrink_zone+0x2ca/0x2e0<br>
[25192.593863]=C2=A0 [&lt;ffffffff811a64ce&gt;] kswapd+0x51e/0x990<br>
[25192.595737]=C2=A0 [&lt;ffffffff811a5fb0&gt;] ? mem_cgroup_shrink_node_zo=
ne+<wbr>0x1c0/0x1c0<br>
[25192.597613]=C2=A0 [&lt;ffffffff810a0808&gt;] kthread+0xd8/0xf0<br>
[25192.599495]=C2=A0 [&lt;ffffffff810a0730&gt;] ? kthread_create_on_node+0x=
1e0/<wbr>0x1e0<br>
[25192.601335]=C2=A0 [&lt;ffffffff8182e34f&gt;] ret_from_fork+0x3f/0x70<br>
[25192.603193]=C2=A0 [&lt;ffffffff810a0730&gt;] ? kthread_create_on_node+0x=
1e0/<wbr>0x1e0<br>
[25192.605083] Code: 8d 7e 08 4c 89 fe e8 4f cc 23 00 84 c0 74 20 4c 89 ef =
c6 07 00 66 66 66 90 bb 01 00 00 00 e9 c5 fe ff ff 0f 0b 0f 0b 0f 0b 0f 0b =
&lt;0f&gt; 0b 0f 0b 0f 0b 66 0f 1f 84 00 00 00 00 00 66 66 66 66 90 55<br>
[25192.609252] RIP=C2=A0 [&lt;ffffffff811ba501&gt;] shadow_lru_isolate+0x18=
1/0x190<br>
[25192.611304]=C2=A0 RSP &lt;ffff88040748bbe0&gt;<br>
<br>
which corresponds to the following sanity check in the shadow node<br>
tracking:<br>
<br>
=C2=A0 BUG_ON(node-&gt;count &amp; RADIX_TREE_COUNT_MASK);<br>
<br>
The workingset code tracks radix tree nodes that exclusively contain<br>
shadow entries of evicted pages in them, and this (somewhat obscure)<br>
checks if there are real pages left that would interfere with reclaim<br>
of the radix tree node under memory pressure.<br>
<br>
Discussing ways of how fuse might sneak pages into the radix tree past<br>
the workingset code, Miklos pointed to replace_page_cache_page(), and<br>
indeed there is a problem there: it properly accounts for the old page<br>
being removed (__delete_from_page_cache() does that), but then does a<br>
raw raw radix_tree_insert(), not accounting for the replacement page;<br>
the page counter bits in node-&gt;count eventually underflow.<br>
<br>
To address this, make sure replace_page_cache_page() uses the tracked<br>
page insertion code, page_cache_tree_insert().<br>
<br>
Also, make the sanity checks a bit less obscure by using the helpers<br>
for checking the number of pages and shadows in a radix tree node.<br>
<br>
Fixes: 449dd6984d0e (&quot;mm: keep page cache radix tree nodes in check&qu=
ot;)<br>
Cc: <a href=3D"mailto:stable@vger.kernel.org">stable@vger.kernel.org</a> # =
3.15+<br>
Reported-by: Antonio SJ Musumeci &lt;trapexit@spawn.link&gt;<br>
Debugged-by: Miklos Szeredi &lt;<a href=3D"mailto:miklos@szeredi.hu">miklos=
@szeredi.hu</a>&gt;<br>
Signed-off-by: Johannes Weiner &lt;<a href=3D"mailto:hannes@cmpxchg.org">ha=
nnes@cmpxchg.org</a>&gt;<br>
---<br>
=C2=A0include/linux/swap.h |=C2=A0 =C2=A02 +<br>
=C2=A0mm/filemap.c=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| 114 +++++++++++++++++=
++++++++-----<wbr>---------------------<br>
=C2=A0mm/workingset.c=C2=A0 =C2=A0 =C2=A0 |=C2=A0 10 ++---<br>
=C2=A03 files changed, 63 insertions(+), 63 deletions(-)<br>
<br>
diff --git a/include/linux/swap.h b/include/linux/swap.h<br>
index b17cc4830fa6..4a529c984a3f 100644<br>
--- a/include/linux/swap.h<br>
+++ b/include/linux/swap.h<br>
@@ -257,6 +257,7 @@ static inline void workingset_node_pages_inc(<wbr>struc=
t radix_tree_node *node)<br>
<br>
=C2=A0static inline void workingset_node_pages_dec(<wbr>struct radix_tree_n=
ode *node)<br>
=C2=A0{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON(!workingset_node_<wbr>pages(node));<b=
r>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 node-&gt;count--;<br>
=C2=A0}<br>
<br>
@@ -272,6 +273,7 @@ static inline void workingset_node_shadows_inc(<wbr>str=
uct radix_tree_node *node)<br>
<br>
=C2=A0static inline void workingset_node_shadows_dec(<wbr>struct radix_tree=
_node *node)<br>
=C2=A0{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON(!workingset_node_<wbr>shadows(node));=
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 node-&gt;count -=3D 1U &lt;&lt; RADIX_TREE_COUN=
T_SHIFT;<br>
=C2=A0}<br>
<br>
diff --git a/mm/filemap.c b/mm/filemap.c<br>
index 8a287dfc5372..2d0986a64f1f 100644<br>
--- a/mm/filemap.c<br>
+++ b/mm/filemap.c<br>
@@ -110,6 +110,62 @@<br>
=C2=A0 *=C2=A0 =C2=A0-&gt;tasklist_lock=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 (memory_failure, collect_procs_ao)<br>
=C2=A0 */<br>
<br>
+static int page_cache_tree_insert(struct address_space *mapping,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page, void **shad=
owp)<br>
+{<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0struct radix_tree_node *node;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0void **slot;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0int error;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D __radix_tree_create(&amp;mapping-&gt;=
<wbr>page_tree, page-&gt;index, 0,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&amp;node, &amp;slot);<=
br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (error)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return error;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (*slot) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0void *p;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0p =3D radix_tree_de=
ref_slot_<wbr>protected(slot, &amp;mapping-&gt;tree_lock);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!radix_tree_exc=
eptional_<wbr>entry(p))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return -EEXIST;<br>
+<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mapping-&gt;nrexcep=
tional--;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!dax_mapping(ma=
pping)) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (shadowp)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*shadowp =3D p;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (node)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0workingset_node_shadows_dec(<wbr>node=
);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* DAX can replace empty locked entry with a hole */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0WARN_ON_ONCE(p !=3D<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(void *)(RADIX_TREE_EXCEPTIONAL_<wbr>=
ENTRY |<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 RADIX_DA=
X_ENTRY_LOCK));<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* DAX accounts exceptional entries as normal pages */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (node)<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0workingset_node_pages_dec(<wbr>node);=
<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* Wakeup waiters for exceptional entry lock */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0dax_wake_mapping_entry_waiter(<wbr>mapping, page-&gt;index,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0false);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0radix_tree_replace_slot(slot, page);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0mapping-&gt;nrpages++;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0if (node) {<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0workingset_node_pag=
es_inc(<wbr>node);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Don&#39;t track =
node that contains actual pages.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Avoid acquiring =
the list_lru lock if already<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * untracked.=C2=A0=
 The list_empty() test is safe as<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * node-&gt;private=
_list is protected by<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * mapping-&gt;tree=
_lock.<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!list_empty(&am=
p;node-&gt;private_<wbr>list))<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0list_lru_del(&amp;workingset_<wbr>shadow_nodes,<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &amp;node-&gt;private_=
list);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;<br>
+}<br>
+<br>
=C2=A0static void page_cache_tree_delete(struct address_space *mapping,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page, void=
 *shadow)<br>
=C2=A0{<br>
@@ -561,7 +617,7 @@ int replace_page_cache_page(struct page *old, struct pa=
ge *new, gfp_t gfp_mask)<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irqsave(&=
amp;mapping-&gt;<wbr>tree_lock, flags);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 __delete_from_page_=
cache(old, NULL);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D radix_tre=
e_insert(&amp;mapping-&gt;<wbr>page_tree, offset, new);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D page_cach=
e_tree_insert(<wbr>mapping, new, NULL);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG_ON(error);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mapping-&gt;nrpages=
++;<br>
<br>
@@ -584,62 +640,6 @@ int replace_page_cache_page(struct page *old, struct p=
age *new, gfp_t gfp_mask)<br>
=C2=A0}<br>
=C2=A0EXPORT_SYMBOL_GPL(replace_<wbr>page_cache_page);<br>
<br>
-static int page_cache_tree_insert(struct address_space *mapping,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page, void **shad=
owp)<br>
-{<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0struct radix_tree_node *node;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0void **slot;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0int error;<br>
-<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0error =3D __radix_tree_create(&amp;mapping-&gt;=
<wbr>page_tree, page-&gt;index, 0,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&amp;node, &amp;slot);<=
br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (error)<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return error;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (*slot) {<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0void *p;<br>
-<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0p =3D radix_tree_de=
ref_slot_<wbr>protected(slot, &amp;mapping-&gt;tree_lock);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!radix_tree_exc=
eptional_<wbr>entry(p))<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0return -EEXIST;<br>
-<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mapping-&gt;nrexcep=
tional--;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!dax_mapping(ma=
pping)) {<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (shadowp)<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*shadowp =3D p;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (node)<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0workingset_node_shadows_dec(<wbr>node=
);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0} else {<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* DAX can replace empty locked entry with a hole */<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0WARN_ON_ONCE(p !=3D<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0(void *)(RADIX_TREE_EXCEPTIONAL_<wbr>=
ENTRY |<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 RADIX_DA=
X_ENTRY_LOCK));<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* DAX accounts exceptional entries as normal pages */<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0if (node)<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0workingset_node_pages_dec(<wbr>node);=
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0/* Wakeup waiters for exceptional entry lock */<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0dax_wake_mapping_entry_waiter(<wbr>mapping, page-&gt;index,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0false);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0radix_tree_replace_slot(slot, page);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0mapping-&gt;nrpages++;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0if (node) {<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0workingset_node_pag=
es_inc(<wbr>node);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Don&#39;t track =
node that contains actual pages.<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 *<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Avoid acquiring =
the list_lru lock if already<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * untracked.=C2=A0=
 The list_empty() test is safe as<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * node-&gt;private=
_list is protected by<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * mapping-&gt;tree=
_lock.<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!list_empty(&am=
p;node-&gt;private_<wbr>list))<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0list_lru_del(&amp;workingset_<wbr>shadow_nodes,<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &amp;node-&gt;private_=
list);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0}<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;<br>
-}<br>
-<br>
=C2=A0static int __add_to_page_cache_locked(<wbr>struct page *page,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct address_=
space *mapping,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 pgoff_t offset,=
 gfp_t gfp_mask,<br>
diff --git a/mm/workingset.c b/mm/workingset.c<br>
index 69551cfae97b..617475f529f4 100644<br>
--- a/mm/workingset.c<br>
+++ b/mm/workingset.c<br>
@@ -418,21 +418,19 @@ static enum lru_status shadow_lru_isolate(struct list=
_head *item,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* no pages, so we expect to be able to re=
move them all and<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* delete and free the empty node afterwar=
ds.<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/<br>
-<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(!node-&gt;count);<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(node-&gt;count &amp; RADIX_TREE_COUNT_MA=
SK);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(!workingset_node_<wbr>shadows(node));<br=
>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(workingset_node_pages(<wbr>node));<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 for (i =3D 0; i &lt; RADIX_TREE_MAP_SIZE; i++) =
{<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (node-&gt;slots[=
i]) {<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 BUG_ON(!radix_tree_<wbr>exceptional_entry(node-&gt;slots[<wbr>i]=
));<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 node-&gt;slots[i] =3D NULL;<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0BUG_ON(node-&gt;count &lt; (1U &lt;&lt; RADIX_TREE_COUNT_SHIFT));=
<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0node-&gt;count -=3D 1U &lt;&lt; RADIX_TREE_COUNT_SHIFT;<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0workingset_node_shadows_dec(<wbr>node);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 BUG_ON(!mapping-&gt;<wbr>nrexceptional);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 mapping-&gt;nrexceptional--;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
-=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(node-&gt;count);<br>
+=C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(workingset_node_<wbr>shadows(node));<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 inc_node_state(page_pgdat(<wbr>virt_to_page(nod=
e)), WORKINGSET_NODERECLAIM);<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!__radix_tree_delete_node(&amp;<wbr>mapping=
-&gt;page_tree, node))<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 BUG();<br>
<span class=3D"HOEnZb"><font color=3D"#888888">--<br>
2.9.3<br>
</font></span></blockquote></div><br></div>

--001a113eb96c19e271053c78e0c5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
