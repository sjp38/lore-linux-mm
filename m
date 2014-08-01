Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f180.google.com (mail-vc0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id C23AD6B0036
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 10:37:49 -0400 (EDT)
Received: by mail-vc0-f180.google.com with SMTP id ij19so6629024vcb.25
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 07:37:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 97si15849919qgo.75.2014.08.01.07.37.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Aug 2014 07:37:49 -0700 (PDT)
Message-ID: <53DBA604.1090204@redhat.com>
Date: Fri, 01 Aug 2014 16:36:52 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] mm, shmem: Add shmem resident memory accounting
References: <1406036632-26552-1-git-send-email-jmarchan@redhat.com> <1406036632-26552-2-git-send-email-jmarchan@redhat.com> <alpine.LSU.2.11.1407312159180.3912@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407312159180.3912@eggly.anvils>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="lxVGKElGwxXE45ip0IhXLqN9P4K6qCS4C"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-doc@vger.kernel.org, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux390@de.ibm.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Randy Dunlap <rdunlap@infradead.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--lxVGKElGwxXE45ip0IhXLqN9P4K6qCS4C
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/01/2014 07:01 AM, Hugh Dickins wrote:
> On Tue, 22 Jul 2014, Jerome Marchand wrote:
>=20
>> Currently looking at /proc/<pid>/status or statm, there is no way to
>> distinguish shmem pages from pages mapped to a regular file (shmem
>> pages are mapped to /dev/zero), even though their implication in
>> actual memory use is quite different.
>> This patch adds MM_SHMEMPAGES counter to mm_rss_stat. It keeps track o=
f
>> resident shmem memory size. Its value is exposed in the new VmShm line=

>> of /proc/<pid>/status.
>=20
> I like adding this info to /proc/<pid>/status - thank you -
> but I think you can make the patch much better in a couple of ways.
>=20
>>
>> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
>> ---
>>  Documentation/filesystems/proc.txt |  2 ++
>>  arch/s390/mm/pgtable.c             |  2 +-
>>  fs/proc/task_mmu.c                 |  9 ++++++---
>>  include/linux/mm.h                 |  7 +++++++
>>  include/linux/mm_types.h           |  7 ++++---
>>  kernel/events/uprobes.c            |  2 +-
>>  mm/filemap_xip.c                   |  2 +-
>>  mm/memory.c                        | 37 +++++++++++++++++++++++++++++=
++------
>>  mm/rmap.c                          |  8 ++++----
>>  9 files changed, 57 insertions(+), 19 deletions(-)
>>
>> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesy=
stems/proc.txt
>> index ddc531a..1c49957 100644
>> --- a/Documentation/filesystems/proc.txt
>> +++ b/Documentation/filesystems/proc.txt
>> @@ -171,6 +171,7 @@ read the file /proc/PID/status:
>>    VmLib:      1412 kB
>>    VmPTE:        20 kb
>>    VmSwap:        0 kB
>> +  VmShm:         0 kB
>>    Threads:        1
>>    SigQ:   0/28578
>>    SigPnd: 0000000000000000
>> @@ -228,6 +229,7 @@ Table 1-2: Contents of the status files (as of 2.6=
=2E30-rc7)
>>   VmLib                       size of shared library code
>>   VmPTE                       size of page table entries
>>   VmSwap                      size of swap usage (the number of referr=
ed swapents)
>> + VmShm	                      size of resident shmem memory
>=20
> Needs to say that includes mappings of tmpfs, and needs to say that
> it's a subset of VmRSS.  Better placed immediately after VmRSS...
>=20
> ...but now that I look through what's in /proc/<pid>/status, it appears=

> that we have to defer to /proc/<pid>/statm to see MM_FILEPAGES (third
> field) and MM_ANONPAGES (subtract third field from second field).
>=20
> That's not a very friendly interface.  If you're going to help by
> exposing MM_SHMPAGES separately, please help even more by exposing
> VmFile and VmAnon here in /proc/<pid>/status too.
>=20

Good point.

> VmRSS, VmAnon, VmShm, VmFile?  I'm not sure what's the best order:
> here I'm thinking that anon comes before file in /proc/meminfo, and
> shm should be halfway between anon and file.  You may have another idea=
=2E
>=20
> And of course the VmFile count here should exclude VmShm: I think it
> will work out least confusingly if you account MM_FILEPAGES separately
> from MM_SHMPAGES, but add them together where needed e.g. for statm.

I chose not to change MM_FILEPAGES to avoid to break anything, but it
might indeed look better not to have MM_SHMPAGES included in
MM_FILEPAGES. I'll look into it.

>=20
>>   Threads                     number of threads
>>   SigQ                        number of signals queued/max. number for=
 queue
>>   SigPnd                      bitmap of pending signals for the thread=

>> diff --git a/arch/s390/mm/pgtable.c b/arch/s390/mm/pgtable.c
>> index 37b8241..9fe31b0 100644
>> --- a/arch/s390/mm/pgtable.c
>> +++ b/arch/s390/mm/pgtable.c
>> @@ -612,7 +612,7 @@ static void gmap_zap_swap_entry(swp_entry_t entry,=
 struct mm_struct *mm)
>>  		if (PageAnon(page))
>>  			dec_mm_counter(mm, MM_ANONPAGES);
>>  		else
>> -			dec_mm_counter(mm, MM_FILEPAGES);
>> +			dec_mm_file_counters(mm, page);
>>  	}
>=20
> That is a recurring pattern: please try putting
>=20
> static inline int mm_counter(struct page *page)
> {
> 	if (PageAnon(page))
> 		return MM_ANONPAGES;
> 	if (PageSwapBacked(page))
> 		return MM_SHMPAGES;
> 	return MM_FILEPAGES;
> }
>=20
> in include/linux/mm.h.
>=20
> Then dec_mm_counter(mm, mm_counter(page)) here, and wherever you can,
> use mm_counter(page) to simplify the code throughout.
>=20
> I say "try" because I think factoring out mm_counter() will simplify
> the most code, given the profusion of different accessors, particularly=

> in mm/memory.c.  But I'm not sure how much bloat having it as an inline=

> function will add, versus how much overhead it would add if not inline.=


I'll look into that.

Jerome

>=20
> Hugh
>=20



--lxVGKElGwxXE45ip0IhXLqN9P4K6qCS4C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJT26YEAAoJEHTzHJCtsuoCGpYH/RD+1RP2S7K9/aMTE34PatN3
/lnBqiFH6/ibJmVBZm0gzR3AR6dH7DgYZIVznbybDsE+2QNosSXQ7h2IGJqBdUJE
kj6grHZmZdTa4ISVJXFawEwk+Jg+mq+CoO9FJqA7833/PxtdDI2/84kILFAMmZSN
PFyldr6vZ1AxxzBHnAahQkbxx4Mwp+5QtQLUDHjMLGVGCa3efHWcD7z3oAICT50R
sy4u34ZqyS3EwMNkC0cTyOsl0u5PHQIBnstU2gd+15irka0bwEHkTO2+gZI1XQEt
QPIZeGPwVHkbVg4VayWODjAWGwrd1xlMIlSHXavFWN1mGTqxuBm8Y9xir8Py1+I=
=HVkx
-----END PGP SIGNATURE-----

--lxVGKElGwxXE45ip0IhXLqN9P4K6qCS4C--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
