Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 855426B0032
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 22:02:25 -0400 (EDT)
Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: quoted-printable
Subject: =?gb2312?B?tPC4tDogW1BBVENIIDM0LzUwXSBzY2hlZDogbnVtYTogRG8gbm90IA==?=
	=?gb2312?B?dHJhcCBoaW50aW5nIGZhdWx0cyBmb3Igc2hhcmVkIGxpYnJhcmllcw==?=
Date: Tue, 17 Sep 2013 10:02:22 +0800
Message-ID: <E81554BCB8813E49A8916AACC0503A851844C937@lc-shmail3.SHANGHAI.LEADCORETECH.COM>
In-Reply-To: <1378805550-29949-35-git-send-email-mgorman@suse.de>
From: =?gb2312?B?1cXM7LfJ?= <ZhangTianFei@leadcoretech.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

index fd724bc..5d244d0 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -1227,6 +1227,16 @@ void task_numa_work(struct callback_head *work)
 		if (!vma_migratable(vma))
 			continue;
=20
+		/*
+		 * Shared library pages mapped by multiple processes are not
+		 * migrated as it is expected they are cache replicated. Avoid
+		 * hinting faults in read-only file-backed mappings or the vdso
+		 * as migrating the pages will be of marginal benefit.
+		 */
+		if (!vma->vm_mm ||
+		    (vma->vm_file && (vma->vm_flags & (VM_READ|VM_WRITE)) =3D=3D =
(VM_READ)))
+			continue;
+
=20
=3D=A1=B7 May I ask a question, we should consider some VMAs canot be =
scaned for BalanceNuma?
(VM_DONTEXPAND | VM_RESERVED | VM_INSERTPAGE |
				  VM_NONLINEAR | VM_MIXEDMAP | VM_SAO));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
