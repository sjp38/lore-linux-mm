Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA5E6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 12:26:11 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id m98so33938209iod.2
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 09:26:11 -0800 (PST)
Received: from mail-io0-x22a.google.com (mail-io0-x22a.google.com. [2607:f8b0:4001:c06::22a])
        by mx.google.com with ESMTPS id h2si2443745ite.54.2017.01.12.09.26.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 09:26:10 -0800 (PST)
Received: by mail-io0-x22a.google.com with SMTP id j18so23770361ioe.2
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 09:26:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170112153717.28943-6-mhocko@kernel.org>
References: <20170112153717.28943-1-mhocko@kernel.org> <20170112153717.28943-6-mhocko@kernel.org>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 12 Jan 2017 09:26:09 -0800
Message-ID: <CAGXu5jKhYP=5YNuntzmG64WL92F59VKhByOh9nqaGP7-LBEnng@mail.gmail.com>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded variants
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Yishai Hadas <yishaih@mellanox.com>, Dan Williams <dan.j.williams@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Network Development <netdev@vger.kernel.org>

On Thu, Jan 12, 2017 at 7:37 AM, Michal Hocko <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> There are many code paths opencoding kvmalloc. Let's use the helper
> instead. The main difference to kvmalloc is that those users are usually
> not considering all the aspects of the memory allocator. E.g. allocation
> requests < 64kB are basically never failing and invoke OOM killer to
> satisfy the allocation. This sounds too disruptive for something that
> has a reasonable fallback - the vmalloc. On the other hand those
> requests might fallback to vmalloc even when the memory allocator would
> succeed after several more reclaim/compaction attempts previously. There
> is no guarantee something like that happens though.
>
> This patch converts many of those places to kv[mz]alloc* helpers because
> they are more conservative.
>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Anton Vorontsov <anton@enomsg.org>
> Cc: Colin Cross <ccross@android.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Tony Luck <tony.luck@intel.com>
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Ben Skeggs <bskeggs@redhat.com>
> Cc: Kent Overstreet <kent.overstreet@gmail.com>
> Cc: Santosh Raspatur <santosh@chelsio.com>
> Cc: Hariprasad S <hariprasad@chelsio.com>
> Cc: Tariq Toukan <tariqt@mellanox.com>
> Cc: Yishai Hadas <yishaih@mellanox.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Oleg Drokin <oleg.drokin@intel.com>
> Cc: Andreas Dilger <andreas.dilger@intel.com>
> Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Cc: David Sterba <dsterba@suse.com>
> Cc: "Yan, Zheng" <zyan@redhat.com>
> Cc: Ilya Dryomov <idryomov@gmail.com>
> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  arch/s390/kvm/kvm-s390.c                           | 10 ++-----
>  crypto/lzo.c                                       |  4 +--
>  drivers/acpi/apei/erst.c                           |  8 ++---
>  drivers/char/agp/generic.c                         |  8 +----
>  drivers/gpu/drm/nouveau/nouveau_gem.c              |  4 +--
>  drivers/md/bcache/util.h                           | 12 ++------
>  drivers/net/ethernet/chelsio/cxgb3/cxgb3_defs.h    |  3 --
>  drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c | 25 ++--------------
>  drivers/net/ethernet/chelsio/cxgb3/l2t.c           |  2 +-
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 31 ++++----------------
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c         |  9 ++----
>  drivers/net/ethernet/mellanox/mlx4/mr.c            |  9 ++----
>  drivers/nvdimm/dimm_devs.c                         |  5 +---
>  .../staging/lustre/lnet/libcfs/linux/linux-mem.c   | 11 +------
>  drivers/xen/evtchn.c                               | 14 +--------
>  fs/btrfs/ctree.c                                   |  9 ++----
>  fs/btrfs/ioctl.c                                   |  9 ++----
>  fs/btrfs/send.c                                    | 27 ++++++-----------
>  fs/ceph/file.c                                     |  9 ++----
>  fs/select.c                                        |  5 +---
>  fs/xattr.c                                         | 27 ++++++-----------
>  kernel/bpf/hashtab.c                               | 11 ++-----
>  lib/iov_iter.c                                     |  5 +---
>  mm/frame_vector.c                                  |  5 +---
>  net/ipv4/inet_hashtables.c                         |  6 +---
>  net/ipv4/tcp_metrics.c                             |  5 +---
>  net/mpls/af_mpls.c                                 |  5 +---
>  net/netfilter/x_tables.c                           | 34 ++++++----------------
>  net/netfilter/xt_recent.c                          |  5 +---
>  net/sched/sch_choke.c                              |  5 +---
>  net/sched/sch_fq_codel.c                           | 26 ++++-------------
>  net/sched/sch_hhf.c                                | 33 ++++++---------------
>  net/sched/sch_netem.c                              |  6 +---
>  net/sched/sch_sfq.c                                |  6 +---
>  security/keys/keyctl.c                             | 22 ++++----------
>  35 files changed, 96 insertions(+), 319 deletions(-)
>
> diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
> index 4f74511015b8..e6bbb33d2956 100644
> --- a/arch/s390/kvm/kvm-s390.c
> +++ b/arch/s390/kvm/kvm-s390.c
> @@ -1126,10 +1126,7 @@ static long kvm_s390_get_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
>         if (args->count < 1 || args->count > KVM_S390_SKEYS_MAX)
>                 return -EINVAL;
>
> -       keys = kmalloc_array(args->count, sizeof(uint8_t),
> -                            GFP_KERNEL | __GFP_NOWARN);
> -       if (!keys)
> -               keys = vmalloc(sizeof(uint8_t) * args->count);
> +       keys = kvmalloc(args->count * sizeof(uint8_t), GFP_KERNEL);

Before doing this conversion, can we add a kvmalloc_array() API? This
conversion could allow for the reintroduction of integer overflow
flaws. (This particular situation isn't at risk since ->count is
checked, but I'd prefer we not create a risky set of examples for
using kvmalloc.)

Besides that: yes please. Less open coding. :)

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
