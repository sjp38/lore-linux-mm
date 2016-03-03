Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 473D76B025E
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 17:50:18 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id n186so10878446wmn.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 14:50:18 -0800 (PST)
Received: from smtp5-g21.free.fr (smtp5-g21.free.fr. [212.27.42.5])
        by mx.google.com with ESMTPS id jo9si737112wjb.100.2016.03.03.14.50.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Mar 2016 14:50:17 -0800 (PST)
Date: Thu, 3 Mar 2016 23:49:56 +0100
From: Pierre Moreau <pierre.morrow@free.fr>
Subject: Re: [Nouveau] RFC: [PATCH] x86/kmmio: fix mmiotrace for hugepages
Message-ID: <20160303224956.GA1487@pmoreau.org>
References: <1456966991-6861-1-git-send-email-nouveau@karolherbst.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="VbJkn9YxBvnuCH5J"
Content-Disposition: inline
In-Reply-To: <1456966991-6861-1-git-send-email-nouveau@karolherbst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Karol Herbst <nouveau@karolherbst.de>
Cc: linux-kernel@vger.kernel.org, nouveau@lists.freedesktop.org, rostedt@goodmis.org, linux-mm@kvack.org, mingo@redhat.com, linux-x86_64@vger.kernel.org


--VbJkn9YxBvnuCH5J
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

The secondary hit exception thrown while MMIOtracing NVIDIA's driver is gone
with this patch.

Tested-by: Pierre Moreau <pierre.morrow@free.fr>

On 02:03 AM - Mar 03 2016, Karol Herbst wrote:
> Because Linux might use bigger pages than the 4K pages to handle those mm=
io
> ioremaps, the kmmio code shouldn't rely on the pade id as it currently do=
es.
>=20
> Using the memory address instead of the page id let's us lookup how big t=
he
> page is and what it's base address is, so that we won't get a page fault
> within the same page twice anymore.
>=20
> I don't know if I got this right though, so please read this change with
> great care
>=20
> v2: use page_level macros
>=20
> Signed-off-by: Karol Herbst <nouveau@karolherbst.de>
> ---
>  arch/x86/mm/kmmio.c | 89 ++++++++++++++++++++++++++++++++++++-----------=
------
>  1 file changed, 60 insertions(+), 29 deletions(-)
>=20
> diff --git a/arch/x86/mm/kmmio.c b/arch/x86/mm/kmmio.c
> index 637ab34..d203beb 100644
> --- a/arch/x86/mm/kmmio.c
> +++ b/arch/x86/mm/kmmio.c
> @@ -33,7 +33,7 @@
>  struct kmmio_fault_page {
>  	struct list_head list;
>  	struct kmmio_fault_page *release_next;
> -	unsigned long page; /* location of the fault page */
> +	unsigned long addr; /* the requested address */
>  	pteval_t old_presence; /* page presence prior to arming */
>  	bool armed;
> =20
> @@ -70,9 +70,16 @@ unsigned int kmmio_count;
>  static struct list_head kmmio_page_table[KMMIO_PAGE_TABLE_SIZE];
>  static LIST_HEAD(kmmio_probes);
> =20
> -static struct list_head *kmmio_page_list(unsigned long page)
> +static struct list_head *kmmio_page_list(unsigned long addr)
>  {
> -	return &kmmio_page_table[hash_long(page, KMMIO_PAGE_HASH_BITS)];
> +	unsigned int l;
> +	pte_t *pte =3D lookup_address(addr, &l);
> +
> +	if (!pte)
> +		return NULL;
> +	addr &=3D page_level_mask(l);
> +
> +	return &kmmio_page_table[hash_long(addr, KMMIO_PAGE_HASH_BITS)];
>  }
> =20
>  /* Accessed per-cpu */
> @@ -98,15 +105,19 @@ static struct kmmio_probe *get_kmmio_probe(unsigned =
long addr)
>  }
> =20
>  /* You must be holding RCU read lock. */
> -static struct kmmio_fault_page *get_kmmio_fault_page(unsigned long page)
> +static struct kmmio_fault_page *get_kmmio_fault_page(unsigned long addr)
>  {
>  	struct list_head *head;
>  	struct kmmio_fault_page *f;
> +	unsigned int l;
> +	pte_t *pte =3D lookup_address(addr, &l);
> =20
> -	page &=3D PAGE_MASK;
> -	head =3D kmmio_page_list(page);
> +	if (!pte)
> +		return NULL;
> +	addr &=3D page_level_mask(l);
> +	head =3D kmmio_page_list(addr);
>  	list_for_each_entry_rcu(f, head, list) {
> -		if (f->page =3D=3D page)
> +		if (f->addr =3D=3D addr)
>  			return f;
>  	}
>  	return NULL;
> @@ -137,10 +148,10 @@ static void clear_pte_presence(pte_t *pte, bool cle=
ar, pteval_t *old)
>  static int clear_page_presence(struct kmmio_fault_page *f, bool clear)
>  {
>  	unsigned int level;
> -	pte_t *pte =3D lookup_address(f->page, &level);
> +	pte_t *pte =3D lookup_address(f->addr, &level);
> =20
>  	if (!pte) {
> -		pr_err("no pte for page 0x%08lx\n", f->page);
> +		pr_err("no pte for addr 0x%08lx\n", f->addr);
>  		return -1;
>  	}
> =20
> @@ -156,7 +167,7 @@ static int clear_page_presence(struct kmmio_fault_pag=
e *f, bool clear)
>  		return -1;
>  	}
> =20
> -	__flush_tlb_one(f->page);
> +	__flush_tlb_one(f->addr);
>  	return 0;
>  }
> =20
> @@ -176,12 +187,12 @@ static int arm_kmmio_fault_page(struct kmmio_fault_=
page *f)
>  	int ret;
>  	WARN_ONCE(f->armed, KERN_ERR pr_fmt("kmmio page already armed.\n"));
>  	if (f->armed) {
> -		pr_warning("double-arm: page 0x%08lx, ref %d, old %d\n",
> -			   f->page, f->count, !!f->old_presence);
> +		pr_warning("double-arm: addr 0x%08lx, ref %d, old %d\n",
> +			   f->addr, f->count, !!f->old_presence);
>  	}
>  	ret =3D clear_page_presence(f, true);
> -	WARN_ONCE(ret < 0, KERN_ERR pr_fmt("arming 0x%08lx failed.\n"),
> -		  f->page);
> +	WARN_ONCE(ret < 0, KERN_ERR pr_fmt("arming at 0x%08lx failed.\n"),
> +		  f->addr);
>  	f->armed =3D true;
>  	return ret;
>  }
> @@ -191,7 +202,7 @@ static void disarm_kmmio_fault_page(struct kmmio_faul=
t_page *f)
>  {
>  	int ret =3D clear_page_presence(f, false);
>  	WARN_ONCE(ret < 0,
> -			KERN_ERR "kmmio disarming 0x%08lx failed.\n", f->page);
> +			KERN_ERR "kmmio disarming at 0x%08lx failed.\n", f->addr);
>  	f->armed =3D false;
>  }
> =20
> @@ -215,6 +226,12 @@ int kmmio_handler(struct pt_regs *regs, unsigned lon=
g addr)
>  	struct kmmio_context *ctx;
>  	struct kmmio_fault_page *faultpage;
>  	int ret =3D 0; /* default to fault not handled */
> +	unsigned long page_base =3D addr;
> +	unsigned int l;
> +	pte_t *pte =3D lookup_address(addr, &l);
> +	if (!pte)
> +		return -EINVAL;
> +	page_base &=3D page_level_mask(l);
> =20
>  	/*
>  	 * Preemption is now disabled to prevent process switch during
> @@ -227,7 +244,7 @@ int kmmio_handler(struct pt_regs *regs, unsigned long=
 addr)
>  	preempt_disable();
>  	rcu_read_lock();
> =20
> -	faultpage =3D get_kmmio_fault_page(addr);
> +	faultpage =3D get_kmmio_fault_page(page_base);
>  	if (!faultpage) {
>  		/*
>  		 * Either this page fault is not caused by kmmio, or
> @@ -239,7 +256,7 @@ int kmmio_handler(struct pt_regs *regs, unsigned long=
 addr)
> =20
>  	ctx =3D &get_cpu_var(kmmio_ctx);
>  	if (ctx->active) {
> -		if (addr =3D=3D ctx->addr) {
> +		if (page_base =3D=3D ctx->addr) {
>  			/*
>  			 * A second fault on the same page means some other
>  			 * condition needs handling by do_page_fault(), the
> @@ -267,9 +284,9 @@ int kmmio_handler(struct pt_regs *regs, unsigned long=
 addr)
>  	ctx->active++;
> =20
>  	ctx->fpage =3D faultpage;
> -	ctx->probe =3D get_kmmio_probe(addr);
> +	ctx->probe =3D get_kmmio_probe(page_base);
>  	ctx->saved_flags =3D (regs->flags & (X86_EFLAGS_TF | X86_EFLAGS_IF));
> -	ctx->addr =3D addr;
> +	ctx->addr =3D page_base;
> =20
>  	if (ctx->probe && ctx->probe->pre_handler)
>  		ctx->probe->pre_handler(ctx->probe, regs, addr);
> @@ -354,12 +371,11 @@ out:
>  }
> =20
>  /* You must be holding kmmio_lock. */
> -static int add_kmmio_fault_page(unsigned long page)
> +static int add_kmmio_fault_page(unsigned long addr)
>  {
>  	struct kmmio_fault_page *f;
> =20
> -	page &=3D PAGE_MASK;
> -	f =3D get_kmmio_fault_page(page);
> +	f =3D get_kmmio_fault_page(addr);
>  	if (f) {
>  		if (!f->count)
>  			arm_kmmio_fault_page(f);
> @@ -372,26 +388,25 @@ static int add_kmmio_fault_page(unsigned long page)
>  		return -1;
> =20
>  	f->count =3D 1;
> -	f->page =3D page;
> +	f->addr =3D addr;
> =20
>  	if (arm_kmmio_fault_page(f)) {
>  		kfree(f);
>  		return -1;
>  	}
> =20
> -	list_add_rcu(&f->list, kmmio_page_list(f->page));
> +	list_add_rcu(&f->list, kmmio_page_list(f->addr));
> =20
>  	return 0;
>  }
> =20
>  /* You must be holding kmmio_lock. */
> -static void release_kmmio_fault_page(unsigned long page,
> +static void release_kmmio_fault_page(unsigned long addr,
>  				struct kmmio_fault_page **release_list)
>  {
>  	struct kmmio_fault_page *f;
> =20
> -	page &=3D PAGE_MASK;
> -	f =3D get_kmmio_fault_page(page);
> +	f =3D get_kmmio_fault_page(addr);
>  	if (!f)
>  		return;
> =20
> @@ -420,18 +435,27 @@ int register_kmmio_probe(struct kmmio_probe *p)
>  	int ret =3D 0;
>  	unsigned long size =3D 0;
>  	const unsigned long size_lim =3D p->len + (p->addr & ~PAGE_MASK);
> +	unsigned int l;
> +	pte_t *pte;
> =20
>  	spin_lock_irqsave(&kmmio_lock, flags);
>  	if (get_kmmio_probe(p->addr)) {
>  		ret =3D -EEXIST;
>  		goto out;
>  	}
> +
> +	pte =3D lookup_address(p->addr, &l);
> +	if (!pte) {
> +		ret =3D -EINVAL;
> +		goto out;
> +	}
> +
>  	kmmio_count++;
>  	list_add_rcu(&p->list, &kmmio_probes);
>  	while (size < size_lim) {
>  		if (add_kmmio_fault_page(p->addr + size))
>  			pr_err("Unable to set page fault.\n");
> -		size +=3D PAGE_SIZE;
> +		size +=3D page_level_size(l);
>  	}
>  out:
>  	spin_unlock_irqrestore(&kmmio_lock, flags);
> @@ -506,11 +530,18 @@ void unregister_kmmio_probe(struct kmmio_probe *p)
>  	const unsigned long size_lim =3D p->len + (p->addr & ~PAGE_MASK);
>  	struct kmmio_fault_page *release_list =3D NULL;
>  	struct kmmio_delayed_release *drelease;
> +	unsigned int l;
> +	pte_t *pte;
> +
> +	pte =3D lookup_address(p->addr, &l);
> +	if (!pte) {
> +		return;
> +	}
> =20
>  	spin_lock_irqsave(&kmmio_lock, flags);
>  	while (size < size_lim) {
>  		release_kmmio_fault_page(p->addr + size, &release_list);
> -		size +=3D PAGE_SIZE;
> +		size +=3D page_level_size(l);
>  	}
>  	list_del_rcu(&p->list);
>  	kmmio_count--;
> --=20
> 2.7.2
>=20
> _______________________________________________
> Nouveau mailing list
> Nouveau@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/nouveau

--VbJkn9YxBvnuCH5J
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJW2L+JAAoJEI7uMhYTPh3wweEP/jOBgUu8TECxCV3X2HDhiisf
pca+jon8abFGC0SuP10+LMxQ9Lmjx/ShHDWdpJjYvR6ML7qjiOmI5YQTM5M+Q/gC
Z0QdHONrHN9AgWef3U0uVQ0DKsqDqQJeWfKTdcuPb1M5bDF1sfbh17HRVF0e9O0X
CO9tkGE9YC/ly1kVZsgUyWnX2iHTF/idxbv0U5vw7zAEeZzkQ08yh5D47Ai+ymFq
2/RQ37LJwFrysC0NvCzbTAIZGyNmhN9y5+uUsHXbH5VEeEWFEGTEG4G3mTsA7vv9
lriF4UQmrur+PAXMFF5Z/x7SNktGnPJM8Hu29Xr1yob7kL3b4jM9ApRtu1R0YrP0
JvYSECojy67PoBHpN7X6KcuTPrMvCxr1ZMdzXlbR5EzFRlT28HcqSkO2l3w5HUsD
ycC8uqYjfQgsNunnrNEkVCOK/dfkt+9s11A9VMO3M2xL18zo2Du8RdIqQWlzX/9Q
dncoMXEr5HzyjwSqHDFyR7vWafh3njtN3nAlF2AnfRfzIbu+y2QsuEdW4BPz22MJ
yro7fpYY2Z3XB1CK01H/tRvQ5t7x1yADKVIZjNx8r9Sw8+09Oky57xENSGRl7amG
kZaPJ5O6z/tffOKf0EZK57XjtVgKhhoFlYWrS7KYhSkTVY7srAmZA1uo5EKSFzys
gW337DEH69VR2uE09g+n
=lZDi
-----END PGP SIGNATURE-----

--VbJkn9YxBvnuCH5J--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
