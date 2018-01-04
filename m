Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB0416B04B2
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 20:35:39 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id k44so121679wre.1
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 17:35:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z12sor1402492edm.42.2018.01.03.17.35.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 17:35:38 -0800 (PST)
Date: Thu, 4 Jan 2018 09:38:07 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH 1/2] Move kfree_call_rcu() to slab_common.c
Message-ID: <20180104013807.GA31392@tardis>
References: <1514923898-2495-1-git-send-email-rao.shoaib@oracle.com>
 <20180102222341.GB20405@bombadil.infradead.org>
 <3be609d4-800e-a89e-f885-7e0f5d288862@oracle.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Content-Disposition: inline
In-Reply-To: <3be609d4-800e-a89e-f885-7e0f5d288862@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rao Shoaib <rao.shoaib@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, brouer@redhat.com, linux-mm@kvack.org


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Shoaib,

Good to see you set out a patchset ;-)

On Tue, Jan 02, 2018 at 02:49:25PM -0800, Rao Shoaib wrote:
>=20
>=20
> On 01/02/2018 02:23 PM, Matthew Wilcox wrote:
> > On Tue, Jan 02, 2018 at 12:11:37PM -0800, rao.shoaib@oracle.com wrote:
> > > -#define kfree_rcu(ptr, rcu_head)					\
> > > -	__kfree_rcu(&((ptr)->rcu_head), offsetof(typeof(*(ptr)), rcu_head))
> > > +#define kfree_rcu(ptr, rcu_head_name)	\
> > > +	do { \
> > > +		typeof(ptr) __ptr =3D ptr;	\
> > > +		unsigned long __off =3D offsetof(typeof(*(__ptr)), \
> > > +						      rcu_head_name); \
> > > +		struct rcu_head *__rptr =3D (void *)__ptr + __off; \
> > > +		__kfree_rcu(__rptr, __off); \
> > > +	} while (0)
> > I feel like you're trying to help people understand the code better,
> > but using longer names can really work against that.  Reverting to
> > calling the parameter 'rcu_head' lets you not split the line:
> I think it is a matter of preference, what is the issue with line splitti=
ng
> ?
> Coming from a background other than Linux I find it very annoying that Li=
nux
> allows variables names that are meaning less. Linux does not even enforce
> adding a prefix for structure members, so trying to find out where a memb=
er
> is used or set is impossible using cscope.
> I can not change the Linux requirements so I will go ahead and make the
> change in the next rev.
>=20
> >=20
> > +#define kfree_rcu(ptr, rcu_head)	\
> > +	do { \
> > +		typeof(ptr) __ptr =3D ptr;	\
> > +		unsigned long __off =3D offsetof(typeof(*(__ptr)), rcu_head); \
> > +		struct rcu_head *__rptr =3D (void *)__ptr + __off; \
> > +		__kfree_rcu(__rptr, __off); \
> > +	} while (0)
> >=20
> > Also, I don't understand why you're bothering to create __ptr here.
> > I understand the desire to not mention the same argument more than once,
> > but you have 'ptr' twice anyway.
> >=20
> > And it's good practice to enclose macro arguments in parentheses in case
> > the user has done something really tricksy like pass in "p + 1".
> >=20
> > In summary, I don't see anything fundamentally better in your rewrite
> > of kfree_rcu().  The previous version is more succinct, and to my
> > mind, easier to understand.
> I did not want to make thins change but it is required due to the new tes=
ts
> added for macro expansion where the same name as in the macro can not be
> used twice. It takes care of the 'p + 1' hazard that you refer to above.
> >=20
> > > +void call_rcu_lazy(struct rcu_head *head, rcu_callback_t func)
> > > +{
> > > +	__call_rcu(head, func, &rcu_sched_state, -1, 1);
> > > +}
> > > -void kfree_call_rcu(struct rcu_head *head,
> > > -		    rcu_callback_t func)
> > > -{
> > > -	__call_rcu(head, func, rcu_state_p, -1, 1);
> > > -}
> > You've silently changed this.  Why?  It might well be the right change,
> > but it at least merits mentioning in the changelog.
> This was to address a comment about me not changing the tiny implementati=
on
> to be same as the tree implementation.
>=20

But you introduced a bug here, you should use rcu_state_p instead of
&rcu_sched_state as the third parameter for __call_rcu().

Please re-read:

	https://marc.info/?l=3Dlinux-mm&m=3D151390529209639

, and there are other comments, which you still haven't resolved in this
version. You may want to write a better commit log to explain the
reasons of each modifcation and fix bugs or typos in your previous
version. That's how review process works ;-)

Regards,
Boqun

> Shoaib
> >=20
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlpNhXoACgkQSXnow7UH
+rhezQgApLVacPqQinmL+HFoAZcEJkJsuBRLENwD/8RCctHruwQi9nhtif4KjUJX
hRBR7LMz0pMXt/711ycg4AcyTYl8L1It6t7toN7OjG86+37zUan69O1YMEOr+Ic5
THuQlziZvUO8dc1sYXbd5VudK82jB7a96tCRGcpYNTkAfZNFRIh/o60+pCJc8YKU
pQ5Y83xMV0PPmvz9KMPvtvA3XGs4VH3yvPlCQNMjKIsoRArleBpD+C69KSRw3Ksk
bWsSVZFqCP1NOAnxI/1B6DDmW6La7D9NKeVGBmj+osL6dR+OVvmGP33jqGfPRqeN
He9airSKtMe0MdGbxuB/NzGJGx7muA==
=WVFL
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
