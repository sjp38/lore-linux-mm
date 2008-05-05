Date: Mon, 5 May 2008 14:46:25 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH 01 of 11] mmu-notifier-core
Message-ID: <20080505194625.GA17734@sgi.com>
References: <patchbomb.1209740703@duo.random> <1489529e7b53d3f2dab8.1209740704@duo.random> <20080505162113.GA18761@sgi.com> <20080505171434.GF8470@duo.random> <20080505172506.GA9247@sgi.com> <20080505183405.GI8470@duo.random>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="FL5UXtIhxfXey3p5"
Content-Disposition: inline
In-Reply-To: <20080505183405.GI8470@duo.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

--FL5UXtIhxfXey3p5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, May 05, 2008 at 08:34:05PM +0200, Andrea Arcangeli wrote:
> On Mon, May 05, 2008 at 12:25:06PM -0500, Jack Steiner wrote:
> > Agree. My apologies... I should have caught it.
> 
> No problem.
> 
> > __mmu_notifier_register/__mmu_notifier_unregister seems like a better way to
> > go, although either is ok.
> 
> If you also like __mmu_notifier_register more I'll go with it. The
> bitflags seems like a bit of overkill as I can't see the need of any
> other bitflag other than this one and they also can't be removed as
> easily in case you'll find a way to call it outside the lock later.
> 
> > Let me finish my testing. At one time, I did not use ->release but
> > with all the locking & teardown changes, I need to do some reverification.

I finished testing & everything looks good. I do use the ->release callout but
mainly as a performance hint that teardown is in progress & that TLB flushing is
no longer needed. (GRU TLB entries are tagged with a task-specific ID that will
not be reused until a full TLB purge is done. This eliminates the requirement
to purge at task-exit.)


Normally, a notifier is registered when a GRU segment is mmaped, and unregistered
when the segment is unmapped. Well behaved tasks will not have a GRU or
a notifier when exit starts.

If a task fails to unmap a GRU segment, they still exist at the start of
exit. On the ->release callout, I set a flag in the container of my
mmu_notifier that exit has started. As VMA are cleaned up, TLB flushes
are skipped because of the flag is set. When the GRU VMA is deleted, I free
my structure containing the notifier.

I _think_ works. Do you see any problems?

I should also mention that I have an open-coded function that possibly
belongs in mmu_notifier.c. A user is allowed to have multiple GRU segments.
Each GRU has a couple of data structures linked to the VMA. All, however,
need to share the same notifier. I currently open code a function that
scans the notifier list to determine if a GRU notifier already exists.
If it does, I update a refcnt & use it. Otherwise, I register a new
one. All of this is protected by the mmap_sem.

Just in case I mangled the above description, I'll attach a copy of the GRU mmuops
code.

--- jack

--FL5UXtIhxfXey3p5
Content-Type: application/x-compress
Content-Disposition: attachment; filename=z
Content-Transfer-Encoding: quoted-printable

/*=0A * MMUOPS notifier callout functions=0A */=0Astatic void gru_invalidat=
e_range_start(struct mmu_notifier *mn,=0A	       struct mm_struct *mm, unsi=
gned long start, unsigned long end)=0A{=0A	struct gru_mm_struct *gms =3D co=
ntainer_of(mn, struct gru_mm_struct,=0A				ms_notifier);=0A=0A	atomic_inc(&=
gms->ms_range_active);=0A	if (!gms->ms_released)=0A		gru_flush_tlb_range(gm=
s, start, end - start);=0A}=0A=0Astatic void gru_invalidate_range_end(struc=
t mmu_notifier *mn,=0A		struct mm_struct *mm, unsigned long start, unsigned=
 long end)=0A{=0A	struct gru_mm_struct *gms =3D container_of(mn, struct gru=
_mm_struct,=0A					ms_notifier);=0A=0A	atomic_dec(&gms->ms_range_active);=
=0A	wake_up_all(&gms->ms_wait_queue);=0A}=0A=0Astatic void gru_invalidate_p=
age(struct mmu_notifier *mn, struct mm_struct *mm,=0A				       unsigned lo=
ng address)=0A{=0A	struct gru_mm_struct *gms =3D container_of(mn, struct gr=
u_mm_struct,=0A					ms_notifier);=0A=0A	if (!gms->ms_released)=0A		gru_flus=
h_tlb_range(gms, address, address + PAGE_SIZE);=0A}=0A=0Astatic int gru_cle=
ar_flush_young(struct mmu_notifier *mn, struct mm_struct *mm,=0A				       =
unsigned long address)=0A{=0A	return 1;=0A}=0A=0Astatic void gru_mmu_releas=
e(struct mmu_notifier *mn, struct mm_struct *mm)=0A{=0A	struct gru_mm_struc=
t *gms =3D container_of(mn, struct gru_mm_struct,=0A					ms_notifier);=0A=
=0A	gms->ms_released =3D 1;=0A}=0A=0Astruct mmu_notifier_ops  gru_mmuops =
=3D {=0A	.release =3D gru_mmu_release,=0A	.clear_flush_young =3D gru_clear_=
flush_young,=0A	.invalidate_page =3D  gru_invalidate_page,=0A	.invalidate_r=
ange_start =3D gru_invalidate_range_start,=0A	.invalidate_range_end =3D gru=
_invalidate_range_end,=0A};=0A=0A/* Move this to the basic mmu_notifier fil=
e. But for now... */=0Astatic struct mmu_notifier *mmu_find_ops(struct mm_s=
truct *mm)=0A{=0A	struct mmu_notifier *mn;=0A	struct hlist_node *n;=0A=0A	i=
f (mm->mmu_notifier_mm)=0A		hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifi=
er_mm->list, hlist)=0A			if (mn->ops =3D=3D &gru_mmuops)=0A				return mn;=
=0A	return NULL;=0A}=0A=0Astruct gru_mm_struct *gru_register_mmu_notifier(v=
oid)=0A{=0A	struct gru_mm_struct *gms;=0A	struct mmu_notifier *mn;=0A=0A	mn=
 =3D mmu_find_ops(current->mm);=0A	if (mn) {=0A		gms =3D container_of(mn, s=
truct gru_mm_struct, ms_notifier);=0A		atomic_inc(&gms->ms_refcnt);=0A	} el=
se {=0A		gms =3D kzalloc(sizeof(*gms), GFP_KERNEL);=0A		if (gms) {=0A			spi=
n_lock_init(&gms->ms_asid_lock);=0A			gms->ms_notifier.ops =3D &gru_mmuops;=
=0A			atomic_set(&gms->ms_refcnt, 1);=0A			init_waitqueue_head(&gms->ms_wai=
t_queue);=0A			mmu_notifier_register(&gms->ms_notifier, current->mm);=0A			=
synchronize_rcu();=0A		}=0A	}=0A	return gms;=0A}=0A=0Avoid gru_drop_mmu_not=
ifier(struct gru_mm_struct *gms)=0A{=0A	if (atomic_dec_return(&gms->ms_refc=
nt) =3D=3D 0) {=0A		if (!gms->ms_released)=0A			mmu_notifier_unregister(&gm=
s->ms_notifier, current->mm);=0A		kfree(gms);=0A	}=0A}=0A=0A
--FL5UXtIhxfXey3p5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
