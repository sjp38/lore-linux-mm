Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A70266B0387
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 05:30:42 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id g10so64247476wrg.5
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:30:42 -0800 (PST)
Received: from mail-wr0-f193.google.com (mail-wr0-f193.google.com. [209.85.128.193])
        by mx.google.com with ESMTPS id h9si16557031wrc.243.2017.03.06.02.30.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 02:30:41 -0800 (PST)
Received: by mail-wr0-f193.google.com with SMTP id l37so21086473wrc.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 02:30:40 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 0/6 v5] kvmalloc
Date: Mon,  6 Mar 2017 11:30:23 +0100
Message-Id: <20170306103032.2540-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Alexei Starovoitov <ast@kernel.org>, Andreas Dilger <adilger@dilger.ca>, Andreas Dilger <andreas.dilger@intel.com>, Anton Vorontsov <anton@enomsg.org>, Ben Skeggs <bskeggs@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Colin Cross <ccross@android.com>, Dan Williams <dan.j.williams@intel.com>, David Sterba <dsterba@suse.com>, Eric Dumazet <edumazet@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, Hariprasad S <hariprasad@chelsio.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Ilya Dryomov <idryomov@gmail.com>, John Hubbard <jhubbard@nvidia.com>, Kees Cook <keescook@chromium.org>, Kent Overstreet <kent.overstreet@gmail.com>, Leon Romanovsky <leonro@mellanox.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>, Mike Snitzer <snitzer@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>, Oleg Drokin <oleg.drokin@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Santosh Raspatur <santosh@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Tom Herbert <tom@herbertland.com>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, "Yan, Zheng" <zyan@redhat.com>, Yishai Hadas <yishaih@mellanox.com>

Hi,
this has been previously posted here [1]. Based on the discussion I have
dropped "[PATCH 9/9] net, bpf: use kvzalloc helper" and added "[PATCH]
xattr: zero out memory copied to userspace in getxattr". I have rebased
the series on top of 4.11-rc1.  I hope there are no further obstacles to
have this merged during this release cycle.

Original cover:

There are many open coded kmalloc with vmalloc fallback instances in
the tree.  Most of them are not careful enough or simply do not care
about the underlying semantic of the kmalloc/page allocator which means
that a) some vmalloc fallbacks are basically unreachable because the
kmalloc part will keep retrying until it succeeds b) the page allocator
can invoke a really disruptive steps like the OOM killer to move forward
which doesn't sound appropriate when we consider that the vmalloc
fallback is available.

As it can be seen implementing kvmalloc requires quite an intimate
knowledge if the page allocator and the memory reclaim internals which
strongly suggests that a helper should be implemented in the memory
subsystem proper.

Most callers, I could find, have been converted to use the helper
instead.  This is patch 6. There are some more relying on __GFP_REPEAT
in the networking stack which I have converted as well and Eric Dumazet
was not opposed [2] to convert them as well.

[1] http://lkml.kernel.org/r/20170130094940.13546-1-mhocko@kernel.org
[2] http://lkml.kernel.org/r/1485273626.16328.301.camel@edumazet-glaptop3.roam.corp.google.com

Michal Hocko (9):
      mm: introduce kv[mz]alloc helpers
      mm: support __GFP_REPEAT in kvmalloc_node for >32kB
      rhashtable: simplify a strange allocation pattern
      ila: simplify a strange allocation pattern
      xattr: zero out memory copied to userspace in getxattr
      treewide: use kv[mz]alloc* rather than opencoded variants
      net: use kvmalloc with __GFP_REPEAT rather than open coded variant
      md: use kvmalloc rather than opencoded variant
      bcache: use kvmalloc

Diffstat says:
 arch/s390/kvm/kvm-s390.c                           | 10 +---
 arch/x86/kvm/lapic.c                               |  4 +-
 arch/x86/kvm/page_track.c                          |  4 +-
 arch/x86/kvm/x86.c                                 |  4 +-
 crypto/lzo.c                                       |  4 +-
 drivers/acpi/apei/erst.c                           |  8 +--
 drivers/char/agp/generic.c                         |  8 +--
 drivers/gpu/drm/nouveau/nouveau_gem.c              |  4 +-
 drivers/md/bcache/super.c                          |  8 +--
 drivers/md/bcache/util.h                           | 12 +----
 drivers/md/dm-ioctl.c                              | 13 ++---
 drivers/md/dm-stats.c                              |  7 +--
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_defs.h    |  3 --
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c | 29 ++---------
 drivers/net/ethernet/chelsio/cxgb3/l2t.c           |  8 +--
 drivers/net/ethernet/chelsio/cxgb3/l2t.h           |  1 -
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c      | 12 ++---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  3 --
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 10 ++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c |  8 +--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 31 ++----------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  | 14 +++---
 drivers/net/ethernet/chelsio/cxgb4/l2t.c           |  2 +-
 drivers/net/ethernet/chelsio/cxgb4/sched.c         | 12 ++---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |  9 ++--
 drivers/net/ethernet/mellanox/mlx4/mr.c            |  9 ++--
 drivers/nvdimm/dimm_devs.c                         |  5 +-
 .../staging/lustre/lnet/libcfs/linux/linux-mem.c   | 11 +----
 drivers/vhost/net.c                                |  9 ++--
 drivers/vhost/vhost.c                              | 15 ++----
 drivers/vhost/vsock.c                              |  9 ++--
 drivers/xen/evtchn.c                               | 14 +-----
 fs/btrfs/ctree.c                                   |  9 ++--
 fs/btrfs/ioctl.c                                   |  9 ++--
 fs/btrfs/send.c                                    | 27 ++++------
 fs/ceph/file.c                                     |  9 ++--
 fs/ext4/mballoc.c                                  |  2 +-
 fs/ext4/super.c                                    |  4 +-
 fs/f2fs/f2fs.h                                     | 20 --------
 fs/f2fs/file.c                                     |  4 +-
 fs/f2fs/node.c                                     |  4 +-
 fs/f2fs/segment.c                                  | 14 +++---
 fs/select.c                                        |  5 +-
 fs/seq_file.c                                      | 16 +-----
 fs/xattr.c                                         | 27 ++++------
 include/linux/kvm_host.h                           |  2 -
 include/linux/mlx5/driver.h                        |  7 +--
 include/linux/mm.h                                 | 22 +++++++++
 include/linux/vmalloc.h                            |  1 +
 ipc/util.c                                         |  7 +--
 lib/iov_iter.c                                     |  5 +-
 lib/rhashtable.c                                   | 13 ++---
 mm/frame_vector.c                                  |  5 +-
 mm/nommu.c                                         |  5 ++
 mm/util.c                                          | 57 ++++++++++++++++++++++
 mm/vmalloc.c                                       |  9 +++-
 net/core/dev.c                                     | 24 ++++-----
 net/ipv4/inet_hashtables.c                         |  6 +--
 net/ipv4/tcp_metrics.c                             |  5 +-
 net/ipv6/ila/ila_xlat.c                            |  8 +--
 net/mpls/af_mpls.c                                 |  5 +-
 net/netfilter/x_tables.c                           | 21 ++------
 net/netfilter/xt_recent.c                          |  5 +-
 net/sched/sch_choke.c                              |  5 +-
 net/sched/sch_fq.c                                 | 12 +----
 net/sched/sch_fq_codel.c                           | 26 +++-------
 net/sched/sch_hhf.c                                | 33 ++++---------
 net/sched/sch_netem.c                              |  6 +--
 net/sched/sch_sfq.c                                |  6 +--
 security/apparmor/apparmorfs.c                     |  2 +-
 security/apparmor/include/lib.h                    | 11 -----
 security/apparmor/lib.c                            | 30 ------------
 security/apparmor/match.c                          |  2 +-
 security/apparmor/policy_unpack.c                  |  2 +-
 security/keys/keyctl.c                             | 22 +++------
 virt/kvm/kvm_main.c                                | 18 ++-----
 76 files changed, 271 insertions(+), 561 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
