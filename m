Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 474506B0280
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 04:16:01 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c73so49987445pfb.7
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 01:16:01 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id w4si2981951pfw.103.2017.01.19.01.16.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 01:16:00 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id y143so2979527pfb.1
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 01:16:00 -0800 (PST)
Date: Thu, 19 Jan 2017 17:16:27 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v5 01/13] lockdep: Refactor lookup_chain_cache()
Message-ID: <20170119091627.GG15084@tardis.cn.ibm.com>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
 <1484745459-2055-2-git-send-email-byungchul.park@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="VkVuOCYP9O7H3CXI"
Content-Disposition: inline
In-Reply-To: <1484745459-2055-2-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: peterz@infradead.org, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com


--VkVuOCYP9O7H3CXI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 18, 2017 at 10:17:27PM +0900, Byungchul Park wrote:
> Currently, lookup_chain_cache() provides both 'lookup' and 'add'
> functionalities in a function. However, each is useful. So this
> patch makes lookup_chain_cache() only do 'lookup' functionality and
> makes add_chain_cahce() only do 'add' functionality. And it's more
> readable than before.
>=20
> Signed-off-by: Byungchul Park <byungchul.park@lge.com>
> ---
>  kernel/locking/lockdep.c | 129 +++++++++++++++++++++++++++++------------=
------
>  1 file changed, 81 insertions(+), 48 deletions(-)
>=20
> diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
> index 4d7ffc0..f37156f 100644
> --- a/kernel/locking/lockdep.c
> +++ b/kernel/locking/lockdep.c
> @@ -2109,15 +2109,9 @@ static int check_no_collision(struct task_struct *=
curr,
>  	return 1;
>  }
> =20
> -/*
> - * Look up a dependency chain. If the key is not present yet then
> - * add it and return 1 - in this case the new dependency chain is
> - * validated. If the key is already hashed, return 0.
> - * (On return with 1 graph_lock is held.)
> - */

I think you'd better put some comments here for the behavior of
add_chain_cache(), something like:

/*
 * Add a dependency chain into chain hashtable.
 *=20
 * Must be called with graph_lock held.
 * Return 0 if fail to add the chain, and graph_lock is released.
 * Return 1 with graph_lock held if succeed.
 */

Regards,
Boqun

> -static inline int lookup_chain_cache(struct task_struct *curr,
> -				     struct held_lock *hlock,
> -				     u64 chain_key)
> +static inline int add_chain_cache(struct task_struct *curr,
> +				  struct held_lock *hlock,
> +				  u64 chain_key)
>  {
>  	struct lock_class *class =3D hlock_class(hlock);
>  	struct hlist_head *hash_head =3D chainhashentry(chain_key);
> @@ -2125,49 +2119,18 @@ static inline int lookup_chain_cache(struct task_=
struct *curr,
>  	int i, j;
> =20
>  	/*
> +	 * Allocate a new chain entry from the static array, and add
> +	 * it to the hash:
> +	 */
> +
> +	/*
>  	 * We might need to take the graph lock, ensure we've got IRQs
>  	 * disabled to make this an IRQ-safe lock.. for recursion reasons
>  	 * lockdep won't complain about its own locking errors.
>  	 */
>  	if (DEBUG_LOCKS_WARN_ON(!irqs_disabled()))
>  		return 0;
[...]

--VkVuOCYP9O7H3CXI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAliAg+cACgkQSXnow7UH
+rh2Jgf/fmUbrOVM0V2wjEeynnt2EYwHfMJfx5jihIcOU13CammK9+rMyHHkQgoL
Kx/0AXWOme22RbvRmRsCsCkp6zMFXFwOb0Ax99Tlz+oi3ggRXQB3aHxxxNNkYZef
iIJuGqgR/R5PnypA9cAcUPluXErXt5P9Ie9DSXXSMgn4c7r8NMnn2BVKxG1AjUHK
/kLyYvlkV+3mKHnxkP24WikrFuRSwtuZ6g/ymV1ic6MDczouSEZBRPfKku2SduBJ
hpQz+ZwiCRjHDqy6R45ZnLN8k9tUye0NGv2XvMe53b3sYj8SODl5j1NuXduRW30Q
TKhK2At4KXtQMtNtCGdzR1bPe8q3nQ==
=qFe1
-----END PGP SIGNATURE-----

--VkVuOCYP9O7H3CXI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
