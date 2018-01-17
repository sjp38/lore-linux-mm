Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 80479280263
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 19:45:29 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id d13so2497119ybn.14
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 16:45:29 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id y186si801554ywe.612.2018.01.16.16.45.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 16:45:28 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [PATCH] mm: numa: Do not trap faults on shared data section
 pages.
From: Henry Willard <henry.willard@oracle.com>
In-Reply-To: <20180116212614.gudglzw7kwzd3get@suse.de>
Date: Tue, 16 Jan 2018 16:45:22 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <E6D833F4-C32F-45F3-AA88-26D6E58E10E4@oracle.com>
References: <1516130924-3545-1-git-send-email-henry.willard@oracle.com>
 <1516130924-3545-2-git-send-email-henry.willard@oracle.com>
 <20180116212614.gudglzw7kwzd3get@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: akpm@linux-foundation.org, kstewart@linuxfoundation.org, zi.yan@cs.rutgers.edu, pombredanne@nexb.com, aarcange@redhat.com, gregkh@linuxfoundation.org, aneesh.kumar@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, jglisse@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



> On Jan 16, 2018, at 1:26 PM, Mel Gorman <mgorman@suse.de> wrote:
>=20
> On Tue, Jan 16, 2018 at 11:28:44AM -0800, Henry Willard wrote:
>> Workloads consisting of a large number processes running the same =
program
>> with a large shared data section may suffer from excessive numa =
balancing
>> page migration of the pages in the shared data section. This shows up =
as
>> high I/O wait time and degraded performance on machines with higher =
socket
>> or node counts.
>>=20
>> This patch skips shared copy-on-write pages in change_pte_range() for =
the
>> numa balancing case.
>>=20
>> Signed-off-by: Henry Willard <henry.willard@oracle.com>
>> Reviewed-by: H=C3=A5kon Bugge <haakon.bugge@oracle.com>
>> Reviewed-by: Steve Sistare steven.sistare@oracle.com
>=20
> Merge the leader and this mail together. It would have been nice to =
see
> data on other realistic workloads as well.
>=20
> My main source of discomfort is the fact that this is permanent as two
> processes perfectly isolated but with a suitably shared COW mapping
> will never migrate the data. A potential improvement to get the =
reported
> bandwidth up in the test program would be to skip the rest of the VMA =
if
> page_mapcount !=3D 1 in a COW mapping as it would be reasonable to =
assume
> the remaining pages in the VMA are also affected and the scan is =
wasteful.
> There are counter-examples to this but I suspect that the full VMA =
being
> shared is the common case. Whether you do that or not;
>=20
> Acked-by: Mel Gorman <mgorman@suse.de>

Thanks. The real customer cases where this was observed involved large, =
1TB or more, eight socket machines running very active RDBMS workloads. =
These customers saw high iowait times and a loss in performance when =
numa balancing was enabled. Previously there was no reported iowait =
time. The extent of the loss of performance was variable depending on =
the activity and never quantified. The little test program is a =
distillation of what was observed. In the real workload, a large part of =
the VMA is shared, but not all of it, so this seemed the simplest and =
most reliable patch.

Henry

>=20
> --=20
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
