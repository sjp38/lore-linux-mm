Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f42.google.com (mail-vk0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 65A5C6B0038
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 11:28:56 -0500 (EST)
Received: by vkbs1 with SMTP id s1so13758303vkb.3
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 08:28:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 132si3178332vki.116.2015.11.12.08.28.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 08:28:55 -0800 (PST)
Subject: Re: [PATCH] mm: vmalloc: don't remove inexistent guard hole in
 remove_vm_area()
References: <1447341424-11466-1-git-send-email-jmarchan@redhat.com>
 <CAPAsAGxNWhHSNHZWfaOb3NmbubSBGRd8O81L5rw1wMs-n_UgmA@mail.gmail.com>
From: Jerome Marchand <jmarchan@redhat.com>
Message-ID: <5644BE3E.7010708@redhat.com>
Date: Thu, 12 Nov 2015 17:28:46 +0100
MIME-Version: 1.0
In-Reply-To: <CAPAsAGxNWhHSNHZWfaOb3NmbubSBGRd8O81L5rw1wMs-n_UgmA@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="gqqIdGCaXdtJMGiBHV7IvAAvr2EAt2BPw"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-sh@vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--gqqIdGCaXdtJMGiBHV7IvAAvr2EAt2BPw
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 11/12/2015 04:55 PM, Andrey Ryabinin wrote:
> 2015-11-12 18:17 GMT+03:00 Jerome Marchand <jmarchan@redhat.com>:
>> Commit 71394fe50146 ("mm: vmalloc: add flag preventing guard hole
>> allocation") missed a spot. Currently remove_vm_area() decreases
>> vm->size to remove the guard hole page, even when it isn't present.
>> This patch only decreases vm->size when VM_NO_GUARD isn't set.
>>
>> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
>> ---
>>  mm/vmalloc.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>> index d045634..1388c3d 100644
>> --- a/mm/vmalloc.c
>> +++ b/mm/vmalloc.c
>> @@ -1443,7 +1443,8 @@ struct vm_struct *remove_vm_area(const void *add=
r)
>>                 vmap_debug_free_range(va->va_start, va->va_end);
>>                 kasan_free_shadow(vm);
>>                 free_unmap_vmap_area(va);
>> -               vm->size -=3D PAGE_SIZE;
>> +               if (!(vm->flags & VM_NO_GUARD))
>> +                       vm->size -=3D PAGE_SIZE;
>>
>=20
> I'd fix this in another way. I think that remove_vm_area() shouldn't
> change vm's size, IMO it doesn't make sense.
> The only caller who cares about vm's size after removing is __vunmap():=

>          area =3D remove_vm_area(addr);
>          ....
>          debug_check_no_locks_freed(addr, area->size);
>          debug_check_no_obj_freed(addr, area->size);
>=20
> We already have proper get_vm_area_size() helper which takes
> VM_NO_GUARD into account.
> So I think we should use that helper for debug_check_no_*() and just
> remove 'vm->size -=3D PAGE_SIZE;' line
> from remove_vm_area()

Sure, that would be cleaner.

Btw, there might be a leak in sq_unmap() (arch/sh/kernel/cpu/sh4/sq.c)
as the vm_struct doesn't seem to be freed. CCed the SuperH folks.

Thanks,
Jerome

>=20
>=20
>=20
>>                 return vm;
>>         }
>> --
>> 2.4.3
>>



--gqqIdGCaXdtJMGiBHV7IvAAvr2EAt2BPw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWRL4+AAoJEHTzHJCtsuoCZlgH/0CJ5pcOXspQy8GGVnMaDFn+
CA2dc661YpyTb7BN3LeqLa9Eidx3/3QFARmRdKetyUWh8wQZqy9QLpjesJrgyRz9
+yCVikMQemMChbAVRtDJ7FPY1jupVMfO5oqufc1maeRk5KYIz0bmfcUYxPqdnh+6
9L7pBzbMx6jyE/wNjyiUq6Xh1xG6Pj4UzSCD1YpcveW5QE2IAtIMXsMeFh/b34Fg
MkSNP010rFKb2kHLGBpu+5RUeS1dIHOZ9lA6BSv5iYQ9NhVmiFX8vqBryMRnRIde
5S+dOkytVEvfvBTZmV6M42hSA+LME8jbU0reSLVQUbyuyylCx4A7yCmaohuzW3k=
=XIS2
-----END PGP SIGNATURE-----

--gqqIdGCaXdtJMGiBHV7IvAAvr2EAt2BPw--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
