Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 006976B0333
	for <linux-mm@kvack.org>; Mon, 27 Mar 2017 02:43:27 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id n55so34247133wrn.0
        for <linux-mm@kvack.org>; Sun, 26 Mar 2017 23:43:27 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTPS id t24si8061901wra.71.2017.03.26.23.43.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Mar 2017 23:43:26 -0700 (PDT)
Date: Mon, 27 Mar 2017 08:43:25 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/1] module: check if memory leak by module.
Message-ID: <20170327064325.GA27625@amd>
References: <CGME20170324113058epcas5p48d9b7cf45d62d2cf7c2146ebc8719542@epcas5p4.samsung.com>
 <1490355028-13292-1-git-send-email-maninder1.s@samsung.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nFreZHaLTZJo0R7j"
Content-Disposition: inline
In-Reply-To: <1490355028-13292-1-git-send-email-maninder1.s@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maninder Singh <maninder1.s@samsung.com>
Cc: jeyu@redhat.com, rusty@rustcorp.com.au, akpm@linux-foundation.org, chris@chris-wilson.co.uk, aryabinin@virtuozzo.com, joonas.lahtinen@linux.intel.com, mhocko@suse.com, keescook@chromium.org, jinb.park7@gmail.com, anisse@astier.eu, rafael.j.wysocki@intel.com, zijun_hu@htc.com, mingo@kernel.org, mawilcox@microsoft.com, thgarnie@google.com, joelaf@google.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, pankaj.m@samsung.com, ajeet.y@samsung.com, hakbong5.lee@samsung.com, a.sahrawat@samsung.com, lalit.mohan@samsung.com, cpgs@samsung.com, Vaneet Narang <v.narang@samsung.com>


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

> This patch adds new config VMALLOC_MEMORY_LEAK to check if any
> module which is going to be unloaded is doing vmalloc memory leak.
>=20
> Logs:-
> [  129.336368] Module vmalloc is getting unloaded before doing vfree
> [  129.336371] Memory still allocated: addr:0xffffc90001461000 - 0xffffc9=
00014c7000, pages 101
> [  129.336376] Allocating function kernel_init+0x1c/0x20 [vmalloc]
>=20
> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
> Signed-off-by: Vaneet Narang <v.narang@samsung.com>

Let me see...

> diff --git a/kernel/module.c b/kernel/module.c
> index 529efae..b492f34 100644
> --- a/kernel/module.c
> +++ b/kernel/module.c
> @@ -2082,9 +2082,37 @@ void __weak module_arch_freeing_init(struct module=
 *mod)
>  {
>  }
> =20
> +#ifdef CONFIG_VMALLOC_MEMORY_LEAK

I'd not make this optional -- the performance cost is not all that
big, right?

> +static void check_memory_leak(struct module *mod)
> +{
> +	struct vmap_area *va;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(va, &vmap_area_list, list) {
> +		if (!(va->flags & VM_VM_AREA))
> +			continue;
> +		if ((mod->core_layout.base < va->vm->caller) &&
> +			(mod->core_layout.base +  mod->core_layout.size) > va->vm->caller) {

Two spaces after "+".

> +			pr_alert("Module %s is getting unloaded before doing vfree\n", mod->n=
ame);
> +			pr_alert("Memory still allocated: addr:0x%lx - 0x%lx, pages %u\n",
> +				va->va_start, va->va_end, va->vm->nr_pages);
> +			pr_alert("Allocating function %pS\n", va->vm->caller);
> +		}

Plain pr_err() would be preffered. Its just a memory leak.

Otherwise looks good to me..
									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--nFreZHaLTZJo0R7j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAljYtI0ACgkQMOfwapXb+vLfaQCeIunUrVt4Md5jr8Tls1+p0jP/
e3oAoIK9YfEzYDt2iZwvfTsKCi8ZjGwQ
=70Qu
-----END PGP SIGNATURE-----

--nFreZHaLTZJo0R7j--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
