Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f50.google.com (mail-lf0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 492BB6B0009
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 07:29:42 -0500 (EST)
Received: by mail-lf0-f50.google.com with SMTP id m1so10732061lfg.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 04:29:42 -0800 (PST)
Received: from mail-lb0-x230.google.com (mail-lb0-x230.google.com. [2a00:1450:4010:c04::230])
        by mx.google.com with ESMTPS id a21si1485758lfb.189.2016.02.10.04.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Feb 2016 04:29:40 -0800 (PST)
Received: by mail-lb0-x230.google.com with SMTP id x4so9425747lbm.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 04:29:40 -0800 (PST)
From: Dmitry Monakhov <dmonlist@gmail.com>
Subject: Re: Another proposal for DAX fault locking
In-Reply-To: <20160209172416.GB12245@quack.suse.cz>
References: <20160209172416.GB12245@quack.suse.cz>
Date: Wed, 10 Feb 2016 15:29:34 +0300
Message-ID: <87egck4ukx.fsf@openvz.org>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, linux-fsdevel@vger.kernel.org

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Jan Kara <jack@suse.cz> writes:

> Hello,
>
> I was thinking about current issues with DAX fault locking [1] (data
> corruption due to racing faults allocating blocks) and also races which
> currently don't allow us to clear dirty tags in the radix tree due to rac=
es
> between faults and cache flushing [2]. Both of these exist because we don=
't
> have an equivalent of page lock available for DAX. While we have a
> reasonable solution available for problem [1], so far I'm not aware of a
> decent solution for [2]. After briefly discussing the issue with Mel he h=
ad
> a bright idea that we could used hashed locks to deal with [2] (and I thi=
nk
> we can solve [1] with them as well). So my proposal looks as follows:
>
> DAX will have an array of mutexes (the array can be made per device but
> initially a global one should be OK). We will use mutexes in the array as=
 a
> replacement for page lock - we will use hashfn(mapping, index) to get
> particular mutex protecting our offset in the mapping. On fault / page
> mkwrite, we'll grab the mutex similarly to page lock and release it once =
we
> are done updating page tables. This deals with races in [1]. When flushing
> caches we grab the mutex before clearing writeable bit in page tables
> and clearing dirty bit in the radix tree and drop it after we have flushed
> caches for the pfn. This deals with races in [2].
>
> Thoughts?
Agree, only small note:
Hash locks has side effect for batch locking due to collision.
Some times we want to lock several pages/entries (migration/defragmentation)
So we will endup with deadlock due to hash collision.
>
> 								Honza
>
> [1] http://oss.sgi.com/archives/xfs/2016-01/msg00575.html
> [2] https://lists.01.org/pipermail/linux-nvdimm/2016-January/004057.html
>
> --=20
> Jan Kara <jack@suse.com>
> SUSE Labs, CR
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBCgAGBQJWuy0uAAoJELhyPTmIL6kBG5cIAJXSd1Ta5jXS9UR4eWvbSrvb
s1dDJ9/mSsczuXhCVFdsWd6JkweN3xHYaLyqbkUwNdk8qgsjMZCoAiggHK5/zF5k
7RAMhTyuM7n2NyRfYztG+YOI+713X4V5h3sPolY0wCzUMbbze7M9kYBmFrenMj3H
qSvkN0lB5CO1C3NsZPmnga5uIBD11ony6ZP8sIRkZdB/M7GKK6n3UHvVAN2ulMJ/
y706UznvEH7VgMExYftjvME5VayoV0ktrKxQJJfxUJZcZC19HW7NC0rGkuny54Qr
0zmxw4TJLvAXolu73hgaShgOjTYKdgrTMC5iwl62v0L4unQAUu3Cc770tIUtH2Q=
=of95
-----END PGP SIGNATURE-----
--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
