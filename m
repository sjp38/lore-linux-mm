Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A85816B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 22:24:45 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id t126so24508063pgc.9
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 19:24:45 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id p30si24686472pgn.165.2017.06.02.19.24.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Jun 2017 19:24:44 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id f27so14374239pfe.0
        for <linux-mm@kvack.org>; Fri, 02 Jun 2017 19:24:44 -0700 (PDT)
Date: Sat, 3 Jun 2017 10:24:40 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC PATCH 2/4] mm, tree wide: replace __GFP_REPEAT by
 __GFP_RETRY_MAYFAIL with more useful semantic
Message-ID: <20170603022440.GA11080@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20170307154843.32516-1-mhocko@kernel.org>
 <20170307154843.32516-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="UugvWAfsgieZRqgk"
Content-Disposition: inline
In-Reply-To: <20170307154843.32516-3-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi, Michal

Just go through your patch.

I have one question and one suggestion as below.

One suggestion:

This patch does two things to me:
1. Replace __GFP_REPEAT with __GFP_RETRY_MAYFAIL
2. Adjust the logic in page_alloc to provide the middle semantic

My suggestion is to split these two task into two patches, so that readers
could catch your fundamental logic change easily.

On Tue, Mar 07, 2017 at 04:48:41PM +0100, Michal Hocko wrote:
>From: Michal Hocko <mhocko@suse.com>
>
>__GFP_REPEAT was designed to allow retry-but-eventually-fail semantic to
>the page allocator. This has been true but only for allocations requests
>larger than PAGE_ALLOC_COSTLY_ORDER. It has been always ignored for
>smaller sizes. This is a bit unfortunate because there is no way to
>express the same semantic for those requests and they are considered too
>important to fail so they might end up looping in the page allocator for
>ever, similarly to GFP_NOFAIL requests.
>
>Now that the whole tree has been cleaned up and accidental or misled
>usage of __GFP_REPEAT flag has been removed for !costly requests we can
>give the original flag a better name and more importantly a more useful
>semantic. Let's rename it to __GFP_RETRY_MAYFAIL which tells the user that
>the allocator would try really hard but there is no promise of a
>success. This will work independent of the order and overrides the
>default allocator behavior. Page allocator users have several levels of
>guarantee vs. cost options (take GFP_KERNEL as an example)
>- GFP_KERNEL & ~__GFP_RECLAIM - optimistic allocation without _any_
>  attempt to free memory at all. The most light weight mode which even
>  doesn't kick the background reclaim. Should be used carefully because
>  it might deplete the memory and the next user might hit the more
>  aggressive reclaim
>- GFP_KERNEL & ~__GFP_DIRECT_RECLAIM (or GFP_NOWAIT)- optimistic
>  allocation without any attempt to free memory from the current context
>  but can wake kswapd to reclaim memory if the zone is below the low
>  watermark. Can be used from either atomic contexts or when the request
>  is a performance optimization and there is another fallback for a slow
>  path.
>- (GFP_KERNEL|__GFP_HIGH) & ~__GFP_DIRECT_RECLAIM (aka GFP_ATOMIC) - non
>  sleeping allocation with an expensive fallback so it can access some
>  portion of memory reserves. Usually used from interrupt/bh context with
>  an expensive slow path fallback.
>- GFP_KERNEL - both background and direct reclaim are allowed and the
>  _default_ page allocator behavior is used. That means that !costly
>  allocation requests are basically nofail (unless the requesting task
>  is killed by the OOM killer) and costly will fail early rather than
>  cause disruptive reclaim.
>- GFP_KERNEL | __GFP_NORETRY - overrides the default allocator behavior and
>  all allocation requests fail early rather than cause disruptive
>  reclaim (one round of reclaim in this implementation). The OOM killer
>  is not invoked.
>- GFP_KERNEL | __GFP_RETRY_MAYFAIL - overrides the default allocator behav=
ior
>  and all allocation requests try really hard. The request will fail if the
>  reclaim cannot make any progress. The OOM killer won't be triggered.
>- GFP_KERNEL | __GFP_NOFAIL - overrides the default allocator behavior
>  and all allocation requests will loop endlessly until they
>  succeed. This might be really dangerous especially for larger orders.
>
>Existing users of __GFP_REPEAT are changed to __GFP_RETRY_MAYFAIL because
>they already had their semantic. No new users are added.
>__alloc_pages_slowpath is changed to bail out for __GFP_RETRY_MAYFAIL if
>there is no progress and we have already passed the OOM point. This
>means that all the reclaim opportunities have been exhausted except the
>most disruptive one (the OOM killer) and a user defined fallback
>behavior is more sensible than keep retrying in the page allocator.
>
>Signed-off-by: Michal Hocko <mhocko@suse.com>
>---
> Documentation/DMA-ISA-LPC.txt                |  2 +-
> arch/powerpc/include/asm/book3s/64/pgalloc.h |  2 +-
> arch/powerpc/kvm/book3s_64_mmu_hv.c          |  2 +-
> drivers/mmc/host/wbsd.c                      |  2 +-
> drivers/s390/char/vmcp.c                     |  2 +-
> drivers/target/target_core_transport.c       |  2 +-
> drivers/vhost/net.c                          |  2 +-
> drivers/vhost/scsi.c                         |  2 +-
> drivers/vhost/vsock.c                        |  2 +-
> fs/btrfs/check-integrity.c                   |  2 +-
> fs/btrfs/raid56.c                            |  2 +-
> include/linux/gfp.h                          | 32 +++++++++++++++++++----=
-----
> include/linux/slab.h                         |  3 ++-
> include/trace/events/mmflags.h               |  2 +-
> mm/hugetlb.c                                 |  4 ++--
> mm/internal.h                                |  2 +-
> mm/page_alloc.c                              | 14 +++++++++---
> mm/sparse-vmemmap.c                          |  4 ++--
> mm/util.c                                    |  6 +++---
> mm/vmalloc.c                                 |  2 +-
> mm/vmscan.c                                  |  8 +++----
> net/core/dev.c                               |  6 +++---
> net/core/skbuff.c                            |  2 +-
> net/sched/sch_fq.c                           |  2 +-
> tools/perf/builtin-kmem.c                    |  2 +-
> 25 files changed, 66 insertions(+), 45 deletions(-)
>
>diff --git a/Documentation/DMA-ISA-LPC.txt b/Documentation/DMA-ISA-LPC.txt
>index c41331398752..7a065ac4a9d1 100644
>--- a/Documentation/DMA-ISA-LPC.txt
>+++ b/Documentation/DMA-ISA-LPC.txt
>@@ -42,7 +42,7 @@ requirements you pass the flag GFP_DMA to kmalloc.
>=20
> Unfortunately the memory available for ISA DMA is scarce so unless you
> allocate the memory during boot-up it's a good idea to also pass
>-__GFP_REPEAT and __GFP_NOWARN to make the allocator try a bit harder.
>+__GFP_RETRY_MAYFAIL and __GFP_NOWARN to make the allocator try a bit hard=
er.
>=20
> (This scarcity also means that you should allocate the buffer as
> early as possible and not release it until the driver is unloaded.)
>diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/i=
nclude/asm/book3s/64/pgalloc.h
>index cd5e7aa8cc34..1b835aa5b4d1 100644
>--- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
>+++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
>@@ -56,7 +56,7 @@ static inline pgd_t *radix__pgd_alloc(struct mm_struct *=
mm)
> 	return (pgd_t *)__get_free_page(PGALLOC_GFP);
> #else
> 	struct page *page;
>-	page =3D alloc_pages(PGALLOC_GFP | __GFP_REPEAT, 4);
>+	page =3D alloc_pages(PGALLOC_GFP | __GFP_RETRY_MAYFAIL, 4);
> 	if (!page)
> 		return NULL;
> 	return (pgd_t *) page_address(page);
>diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s=
_64_mmu_hv.c
>index 8c68145ba1bd..8ad2c309f14a 100644
>--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
>+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
>@@ -93,7 +93,7 @@ int kvmppc_allocate_hpt(struct kvm_hpt_info *info, u32 o=
rder)
> 	}
>=20
> 	if (!hpt)
>-		hpt =3D __get_free_pages(GFP_KERNEL|__GFP_ZERO|__GFP_REPEAT
>+		hpt =3D __get_free_pages(GFP_KERNEL|__GFP_ZERO|__GFP_RETRY_MAYFAIL
> 				       |__GFP_NOWARN, order - PAGE_SHIFT);
>=20
> 	if (!hpt)
>diff --git a/drivers/mmc/host/wbsd.c b/drivers/mmc/host/wbsd.c
>index bd04e8bae010..b58fa5b5b972 100644
>--- a/drivers/mmc/host/wbsd.c
>+++ b/drivers/mmc/host/wbsd.c
>@@ -1386,7 +1386,7 @@ static void wbsd_request_dma(struct wbsd_host *host,=
 int dma)
> 	 * order for ISA to be able to DMA to it.
> 	 */
> 	host->dma_buffer =3D kmalloc(WBSD_DMA_SIZE,
>-		GFP_NOIO | GFP_DMA | __GFP_REPEAT | __GFP_NOWARN);
>+		GFP_NOIO | GFP_DMA | __GFP_RETRY_MAYFAIL | __GFP_NOWARN);
> 	if (!host->dma_buffer)
> 		goto free;
>=20
>diff --git a/drivers/s390/char/vmcp.c b/drivers/s390/char/vmcp.c
>index 65f5a794f26d..98749fa817da 100644
>--- a/drivers/s390/char/vmcp.c
>+++ b/drivers/s390/char/vmcp.c
>@@ -98,7 +98,7 @@ vmcp_write(struct file *file, const char __user *buff, s=
ize_t count,
> 	}
> 	if (!session->response)
> 		session->response =3D (char *)__get_free_pages(GFP_KERNEL
>-						| __GFP_REPEAT | GFP_DMA,
>+						| __GFP_RETRY_MAYFAIL | GFP_DMA,
> 						get_order(session->bufsize));
> 	if (!session->response) {
> 		mutex_unlock(&session->mutex);
>diff --git a/drivers/target/target_core_transport.c b/drivers/target/targe=
t_core_transport.c
>index 434d9d693989..e585d301c665 100644
>--- a/drivers/target/target_core_transport.c
>+++ b/drivers/target/target_core_transport.c
>@@ -251,7 +251,7 @@ int transport_alloc_session_tags(struct se_session *se=
_sess,
> 	int rc;
>=20
> 	se_sess->sess_cmd_map =3D kzalloc(tag_num * tag_size,
>-					GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
>+					GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_MAYFAIL);
> 	if (!se_sess->sess_cmd_map) {
> 		se_sess->sess_cmd_map =3D vzalloc(tag_num * tag_size);
> 		if (!se_sess->sess_cmd_map) {
>diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
>index f61f852d6cfd..7d2c4ce6d8d1 100644
>--- a/drivers/vhost/net.c
>+++ b/drivers/vhost/net.c
>@@ -817,7 +817,7 @@ static int vhost_net_open(struct inode *inode, struct =
file *f)
> 	struct vhost_virtqueue **vqs;
> 	int i;
>=20
>-	n =3D kvmalloc(sizeof *n, GFP_KERNEL | __GFP_REPEAT);
>+	n =3D kvmalloc(sizeof *n, GFP_KERNEL | __GFP_RETRY_MAYFAIL);
> 	if (!n)
> 		return -ENOMEM;
> 	vqs =3D kmalloc(VHOST_NET_VQ_MAX * sizeof(*vqs), GFP_KERNEL);
>diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
>index fd6c8b66f06f..ff02a942c4d5 100644
>--- a/drivers/vhost/scsi.c
>+++ b/drivers/vhost/scsi.c
>@@ -1404,7 +1404,7 @@ static int vhost_scsi_open(struct inode *inode, stru=
ct file *f)
> 	struct vhost_virtqueue **vqs;
> 	int r =3D -ENOMEM, i;
>=20
>-	vs =3D kzalloc(sizeof(*vs), GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
>+	vs =3D kzalloc(sizeof(*vs), GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_MAYF=
AIL);
> 	if (!vs) {
> 		vs =3D vzalloc(sizeof(*vs));
> 		if (!vs)
>diff --git a/drivers/vhost/vsock.c b/drivers/vhost/vsock.c
>index d403c647ba56..5b76242d73e3 100644
>--- a/drivers/vhost/vsock.c
>+++ b/drivers/vhost/vsock.c
>@@ -460,7 +460,7 @@ static int vhost_vsock_dev_open(struct inode *inode, s=
truct file *file)
> 	/* This struct is large and allocation could fail, fall back to vmalloc
> 	 * if there is no other way.
> 	 */
>-	vsock =3D kvmalloc(sizeof(*vsock), GFP_KERNEL | __GFP_REPEAT);
>+	vsock =3D kvmalloc(sizeof(*vsock), GFP_KERNEL | __GFP_RETRY_MAYFAIL);
> 	if (!vsock)
> 		return -ENOMEM;
>=20
>diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
>index ab14c2e635ca..e334ed2b7e64 100644
>--- a/fs/btrfs/check-integrity.c
>+++ b/fs/btrfs/check-integrity.c
>@@ -2923,7 +2923,7 @@ int btrfsic_mount(struct btrfs_fs_info *fs_info,
> 		       fs_info->sectorsize, PAGE_SIZE);
> 		return -1;
> 	}
>-	state =3D kzalloc(sizeof(*state), GFP_KERNEL | __GFP_NOWARN | __GFP_REPE=
AT);
>+	state =3D kzalloc(sizeof(*state), GFP_KERNEL | __GFP_NOWARN | __GFP_RETR=
Y_MAYFAIL);
> 	if (!state) {
> 		state =3D vzalloc(sizeof(*state));
> 		if (!state) {
>diff --git a/fs/btrfs/raid56.c b/fs/btrfs/raid56.c
>index 1571bf26dc07..94af3db1d0e4 100644
>--- a/fs/btrfs/raid56.c
>+++ b/fs/btrfs/raid56.c
>@@ -218,7 +218,7 @@ int btrfs_alloc_stripe_hash_table(struct btrfs_fs_info=
 *info)
> 	 * of a failing mount.
> 	 */
> 	table_size =3D sizeof(*table) + sizeof(*h) * num_entries;
>-	table =3D kzalloc(table_size, GFP_KERNEL | __GFP_NOWARN | __GFP_REPEAT);
>+	table =3D kzalloc(table_size, GFP_KERNEL | __GFP_NOWARN | __GFP_RETRY_MA=
YFAIL);
> 	if (!table) {
> 		table =3D vzalloc(table_size);
> 		if (!table)
>diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>index 2bfcfd33e476..60af7937c6f2 100644
>--- a/include/linux/gfp.h
>+++ b/include/linux/gfp.h
>@@ -25,7 +25,7 @@ struct vm_area_struct;
> #define ___GFP_FS		0x80u
> #define ___GFP_COLD		0x100u
> #define ___GFP_NOWARN		0x200u
>-#define ___GFP_REPEAT		0x400u
>+#define ___GFP_RETRY_MAYFAIL		0x400u
> #define ___GFP_NOFAIL		0x800u
> #define ___GFP_NORETRY		0x1000u
> #define ___GFP_MEMALLOC		0x2000u
>@@ -136,26 +136,38 @@ struct vm_area_struct;
>  *
>  * __GFP_RECLAIM is shorthand to allow/forbid both direct and kswapd recl=
aim.
>  *
>- * __GFP_REPEAT: Try hard to allocate the memory, but the allocation atte=
mpt
>- *   _might_ fail.  This depends upon the particular VM implementation.
>+ * The default allocator behavior depends on the request size. We have a =
concept
>+ * of so called costly allocations (with order > PAGE_ALLOC_COSTLY_ORDER).
>+ * !costly allocations are too essential to fail so they are implicitly
>+ * non-failing (with some exceptions like OOM victims might fail) by defa=
ult while
>+ * costly requests try to be not disruptive and back off even without inv=
oking
>+ * the OOM killer. The following three modifiers might be used to overrid=
e some of
>+ * these implicit rules
>+ *
>+ * __GFP_NORETRY: The VM implementation must not retry indefinitely and w=
ill
>+ *   return NULL when direct reclaim and memory compaction have failed to=
 allow
>+ *   the allocation to succeed.  The OOM killer is not called with the cu=
rrent
>+ *   implementation. This is a default mode for costly allocations.
>+ *
>+ * __GFP_RETRY_MAYFAIL: Try hard to allocate the memory, but the allocati=
on attempt
>+ *   _might_ fail. All viable forms of memory reclaim are tried before th=
e fail.
>+ *   The OOM killer is excluded because this would be too disruptive. Thi=
s can be
>+ *   used to override non-failing default behavior for !costly requests a=
s well as
>+ *   fortify costly requests.
>  *
>  * __GFP_NOFAIL: The VM implementation _must_ retry infinitely: the caller
>  *   cannot handle allocation failures. New users should be evaluated car=
efully
>  *   (and the flag should be used only when there is no reasonable failure
>  *   policy) but it is definitely preferable to use the flag rather than
>- *   opencode endless loop around allocator.
>- *
>- * __GFP_NORETRY: The VM implementation must not retry indefinitely and w=
ill
>- *   return NULL when direct reclaim and memory compaction have failed to=
 allow
>- *   the allocation to succeed.  The OOM killer is not called with the cu=
rrent
>- *   implementation.
>+ *   opencode endless loop around allocator. Using this flag for costly a=
llocations
>+ *   is _highly_ discouraged.
>  */
> #define __GFP_IO	((__force gfp_t)___GFP_IO)
> #define __GFP_FS	((__force gfp_t)___GFP_FS)
> #define __GFP_DIRECT_RECLAIM	((__force gfp_t)___GFP_DIRECT_RECLAIM) /* Ca=
ller can reclaim */
> #define __GFP_KSWAPD_RECLAIM	((__force gfp_t)___GFP_KSWAPD_RECLAIM) /* ks=
wapd can wake */
> #define __GFP_RECLAIM ((__force gfp_t)(___GFP_DIRECT_RECLAIM|___GFP_KSWAP=
D_RECLAIM))
>-#define __GFP_REPEAT	((__force gfp_t)___GFP_REPEAT)
>+#define __GFP_RETRY_MAYFAIL	((__force gfp_t)___GFP_RETRY_MAYFAIL)
> #define __GFP_NOFAIL	((__force gfp_t)___GFP_NOFAIL)
> #define __GFP_NORETRY	((__force gfp_t)___GFP_NORETRY)
>=20
>diff --git a/include/linux/slab.h b/include/linux/slab.h
>index 3c37a8c51921..064901ac3e37 100644
>--- a/include/linux/slab.h
>+++ b/include/linux/slab.h
>@@ -469,7 +469,8 @@ static __always_inline void *kmalloc_large(size_t size=
, gfp_t flags)
>  *
>  * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
>  *
>- * %__GFP_REPEAT - If allocation fails initially, try once more before fa=
iling.
>+ * %__GFP_RETRY_MAYFAIL - Try really hard to succeed the allocation but f=
ail
>+ *   eventually.
>  *
>  * There are other flags available as well, but these are not intended
>  * for general use, and so are not documented here. For a full list of
>diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags=
=2Eh
>index 304ff94363b2..418142a4efce 100644
>--- a/include/trace/events/mmflags.h
>+++ b/include/trace/events/mmflags.h
>@@ -34,7 +34,7 @@
> 	{(unsigned long)__GFP_FS,		"__GFP_FS"},		\
> 	{(unsigned long)__GFP_COLD,		"__GFP_COLD"},		\
> 	{(unsigned long)__GFP_NOWARN,		"__GFP_NOWARN"},	\
>-	{(unsigned long)__GFP_REPEAT,		"__GFP_REPEAT"},	\
>+	{(unsigned long)__GFP_RETRY_MAYFAIL,	"__GFP_RETRY_MAYFAIL"},	\
> 	{(unsigned long)__GFP_NOFAIL,		"__GFP_NOFAIL"},	\
> 	{(unsigned long)__GFP_NORETRY,		"__GFP_NORETRY"},	\
> 	{(unsigned long)__GFP_COMP,		"__GFP_COMP"},		\
>diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>index a7aa811b7d14..dc598bfe4ce9 100644
>--- a/mm/hugetlb.c
>+++ b/mm/hugetlb.c
>@@ -1369,7 +1369,7 @@ static struct page *alloc_fresh_huge_page_node(struc=
t hstate *h, int nid)
>=20
> 	page =3D __alloc_pages_node(nid,
> 		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
>-						__GFP_REPEAT|__GFP_NOWARN,
>+						__GFP_RETRY_MAYFAIL|__GFP_NOWARN,
> 		huge_page_order(h));
> 	if (page) {
> 		prep_new_huge_page(h, page, nid);
>@@ -1510,7 +1510,7 @@ static struct page *__hugetlb_alloc_buddy_huge_page(=
struct hstate *h,
> 		struct vm_area_struct *vma, unsigned long addr, int nid)
> {
> 	int order =3D huge_page_order(h);
>-	gfp_t gfp =3D htlb_alloc_mask(h)|__GFP_COMP|__GFP_REPEAT|__GFP_NOWARN;
>+	gfp_t gfp =3D htlb_alloc_mask(h)|__GFP_COMP|__GFP_RETRY_MAYFAIL|__GFP_NO=
WARN;
> 	unsigned int cpuset_mems_cookie;
>=20
> 	/*
>diff --git a/mm/internal.h b/mm/internal.h
>index 823a7a89099b..8e6d347f70fb 100644
>--- a/mm/internal.h
>+++ b/mm/internal.h
>@@ -23,7 +23,7 @@
>  * hints such as HIGHMEM usage.
>  */
> #define GFP_RECLAIM_MASK (__GFP_RECLAIM|__GFP_HIGH|__GFP_IO|__GFP_FS|\
>-			__GFP_NOWARN|__GFP_REPEAT|__GFP_NOFAIL|\
>+			__GFP_NOWARN|__GFP_RETRY_MAYFAIL|__GFP_NOFAIL|\
> 			__GFP_NORETRY|__GFP_MEMALLOC|__GFP_NOMEMALLOC|\
> 			__GFP_ATOMIC)
>=20
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index 5238b87aec91..bfe4a9bad0f8 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -3181,6 +3181,14 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int =
order,
> 	/* The OOM killer will not help higher order allocs */
> 	if (order > PAGE_ALLOC_COSTLY_ORDER)
> 		goto out;
>+	/*
>+	 * We have already exhausted all our reclaim opportunities without any
>+	 * success so it is time to admit defeat. We will skip the OOM killer
>+	 * because it is very likely that the caller has a more reasonable
>+	 * fallback than shooting a random task.
>+	 */
>+	if (gfp_mask & __GFP_RETRY_MAYFAIL)
>+		goto out;
> 	/* The OOM killer does not needlessly kill tasks for lowmem */
> 	if (ac->high_zoneidx < ZONE_NORMAL)
> 		goto out;
>@@ -3309,7 +3317,7 @@ should_compact_retry(struct alloc_context *ac, int o=
rder, int alloc_flags,
> 	}
>=20
> 	/*
>-	 * !costly requests are much more important than __GFP_REPEAT
>+	 * !costly requests are much more important than __GFP_RETRY_MAYFAIL
> 	 * costly ones because they are de facto nofail and invoke OOM
> 	 * killer to move on while costly can fail and users are ready
> 	 * to cope with that. 1/4 retries is rather arbitrary but we
>@@ -3776,9 +3784,9 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int =
order,
>=20
> 	/*
> 	 * Do not retry costly high order allocations unless they are
>-	 * __GFP_REPEAT
>+	 * __GFP_RETRY_MAYFAIL
> 	 */
>-	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_REPEAT))
>+	if (order > PAGE_ALLOC_COSTLY_ORDER && !(gfp_mask & __GFP_RETRY_MAYFAIL))
> 		goto nopage;

One question:

=46rom your change log, it mentions will provide the same semantic for !cos=
tly
allocations. While the logic here is the same as before.

For a !costly allocation with __GFP_REPEAT flag, the difference after this
patch is no OOM will be invoked, while it will still continue in the loop.

Maybe I don't catch your point in this message:

  __GFP_REPEAT was designed to allow retry-but-eventually-fail semantic to
  the page allocator. This has been true but only for allocations requests
  larger than PAGE_ALLOC_COSTLY_ORDER. It has been always ignored for
  smaller sizes. This is a bit unfortunate because there is no way to
  express the same semantic for those requests and they are considered too
  important to fail so they might end up looping in the page allocator for
  ever, similarly to GFP_NOFAIL requests.

I thought you will provide the same semantic to !costly allocation, or I
misunderstand?

>=20
> 	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
>diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
>index 574c67b663fe..b21ba0dfe102 100644
>--- a/mm/sparse-vmemmap.c
>+++ b/mm/sparse-vmemmap.c
>@@ -56,11 +56,11 @@ void * __meminit vmemmap_alloc_block(unsigned long siz=
e, int node)
>=20
> 		if (node_state(node, N_HIGH_MEMORY))
> 			page =3D alloc_pages_node(
>-				node, GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
>+				node, GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_MAYFAIL,
> 				get_order(size));
> 		else
> 			page =3D alloc_pages(
>-				GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
>+				GFP_KERNEL | __GFP_ZERO | __GFP_RETRY_MAYFAIL,
> 				get_order(size));
> 		if (page)
> 			return page_address(page);
>diff --git a/mm/util.c b/mm/util.c
>index 6ed3e49bf1e5..885a78d1941b 100644
>--- a/mm/util.c
>+++ b/mm/util.c
>@@ -339,7 +339,7 @@ EXPORT_SYMBOL(vm_mmap);
>  * Uses kmalloc to get the memory but if the allocation fails then falls =
back
>  * to the vmalloc allocator. Use kvfree for freeing the memory.
>  *
>- * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. =
__GFP_REPEAT
>+ * Reclaim modifiers - __GFP_NORETRY and __GFP_NOFAIL are not supported. =
__GFP_RETRY_MAYFAIL
>  * is supported only for large (>32kB) allocations, and it should be used=
 only if
>  * kmalloc is preferable to the vmalloc fallback, due to visible performa=
nce drawbacks.
>  *
>@@ -364,11 +364,11 @@ void *kvmalloc_node(size_t size, gfp_t flags, int no=
de)
> 		kmalloc_flags |=3D __GFP_NOWARN;
>=20
> 		/*
>-		 * We have to override __GFP_REPEAT by __GFP_NORETRY for !costly
>+		 * We have to override __GFP_RETRY_MAYFAIL by __GFP_NORETRY for !costly
> 		 * requests because there is no other way to tell the allocator
> 		 * that we want to fail rather than retry endlessly.
> 		 */
>-		if (!(kmalloc_flags & __GFP_REPEAT) ||
>+		if (!(kmalloc_flags & __GFP_RETRY_MAYFAIL) ||
> 				(size <=3D PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER))
> 			kmalloc_flags |=3D __GFP_NORETRY;
> 	}
>diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>index 32979d945766..c2fa2e1b79fc 100644
>--- a/mm/vmalloc.c
>+++ b/mm/vmalloc.c
>@@ -1747,7 +1747,7 @@ void *__vmalloc_node_range(unsigned long size, unsig=
ned long align,
>  *	allocator with @gfp_mask flags.  Map them into contiguous
>  *	kernel virtual space, using a pagetable protection of @prot.
>  *
>- *	Reclaim modifiers in @gfp_mask - __GFP_NORETRY, __GFP_REPEAT
>+ *	Reclaim modifiers in @gfp_mask - __GFP_NORETRY, __GFP_RETRY_MAYFAIL
>  *	and __GFP_NOFAIL are not supported
>  *
>  *	Any use of gfp flags outside of GFP_KERNEL should be consulted
>diff --git a/mm/vmscan.c b/mm/vmscan.c
>index 4e0a828781e5..8f547176e02c 100644
>--- a/mm/vmscan.c
>+++ b/mm/vmscan.c
>@@ -2435,18 +2435,18 @@ static inline bool should_continue_reclaim(struct =
pglist_data *pgdat,
> 		return false;
>=20
> 	/* Consider stopping depending on scan and reclaim activity */
>-	if (sc->gfp_mask & __GFP_REPEAT) {
>+	if (sc->gfp_mask & __GFP_RETRY_MAYFAIL) {
> 		/*
>-		 * For __GFP_REPEAT allocations, stop reclaiming if the
>+		 * For __GFP_RETRY_MAYFAIL allocations, stop reclaiming if the
> 		 * full LRU list has been scanned and we are still failing
> 		 * to reclaim pages. This full LRU scan is potentially
>-		 * expensive but a __GFP_REPEAT caller really wants to succeed
>+		 * expensive but a __GFP_RETRY_MAYFAIL caller really wants to succeed
> 		 */
> 		if (!nr_reclaimed && !nr_scanned)
> 			return false;
> 	} else {
> 		/*
>-		 * For non-__GFP_REPEAT allocations which can presumably
>+		 * For non-__GFP_RETRY_MAYFAIL allocations which can presumably
> 		 * fail without consequence, stop if we failed to reclaim
> 		 * any pages from the last SWAP_CLUSTER_MAX number of
> 		 * pages that were scanned. This will return to the
>diff --git a/net/core/dev.c b/net/core/dev.c
>index d947308ee255..3e659ac9e0ed 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -7121,7 +7121,7 @@ static int netif_alloc_rx_queues(struct net_device *=
dev)
>=20
> 	BUG_ON(count < 1);
>=20
>-	rx =3D kvzalloc(sz, GFP_KERNEL | __GFP_REPEAT);
>+	rx =3D kvzalloc(sz, GFP_KERNEL | __GFP_RETRY_MAYFAIL);
> 	if (!rx)
> 		return -ENOMEM;
>=20
>@@ -7161,7 +7161,7 @@ static int netif_alloc_netdev_queues(struct net_devi=
ce *dev)
> 	if (count < 1 || count > 0xffff)
> 		return -EINVAL;
>=20
>-	tx =3D kvzalloc(sz, GFP_KERNEL | __GFP_REPEAT);
>+	tx =3D kvzalloc(sz, GFP_KERNEL | __GFP_RETRY_MAYFAIL);
> 	if (!tx)
> 		return -ENOMEM;
>=20
>@@ -7698,7 +7698,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv,=
 const char *name,
> 	/* ensure 32-byte alignment of whole construct */
> 	alloc_size +=3D NETDEV_ALIGN - 1;
>=20
>-	p =3D kvzalloc(alloc_size, GFP_KERNEL | __GFP_REPEAT);
>+	p =3D kvzalloc(alloc_size, GFP_KERNEL | __GFP_RETRY_MAYFAIL);
> 	if (!p)
> 		return NULL;
>=20
>diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>index 9ccba86fa23d..26af038e27f0 100644
>--- a/net/core/skbuff.c
>+++ b/net/core/skbuff.c
>@@ -4653,7 +4653,7 @@ struct sk_buff *alloc_skb_with_frags(unsigned long h=
eader_len,
>=20
> 	gfp_head =3D gfp_mask;
> 	if (gfp_head & __GFP_DIRECT_RECLAIM)
>-		gfp_head |=3D __GFP_REPEAT;
>+		gfp_head |=3D __GFP_RETRY_MAYFAIL;
>=20
> 	*errcode =3D -ENOBUFS;
> 	skb =3D alloc_skb(header_len, gfp_head);
>diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
>index 594f77d89f6c..daebe062a2dd 100644
>--- a/net/sched/sch_fq.c
>+++ b/net/sched/sch_fq.c
>@@ -640,7 +640,7 @@ static int fq_resize(struct Qdisc *sch, u32 log)
> 		return 0;
>=20
> 	/* If XPS was setup, we can allocate memory on right NUMA node */
>-	array =3D kvmalloc_node(sizeof(struct rb_root) << log, GFP_KERNEL | __GF=
P_REPEAT,
>+	array =3D kvmalloc_node(sizeof(struct rb_root) << log, GFP_KERNEL | __GF=
P_RETRY_MAYFAIL,
> 			      netdev_queue_numa_node_read(sch->dev_queue));
> 	if (!array)
> 		return -ENOMEM;
>diff --git a/tools/perf/builtin-kmem.c b/tools/perf/builtin-kmem.c
>index 6da8d083e4e5..01ca903fcdb9 100644
>--- a/tools/perf/builtin-kmem.c
>+++ b/tools/perf/builtin-kmem.c
>@@ -638,7 +638,7 @@ static const struct {
> 	{ "__GFP_FS",			"F" },
> 	{ "__GFP_COLD",			"CO" },
> 	{ "__GFP_NOWARN",		"NWR" },
>-	{ "__GFP_REPEAT",		"R" },
>+	{ "__GFP_RETRY_MAYFAIL",	"R" },
> 	{ "__GFP_NOFAIL",		"NF" },
> 	{ "__GFP_NORETRY",		"NR" },
> 	{ "__GFP_COMP",			"C" },
>--=20
>2.11.0

--=20
Wei Yang
Help you, Help me

--UugvWAfsgieZRqgk
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZMh3oAAoJEKcLNpZP5cTdk9YP/3UJ/2Ax/aVRBVIE1nTRo+nq
IgBB4CDcl6WbvkPuyl8tqplIXfvsVMZ07m/1t7e2FD2Q9xVJJXfRab5/klHEpyku
HqjY+uhc8roXyztAAM06Veb7k0lUVtz/soKu/4ULiquhQ2rHpOiuavgc4c10cFZE
23RIaT0U7oSmir8EhCHgzvKp/fkpID5V8Z6gpC2EgVEI3bAVQ+zM4LI4iFcPX+A2
wDDC3GP69rQuYYXMdlsFJMnFu8pEbgCFBYrj4J55yc+npg1LbXVo6P5Zcdm8/vTC
MkdtPCDpcUnk2D5xFXFnq8H98kQltKFwpx1MbOHXcmSeZ/W5YyUvWiAt7rnRUolM
4TLe8lPxogBXnZ0A8renU5WgCVSS0PaBCTe0B5ywFSo3ZIxkcJwePdahRY8osq6o
sTAdaoir1s9yQAJ6aQPlNH1n4iFABro2JwDRAT0Abfni36qhVj7RsU7qM+Gn+mFt
UCwd3O98/Rlf7kD6oWZkaeMK/dWeEd+4gYVKGDW4DzGxWrqRu468arhWjB+NDvDD
Ai+IVoTnjjE7g1RreVLHvwkQSVdXeG+kPV+oR5wjj4yYpxVYrwqmgTW5RrNQKh+Y
YdUsBUz29vsUDv5CIDzE47l4GOOzrJga4QCAovgv9C0bac7cK8dTXyLYOE7/BMyQ
ga70PJAzGYxBbU43IS7Y
=b3Uo
-----END PGP SIGNATURE-----

--UugvWAfsgieZRqgk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
