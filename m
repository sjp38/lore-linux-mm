Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A6E216B0278
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 10:00:17 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so28337583wmv.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 07:00:17 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o97si23129809wrc.185.2017.01.24.07.00.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Jan 2017 07:00:16 -0800 (PST)
Date: Tue, 24 Jan 2017 16:00:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
Message-ID: <20170124150004.GM6867@dhcp22.suse.cz>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
 <CAGXu5jKhYP=5YNuntzmG64WL92F59VKhByOh9nqaGP7-LBEnng@mail.gmail.com>
 <20170112173745.GC31509@dhcp22.suse.cz>
 <7c109e9e-e28b-3ddb-42b6-902f46bf0572@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7c109e9e-e28b-3ddb-42b6-902f46bf0572@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Yishai Hadas <yishaih@mellanox.com>, Dan Williams <dan.j.williams@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Network Development <netdev@vger.kernel.org>

On Fri 20-01-17 14:41:37, Vlastimil Babka wrote:
> On 01/12/2017 06:37 PM, Michal Hocko wrote:
> > On Thu 12-01-17 09:26:09, Kees Cook wrote:
> >> On Thu, Jan 12, 2017 at 7:37 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > [...]
> >>> diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
> >>> index 4f74511015b8..e6bbb33d2956 100644
> >>> --- a/arch/s390/kvm/kvm-s390.c
> >>> +++ b/arch/s390/kvm/kvm-s390.c
> >>> @@ -1126,10 +1126,7 @@ static long kvm_s390_get_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
> >>>         if (args->count < 1 || args->count > KVM_S390_SKEYS_MAX)
> >>>                 return -EINVAL;
> >>>
> >>> -       keys = kmalloc_array(args->count, sizeof(uint8_t),
> >>> -                            GFP_KERNEL | __GFP_NOWARN);
> >>> -       if (!keys)
> >>> -               keys = vmalloc(sizeof(uint8_t) * args->count);
> >>> +       keys = kvmalloc(args->count * sizeof(uint8_t), GFP_KERNEL);
> >>
> >> Before doing this conversion, can we add a kvmalloc_array() API? This
> >> conversion could allow for the reintroduction of integer overflow
> >> flaws. (This particular situation isn't at risk since ->count is
> >> checked, but I'd prefer we not create a risky set of examples for
> >> using kvmalloc.)
> > 
> > Well, I am not opposed to kvmalloc_array but I would argue that this
> > conversion cannot introduce new overflow issues. The code would have
> > to be broken already because even though kmalloc_array checks for the
> > overflow but vmalloc fallback doesn't...
> 
> Yeah I agree, but if some of the places were really wrong, after the
> conversion we won't see them anymore.
> 
> > If there is a general interest for this API I can add it.
> 
> I think it would be better, yes.

OK, fair enough. I will fold the following into the original patch. I
was little bit reluctant to create kvcalloc so I've made the original
callers more talkative and added | __GFP_ZERO. To be honest I do not
really like how kcalloc...
---
diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
index e6bbb33d2956..aa558dce6bb4 100644
--- a/arch/s390/kvm/kvm-s390.c
+++ b/arch/s390/kvm/kvm-s390.c
@@ -1126,7 +1126,7 @@ static long kvm_s390_get_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
 	if (args->count < 1 || args->count > KVM_S390_SKEYS_MAX)
 		return -EINVAL;
 
-	keys = kvmalloc(args->count * sizeof(uint8_t), GFP_KERNEL);
+	keys = kvmalloc_array(args->count, sizeof(uint8_t), GFP_KERNEL);
 	if (!keys)
 		return -ENOMEM;
 
@@ -1168,7 +1168,7 @@ static long kvm_s390_set_skeys(struct kvm *kvm, struct kvm_s390_skeys *args)
 	if (args->count < 1 || args->count > KVM_S390_SKEYS_MAX)
 		return -EINVAL;
 
-	keys = kvmalloc(sizeof(uint8_t) * args->count, GFP_KERNEL);
+	keys = kvmalloc_array(args->count, sizeof(uint8_t), GFP_KERNEL);
 	if (!keys)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 82354fd0a87e..6583d4601480 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -115,7 +115,7 @@ static int mlx4_buddy_init(struct mlx4_buddy *buddy, int max_order)
 
 	for (i = 0; i <= buddy->max_order; ++i) {
 		s = BITS_TO_LONGS(1 << (buddy->max_order - i));
-		buddy->bits[i] = kvzalloc(s * sizeof(long), GFP_KERNEL);
+		buddy->bits[i] = kvmalloc_array(s, sizeof(long), GFP_KERNEL | __GFP_ZERO);
 		if (!buddy->bits[i])
 			goto err_out_free;
 	}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 55fd570c3e1e..22c6e81d0c16 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -498,6 +498,14 @@ static inline void *kvzalloc(size_t size, gfp_t flags)
 	return kvmalloc(size, flags | __GFP_ZERO);
 }
 
+static inline void *kvmalloc_array(size_t n, size_t size, gfp_t flags)
+{
+	if (size != 0 && n > SIZE_MAX / size)
+		return NULL;
+
+	return kvmalloc(n * size, flags);
+}
+
 extern void kvfree(const void *addr);
 
 static inline atomic_t *compound_mapcount_ptr(struct page *page)
diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 4ca30a951bbc..58ec07946fe6 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -320,7 +320,7 @@ static struct bpf_map *htab_map_alloc(union bpf_attr *attr)
 		goto free_htab;
 
 	err = -ENOMEM;
-	htab->buckets = kvmalloc(htab->n_buckets * sizeof(struct bucket), GFP_USER);
+	htab->buckets = kvmalloc_array(htab->n_buckets, sizeof(struct bucket), GFP_USER);
 	if (!htab->buckets)
 		goto free_htab;
 
diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index 45c17b5562b5..8f9caf095172 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -957,7 +957,7 @@ EXPORT_SYMBOL(iov_iter_get_pages);
 
 static struct page **get_pages_array(size_t n)
 {
-	return kvmalloc(n * sizeof(struct page *), GFP_KERNEL);
+	return kvmalloc_array(n, sizeof(struct page *), GFP_KERNEL);
 }
 
 static ssize_t pipe_get_pages_alloc(struct iov_iter *i,
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index a46a9fd8b540..0c4848bd86c4 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -687,7 +687,7 @@ int inet_ehash_locks_alloc(struct inet_hashinfo *hashinfo)
 		/* no more locks than number of hash buckets */
 		nblocks = min(nblocks, hashinfo->ehash_mask + 1);
 
-		hashinfo->ehash_locks = kvmalloc(nblocks * locksz, GFP_KERNEL);
+		hashinfo->ehash_locks = kvmalloc_array(nblocks, locksz, GFP_KERNEL);
 		if (!hashinfo->ehash_locks)
 			return -ENOMEM;
 
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index cdc55d5ee4ad..eca16612b1ae 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -712,10 +712,7 @@ EXPORT_SYMBOL(xt_check_entry_offsets);
  */
 unsigned int *xt_alloc_entry_offsets(unsigned int size)
 {
-	if (size < (SIZE_MAX / sizeof(unsigned int)))
-		return kvzalloc(size * sizeof(unsigned int), GFP_KERNEL);
-
-	return NULL;
+	return kvmalloc_array(size * sizeof(unsigned int), GFP_KERNEL | __GFP_ZERO);
 
 }
 EXPORT_SYMBOL(xt_alloc_entry_offsets);
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 30d6a39fd2c8..47cbfae44898 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -431,7 +431,7 @@ static int choke_change(struct Qdisc *sch, struct nlattr *opt)
 	if (mask != q->tab_mask) {
 		struct sk_buff **ntab;
 
-		ntab = kvzalloc((mask + 1) * sizeof(struct sk_buff *), GFP_KERNEL);
+		ntab = kvmalloc_array((mask + 1), sizeof(struct sk_buff *), GFP_KERNEL | __GFP_ZERO);
 		if (!ntab)
 			return -ENOMEM;
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
