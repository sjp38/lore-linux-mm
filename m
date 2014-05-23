Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 219D06B0038
	for <linux-mm@kvack.org>; Fri, 23 May 2014 00:02:10 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so3471419pab.21
        for <linux-mm@kvack.org>; Thu, 22 May 2014 21:02:09 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id nx5si2056660pab.195.2014.05.22.21.02.08
        for <linux-mm@kvack.org>;
        Thu, 22 May 2014 21:02:09 -0700 (PDT)
Date: Thu, 22 May 2014 23:34:38 -0400
From: "Chen, Gong" <gong.chen@linux.intel.com>
Subject: Re: [PATCH 1/2] memory-failure: Send right signal code to correct
 thread
Message-ID: <20140523033438.GC16945@gchen.bj.intel.com>
References: <cover.1400607328.git.tony.luck@intel.com>
 <eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7qSK/uQB79J36Y4o"
Content-Disposition: inline
In-Reply-To: <eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>


--7qSK/uQB79J36Y4o
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 20, 2014 at 09:28:00AM -0700, Luck, Tony wrote:
> When a thread in a multi-threaded application hits a machine
> check because of an uncorrectable error in memory - we want to
> send the SIGBUS with si.si_code =3D BUS_MCEERR_AR to that thread.
> Currently we fail to do that if the active thread is not the
> primary thread in the process. collect_procs() just finds primary
> threads and this test:
> 	if ((flags & MF_ACTION_REQUIRED) && t =3D=3D current) {
> will see that the thread we found isn't the current thread
> and so send a si.si_code =3D BUS_MCEERR_AO to the primary
> (and nothing to the active thread at this time).
>=20
> We can fix this by checking whether "current" shares the same
> mm with the process that collect_procs() said owned the page.
> If so, we send the SIGBUS to current (with code BUS_MCEERR_AR).
>=20
> Reported-by: Otto Bruggeman <otto.g.bruggeman@intel.com>
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  mm/memory-failure.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 35ef28acf137..642c8434b166 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -204,9 +204,9 @@ static int kill_proc(struct task_struct *t, unsigned =
long addr, int trapno,
>  #endif
>  	si.si_addr_lsb =3D compound_order(compound_head(page)) + PAGE_SHIFT;
> =20
> -	if ((flags & MF_ACTION_REQUIRED) && t =3D=3D current) {
> +	if ((flags & MF_ACTION_REQUIRED) && t->mm =3D=3D current->mm) {
>  		si.si_code =3D BUS_MCEERR_AR;
> -		ret =3D force_sig_info(SIGBUS, &si, t);
> +		ret =3D force_sig_info(SIGBUS, &si, current);
>  	} else {
>  		/*
>  		 * Don't use force here, it's convenient if the signal
> --=20
> 1.8.4.1
Very interesting. I remembered there was a thread about AO error. Here is
the link: http://www.spinics.net/lists/linux-mm/msg66653.html.
According to this link, I have two concerns:

1) how to handle the similar scenario like it in this link. I mean once
the main thread doesn't handle AR error but a thread does this, if SIGBUS
can't be handled at once.
2) why that patch isn't merged. From that thread, Naoya should mean
"acknowledge" :-).

--7qSK/uQB79J36Y4o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTfsHOAAoJEI01n1+kOSLH/X0QALHVKglVfaA9qc2D7Av6SMpk
4jZsYFZodl8AkfLIsH7kiY+S4j2PVYlY+umkQNyF1sb3OOWrZfTVH28SMxNNBNTX
/d0/2/zhkLeeAIIUxGEXCoZneHens0wSQJYWwgRI1LQSOeUWnvRyBiuPKAj4wYY4
PP9sw23l7zmJ9s+1Np7LrUT9roqrpJIhpj8tvgfv1vQK1eYiqbxk+au9+5WDfmBI
VMLjxyhes4+5nupAHWU/Zi0CpR0TgfRyWd+QPjoyLpVCN5efuBcja7XFVjEsohaQ
ORQOOmPFNBBKi6d+M0f1GdJ2QK3AQ3LM4WVDaVaczmuSAAxHkgOMUWQW+bqmHQ6D
ns/YYzboBzpbPj0whsqCr33sYWWygq2oWWKva1jKEbiqctWcMuoUfDMTzOGNThiS
Dz8wIhLm8yK5LN8THXkwYhrHzGBEZNEBakamV4HuRnaqy3+irmUJWIoy3NlScbtM
+g1CAPdkRlhFSmwXXZCfhEI6h3Gaxf07kUcRLWqptSfrcJvOazKAbVtVcfFJ1iMQ
2curFsJ9wm5IUbzEDcbfhmK9yRCRqxkZXJVEc6/C9S5mp9roBL890DKxT34zuSVM
aLpkQpe0aUEbrX18GaoNamDFF+PkSo5Ml3dcz2oVG055aQzMRsY5+AFRcBHqyFAE
GVJwJUfZfJBEgef5IMz+
=48ax
-----END PGP SIGNATURE-----

--7qSK/uQB79J36Y4o--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
