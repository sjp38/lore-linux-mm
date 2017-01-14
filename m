Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C31B6B0033
	for <linux-mm@kvack.org>; Sat, 14 Jan 2017 05:56:34 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 80so180458081pfy.2
        for <linux-mm@kvack.org>; Sat, 14 Jan 2017 02:56:34 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id a71si15399438pfg.294.2017.01.14.02.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jan 2017 02:56:33 -0800 (PST)
Date: Sat, 14 Jan 2017 12:56:32 +0200
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
Message-ID: <20170114105632.GV20392@mtr-leonro.local>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="X9hp/qFlD/MyfJCu"
Content-Disposition: inline
In-Reply-To: <20170112153717.28943-6-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Yishai Hadas <yishaih@mellanox.com>, Dan Williams <dan.j.williams@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org


--X9hp/qFlD/MyfJCu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jan 12, 2017 at 04:37:16PM +0100, Michal Hocko wrote:
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

Hi Michal,

I don't see mlx5_vzalloc in the changed list. Any reason why did you skip it?

 881 static inline void *mlx5_vzalloc(unsigned long size)
 882 {
 883         void *rtn;
 884
 885         rtn = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
 886         if (!rtn)
 887                 rtn = vzalloc(size);
 888         return rtn;
 889 }

Thanks

--X9hp/qFlD/MyfJCu
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh6A+AACgkQ5GN7iDZy
WKc9Xw//aXQHDq5T9r/pwydkF96JM5qjO4t25gQzeOZF1c77sTHJLP4h1Hu9Bev+
8Kna7cVLvyvuq78mmlHl4OSj75GMXToi1nNSWxGdBgSiag2AXlpCuNnA4LncW0oH
TsV/YBAGQ9upZ2N46CuI+Sj+YM2675rTZzX3arRJx0ybs1Gyg7nSQeNBOrT0NuLb
GZhws7soqzvRtjAd27Dnjo6WYRmRNCBPjwNCEsC1eIeJQepqEGqIesgMk1sL9Chd
QOltxXBXoeoDBp1om60u5RyjEqs3fB+0P1sa4gGOwljecvDqsICwK3XHrQ1WzeNE
IfZ6eN/IvOqc2/hteeRWzRnA3ENyHOaE2QKkKODQRV25tnEWomlvIwfChlo8VpSL
q2s1dD51eV0A5wLaROJZasX4lIFFDJ8h4IWSGvjGSwcGcLdolIVjzVPCaOwfr6Cx
ZLo7zoPEDDKSjW8C/ZrNPdKiqVi91qyGCQfYLNpVOjlBBmJ7NUMCb4yP53eGQ/Z5
tAO41kyhwlPK11eoslPH1FzyjnahwnGlKiCxV9Li/gvocOt5rt0tVf9zCR24e8ru
XwTTHV3z+1FBNxYaiP9osVfC0yxdQYNr+f4fjXgby4YYrkajFAXEcGWlxbudJrnM
bmauIu3SgS31znni1mbkYiVExZ32AnxSnRcaszFPR8KLFQhFpx4=
=CZY9
-----END PGP SIGNATURE-----

--X9hp/qFlD/MyfJCu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
