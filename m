Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 889796B00A1
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 03:24:27 -0400 (EDT)
Date: Mon, 15 Jul 2013 17:24:32 +1000
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH] mm/hugetlb: per-vma instantiation mutexes
Message-ID: <20130715072432.GA28053@voom.fritz.box>
References: <1373671681.2448.10.camel@buesod1.americas.hpqcorp.net>
 <alpine.LNX.2.00.1307121729590.3899@eggly.anvils>
 <1373858204.13826.9.camel@buesod1.americas.hpqcorp.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Q68bSM7Ycu6FN28Q"
Content-Disposition: inline
In-Reply-To: <1373858204.13826.9.camel@buesod1.americas.hpqcorp.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr.bueso@hp.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Mel Gorman <mgorman@suse.de>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Michal Hocko <mhocko@suse.cz>, "AneeshKumarK.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>


--Q68bSM7Ycu6FN28Q
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jul 14, 2013 at 08:16:44PM -0700, Davidlohr Bueso wrote:
> On Fri, 2013-07-12 at 17:54 -0700, Hugh Dickins wrote:
> > Adding the essential David Gibson to the Cc list.
> >=20
> > On Fri, 12 Jul 2013, Davidlohr Bueso wrote:
> >=20
> > > The hugetlb_instantiation_mutex serializes hugepage allocation and in=
stantiation
> > > in the page directory entry. It was found that this mutex can become =
quite contended
> > > during the early phases of large databases which make use of huge pag=
es - for instance
> > > startup and initial runs. One clear example is a 1.5Gb Oracle databas=
e, where lockstat
> > > reports that this mutex can be one of the top 5 most contended locks =
in the kernel during
> > > the first few minutes:
> > >=20
> > > hugetlb_instantiation_mutex:      10678     10678
> > >              ---------------------------
> > >              hugetlb_instantiation_mutex    10678  [<ffffffff8115e14e=
>] hugetlb_fault+0x9e/0x340
> > >              ---------------------------
> > >              hugetlb_instantiation_mutex    10678  [<ffffffff8115e14e=
>] hugetlb_fault+0x9e/0x340
> > >=20
> > > contentions:          10678
> > > acquisitions:         99476
> > > waittime-total: 76888911.01 us
> > >=20
> > > Instead of serializing each hugetlb fault, we can deal with concurren=
t faults for pages
> > > in different vmas. The per-vma mutex is initialized when creating a n=
ew vma. So, back to
> > > the example above, we now get much less contention:
> > >=20
> > >  &vma->hugetlb_instantiation_mutex:  1         1
> > >        ---------------------------------
> > >        &vma->hugetlb_instantiation_mutex       1   [<ffffffff8115e216=
>] hugetlb_fault+0xa6/0x350
> > >        ---------------------------------
> > >        &vma->hugetlb_instantiation_mutex       1    [<ffffffff8115e21=
6>] hugetlb_fault+0xa6/0x350
> > >=20
> > > contentions:          1
> > > acquisitions:    108092
> > > waittime-total:  621.24 us
> > >=20
> > > Signed-off-by: Davidlohr Bueso <davidlohr.bueso@hp.com>
> >=20
> > I agree this is a problem worth solving,
> > but I doubt this patch is the right solution.

It's not.

> > > ---
> > >  include/linux/mm_types.h |  3 +++
> > >  mm/hugetlb.c             | 12 +++++-------
> > >  mm/mmap.c                |  3 +++
> > >  3 files changed, 11 insertions(+), 7 deletions(-)
> > >=20
> > > diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> > > index fb425aa..b45fd87 100644
> > > --- a/include/linux/mm_types.h
> > > +++ b/include/linux/mm_types.h
> > > @@ -289,6 +289,9 @@ struct vm_area_struct {
> > >  #ifdef CONFIG_NUMA
> > >  	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
> > >  #endif
> > > +#ifdef CONFIG_HUGETLB_PAGE
> > > +	struct mutex hugetlb_instantiation_mutex;
> > > +#endif
> > >  };
> >=20
> > Bloating every vm_area_struct with a rarely useful mutex:
> > I'm sure you can construct cases where per-vma mutex would win over
> > per-mm mutex, but they will have to be very common to justify the bloat.
> >=20
>=20
> I cannot disagree here, this was my main concern about this patch, and,
> as you mentioned, if we can just get rid of the need for the lock, much
> better.

So, by all means try to get rid of the mutex, but doing so is
surprisingly difficult - I made several failed attempts a long time
ago, before giving up and creating the mutex in the first place.

Note that the there is no analogous handling in the normal page case,
because for normal pages we always assume we have a few pages of
"slush" and can temporarily overallocate without problems.  Because
hugepages are a more precious resource, it's usual to want to allocate
and use every single one - spurious OOMs when racing to allocate the
very last hugepage are what the mutex protects against.

> > >  struct core_thread {
> > > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > > index 83aff0a..12e665b 100644
> > > --- a/mm/hugetlb.c
> > > +++ b/mm/hugetlb.c
> > > @@ -137,12 +137,12 @@ static inline struct hugepage_subpool *subpool_=
vma(struct vm_area_struct *vma)
> > >   * The region data structures are protected by a combination of the =
mmap_sem
> > >   * and the hugetlb_instantion_mutex.  To access or modify a region t=
he caller
> > >   * must either hold the mmap_sem for write, or the mmap_sem for read=
 and
> > > - * the hugetlb_instantiation mutex:
> > > + * the vma's hugetlb_instantiation mutex:
> >=20
> > Reading the existing comment, this change looks very suspicious to me.
> > A per-vma mutex is just not going to provide the necessary exclusion, is
> > it?  (But I recall next to nothing about these regions and
> > reservations.)

A per-VMA lock is definitely wrong.  I think it handles one form of
the race, between threads sharing a VM on a MAP_PRIVATE mapping.
However another form of the race can and does occur between different
MAP_SHARED VMAs in the same or different processes.  I think there may
be edge cases involving mremap() and MAP_PRIVATE that will also be
missed by a per-VMA lock.

Note that the libhugetlbfs testsuite contains tests for both PRIVATE
and SHARED variants of the race.

> > >   *
> > >   *	down_write(&mm->mmap_sem);
> > >   * or
> > >   *	down_read(&mm->mmap_sem);
> > > - *	mutex_lock(&hugetlb_instantiation_mutex);
> > > + *	mutex_lock(&vma->hugetlb_instantiation_mutex);
> > >   */
> > >  struct file_region {
> > >  	struct list_head link;
> > > @@ -2547,7 +2547,7 @@ static int unmap_ref_private(struct mm_struct *=
mm, struct vm_area_struct *vma,
> > > =20
> > >  /*
> > >   * Hugetlb_cow() should be called with page lock of the original hug=
epage held.
> > > - * Called with hugetlb_instantiation_mutex held and pte_page locked =
so we
> > > + * Called with the vma's hugetlb_instantiation_mutex held and pte_pa=
ge locked so we
> > >   * cannot race with other handlers or page migration.
> > >   * Keep the pte_same checks anyway to make transition from the mutex=
 easier.
> > >   */
> > > @@ -2847,7 +2847,6 @@ int hugetlb_fault(struct mm_struct *mm, struct =
vm_area_struct *vma,
> > >  	int ret;
> > >  	struct page *page =3D NULL;
> > >  	struct page *pagecache_page =3D NULL;
> > > -	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
> > >  	struct hstate *h =3D hstate_vma(vma);
> > > =20
> > >  	address &=3D huge_page_mask(h);
> > > @@ -2872,7 +2871,7 @@ int hugetlb_fault(struct mm_struct *mm, struct =
vm_area_struct *vma,
> > >  	 * get spurious allocation failures if two CPUs race to instantiate
> > >  	 * the same page in the page cache.
> > >  	 */
> > > -	mutex_lock(&hugetlb_instantiation_mutex);
> > > +	mutex_lock(&vma->hugetlb_instantiation_mutex);
> > >  	entry =3D huge_ptep_get(ptep);
> > >  	if (huge_pte_none(entry)) {
> > >  		ret =3D hugetlb_no_page(mm, vma, address, ptep, flags);
> > > @@ -2943,8 +2942,7 @@ out_page_table_lock:
> > >  	put_page(page);
> > > =20
> > >  out_mutex:
> > > -	mutex_unlock(&hugetlb_instantiation_mutex);
> > > -
> > > +	mutex_unlock(&vma->hugetlb_instantiation_mutex);
> > >  	return ret;
> > >  }
> > > =20
> > > diff --git a/mm/mmap.c b/mm/mmap.c
> > > index fbad7b0..8f0b034 100644
> > > --- a/mm/mmap.c
> > > +++ b/mm/mmap.c
> > > @@ -1543,6 +1543,9 @@ munmap_back:
> > >  	vma->vm_page_prot =3D vm_get_page_prot(vm_flags);
> > >  	vma->vm_pgoff =3D pgoff;
> > >  	INIT_LIST_HEAD(&vma->anon_vma_chain);
> > > +#ifdef CONFIG_HUGETLB_PAGE
> > > +	mutex_init(&vma->hugetlb_instantiation_mutex);
> > > +#endif
> > > =20
> > >  	error =3D -EINVAL;	/* when rejecting VM_GROWSDOWN|VM_GROWSUP */
> > > =20
> >=20
> > The hugetlb_instantiation_mutex has always been rather an embarrassment:
> > it would be much more satisfying to remove the need for it, than to spl=
it
> > it in this way.  (Maybe a technique like THP sometimes uses, marking an
> > entry as in transition while the new entry is prepared.)
>=20
> I didn't realize this was a known issue. Doing some googling I can see
> some additional alternatives to getting rid of the lock:
>=20
> - [PATCH] remove hugetlb_instantiation_mutex:
> https://lkml.org/lkml/2007/7/27/46
>=20
> - Commit 3935baa (hugepage: serialize hugepage allocation and
> instantiation): David mentioned a way to possibly avoid the need for
> this lock.
>=20
> >=20
> > But I suppose it would not have survived so long if that were easy,
> > and I think it may have grown some subtle dependants over the years -
> > as the region comment indicates.
>=20
> Indeed. I'm not very acquainted with hugetlb code, so, assuming this
> patch's approach isn't valid, and we can figure out some way of getting
> rid of the mutex, I'd like to get some mm folks feedback on this.

I have previously proposed a correct method of improving scalability,
although it doesn't eliminate the lock.  That's to use a set of hashed
mutexes.  It wasn't merged before, but I don't recall the reasons
why.  Old and probably bitrotted patch below for reference:

hugepage: Allow parallelization of the hugepage fault path

At present, the page fault path for hugepages is serialized by a
single mutex.  This is used to avoid spurious out-of-memory conditions
when the hugepage pool is fully utilized (two processes or threads can
race to instantiate the same mapping with the last hugepage from the
pool, the race loser returning VM_FAULT_OOM).  This problem is
specific to hugepages, because it is normal to want to use every
single hugepage in the system - with normal pages we simply assume
there will always be a few spare pages which can be used temporarily
until the race is resolved.

Unfortunately this serialization also means that clearing of hugepages
cannot be parallelized across multiple CPUs, which can lead to very
long process startup times when using large numbers of hugepages.

This patch improves the situation by replacing the single mutex with a
table of mutexes, selected based on a hash of the address_space and
file offset being faulted (or mm and virtual address for MAP_PRIVATE
mappings).

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>

Index: working-2.6/mm/hugetlb.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- working-2.6.orig/mm/hugetlb.c	2006-10-25 16:30:00.000000000 +1000
+++ working-2.6/mm/hugetlb.c	2006-10-26 14:38:08.000000000 +1000
@@ -32,6 +32,13 @@ static unsigned int free_huge_pages_node
  */
 static DEFINE_SPINLOCK(hugetlb_lock);
=20
+/*
+ * Serializes faults on the same logical page.  This is used to
+ * prevent spurious OOMs when the hugepage pool is fully utilized.
+ */
+static int num_fault_mutexes;
+static struct mutex *htlb_fault_mutex_table;
+
 static void clear_huge_page(struct page *page, unsigned long addr)
 {
 	int i;
@@ -160,6 +167,13 @@ static int __init hugetlb_init(void)
 	}
 	max_huge_pages =3D free_huge_pages =3D nr_huge_pages =3D i;
 	printk("Total HugeTLB memory allocated, %ld\n", free_huge_pages);
+
+	num_fault_mutexes =3D 2 * num_possible_cpus() - 1;
+	htlb_fault_mutex_table =3D
+		kmalloc(sizeof(struct mutex) * num_fault_mutexes, GFP_KERNEL);
+	for (i =3D 0; i < num_fault_mutexes; i++)
+		mutex_init(&htlb_fault_mutex_table[i]);
+
 	return 0;
 }
 module_init(hugetlb_init);
@@ -458,19 +472,14 @@ static int hugetlb_cow(struct mm_struct=20
 }
=20
 int hugetlb_no_page(struct mm_struct *mm, struct vm_area_struct *vma,
-			unsigned long address, pte_t *ptep, int write_access)
+		    struct address_space *mapping, unsigned long idx,
+		    unsigned long address, pte_t *ptep, int write_access)
 {
 	int ret =3D VM_FAULT_SIGBUS;
-	unsigned long idx;
 	unsigned long size;
 	struct page *page;
-	struct address_space *mapping;
 	pte_t new_pte;
=20
-	mapping =3D vma->vm_file->f_mapping;
-	idx =3D ((address - vma->vm_start) >> HPAGE_SHIFT)
-		+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
-
 	/*
 	 * Use page lock to guard against racing truncation
 	 * before we get page_table_lock.
@@ -545,28 +554,50 @@ out:
 	return ret;
 }
=20
+static int fault_mutex_hash(struct mm_struct *mm, struct vm_area_struct *v=
ma,
+			    struct address_space *mapping,
+			    unsigned long pagenum, unsigned long address)
+{
+	void *p =3D mapping;
+
+	if (! (vma->vm_flags & VM_SHARED)) {
+		p =3D mm;
+		pagenum =3D address << HPAGE_SIZE;
+	}
+
+	return ((unsigned long)p + pagenum) % num_fault_mutexes;
+}
+
 int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			unsigned long address, int write_access)
 {
 	pte_t *ptep;
 	pte_t entry;
 	int ret;
-	static DEFINE_MUTEX(hugetlb_instantiation_mutex);
+	struct address_space *mapping;
+	unsigned long idx;
+	int hash;
=20
 	ptep =3D huge_pte_alloc(mm, address);
 	if (!ptep)
 		return VM_FAULT_OOM;
=20
+	mapping =3D vma->vm_file->f_mapping;
+	idx =3D ((address - vma->vm_start) >> HPAGE_SHIFT)
+		+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
+
 	/*
 	 * Serialize hugepage allocation and instantiation, so that we don't
 	 * get spurious allocation failures if two CPUs race to instantiate
 	 * the same page in the page cache.
 	 */
-	mutex_lock(&hugetlb_instantiation_mutex);
+	hash =3D fault_mutex_hash(mm, vma, mapping, idx, address);
+	mutex_lock(&htlb_fault_mutex_table[hash]);
 	entry =3D *ptep;
 	if (pte_none(entry)) {
-		ret =3D hugetlb_no_page(mm, vma, address, ptep, write_access);
-		mutex_unlock(&hugetlb_instantiation_mutex);
+		ret =3D hugetlb_no_page(mm, vma, mapping, idx,
+				      address, ptep, write_access);
+		mutex_unlock(&htlb_fault_mutex_table[hash]);
 		return ret;
 	}
=20
@@ -578,7 +609,7 @@ int hugetlb_fault(struct mm_struct *mm,=20
 		if (write_access && !pte_write(entry))
 			ret =3D hugetlb_cow(mm, vma, address, ptep, entry);
 	spin_unlock(&mm->page_table_lock);
-	mutex_unlock(&hugetlb_instantiation_mutex);
+	mutex_unlock(&htlb_fault_mutex_table[hash]);
=20
 	return ret;
 }


--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--Q68bSM7Ycu6FN28Q
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iEYEARECAAYFAlHjo7AACgkQaILKxv3ab8bOdACcDFKJ8GWvLq6CBO+2+oMpFd4N
0HAAnR3g3g7tFvbvhP0WxyQB6nzLNMJS
=hNvM
-----END PGP SIGNATURE-----

--Q68bSM7Ycu6FN28Q--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
