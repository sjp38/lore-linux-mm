Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 349A86B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 03:28:49 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f144so241117172pfa.3
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 00:28:49 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id j15si13608130pfj.118.2017.01.16.00.28.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 00:28:48 -0800 (PST)
Date: Mon, 16 Jan 2017 10:28:48 +0200
From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH 5/6] treewide: use kv[mz]alloc* rather than opencoded
 variants
Message-ID: <20170116082848.GA32481@mtr-leonro.local>
References: <20170112153717.28943-1-mhocko@kernel.org>
 <20170112153717.28943-6-mhocko@kernel.org>
 <20170114105632.GV20392@mtr-leonro.local>
 <20170116073310.GA7981@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="YiEDa0DAkWCtVeE4"
Content-Disposition: inline
In-Reply-To: <20170116073310.GA7981@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Herbert Xu <herbert@gondor.apana.org.au>, Anton Vorontsov <anton@enomsg.org>, Colin Cross <ccross@android.com>, Kees Cook <keescook@chromium.org>, Tony Luck <tony.luck@intel.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Ben Skeggs <bskeggs@redhat.com>, Kent Overstreet <kent.overstreet@gmail.com>, Santosh Raspatur <santosh@chelsio.com>, Hariprasad S <hariprasad@chelsio.com>, Tariq Toukan <tariqt@mellanox.com>, Yishai Hadas <yishaih@mellanox.com>, Dan Williams <dan.j.williams@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Sterba <dsterba@suse.com>, "Yan, Zheng" <zyan@redhat.com>, Ilya Dryomov <idryomov@gmail.com>, Alexei Starovoitov <ast@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jan 16, 2017 at 08:33:11AM +0100, Michal Hocko wrote:
> On Sat 14-01-17 12:56:32, Leon Romanovsky wrote:
> [...]
> > Hi Michal,
> >
> > I don't see mlx5_vzalloc in the changed list. Any reason why did you skip it?
> >
> >  881 static inline void *mlx5_vzalloc(unsigned long size)
> >  882 {
> >  883         void *rtn;
> >  884
> >  885         rtn = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
> >  886         if (!rtn)
> >  887                 rtn = vzalloc(size);
> >  888         return rtn;
> >  889 }
>
> No reason to skip it, I just didn't see it. I will fold the following in
> if you are OK with it

Sure, no problem.
Once, the patch set is accepted, we (Mellanox) will get rid of mlx5_vzalloc().

Thanks


> ---
> diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
> index cdd2bd62f86d..5e6063170e48 100644
> --- a/include/linux/mlx5/driver.h
> +++ b/include/linux/mlx5/driver.h
> @@ -874,12 +874,7 @@ static inline u16 cmdif_rev(struct mlx5_core_dev *dev)
>
>  static inline void *mlx5_vzalloc(unsigned long size)
>  {
> -	void *rtn;
> -
> -	rtn = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
> -	if (!rtn)
> -		rtn = vzalloc(size);
> -	return rtn;
> +	return kvzalloc(GFP_KERNEL, size);
>  }
>
>  static inline u32 mlx5_base_mkey(const u32 key)
>
> --
> Michal Hocko
> SUSE Labs
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--YiEDa0DAkWCtVeE4
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh8hEAACgkQ5GN7iDZy
WKfBNxAAkj0ybtP+5KSc+/M9wFhub8PFtORtxzgDRBAHYRABNvI3EiVJHEKpgATk
LyEloC5fDyPla83eJ5euvFeQmxDf6ZXlW9FiA9Cbo9pY35b0TV6dacdGzvuDtbbo
a+eiBrr9SBwqyqYsdbyD/gVp66qyVcw9qAUTIspnAD4T3z/6X01RCAot+np0Dfij
ufCYftxKYXrHOuSy07lrqrCVMiPwr9DGwNuwEA4wjkQnZMEkhlygbT4ZgyEvc6A8
aP3hV84+9m5NSt+ziM/JjPyszG9DVRFTAjhezSS7DzhIHkrP/BJTCeomB22m+Gbr
a6N5F5vHNjzoUQRgAbqNxKbGlle3Ae37Jn4qmlSp2nbHm/9oyJlWhSYlNuIxYuOc
e3f6FKex3niJB0Om6bcfyANzQHQYlKiqI0fAUgZgfXFMw0597BvMxTvs4jRsjntG
Eey2iKvnaaN2GtuuLtQPaGb6IIIe34flsuY8o2JQtwyrIPIT6i8jmvjv5CkQZhqj
HkXX/ZTyIYibQAPqrpiRVd+m2ZTgi+wmj+kZuZ8KTKKZGz+IpaGEZ1xyD7XvQVqA
+gDDmqgdU+hqQkBD7h4iOcUV9EpVz6olWtb3EvrsHF/7p0zwL25mp6Tf4ZDhpT7E
J6r0Zz9paK3eE708RiX2Pc8OhcEfZ8C9uNW/rxxDMEj28/mf4Tw=
=Qluq
-----END PGP SIGNATURE-----

--YiEDa0DAkWCtVeE4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
