Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6D28E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 04:33:16 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w4so2811246otj.2
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 01:33:16 -0800 (PST)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id t25si3014795oth.275.2019.01.16.01.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 01:33:14 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm: hwpoison: use do_send_sig_info() instead of force_sig()
 (Re: PMEM error-handling forces SIGKILL causes kernel panic)
Date: Wed, 16 Jan 2019 09:30:46 +0000
Message-ID: <20190116093046.GA29835@hori1.linux.bs1.fc.nec.co.jp>
References: <e3c4c0e0-1434-4353-b893-2973c04e7ff7@oracle.com>
 <CAPcyv4j67n6H7hD6haXJqysbaauci4usuuj5c+JQ7VQBGngO1Q@mail.gmail.com>
 <20190111081401.GA5080@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20190111081401.GA5080@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <BD3F5D9C9DFE744584823ED995CFB4AB@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Jane Chu <jane.chu@oracle.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

[ CCed Andrew and linux-mm ]

On Fri, Jan 11, 2019 at 08:14:02AM +0000, Horiguchi Naoya(=1B$BKY8}=1B(B =
=1B$BD>Li=1B(B) wrote:
> Hi Dan, Jane,
>=20
> Thanks for the report.
>=20
> On Wed, Jan 09, 2019 at 03:49:32PM -0800, Dan Williams wrote:
> > [ switch to text mail, add lkml and Naoya ]
> >=20
> > On Wed, Jan 9, 2019 at 12:19 PM Jane Chu <jane.chu@oracle.com> wrote:
> ...
> > > 3. The hardware consists the latest revision CPU and Intel NVDIMM, we=
 suspected
> > >    the CPU faulty because it generated MCE over PMEM UE in a unlikely=
 high
> > >    rate for any reasonable NVDIMM (like a few per 24hours).
> > >
> > > After swapping the CPU, the problem stopped reproducing.
> > >
> > > But one could argue that perhaps the faulty CPU exposed a small race =
window
> > > from collect_procs() to unmap_mapping_range() and to kill_procs(), he=
nce
> > > caught the kernel  PMEM error handler off guard.
> >=20
> > There's definitely a race, and the implementation is buggy as can be
> > seen in __exit_signal:
> >=20
> >         sighand =3D rcu_dereference_check(tsk->sighand,
> >                                         lockdep_tasklist_lock_is_held()=
);
> >         spin_lock(&sighand->siglock);
> >=20
> > ...the memory-failure path needs to hold the proper locks before it
> > can assume that de-referencing tsk->sighand is valid.
> >=20
> > > Also note, the same workload on the same faulty CPU were run on Linux=
 prior to
> > > the 4.19 PMEM error handling and did not encounter kernel crash, prob=
ably because
> > > the prior HWPOISON handler did not force SIGKILL?
> >=20
> > Before 4.19 this test should result in a machine-check reboot, not
> > much better than a kernel crash.
> >=20
> > > Should we not to force the SIGKILL, or find a way to close the race w=
indow?
> >=20
> > The race should be closed by holding the proper tasklist and rcu read l=
ock(s).
>=20
> This reasoning and proposal sound right to me. I'm trying to reproduce
> this race (for non-pmem case,) but no luck for now. I'll investigate more=
.

I wrote/tested a patch for this issue.
I think that switching signal API effectively does proper locking.

Thanks,
Naoya Horiguchi
---
>From 16dbf6105ff4831f73276d79d5df238ab467de76 Mon Sep 17 00:00:00 2001
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Wed, 16 Jan 2019 16:59:27 +0900
Subject: [PATCH] mm: hwpoison: use do_send_sig_info() instead of force_sig(=
)

Currently memory_failure() is racy against process's exiting,
which results in kernel crash by null pointer dereference.

The root cause is that memory_failure() uses force_sig() to forcibly
kill asynchronous (meaning not in the current context) processes.  As
discussed in thread https://lkml.org/lkml/2010/6/8/236 years ago for
OOM fixes, this is not a right thing to do.  OOM solves this issue by
using do_send_sig_info() as done in commit d2d393099de2 ("signal:
oom_kill_task: use SEND_SIG_FORCED instead of force_sig()"), so this
patch is suggesting to do the same for hwpoison.  do_send_sig_info()
properly accesses to siglock with lock_task_sighand(), so is free from
the reported race.

I confirmed that the reported bug reproduces with inserting some delay
in kill_procs(), and it never reproduces with this patch.

Note that memory_failure() can send another type of signal using
force_sig_mceerr(), and the reported race shouldn't happen on it
because force_sig_mceerr() is called only for synchronous processes
(i.e. BUS_MCEERR_AR happens only when some process accesses to the
corrupted memory.)

Reported-by: Jane Chu <jane.chu@oracle.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: stable@vger.kernel.org
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 7c72f2a95785..831be5ff5f4d 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -372,7 +372,8 @@ static void kill_procs(struct list_head *to_kill, int f=
orcekill, bool fail,
 			if (fail || tk->addr_valid =3D=3D 0) {
 				pr_err("Memory failure: %#lx: forcibly killing %s:%d because of failur=
e to unmap corrupted page\n",
 				       pfn, tk->tsk->comm, tk->tsk->pid);
-				force_sig(SIGKILL, tk->tsk);
+				do_send_sig_info(SIGKILL, SEND_SIG_PRIV,
+						 tk->tsk, PIDTYPE_PID);
 			}
=20
 			/*
--=20
2.7.5
