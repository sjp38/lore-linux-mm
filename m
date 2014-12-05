Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 78CB46B006E
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 11:18:08 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id w7so688546qcr.14
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 08:18:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i6si15317310qaz.8.2014.12.05.08.18.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Dec 2014 08:18:07 -0800 (PST)
Message-ID: <5481D2F0.2090908@redhat.com>
Date: Fri, 05 Dec 2014 16:44:48 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
References: <546CC0CD.40906@suse.cz> <CALYGNiO9_bAVVZ2GdFq=PO2yV3LPs2utsbcb2pFby7MypptLCw@mail.gmail.com> <CANN689G+y77m2_paF0vBpHG8EsJ2-pEnJvLJSGs-zHf+SqTEjQ@mail.gmail.com> <CALYGNiOC4dEzzVzSQXGC4oxLbgp=8TC=A+duJs67jT97TWQ++g@mail.gmail.com> <546DFFA1.4030700@redhat.com> <CALYGNiP_zqAucmN=Gn75Mm2wK1iE6fPNxTsaTRgnUbFbFE7C-g@mail.gmail.com> <CALYGNiO9NSpCFcRezArgfqzLQcTx2DnFYWYgpyK2HFyCnuGLOA@mail.gmail.com> <20141125105953.GC4607@dhcp22.suse.cz> <CALYGNiPZmf4Y1_vX_FaiALKp-BPvct7fAiaPEjnDGnVx9paS9w@mail.gmail.com> <20141125150006.GB4415@dhcp22.suse.cz> <20141126173517.GA8180@dhcp22.suse.cz>
In-Reply-To: <20141126173517.GA8180@dhcp22.suse.cz>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="ljVvaKbLTp0wFD2DBEHsqLhuNTgc52Hrq"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>, Daniel Forrest <dan.forrest@ssec.wisc.edu>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--ljVvaKbLTp0wFD2DBEHsqLhuNTgc52Hrq
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 11/26/2014 06:35 PM, Michal Hocko wrote:
> On Tue 25-11-14 16:00:06, Michal Hocko wrote:
>> On Tue 25-11-14 16:13:16, Konstantin Khlebnikov wrote:
>>> On Tue, Nov 25, 2014 at 1:59 PM, Michal Hocko <mhocko@suse.cz> wrote:=

>>>> On Mon 24-11-14 11:09:40, Konstantin Khlebnikov wrote:
>>>>> On Thu, Nov 20, 2014 at 6:03 PM, Konstantin Khlebnikov <koct9i@gmai=
l.com> wrote:
>>>>>> On Thu, Nov 20, 2014 at 5:50 PM, Rik van Riel <riel@redhat.com> wr=
ote:
>>>>>>> -----BEGIN PGP SIGNED MESSAGE-----
>>>>>>> Hash: SHA1
>>>>>>>
>>>>>>> On 11/20/2014 09:42 AM, Konstantin Khlebnikov wrote:
>>>>>>>
>>>>>>>> I'm thinking about limitation for reusing anon_vmas which might
>>>>>>>> increase performance without breaking asymptotic estimation of
>>>>>>>> count anon_vma in the worst case. For example this heuristic: al=
low
>>>>>>>> to reuse only anon_vma with single direct descendant. It seems
>>>>>>>> there will be arount up to two times more anon_vmas but
>>>>>>>> false-aliasing must be much lower.
>>>>>
>>>>> Done. RFC patch in attachment.
>=20
> Ok, finally managed to untagnle myself from vma chains and your patch
> makes sense to me, it is quite clever actually. Here is it including th=
e
> fixup.
> ---
>> From 1d4b0b38198c69ecfeb37670cb1dda767a802c9a Mon Sep 17 00:00:00 2001=

>> From: Konstantin Khlebnikov <koct9i@gmail.com>
>> Date: Tue, 25 Nov 2014 10:54:44 +0100
>> Subject: [PATCH] mm: prevent endless growth of anon_vma hierarchy
>>
>> Constantly forking task causes unlimited grow of anon_vma chain.
>> Each next child allocate new level of anon_vmas and links vmas to all
>> previous levels because it inherits pages from them. None of anon_vmas=

>> cannot be freed because there might be pages which points to them.
>>
>> This patch adds heuristic which decides to reuse existing anon_vma ins=
tead
>> of forking new one. It counts vmas and direct descendants for each ano=
n_vma.
>> Anon_vma with degree lower than two will be reused at next fork.
>> As a result each anon_vma has either alive vma or at least two descend=
ants,
>> endless chains are no longer possible and count of anon_vmas is no mor=
e than
>> two times more than count of vmas.
>>
>> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
>> Link: http://lkml.kernel.org/r/20120816024610.GA5350@evergreen.ssec.wi=
sc.edu
>=20
> Tested-by: Michal Hocko <mhocko@suse.cz>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
>=20
> and I guess
> Reported-by: Daniel Forrest <dan.forrest@ssec.wisc.edu>

Tested-by: Jerome Marchand <jmarchan@redhat.com>

Minor nitpicks below.

>=20
> who somehow vanished from CC list (added back) would be appropriate as
> well.
>=20
> plus
>=20
> Fixes: 5beb49305251 (mm: change anon_vma linking to fix multi-process s=
erver scalability issue)
> and mark it for stable
>=20
> Thanks!
>=20
>> ---
>>  include/linux/rmap.h | 16 ++++++++++++++++
>>  mm/rmap.c            | 29 ++++++++++++++++++++++++++++-
>>  2 files changed, 44 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
>> index c0c2bce6b0b7..b1d140c20b37 100644
>> --- a/include/linux/rmap.h
>> +++ b/include/linux/rmap.h
>> @@ -45,6 +45,22 @@ struct anon_vma {
>>  	 * mm_take_all_locks() (mm_all_locks_mutex).
>>  	 */
>>  	struct rb_root rb_root;	/* Interval tree of private "related" vmas *=
/
>> +
>> +	/*
>> +	 * Count of child anon_vmas and VMAs which points to this anon_vma.
>> +	 *
>> +	 * This counter is used for making decision about reusing old anon_v=
ma
>> +	 * instead of forking new one. It allows to detect anon_vmas which h=
ave
>> +	 * just one direct descendant and no vmas. Reusing such anon_vma not=

>> +	 * leads to significant preformance regression but prevents degradat=
ion

Does it or does it not lead to significant performance issue? I can't tel=
l.

>> +	 * of anon_vma hierarchy to endless linear chain.
>> +	 *
>> +	 * Root anon_vma is never reused because it is its own parent and it=
 has
>> +	 * at leat one vma or child, thus at fork it's degree is at least 2.=


s/leat/least/

Thanks,
Jerome

>> +	 */
>> +	unsigned degree;
>> +
>> +	struct anon_vma *parent;	/* Parent of this anon_vma */
>>  };
>> =20
>>  /*
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 19886fb2f13a..40ae8184a1e1 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -72,6 +72,8 @@ static inline struct anon_vma *anon_vma_alloc(void)
>>  	anon_vma =3D kmem_cache_alloc(anon_vma_cachep, GFP_KERNEL);
>>  	if (anon_vma) {
>>  		atomic_set(&anon_vma->refcount, 1);
>> +		anon_vma->degree =3D 1;	/* Reference for first vma */
>> +		anon_vma->parent =3D anon_vma;
>>  		/*
>>  		 * Initialise the anon_vma root to point to itself. If called
>>  		 * from fork, the root will be reset to the parents anon_vma.
>> @@ -188,6 +190,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
>>  		if (likely(!vma->anon_vma)) {
>>  			vma->anon_vma =3D anon_vma;
>>  			anon_vma_chain_link(vma, avc, anon_vma);
>> +			anon_vma->degree++;
>>  			allocated =3D NULL;
>>  			avc =3D NULL;
>>  		}
>> @@ -256,7 +259,17 @@ int anon_vma_clone(struct vm_area_struct *dst, st=
ruct vm_area_struct *src)
>>  		anon_vma =3D pavc->anon_vma;
>>  		root =3D lock_anon_vma_root(root, anon_vma);
>>  		anon_vma_chain_link(dst, avc, anon_vma);
>> +
>> +		/*
>> +		 * Reuse existing anon_vma if its degree lower than two,
>> +		 * that means it has no vma and just one anon_vma child.
>> +		 */
>> +		if (!dst->anon_vma && anon_vma !=3D src->anon_vma &&
>> +				anon_vma->degree < 2)
>> +			dst->anon_vma =3D anon_vma;
>>  	}
>> +	if (dst->anon_vma)
>> +		dst->anon_vma->degree++;
>>  	unlock_anon_vma_root(root);
>>  	return 0;
>> =20
>> @@ -279,6 +292,9 @@ int anon_vma_fork(struct vm_area_struct *vma, stru=
ct vm_area_struct *pvma)
>>  	if (!pvma->anon_vma)
>>  		return 0;
>> =20
>> +	/* Drop inherited anon_vma, we'll reuse old one or allocate new. */
>> +	vma->anon_vma =3D NULL;
>> +
>>  	/*
>>  	 * First, attach the new VMA to the parent VMA's anon_vmas,
>>  	 * so rmap can find non-COWed pages in child processes.
>> @@ -286,6 +302,10 @@ int anon_vma_fork(struct vm_area_struct *vma, str=
uct vm_area_struct *pvma)
>>  	if (anon_vma_clone(vma, pvma))
>>  		return -ENOMEM;
>> =20
>> +	/* An old anon_vma has been reused. */
>> +	if (vma->anon_vma)
>> +		return 0;
>> +
>>  	/* Then add our own anon_vma. */
>>  	anon_vma =3D anon_vma_alloc();
>>  	if (!anon_vma)
>> @@ -299,6 +319,7 @@ int anon_vma_fork(struct vm_area_struct *vma, stru=
ct vm_area_struct *pvma)
>>  	 * lock any of the anon_vmas in this anon_vma tree.
>>  	 */
>>  	anon_vma->root =3D pvma->anon_vma->root;
>> +	anon_vma->parent =3D pvma->anon_vma;
>>  	/*
>>  	 * With refcounts, an anon_vma can stay around longer than the
>>  	 * process it belongs to. The root anon_vma needs to be pinned until=

>> @@ -309,6 +330,7 @@ int anon_vma_fork(struct vm_area_struct *vma, stru=
ct vm_area_struct *pvma)
>>  	vma->anon_vma =3D anon_vma;
>>  	anon_vma_lock_write(anon_vma);
>>  	anon_vma_chain_link(vma, avc, anon_vma);
>> +	anon_vma->parent->degree++;
>>  	anon_vma_unlock_write(anon_vma);
>> =20
>>  	return 0;
>> @@ -339,12 +361,16 @@ void unlink_anon_vmas(struct vm_area_struct *vma=
)
>>  		 * Leave empty anon_vmas on the list - we'll need
>>  		 * to free them outside the lock.
>>  		 */
>> -		if (RB_EMPTY_ROOT(&anon_vma->rb_root))
>> +		if (RB_EMPTY_ROOT(&anon_vma->rb_root)) {
>> +			anon_vma->parent->degree--;
>>  			continue;
>> +		}
>> =20
>>  		list_del(&avc->same_vma);
>>  		anon_vma_chain_free(avc);
>>  	}
>> +	if (vma->anon_vma)
>> +		vma->anon_vma->degree--;
>>  	unlock_anon_vma_root(root);
>> =20
>>  	/*
>> @@ -355,6 +381,7 @@ void unlink_anon_vmas(struct vm_area_struct *vma)
>>  	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) =
{
>>  		struct anon_vma *anon_vma =3D avc->anon_vma;
>> =20
>> +		BUG_ON(anon_vma->degree);
>>  		put_anon_vma(anon_vma);
>> =20
>>  		list_del(&avc->same_vma);
>> --=20
>> 2.1.3
>=20



--ljVvaKbLTp0wFD2DBEHsqLhuNTgc52Hrq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUgdLwAAoJEHTzHJCtsuoCXLgH/2nti42bXPoi1luv0yxkmJl+
303DVMFIcO45LGekL3xWyJaHvnA2IVdXwSd73rMrEzHDpx0Ahh5nQIwi/zQXS5ED
zijKD/JmL/C8FEWGYMp17M6B8zz506RVFSUzlRT/aHQcldIEb7eGRkZIWw7neLXL
gzUVXG+Pqv/3scd6UcoEeFoxwPZVdUUO6Ns3Nj8II+/v8aLZLCCE9eslPTveky7+
epC5GJLlMKf32iehHtMq5axGz001Bk6koA2Zhzmq3Yj7UHK3G9qgsqsumM5vDxZs
AgDFzGYFSIcP1zfRevQRJqh7ln2DWI/wFPfZOUaos4AsMqjJUTS34TwrqLI0ksI=
=dtia
-----END PGP SIGNATURE-----

--ljVvaKbLTp0wFD2DBEHsqLhuNTgc52Hrq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
