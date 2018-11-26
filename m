Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B04F56B3F95
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 21:25:55 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id z22-v6so10264795pfi.0
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 18:25:55 -0800 (PST)
Received: from esa4.dell-outbound.iphmx.com (esa4.dell-outbound.iphmx.com. [68.232.149.214])
        by mx.google.com with ESMTPS id 197si54629636pgb.564.2018.11.25.18.25.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 18:25:54 -0800 (PST)
Received: from pps.filterd (m0142699.ppops.net [127.0.0.1])
	by mx0a-00154901.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAQ38hBp106113
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 22:16:46 -0500
Received: from esa5.dell-outbound2.iphmx.com (esa5.dell-outbound2.iphmx.com [68.232.153.203])
	by mx0a-00154901.pphosted.com with ESMTP id 2p07vjg6ax-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Sun, 25 Nov 2018 22:16:46 -0500
From: "Wang, Matt" <Matt.Wang@Dell.com>
Subject: RE: Make  __memblock_free_early a wrapper of memblock_free rather
 dup it
Date: Mon, 26 Nov 2018 02:25:44 +0000
Message-ID: <C8ECE1B7A767434691FEEFA3A01765D72AFB95CA@MX203CL03.corp.emc.com>
References: <C8ECE1B7A767434691FEEFA3A01765D72AFB8E78@MX203CL03.corp.emc.com>
 <20181121212740.84884a0c4532334d81fc6961@linux-foundation.org>
 <20181125102940.GE28634@rapoport-lnx>
In-Reply-To: <20181125102940.GE28634@rapoport-lnx>
Content-Language: en-US
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

I believe I explained why we choose it to be a wrapper,
" I noticed that __memblock_free_early and memblock_free has the same code.=
 At first I think we can delete __memblock_free_early till __memblock_free_=
late remind me __memblock_free_early is meaningful. It=1B$B!G=1B(Bs a note =
to call this before struct page was initialized."

Andrew may choose plan as he see fit.

Regards,
Matt

-----Original Message-----
From: Mike Rapoport [mailto:rppt@linux.ibm.com]=20
Sent: 2018=1B$BG/=1B(B11=1B$B7n=1B(B25=1B$BF|=1B(B 18:30
To: Andrew Morton
Cc: Wang, Matt; linux-mm@kvack.org
Subject: Re: Make __memblock_free_early a wrapper of memblock_free rather d=
up it


[EXTERNAL EMAIL]=20

On Wed, Nov 21, 2018 at 09:27:40PM -0800, Andrew Morton wrote:
> On Thu, 22 Nov 2018 04:01:53 +0000 "Wang, Matt" <Matt.Wang@Dell.com> wrot=
e:
>=20
> > Subject: [PATCH] Make __memblock_free_early a wrapper of=20
> > memblock_free rather  than dup it
> >=20
> > Signed-off-by: Wentao Wang <witallwang@gmail.com>
> > ---
> >  mm/memblock.c | 7 +------
> >  1 file changed, 1 insertion(+), 6 deletions(-)
> >=20
> > diff --git a/mm/memblock.c b/mm/memblock.c index 9a2d5ae..08bf136=20
> > 100644
> > --- a/mm/memblock.c
> > +++ b/mm/memblock.c
> > @@ -1546,12 +1546,7 @@ void * __init memblock_alloc_try_nid(
> >   */
> >  void __init __memblock_free_early(phys_addr_t base, phys_addr_t=20
> > size)  {
> > -	phys_addr_t end =3D base + size - 1;
> > -
> > -	memblock_dbg("%s: [%pa-%pa] %pF\n",
> > -		     __func__, &base, &end, (void *)_RET_IP_);
> > -	kmemleak_free_part_phys(base, size);
> > -	memblock_remove_range(&memblock.reserved, base, size);
> > +	memblock_free(base, size);
> >  }
>=20
> hm, I suppose so.  The debug messaging becomes less informative but=20
> the duplication is indeed irritating and if we really want to show the=20
> different caller info in the messages, we could do it in a smarter=20
> fashion.

Sorry for jumping late, but I believe the better way would be simply replac=
e the only two calls to __memblock_free_early() with calls to memblock_free=
().

The patch below is based on the current mmots.

>From 4de5a2aabb0b898c6b4add6bf91175fc55725362 Mon Sep 17 00:00:00 2001
From: Mike Rapoport <rppt@linux.ibm.com>
Date: Sun, 25 Nov 2018 12:20:46 +0200
Subject: [PATCH] memblock: replace usage of __memblock_free_early() with
 memblock_free()

The __memblock_free_early() function is only used by the convinince wrapper=
s, so essentially we wrap a call to memblock_free() twice.
Replace calls of __memblock_free_early() with calls to memblock_free() and =
drop the former.

Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
---
 include/linux/memblock.h |  5 ++---
 mm/memblock.c            | 22 ++++++++--------------
 2 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h index 5ba5=
2a7..e9e4017 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -154,7 +154,6 @@ void __next_mem_range_rev(u64 *idx, int nid, enum membl=
ock_flags flags,  void __next_reserved_mem_region(u64 *idx, phys_addr_t *ou=
t_start,
 				phys_addr_t *out_end);
=20
-void __memblock_free_early(phys_addr_t base, phys_addr_t size);  void __me=
mblock_free_late(phys_addr_t base, phys_addr_t size);
=20
 /**
@@ -452,13 +451,13 @@ static inline void * __init memblock_alloc_node_nopan=
ic(phys_addr_t size,  static inline void __init memblock_free_early(phys_ad=
dr_t base,
 					      phys_addr_t size)
 {
-	__memblock_free_early(base, size);
+	memblock_free(base, size);
 }
=20
 static inline void __init memblock_free_early_nid(phys_addr_t base,
 						  phys_addr_t size, int nid)
 {
-	__memblock_free_early(base, size);
+	memblock_free(base, size);
 }
=20
 static inline void __init memblock_free_late(phys_addr_t base, phys_addr_t=
 size) diff --git a/mm/memblock.c b/mm/memblock.c index 0559979..b842ce1 10=
0644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -800,7 +800,14 @@ int __init_memblock memblock_remove(phys_addr_t base, =
phys_addr_t size)
 	return memblock_remove_range(&memblock.memory, base, size);  }
=20
-
+/**
+ * memblock_free - free boot memory block
+ * @base: phys starting address of the  boot memory block
+ * @size: size of the boot memory block in bytes
+ *
+ * Free boot memory block previously allocated by memblock_alloc_xx() API.
+ * The freeing memory will not be released to the buddy allocator.
+ */
 int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)  {
 	phys_addr_t end =3D base + size - 1;
@@ -1600,19 +1607,6 @@ void * __init memblock_alloc_try_nid(  }
=20
 /**
- * __memblock_free_early - free boot memory block
- * @base: phys starting address of the  boot memory block
- * @size: size of the boot memory block in bytes
- *
- * Free boot memory block previously allocated by memblock_alloc_xx() API.
- * The freeing memory will not be released to the buddy allocator.
- */
-void __init __memblock_free_early(phys_addr_t base, phys_addr_t size) -{
-	memblock_free(base, size);
-}
-
-/**
  * __memblock_free_late - free bootmem block pages directly to buddy alloc=
ator
  * @base: phys starting address of the  boot memory block
  * @size: size of the boot memory block in bytes
--
2.7.4


--=20
Sincerely yours,
Mike.
