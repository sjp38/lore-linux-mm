Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1BEBC6B0036
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 11:24:42 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so5992856pab.2
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 08:24:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j8si16032503qab.100.2014.08.01.08.24.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Aug 2014 08:24:41 -0700 (PDT)
Message-ID: <53DBB10A.7080200@redhat.com>
Date: Fri, 01 Aug 2014 17:23:54 +0200
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm, shmem: Show location of non-resident shmem pages
 in smaps
References: <1406036632-26552-1-git-send-email-jmarchan@redhat.com> <1406036632-26552-6-git-send-email-jmarchan@redhat.com> <alpine.LSU.2.11.1407312205170.3912@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1407312205170.3912@eggly.anvils>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Sn2NKk3m4J8TAGH3NbTwf0SUVKn34bk5g"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-doc@vger.kernel.org, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux390@de.ibm.com, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Randy Dunlap <rdunlap@infradead.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Sn2NKk3m4J8TAGH3NbTwf0SUVKn34bk5g
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/01/2014 07:06 AM, Hugh Dickins wrote:
> On Tue, 22 Jul 2014, Jerome Marchand wrote:
>=20
>> Adds ShmOther, ShmOrphan, ShmSwapCache and ShmSwap lines to
>> /proc/<pid>/smaps for shmem mappings.
>>
>> ShmOther: amount of memory that is currently resident in memory, not
>> present in the page table of this process but present in the page
>> table of an other process.
>> ShmOrphan: amount of memory that is currently resident in memory but
>> not present in any process page table. This can happens when a process=

>> unmaps a shared mapping it has accessed before or exits. Despite being=

>> resident, this memory is not currently accounted to any process.
>> ShmSwapcache: amount of memory currently in swap cache
>> ShmSwap: amount of memory that is paged out on disk.
>>
>> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
>=20
> You will have to do a much better job of persuading me that these
> numbers are of any interest.  Okay, maybe not me, I'm not that keen
> on /proc/<pid>/smaps at the best of times.  But you will need to show
> plausible cases where having these numbers available would have made
> a real difference, and drum up support for their inclusion from
> /proc/<pid>/smaps devotees.
>=20
> Do you have a customer, who has underprovisioned with swap,
> and wants these numbers to work out how much more is needed?

We have a customer who needs to know how much memory a process with big
shared anonymous mappings have in swap.

>=20
> As it is, they appear to be numbers that you found you could provide,
> and so you're adding them into /proc/<pid>/smaps, but having great
> difficulty in finding good names to describe them - which is itself
> an indicator that they're probably not the most useful statistics
> a sysadmin is wanting.

ShmSwap is obviously the stat I needed for our customer. I also have use
for the ill named ShmOrphan (see below). I may have add the two others
because there were low hanging fruits, or maybe because there were
useful to me for debugging. I will get rid of them.

>=20
> (Google is a /proc/<pid>/smaps user: let's take a look to see if
> we have been driven to add in stats of this kind: no, not at all.)
>=20
> The more numbers we add to /proc/<pid>/smaps, the longer it will take t=
o
> print, the longer mmap_sem will be held, and the more it will interfere=

> with proper system operation - that's the concern I more often see.
>=20
>> ---
>>  Documentation/filesystems/proc.txt | 11 ++++++++
>>  fs/proc/task_mmu.c                 | 56 +++++++++++++++++++++++++++++=
++++++++-
>>  2 files changed, 66 insertions(+), 1 deletion(-)
>>
>> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesy=
stems/proc.txt
>> index 1a15c56..a65ab59 100644
>> --- a/Documentation/filesystems/proc.txt
>> +++ b/Documentation/filesystems/proc.txt
>> @@ -422,6 +422,10 @@ Swap:                  0 kB
>>  KernelPageSize:        4 kB
>>  MMUPageSize:           4 kB
>>  Locked:              374 kB
>> +ShmOther:            124 kB
>> +ShmOrphan:             0 kB
>> +ShmSwapCache:         12 kB
>> +ShmSwap:              36 kB
>>  VmFlags: rd ex mr mw me de
>> =20
>>  the first of these lines shows the same information as is displayed f=
or the
>> @@ -437,6 +441,13 @@ a mapping associated with a file may contain anon=
ymous pages: when MAP_PRIVATE
>>  and a page is modified, the file page is replaced by a private anonym=
ous copy.
>>  "Swap" shows how much would-be-anonymous memory is also used, but out=
 on
>>  swap.
>> +The ShmXXX lines only appears for shmem mapping. They show the amount=
 of memory
>> +from the mapping that is currently:
>> + - resident in RAM, not present in the page table of this process but=
 present
>> + in the page table of an other process (ShmOther)
>=20
> We don't show that for files of any other filesystem, why for shmem?
> Perhaps you are too focussed on SysV SHM, and I am too focussed on tmpf=
s.

I must admit that I see all this from SysV SHM / shared anon mappings
point of view.

>=20
> It is a very specialized statistic, and therefore hard to name: I don't=

> think ShmOther is a good name, but doubt any would do.  ShmOtherMapped?=

>=20
>> + - resident in RAM but not present in the page table of any process (=
ShmOrphan)
>=20
> We don't show that for files of any other filesystem, why for shmem?

Because these pages can not be discarded of write back to disk. Under
memory pressure, they need space on swap or have to stay in RAM.

>=20
> Orphan?  We do use the word "orphan" to describe pages which have been
> truncated off a file, but somehow not yet removed from pagecache.

I was unaware of that.

>  We
> don't use the the word "orphan" to describe pagecache pages which are
> not mapped into userspace - they are known as "pagecache pages which
> are not mapped into userspace".  ShmNotMapped?

I'm not sure about the terminology here. These pages are not mapped in
the sense that their map_count is zero, but they belong to a userspace
mapping.

>=20
>> + - in swap cache (ShmSwapCache)
>=20
> Is this interesting?  It's a transitional state: either memory pressure=

> has forced the page to swapcache, but not yet freed it from memory; or
> swapin_readahead has brought this page back in when bringing in a nearb=
y
> page of swap.
>=20
> I can understand that we might want better stats on the behaviour of
> swapin_readahead; better stats on shmem objects and swap; better stats
> on duplication between pagecache and swap; but I'm not convinced that
> /proc/<pid>/smaps is the right place for those.
>=20
> Against all that, of course, we do have mincore() showing these pages
> as incore, where /proc/<pid>/smaps does not.  But I think that is
> justified by mincore()'s mission to show what's incore.
>=20
>> + - paged out on swap (ShmSwap).
>=20
> This one has the best case for inclusion: we do show Swap for the anon
> pages which are out on swap, but not for the shmem areas, where swap
> entry does not go into page table.  But there is good reason for that:
> this is shared memory, files, objects commonly shared between
> processes, so it's a poor fit then to account them by processes.
>=20
> (We have "df" and "du" showing the occupancy of mounted tmpfs
> filesystems: it would be nice if we had something like those,
> which showed also the swap occupancy, and for the non-user-mounts.)

I guess that works for tmpfs, but shared anon mappings are invisible to
these tools.

Jerome

>=20
> I need much more convincing on this patch: I expect you will drop
> some of the numbers, and provide an argument for others.
>=20
> Hugh
>=20



--Sn2NKk3m4J8TAGH3NbTwf0SUVKn34bk5g
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJT27EKAAoJEHTzHJCtsuoC42AH/0YMOTGyGFnbE2D/Kli7M37f
i+Wj42s1UhCz6B7mYjAUDil9qWVIJpZPnmyRBmPAxlqkcOskC0Sj3Xypk7e30onU
kgDA4Jjvi93Tz6Q880PqaN7IYrW8oQB5sPozdKEnBK5ZSyoImylUvhqOvx+qJ6mn
XPBPsBoGBFa2WK/o8GtkQ2CYBwCJoFuh9en8HFtMky87Sc6ceHQjBkoOL8tCLhyM
SF7JAH2SwBJgZdix6FdwqBij0DYfocKZs1n1R78jnr9+R+CiZv7M5ZD8RmqxKW6g
0asGmAHonGDIuWqA/afM6SdQQB4uXGvMbFioS9LxBEzo9dJe+3aDK2j20KCxXoo=
=du00
-----END PGP SIGNATURE-----

--Sn2NKk3m4J8TAGH3NbTwf0SUVKn34bk5g--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
