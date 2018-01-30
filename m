Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE3BF6B0006
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 10:53:32 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id e12so8094063pgu.11
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 07:53:32 -0800 (PST)
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (mail-cys01nam02on0102.outbound.protection.outlook.com. [104.47.37.102])
        by mx.google.com with ESMTPS id r64si14702934pfk.217.2018.01.30.07.53.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 07:53:31 -0800 (PST)
Message-ID: <5A7094DA.4000804@cs.rutgers.edu>
Date: Tue, 30 Jan 2018 10:52:58 -0500
From: Zi Yan <zi.yan@cs.rutgers.edu>
MIME-Version: 1.0
Subject: Re: [PATCH] Lock mmap_sem when calling migrate_pages() in do_move_pages_to_node()
References: <20180130030011.4310-1-zi.yan@sent.com> <20180130081415.GO21609@dhcp22.suse.cz>
In-Reply-To: <20180130081415.GO21609@dhcp22.suse.cz>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------enig7AA550367DB032CD46EA031F"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Zi Yan <zi.yan@sent.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7AA550367DB032CD46EA031F
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable



Michal Hocko wrote:
> On Mon 29-01-18 22:00:11, Zi Yan wrote:
>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>
>> migrate_pages() requires at least down_read(mmap_sem) to protect
>> related page tables and VMAs from changing. Let's do it in
>> do_page_moves() for both do_move_pages_to_node() and
>> add_page_for_migration().
>>
>> Also add this lock requirement in the comment of migrate_pages().
>=20
> This doesn't make much sense to me, to be honest. We are holding
> mmap_sem for _read_ so we allow parallel updates like page faults
> or unmaps. Therefore we are isolating pages prior to the migration.
>=20
> The sole purpose of the mmap_sem in add_page_for_migration is to protec=
t
> from vma going away _while_ need it to get the proper page.

Then, I am wondering why we are holding mmap_sem when calling
migrate_pages() in existing code.
http://elixir.free-electrons.com/linux/latest/source/mm/migrate.c#L1576

>=20
> Moving the lock up is just wrong because it allows caller to hold the
> lock for way too long if a lot of pages is migrated. Not only that,
> it is even incorrect because we are doing get_user() (aka page fault)
> and while read lock recursion is OK, we might block and deadlock when
> there is a writer pending. I haven't checked the current implementation=

> of semaphores but I believe we do not allow recursive locking.
>=20

Sorry, I missed that. If mmap_sem is not needed for migrate_pages(),
please ignore this patch.


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
>>   */
>>  int migrate_pages(struct list_head *from, new_page_t get_new_page,
>>  		free_page_t put_new_page, unsigned long private,
>> @@ -1457,6 +1460,12 @@ static int store_status(int __user *status, int=
 start, int value, int nr)
>>  	return 0;
>>  }
>> =20
>> +/*
>> + * Migrates the pages from pagelist and put back those not migrated.
>> + *
>> + * The caller must at least hold down_read(mmap_sem), which is requir=
ed
>> + * for migrate_pages()
>> + */
>>  static int do_move_pages_to_node(struct mm_struct *mm,
>>  		struct list_head *pagelist, int node)
>>  {
>> @@ -1487,7 +1496,6 @@ static int add_page_for_migration(struct mm_stru=
ct *mm, unsigned long addr,
>>  	unsigned int follflags;
>>  	int err;
>> =20
>> -	down_read(&mm->mmap_sem);
>>  	err =3D -EFAULT;
>>  	vma =3D find_vma(mm, addr);
>>  	if (!vma || addr < vma->vm_start || !vma_migratable(vma))
>> @@ -1540,7 +1548,6 @@ static int add_page_for_migration(struct mm_stru=
ct *mm, unsigned long addr,
>>  	 */
>>  	put_page(page);
>>  out:
>> -	up_read(&mm->mmap_sem);
>>  	return err;
>>  }
>> =20
>> @@ -1561,6 +1568,7 @@ static int do_pages_move(struct mm_struct *mm, n=
odemask_t task_nodes,
>> =20
>>  	migrate_prep();
>> =20
>> +	down_read(&mm->mmap_sem);
>>  	for (i =3D start =3D 0; i < nr_pages; i++) {
>>  		const void __user *p;
>>  		unsigned long addr;
>> @@ -1628,6 +1636,7 @@ static int do_pages_move(struct mm_struct *mm, n=
odemask_t task_nodes,
>>  	if (!err)
>>  		err =3D err1;
>>  out:
>> +	up_read(&mm->mmap_sem);
>>  	return err;
>>  }
>> =20
>> --=20
>> 2.15.1
>=20

--=20
Best Regards,
Yan Zi


--------------enig7AA550367DB032CD46EA031F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQEcBAEBCAAGBQJacJT6AAoJEEGLLxGcTqbMOSMH/RTnT/k9cu8apbbJVImFzYLb
TkeT1eR4ieZCPMoWAXVMmr8xD2hylaPUhExp+wagh0vBfG1uo6bzlZg4kQmXnGn9
/3jxULV+mPgm6nA05H9xr/JQUBK7vnzdZU4jxPwXx7NjaZQuG/JlJsrLecA5mfT4
iTq8HCCq7KLgoeJLDEfVQQXnN8krfZeDiRYfysu/1G2BaNzCGdsbyC8bYmq3eREy
Mz5Gu0ASYE7XHqBKV8+kH61AckLh73lblszN86k+ECIMmQFOAjxokRb1XvJANSvr
KonqjR5OaUx3+yNjYe1ZCHkaentWOyuzlgjezn8v5xZvDWsatMOCedMM0BSnY2w=
=mxsp
-----END PGP SIGNATURE-----

--------------enig7AA550367DB032CD46EA031F--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
