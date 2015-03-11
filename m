Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id BA447900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 11:27:42 -0400 (EDT)
Received: by wghk14 with SMTP id k14so10046479wgh.7
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 08:27:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w5si7091038wix.8.2015.03.11.08.27.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 08:27:40 -0700 (PDT)
Message-ID: <55005EBA.8080201@redhat.com>
Date: Wed, 11 Mar 2015 16:26:50 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm, procfs: account for shmem swap in /proc/pid/smaps
References: <1424958666-18241-1-git-send-email-vbabka@suse.cz>	<1424958666-18241-3-git-send-email-vbabka@suse.cz> <CALYGNiPn-C6AESik_BrQBEJpOsvcy7qG_sacAyf+O24A6P9kyA@mail.gmail.com> <5500592D.4090309@yandex-team.ru>
In-Reply-To: <5500592D.4090309@yandex-team.ru>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="oKqHwNA89IQoqu8VfDE7xpr1Sm8MP6A0p"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Konstantin Khlebnikov <koct9i@gmail.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--oKqHwNA89IQoqu8VfDE7xpr1Sm8MP6A0p
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/11/2015 04:03 PM, Konstantin Khlebnikov wrote:
> On 11.03.2015 15:30, Konstantin Khlebnikov wrote:
>> On Thu, Feb 26, 2015 at 4:51 PM, Vlastimil Babka <vbabka@suse.cz> wrot=
e:
>>> Currently, /proc/pid/smaps will always show "Swap: 0 kB" for
>>> shmem-backed
>>> mappings, even if the mapped portion does contain pages that were
>>> swapped out.
>>> This is because unlike private anonymous mappings, shmem does not
>>> change pte
>>> to swap entry, but pte_none when swapping the page out. In the smaps
>>> page
>>> walk, such page thus looks like it was never faulted in.
>>
>> Maybe just add count of swap entries allocated by mapped shmem into
>> swap usage of this vma? That's isn't exactly correct for partially
>> mapped shmem but this is something weird anyway.
>=20
> Something like that (see patch in attachment)
>=20

-8<---

diff --git a/mm/shmem.c b/mm/shmem.c
index cf2d0ca010bc..492f78f51fc2 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1363,6 +1363,13 @@ static struct mempolicy *shmem_get_policy(struct
vm_area_struct *vma,
 }
 #endif

+static unsigned long shmem_get_swap_usage(struct vm_area_struct *vma)
+{
+	struct inode *inode =3D file_inode(vma->vm_file);
+
+	return SHMEM_I(inode)->swapped;
+}
+
 int shmem_lock(struct file *file, int lock, struct user_struct *user)
 {
 	struct inode *inode =3D file_inode(file);

-8<---

That will not work for shared anonymous mapping since they all share the
same vm_file (/dev/zero).

Jerome


--oKqHwNA89IQoqu8VfDE7xpr1Sm8MP6A0p
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJVAF66AAoJEHTzHJCtsuoC/iYH/2EASD+Iir8EV3jvFdz51mh7
m4jF5JCw/hKUk+Nus9t4zsTF1Piak6Ui2fdEbzggijVec4qQvcigYdscrE4On9wa
jTJHxt2FZocD44OwTND/Seb7pKt2cBjmQ+W0dHBQH3LTo4Th9c+wCtzVM1KJmoMS
jvdA0a3u4BqCxFy9jmRtVhUTDSM6Yif4W0dCuy75KF5u3RyPgqJJIg3jK5r5wTYZ
Wb9SFVaBV1nEWhdohBl1oglmyEefd87UYoZT+LOCNPV/tQi4BAjWGwDRNZbOm+g3
ui5RuizA94zNgsn3GyQuDQ5pkRrDltIPkipGrvaLzr30wfSlccukNGEcdDX7WgU=
=BjwP
-----END PGP SIGNATURE-----

--oKqHwNA89IQoqu8VfDE7xpr1Sm8MP6A0p--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
