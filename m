Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id DBDE86B0069
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 10:32:46 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y44so3184039wrd.16
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 07:32:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t29si9082828wrb.315.2017.10.02.07.32.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 02 Oct 2017 07:32:44 -0700 (PDT)
Date: Mon, 2 Oct 2017 16:32:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: crash during new kmem-limited memory cgroup creation if
 kmem_cache has been created when previous memory cgroup were inactive
Message-ID: <20171002143244.lrp5nd2rf3lmjsql@dhcp22.suse.cz>
References: <0537E873-CE22-4E6D-912A-6C8FDCF85493@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0537E873-CE22-4E6D-912A-6C8FDCF85493@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Faccini, Bruno" <bruno.faccini@intel.com>
Cc: "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org

[CC Vldimir and linux-mm]

On Tue 19-09-17 22:42:37, Faccini, Bruno wrote:
> The panic threada??s stack looks like :
> ============================
> [38212.118675] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> [38212.120795] IP: [<ffffffff811dbb04>] __memcg_kmem_get_cache+0xe4/0x220
> [38212.121489] PGD 310c0a067 PUD 28e92c067 PMD 0 
> [38212.122192] Oops: 0000 [#1] SMP DEBUG_PAGEALLOC
> [38212.122849] Modules linked in: lustre(OE) ofd(OE) osp(OE) lod(OE) ost(OE) mdt(OE) mdd(OE) mgs(OE) osd_zfs(OE) lquota(OE) lfsck(OE) obdecho(OE) mgc(OE) lov(OE) osc(OE) mdc(OE) lmv(OE) fid(OE) fld(OE) ptlrpc_gss(OE) ptlrpc(OE) obdclass(OE) ksocklnd(OE) lnet(OE) libcfs(OE) brd ext4 mbcache loop zfs(PO) zunicode(PO) zavl(PO) icp(PO) zcommon(PO) znvpair(PO) spl(O) zlib_deflate jbd2 syscopyarea sysfillrect ata_generic sysimgblt pata_acpi ttm drm_kms_helper ata_piix drm i2c_piix4 libata serio_raw virtio_balloon pcspkr virtio_console i2c_core virtio_blk floppy nfsd ip_tables rpcsec_gss_krb5 [last unloaded: libcfs]
> [38212.145920] CPU: 2 PID: 31539 Comm: dd Tainted: P        W  OE  ------------   3.10.0-debug #2
> [38212.147177] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
> [38212.147821] task: ffff8802f2bf4800 ti: ffff880294f20000 task.ti: ffff880294f20000
> [38212.152755] RIP: 0010:[<ffffffff811dbb04>]  [<ffffffff811dbb04>] __memcg_kmem_get_cache+0xe4/0x220
> [38212.153730] RSP: 0018:ffff880294f237f0  EFLAGS: 00010286
> [38212.154194] RAX: 0000000000000000 RBX: ffff8803232c5c40 RCX: 0000000000000002
> [38212.154672] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000246
> [38212.155168] RBP: ffff880294f23810 R08: 0000000000000000 R09: 0000000000000000
> [38212.155647] R10: 0000000000000000 R11: 0000000200000007 R12: ffff8802f2bf4800
> [38212.156134] R13: ffff88031f6a6000 R14: ffff8803232c5c40 R15: ffff8803232c5c40
> [38212.156898] FS:  00007f1f35a4e740(0000) GS:ffff88033e440000(0000) knlGS:0000000000000000
> [38212.159271] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [38212.159923] CR2: 0000000000000008 CR3: 00000002f011d000 CR4: 00000000000006e0
> [38212.160625] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [38212.161320] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [38212.163273] Stack:
> [38212.163852]  ffffffff811dba68 0000000000008050 ffff8802c59a5000 ffff8802a991ee00
> [38212.165119]  ffff880294f238a0 ffffffff811cca5c ffffffffa0570615 ffffc9000ab51000
> [38212.166468]  ffff880200000127 ffffffffa05a5547 ffff88028b683e80 ffff8803232c5c40
> [38212.168537] Call Trace:
> [38212.169340]  [<ffffffff811dba68>] ? __memcg_kmem_get_cache+0x48/0x220
> [38212.170547]  [<ffffffff811cca5c>] kmem_cache_alloc+0x1ec/0x640
> [38212.171879]  [<ffffffffa0570615>] ? ldlm_resource_putref+0x75/0x400 [ptlrpc]
> [38212.172659]  [<ffffffffa05a5547>] ? ptlrpc_request_cache_alloc+0x27/0x110 [ptlrpc]
> [38212.174145]  [<ffffffffa07c0f0d>] ? mdc_resource_get_unused+0x14d/0x2a0 [mdc]
> [38212.174871]  [<ffffffffa05a5547>] ptlrpc_request_cache_alloc+0x27/0x110 [ptlrpc]
> [38212.177273]  [<ffffffffa05a5655>] ptlrpc_request_alloc_internal+0x25/0x480 [ptlrpc]
> [38212.178618]  [<ffffffffa05a5ac3>] ptlrpc_request_alloc+0x13/0x20 [ptlrpc]
> [38212.179440]  [<ffffffffa07c6a60>] mdc_enqueue_base+0x6c0/0x18a0 [mdc]
> [38212.180168]  [<ffffffffa07c845b>] mdc_intent_lock+0x26b/0x520 [mdc]
> [38212.180869]  [<ffffffffa161dad0>] ? ll_invalidate_negative_children+0x1e0/0x1e0 [lustre]
> [38212.182291]  [<ffffffffa0584ab0>] ? ldlm_expired_completion_wait+0x240/0x240 [ptlrpc]
> [38212.183569]  [<ffffffffa079723d>] lmv_intent_lock+0xc0d/0x1b50 [lmv]
> [38212.184289]  [<ffffffff810ac3c1>] ? in_group_p+0x31/0x40
> [38212.184941]  [<ffffffffa161e5c5>] ? ll_i2suppgid+0x15/0x40 [lustre]
> [38212.185667]  [<ffffffffa161e614>] ? ll_i2gids+0x24/0xb0 [lustre]
> [38212.186372]  [<ffffffff811073d2>] ? from_kgid+0x12/0x20
> [38212.187062]  [<ffffffffa1609275>] ? ll_prep_md_op_data+0x235/0x520 [lustre]
> [38212.187754]  [<ffffffffa161dad0>] ? ll_invalidate_negative_children+0x1e0/0x1e0 [lustre]
> [38212.190244]  [<ffffffffa161fd34>] ll_lookup_it+0x2a4/0xef0 [lustre]
> [38212.190918]  [<ffffffffa1620ab7>] ll_atomic_open+0x137/0x12d0 [lustre]
> [38212.191636]  [<ffffffff817063d7>] ? _raw_spin_unlock+0x27/0x40
> [38212.192425]  [<ffffffff811f82fb>] ? lookup_dcache+0x8b/0xb0
> [38212.193270]  [<ffffffff811fd551>] do_last+0xa21/0x12b0
> [38212.194603]  [<ffffffff811fdea2>] path_openat+0xc2/0x4a0
> [38212.195481]  [<ffffffff811ff69b>] do_filp_open+0x4b/0xb0
> [38212.196351]  [<ffffffff817063d7>] ? _raw_spin_unlock+0x27/0x40
> [38212.197169]  [<ffffffff8120d137>] ? __alloc_fd+0xa7/0x130
> [38212.197815]  [<ffffffff811ec553>] do_sys_open+0xf3/0x1f0
> [38212.198506]  [<ffffffff811ec66e>] SyS_open+0x1e/0x20
> [38212.199225]  [<ffffffff8170fc49>] system_call_fastpath+0x16/0x1b
> [38212.199896] Code: 01 00 00 41 f6 85 10 03 00 00 03 0f 84 f6 00 00 00 4d 85 ed 48 c7 c2 ff ff ff ff 74 07 49 63 95 98 06 00 00 48 8b 83 e0 00 00 00 <4c> 8b 64 d0 08 4d 85 e4 0f 85 d1 00 00 00 41 f6 45 10 01 0f 84 
> [38212.202617] RIP  [<ffffffff811dbb04>] __memcg_kmem_get_cache+0xe4/0x220
> [38212.203345]  RSP <ffff880294f237f0>
> ============================
> and we can easily trigger it when running one of our regression test that is intended to test our software robustness against lack of Kernel memory, by setting very restrictive kmem limit for a memory cgroup where testa??s tasks/contexts will be attached during their execution.
> 
> The crash occurs, because one of Lustre recently created kmem_cache has no memcg_params  allocated :
> ===========================
> struct kmem_cache *__memcg_kmem_get_cache(struct kmem_cache *cachep,
>                                           gfp_t gfp)
> {
>         struct mem_cgroup *memcg;
>         int idx;
> 
>         VM_BUG_ON(!cachep->memcg_params); <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< VM_BUG_ON() is undefined ...
>         VM_BUG_ON(!cachep->memcg_params->is_root_cache);
> 
>         if (!current->mm || current->memcg_kmem_skip_account)
>                 return cachep;
> 
>         rcu_read_lock();
>         memcg = mem_cgroup_from_task(rcu_dereference(current->mm->owner));
> 
>         if (!memcg_can_account_kmem(memcg))
>                 goto out;
> 
>         idx = memcg_cache_id(memcg);
> 
>         /*
>          * barrier to mare sure we're always seeing the up to date value.  The
>          * code updating memcg_caches will issue a write barrier to match this.
>          */
>         read_barrier_depends();
>         if (likely(cachep->memcg_params->memcg_caches[idx])) {  <<<<<<<<<<<<<<<<< Oops is here!
>                 cachep = cachep->memcg_params->memcg_caches[idx];
>                 goto out;
>         }
> a?|a?|a?|a?|a?|
> ===========================
> 
> It took me sometime to find how/why this could happen, but finally the only possible scenario is that kmem_cache has been created when previous memory cgroup were already inactive, thus its memcg_params had not been populated in memcg_register_cache(), when called from kmem_cache_create()/kmem_cache_create_memcg() :
> ===========================
> int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
>                          struct kmem_cache *root_cache)
> {
>         size_t size = sizeof(struct memcg_cache_params);
> 
>         if (!memcg_kmem_enabled()) <<<<<<<<<<<<<<<<< true if no more kmem memcg activea?|.
>                 return 0;
> 
>         if (!memcg)
>                 size += memcg_limited_groups_array_size * sizeof(void *);
> 
>         s->memcg_params = kzalloc(size, GFP_KERNEL); <<<<<<<<<<<<<<<<<<<<<<< not done!
> a?|a?|a?|a?|a?|...
> ===========================
> 
> nor in memcg_update_cache_size() when a new memcg will be created but its id has already been pre-created :
> ===========================
> #define MEMCG_CACHES_MIN_SIZE 4
> 
> static size_t memcg_caches_array_size(int num_groups)
> {
>         ssize_t size;
>         if (num_groups <= 0)
>                 return 0;
> 
>         size = 2 * num_groups;
>         if (size < MEMCG_CACHES_MIN_SIZE)
>                 size = MEMCG_CACHES_MIN_SIZE;
>         else if (size > MEMCG_CACHES_MAX_SIZE)
>                 size = MEMCG_CACHES_MAX_SIZE;
> 
>         return size;
> }
> 
> int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
> {
>         struct memcg_cache_params *cur_params = s->memcg_params;
> 
>         VM_BUG_ON(s->memcg_params && !s->memcg_params->is_root_cache);
> 
>         if (num_groups > memcg_limited_groups_array_size) { <<<<<<<<<<<<<<<< false if num_groups already pre-created!
>                 int i;
>                 ssize_t size = memcg_caches_array_size(num_groups);
> 
>                 size *= sizeof(void *);
>                 size += sizeof(struct memcg_cache_params);
> 
>                 s->memcg_params = kzalloc(size, GFP_KERNEL); <<<<<<<<<<<<<<< not done!
> a?|a?|a?|a?|a?|a?|.
> ===========================
> 
> This issue seems to be already fixed in 4.x Kernels due to memcg_params now being an embedded struct into kmem_cache instead of a pointer to be allocated in 3.x Kernels and where this problem seems to be still present.
> 
> And I guess there are 2 possible ways to fix this problem, during either new kmem-limted memory cgroup create/init :
> ===========================
> # diff -urN orig/mm/memcontrol.c bfi/mm/memcontrol.c
> --a?? orig/mm/memcontrol.c     2016-06-09 06:31:12.000000000 -0700
> +++ bfi/mm/memcontrol.c      2017-09-08 07:37:18.647281366 -0700
> @@ -3163,7 +3163,15 @@ int memcg_update_cache_size(struct kmem_cache *s, int num_groups)
>  
>         VM_BUG_ON(s->memcg_params && !s->memcg_params->is_root_cache);
>  
> -       if (num_groups > memcg_limited_groups_array_size) {
> +       /* resize/grow existing memcg_params or allocate it if had not already
> +        * been done during kmem_cache creation because none of previously used
> +        * kmem memcg were present at this time (i.e.
> +        * memcg_limited_groups_array_size != 0 but memcg_kmem_enabled()
> +        * returned false). It could not have been necessary if
> +        * memcg_caches_array_size() was not used to anticipate more than slots
> +        * required and if memcg_limited_groups_array_size would simply
> +        * increment upon each new kmem memcg creation.
> +       if (num_groups > memcg_limited_groups_array_size || !s->memcg_params) {
>                 int i;
>                 ssize_t size = memcg_caches_array_size(num_groups);
>  
> @@ -3203,7 +3211,8 @@
>                  * bigger than the others. And all updates will reset this
>                  * anyway.
>                  */
> -               kfree(cur_params);
> +               if (cur_params)
> +                       kfree(cur_params);
>         }
>         return 0;
>  }                                                                                                                                                                                                             
> ===========================
> 
> or immediately during new kmem_cache creation :
> ===========================
> # diff -urN orig/mm/memcontrol.c bfi/mm/memcontrol.c
> a??-- orig/mm/memcontrol.c     2016-06-09 06:31:12.000000000 -0700
> +++ bfi/mm/memcontrol.c        2017-09-12 09:24:53.235452071 -0700
> @@ -3213,7 +3213,7 @@ int memcg_register_cache(struct mem_cgroup *memcg, struct kmem_cache *s,
>  {
>         size_t size = sizeof(struct memcg_cache_params);
>  
> -       if (!memcg_kmem_enabled())
> +       if (!memcg_kmem_enabled() && memcg_limited_groups_array_size == 0)
>                 return 0;
>  
>         if (!memcg)
> ===========================
> 
> 
> ---------------------------------------------------------------------
> Intel Corporation SAS (French simplified joint stock company)
> Registered headquarters: "Les Montalets"- 2, rue de Paris, 
> 92196 Meudon Cedex, France
> Registration Number:  302 456 199 R.C.S. NANTERRE
> Capital: 4,572,000 Euros
> 
> This e-mail and any attachments may contain confidential material for
> the sole use of the intended recipient(s). Any review or distribution
> by others is strictly prohibited. If you are not the intended
> recipient, please contact the sender and delete all copies.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
