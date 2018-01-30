Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 41AD46B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 10:56:14 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e1so8660580pfi.10
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 07:56:14 -0800 (PST)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0094.outbound.protection.outlook.com. [104.47.42.94])
        by mx.google.com with ESMTPS id bc10-v6si2485861plb.190.2018.01.30.07.56.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 07:56:13 -0800 (PST)
Message-ID: <5A70959C.9000004@cs.rutgers.edu>
Date: Tue, 30 Jan 2018 10:56:12 -0500
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH] Lock mmap_sem when calling migrate_pages() in do_move_pages_to_node()
References: <20180130030011.4310-1-zi.yan@sent.com> <alpine.LSU.2.11.1801291943330.2657@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1801291943330.2657@eggly.anvils>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------enig4359BF07744F88F21F46F7E6"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Zi Yan <zi.yan@sent.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4359BF07744F88F21F46F7E6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Hugh Dickins wrote:
> On Mon, 29 Jan 2018, Zi Yan wrote:
>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>
>> migrate_pages() requires at least down_read(mmap_sem) to protect
>> related page tables and VMAs from changing. Let's do it in
>=20
> Page tables are protected by their locks.  VMAs may change while
> migration is active on them, but does that need locking against?
>=20
>> do_page_moves() for both do_move_pages_to_node() and
>> add_page_for_migration().
>>
>> Also add this lock requirement in the comment of migrate_pages().
>>
>> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
>> ---
>>  mm/migrate.c | 13 +++++++++++--
>>  1 file changed, 11 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/migrate.c b/mm/migrate.c
>> index 5d0dc7b85f90..52d029953c32 100644
>> --- a/mm/migrate.c
>> +++ b/mm/migrate.c
>> @@ -1354,6 +1354,9 @@ static int unmap_and_move_huge_page(new_page_t g=
et_new_page,
>>   * or free list only if ret !=3D 0.
>>   *
>>   * Returns the number of pages that were not migrated, or an error co=
de.
>> + *
>> + * The caller must hold at least down_read(mmap_sem) for to-be-migrat=
ed pages
>> + * to protect related page tables and VMAs from changing.
>=20
> I have not been keeping up with Michal's recent migration changes,
> but migrate_pages() never used to need mmap_sem held (despite being
> called with an mmap_sem held from some of its callsites), and it
> would be a backward step to require that now.
>=20
> There is not even an mm argument to migrate_pages(), so which
> mm->mmap_sem do you think would be required for it?  There may be
> particular cases in which it is required (when the new_page function
> involves the old_page's vma - is that so below?), but in general not.

mmap_sem is held during migrate_pages() in current implementation.
http://elixir.free-electrons.com/linux/latest/source/mm/migrate.c#L1576


--=20
Best Regards,
Yan Zi


--------------enig4359BF07744F88F21F46F7E6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJacJWdAAoJEEGLLxGcTqbMgOIH/2PjV4TPU9qC91J1S6jnIM6U
1Vr5heZS3a79kGJ9DtFsAOrZaoDgWYnhn9TXt7y5paQ7tWeGZPfmtHJPZajiZrud
sn3VcV+EjOp+q3DKlmQ51Z55/b/7EgkapN4Sy4Q7+RDKqPUonZVyvuSG1zV0RlUL
1iAoZDu/waZ07qRVdG0aw75/1pCPs7hG9qkkTy/X1US+o5Sxo0/1YFw3V9xw9vHe
NDsif0I8EhkVxxRjGiaODxCzexSD4K5boEjRthOAjvIVP3JKP3qQrhCJ3K5GqLTj
U0RZnWT3vnUG4Xe8SoN+jFNSobZt/seNhJ0atZZla+WNdeUChilG16aVJOEq++s=
=+r0J
-----END PGP SIGNATURE-----

--------------enig4359BF07744F88F21F46F7E6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
