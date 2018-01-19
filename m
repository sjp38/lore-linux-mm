Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 564E16B0038
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 20:07:08 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id k11so160370qth.23
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 17:07:08 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id z7si892390qta.76.2018.01.18.17.07.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jan 2018 17:07:06 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] mm: numa: Do not trap faults on shared data section
 pages.
From: Henry Willard <henry.willard@oracle.com>
In-Reply-To: <alpine.DEB.2.20.1801171219270.23209@nuc-kabylake>
Date: Thu, 18 Jan 2018 17:06:54 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <2BEFC6DE-7A47-4CB9-AAE5-CEF70453B46F@oracle.com>
References: <1516130924-3545-1-git-send-email-henry.willard@oracle.com>
 <1516130924-3545-2-git-send-email-henry.willard@oracle.com>
 <20180116212614.gudglzw7kwzd3get@suse.de>
 <alpine.DEB.2.20.1801171219270.23209@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, kstewart@linuxfoundation.org, zi.yan@cs.rutgers.edu, pombredanne@nexb.com, aarcange@redhat.com, gregkh@linuxfoundation.org, aneesh.kumar@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



> On Jan 17, 2018, at 10:23 AM, Christopher Lameter <cl@linux.com> =
wrote:
>=20
> On Tue, 16 Jan 2018, Mel Gorman wrote:
>=20
>> My main source of discomfort is the fact that this is permanent as =
two
>> processes perfectly isolated but with a suitably shared COW mapping
>> will never migrate the data. A potential improvement to get the =
reported
>> bandwidth up in the test program would be to skip the rest of the VMA =
if
>> page_mapcount !=3D 1 in a COW mapping as it would be reasonable to =
assume
>> the remaining pages in the VMA are also affected and the scan is =
wasteful.
>> There are counter-examples to this but I suspect that the full VMA =
being
>> shared is the common case. Whether you do that or not;
>=20
> Same concern here. Typically CAP_SYS_NICE will bypass the check that =
the
> page is only mapped to a single process and the check looks exactly =
like
> the ones for manual migration. Using CAP_SYS_NICE would be surprising
> here since autonuma is not triggered by the currently running process.
>=20
> Can we configure this somehow via sysfs?

If I understand the code correctly, CAP_SYS_NICE allows MPOL_MF_MOVE_ALL =
to be set with mbind() or used with move_pages(). CAP_SYS_NICE also =
causes migrate_pages() to behave as if MPOL_MF_MOVE_ALL were specified. =
There are checks requiring either MPOL_MF_MOVE_ALL or =
page_mapcount(page) =3D=3D 1. The normal case does not call =
change_prot_numa(). change_prot_numa() is only called when MPOL_MF_LAZY =
is specified, and at the moment MPOL_MF_LAZY is not recognized as a =
valid flag. It looks to me that as things stand now, change_prot_numa() =
is only called from task_numa_work().

If MPOL_MF_LAZY were allowed and specified things would not work =
correctly. change_pte_range() is unaware of and can=E2=80=99t honor the =
difference between MPOL_MF_MOVE_ALL and MPOL_MF_MOVE.=20

For the case of auto numa balancing, it may be undesirable for shared =
pages to be migrated whether they are also copy-on-write or not. The =
copy-on-write test was added to restrict the effect of the patch to the =
specific situation we observed. Perhaps I should remove it, I don=E2=80=99=
t understand why it would be desirable to modify the behavior via sysfs.

Thanks,
Henry
>=20
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
