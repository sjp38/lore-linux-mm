Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 20A096B006E
	for <linux-mm@kvack.org>; Tue, 24 Feb 2015 03:36:44 -0500 (EST)
Received: by pdno5 with SMTP id o5so31855279pdn.8
        for <linux-mm@kvack.org>; Tue, 24 Feb 2015 00:36:43 -0800 (PST)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0641.outbound.protection.outlook.com. [2a01:111:f400:fe00::641])
        by mx.google.com with ESMTPS id bk4si26127575pad.143.2015.02.24.00.36.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Feb 2015 00:36:43 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: RE: [PATCH V5 0/4] Refactor do_wp_page, no functional change
Date: Tue, 24 Feb 2015 08:36:09 +0000
Message-ID: <AM3PR05MB09359319822E332E9106EB05DC160@AM3PR05MB0935.eurprd05.prod.outlook.com>
References: <1424612538-25889-1-git-send-email-raindel@mellanox.com>
 <20150223162005.6eebce98b795699456464df4@linux-foundation.org>
In-Reply-To: <20150223162005.6eebce98b795699456464df4@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mgorman@suse.de" <mgorman@suse.de>, "riel@redhat.com" <riel@redhat.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "matthew.r.wilcox@intel.com" <matthew.r.wilcox@intel.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Haggai Eran <haggaie@mellanox.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "pfeiner@google.com" <pfeiner@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Sagi
 Grimberg <sagig@mellanox.com>, "walken@google.com" <walken@google.com>



> -----Original Message-----
> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Sent: Tuesday, February 24, 2015 2:20 AM
> To: Shachar Raindel
> Cc: linux-mm@kvack.org; kirill.shutemov@linux.intel.com;
> mgorman@suse.de; riel@redhat.com; ak@linux.intel.com;
> matthew.r.wilcox@intel.com; dave.hansen@linux.intel.com; n-
> horiguchi@ah.jp.nec.com; torvalds@linux-foundation.org; Haggai Eran;
> aarcange@redhat.com; pfeiner@google.com; hannes@cmpxchg.org; Sagi
> Grimberg; walken@google.com
> Subject: Re: [PATCH V5 0/4] Refactor do_wp_page, no functional change
>=20
> On Sun, 22 Feb 2015 15:42:14 +0200 Shachar Raindel
> <raindel@mellanox.com> wrote:
>=20
> > Currently do_wp_page contains 265 code lines. It also contains 9 goto
> > statements, of which 5 are targeting labels which are not cleanup
> > related. This makes the function extremely difficult to
> > understand. The following patches are an attempt at breaking the
> > function to its basic components, and making it easier to understand.
> >
> > The patches are straight forward function extractions from
> > do_wp_page. As we extract functions, we remove unneeded parameters and
> > simplify the code as much as possible. However, the functionality is
> > supposed to remain completely unchanged. The patches also attempt to
> > document the functionality of each extracted function. In patch 2, we
> > split the unlock logic to the contain logic relevant to specific needs
> > of each use case, instead of having huge number of conditional
> > decisions in a single unlock flow.
>=20
> gcc-4.4.4:
>=20
>    text    data     bss     dec     hex filename
>   40898     186   13344   54428    d49c mm/memory.o-before
>   41422     186   13456   55064    d718 mm/memory.o-after
>=20
> gcc-4.8.2:
>=20
>    text    data     bss     dec     hex filename
>   35261   12118   13904   61283    ef63 mm/memory.o
>   35646   12278   14032   61956    f204 mm/memory.o
>=20

My results (gcc version 4.8.2 20140120 (Red Hat 4.8.2-16)) differ:
   text	   data	    bss	    dec	    hex	filename
  29957	     70	     32	  30059	   756b	memory.o.next-20150219
  30061	     70	     32	  30163	   75d3	memory.o.next-20150219+1
  30093	     70	     32	  30195	   75f3	memory.o.next-20150219+2
  30165	     70	     32	  30267	   763b	memory.o.next-20150219+3
  30165	     70	     32	  30267	   763b	memory.o.next-20150219+4


> The more recent compiler is more interesting but either way, that's a
> somewhat disappointing increase in code size for refactoring of a
> single function.
>=20

Seems like the majority of the size impact (104 bytes out of 208) originate
from the first patch - "mm: Refactor do_wp_page, extract the reuse case"

This is probably due to changing 3 gotos into returning a function call.
As gcc cannot do tail call optimization there, it is forced to create
3 new call sites there. Adding an inline to wp_page_reuse reduced the total
size to:
   text	   data	    bss	    dec	    hex	filename
  30109	     70	     32	  30211	   7603	memory.o

> I had a brief poke around and couldn't find any obvious improvements
> to make.

IMHO, 152 bytes in code size is a small price to pay for code that is
not spaghetti.

The patch to add the strategic inline which saves 56 bytes on my GCC:

diff --git a/mm/memory.c b/mm/memory.c
index b246d22..9025285 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1990,7 +1990,7 @@ static int do_page_mkwrite(struct vm_area_struct *vma=
, struct page *page,
  * case, all we need to do here is to mark the page as writable and update
  * any related book-keeping.
  */
-static int wp_page_reuse(struct mm_struct *mm, struct vm_area_struct *vma,
+static inline int wp_page_reuse(struct mm_struct *mm, struct vm_area_struc=
t *vma,
                         unsigned long address, pte_t *page_table,
                         spinlock_t *ptl, pte_t orig_pte,
                         struct page *page, int page_mkwrite,



Thanks,
--Shachar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
