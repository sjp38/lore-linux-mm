Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 93A24800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 19:41:21 -0500 (EST)
Received: by mail-ua0-f197.google.com with SMTP id w27so8036032uaa.5
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 16:41:21 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id j67si1982824vkd.279.2018.01.22.16.41.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 16:41:20 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] mm: numa: Do not trap faults on shared data section
 pages.
From: Henry Willard <henry.willard@oracle.com>
In-Reply-To: <alpine.DEB.2.20.1801192002161.14056@nuc-kabylake>
Date: Mon, 22 Jan 2018 16:41:11 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <BF7AF910-28E1-42F2-A5FE-09B9D337C4A4@oracle.com>
References: <1516130924-3545-1-git-send-email-henry.willard@oracle.com>
 <1516130924-3545-2-git-send-email-henry.willard@oracle.com>
 <20180116212614.gudglzw7kwzd3get@suse.de>
 <alpine.DEB.2.20.1801171219270.23209@nuc-kabylake>
 <2BEFC6DE-7A47-4CB9-AAE5-CEF70453B46F@oracle.com>
 <alpine.DEB.2.20.1801192002161.14056@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, kstewart@linuxfoundation.org, zi.yan@cs.rutgers.edu, pombredanne@nexb.com, aarcange@redhat.com, gregkh@linuxfoundation.org, aneesh.kumar@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



> On Jan 19, 2018, at 6:12 PM, Christopher Lameter <cl@linux.com> wrote:
>=20
> On Thu, 18 Jan 2018, Henry Willard wrote:
>=20
>> If MPOL_MF_LAZY were allowed and specified things would not work
>> correctly. change_pte_range() is unaware of and can=E2=80=99t honor =
the
>> difference between MPOL_MF_MOVE_ALL and MPOL_MF_MOVE.
>=20
> Not sure how that relates to what I said earlier... Sorry.

Only that CAP_SYS_NICE is not relevant to this patch.

>=20
>>=20
>> For the case of auto numa balancing, it may be undesirable for shared
>> pages to be migrated whether they are also copy-on-write or not. The
>> copy-on-write test was added to restrict the effect of the patch to =
the
>> specific situation we observed. Perhaps I should remove it, I don=E2=80=
=99t
>> understand why it would be desirable to modify the behavior via =
sysfs.
>=20
> I think the most common case of shared pages occurs for pages that =
contain
> code. In that case a page may be mapped into hundreds if not thousands =
of
> processes. In particular that is often the case for basic system =
libraries
> like the c library which may actually be mapped into every binary that =
is
> running.

That is true, but auto numa balancing skips these and similar pages =
before it calls change_prot_numa(). They don=E2=80=99t even have to be =
actually shared to be skipped.=20

>=20
> It is very difficult and expensive to unmap these pages from all the
> processes in order to migrate them. So some sort of limit would be =
useful
> to avoid unnecessary migration attempts. One example would be to =
forbid
> migrating pages that are mapped in more than 5 processes. Some sysctl =
know
> would be useful here to set the boundary.
>=20
> Your patch addresses a special case here by forbidding migration of =
any
> page mapped by more than a single process (mapcount !=3D1).

The current patch skips pages that are in copy-on-write VMAs and still =
shared. These include pages in the program=E2=80=99s data segment that =
are writable. but have not been written to. Once the pages are modified =
they are no longer shared and can be migrated. The problem is that in =
some cases, the pages are never modified and remain shared.

Prior to commit 4b10e7d562c90d0a72f324832c26653947a07381, =
change_prot_numa() called change_prot_numa_range(), which tested for =
(page_mapcount(page) !=3D 1) and bailed out for any shared pages. This =
patch is more selective. A simple test for shared or not seems to be =
common.

>=20
> That would mean f.e. that the complete migration of a set of processes
> that rely on sharing data via a memory segment is impossible because =
those
> shared pages can never be moved.
>=20
> By setting the limit higher that migration would still be possible.
>=20
> Maybe we can set that limit by default at 5 and allow a higher setting
> if users have applications that require a higher mapcoun? F.e. a
> common construct is a shepherd task and N worker threads. If those
> tasks each have their own address space and only communicate via
> a shared data segment then one may want to set the limit higher than N
> in order to allow the migration of the group of processes.

This example would be unaffected by this patch, because the patch does =
not affect explicitly shared memory. A process with the necessary =
capabilities is still able to migrate all pages.

Henry


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
