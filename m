Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id F28F86B0044
	for <linux-mm@kvack.org>; Tue, 14 Aug 2012 19:25:58 -0400 (EDT)
Date: Wed, 15 Aug 2012 09:25:23 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 01/16] hashtable: introduce a small and naive hashtable
Message-ID: <20120815092523.00a909ef@notabene.brown>
In-Reply-To: <1344961490-4068-2-git-send-email-levinsasha928@gmail.com>
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
	<1344961490-4068-2-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/WaPYDSkmDZTaSUO/RNup8tR"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

--Sig_/WaPYDSkmDZTaSUO/RNup8tR
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 14 Aug 2012 18:24:35 +0200 Sasha Levin <levinsasha928@gmail.com>
wrote:


> +static inline void hash_init_size(struct hlist_head *hashtable, int bits)
> +{
> +	int i;
> +
> +	for (i =3D 0; i < HASH_SIZE(bits); i++)
> +		INIT_HLIST_HEAD(hashtable + i);
> +}

This seems like an inefficient way to do "memset(hashtable, 0, ...);".
And in many cases it isn't needed as the hash table is static and initialis=
ed
to zero.
I note that in the SUNRPC/cache patch you call hash_init(), but in the lockd
patch you don't.  You don't actually need to in either case.

I realise that any optimisation here is for code that is only executed once
per boot, so no big deal, and even the presence of extra code making the
kernel bigger is unlikely to be an issue.  But I'd at least like to see
consistency: Either use hash_init everywhere, even when not needed, or only
use it where absolutely needed which might be no-where because static tables
are already initialised, and dynamic tables can use GFP_ZERO.

And if you keep hash_init_size I would rather see a memset(0)....

Thanks,
NeilBrown

--Sig_/WaPYDSkmDZTaSUO/RNup8tR
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUCreYznsnt1WYoG5AQJjuA//cxInQBsHXHRtWYyYJpxwOX9hqpSDNaZ2
37aTlFSGjdhr1yn+RcwmtWh9nEj+oHEFlds46gW/woLpGFSXuCPD85CDtZDjPSpL
7VNXdZ1i3+EEPR0K2vjMaUs1cpdz2KIx8KZjIXfQVnARaZNfts7EuaTCpGM+5bac
G4CX6uoFtPc/A4LVEiYbowLzhUG+GmxcofMjd9ZJ4Ug0Xg4sl8xXtYg8YDkSn3LJ
zef9ltlJ1WxLSTtBm6+jyH25Xlb31P7TT3BUgNcStSz9Jak2wdggbUE79iOb3GJL
sP6/meXapGELz7IE8PVo/cdYdfBcskH6M8ai8pNNYTguSh/2VSRnjR1hPqXhgUYn
FDKLL8galmS5OxQMwv4mb3zhUIHIiTT7tWBq6eYXo3xUzInU5VufAyLIcpRX3fXm
VNLnnDOyaoWJCP/fUDrmHskSWPhLQA5/1YtiSI1NYwbY2C+OCybFHYixcWe5CT4w
YvQ2TTweApDjk5JRndjiO0/j4++kAYvQ8KwC7oo7CUK13dH/9h8rxzV3H4zAhxkh
4F6FzPEagR1CzKpSkJEA46DJQNIdAbbyCM0VkHORy7gTUa0MA3MsjW8dOKSnBnux
xsx1GI08WW16NEf1TyGrkqdE/caa4WtDDoLNG3cpwLTZNlMACcZOHXQmgeQu3Ija
TqL1y22gF/Q=
=lYgD
-----END PGP SIGNATURE-----

--Sig_/WaPYDSkmDZTaSUO/RNup8tR--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
