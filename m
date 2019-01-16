Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F2DEC43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 09:33:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3F9520840
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 09:33:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3F9520840
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AB6E8E0003; Wed, 16 Jan 2019 04:33:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5819A8E0002; Wed, 16 Jan 2019 04:33:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 470ED8E0003; Wed, 16 Jan 2019 04:33:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1B6D28E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 04:33:16 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id w4so2811246otj.2
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 01:33:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:thread-topic:thread-index:date:message-id:references
         :in-reply-to:accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=+9MEesuIzPiKW7yRd6viT+xrQDda+KW+dkLlt8DKEw8=;
        b=Yapj/+5lJ4BT9c/Lz4/YUd43k6nAnTgn16+qR34+XyHHDg/fGafBzZpzAbDg5j7dBc
         81xh9G7N2Eg5Mg6vhd1NSSiyqBqwxHi7MIcHzXNrpqkI0YApJKsKRcJGK6VWTnTaQDnW
         P38PSRTZ0DYjLfmHuG0AyV5R+I2Vh1CA0agQF/nbo+5ItObbiLpFkX+yshaRNDTJcl07
         IsZwgzy4zFtEnQncU0UH8xrTXDvRyrK34QYtmYOlJreM6e7jxGbddZcNyQC9s4S0ZVOT
         UUtW2t4rWoe3nHX7FsiNczJIuTWYLiGUR23mQPVnqVwJ7pwONtfVzLyi0/zmqlPCg9II
         uJaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
X-Gm-Message-State: AJcUukepzfWazwfWxKiu6Q9CCxuMeiKWjiD1cxZEdGw+mcnWfLF+I0BS
	IuMN4G0gmRW6O1z0JXYuGrX5jKHMLKHfzFwihidURYQLz2A7FltcKxSmirmyjCPd5BX/ug+jZl0
	V4eI0WJwKIw0Dg7UIyuh5HG1tmQaoy1XCfL9ZtkvfgsDUaQn93JBPrs2NVA8WgQcl7Q==
X-Received: by 2002:a9d:37e1:: with SMTP id x88mr4826306otb.85.1547631195829;
        Wed, 16 Jan 2019 01:33:15 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7fz5ig6gcnFg7M7gMYidhjy9cK065qX5XsFKRYiNDDqz3p3iDPc7hdm+/QVSYDwNbXoccy
X-Received: by 2002:a9d:37e1:: with SMTP id x88mr4826280otb.85.1547631194857;
        Wed, 16 Jan 2019 01:33:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547631194; cv=none;
        d=google.com; s=arc-20160816;
        b=Bizg9AznujBCwYPQZ1gXGGYvMNXBSBqjN3ebLGhU7BRQJAi11kUD1OD4LFbVfVJSDD
         fdo4cuqfbZtqKlNL9jHM7CtiQZX0yP5uGcopzRL+GMe01WhPH0cCI515kEWETJ5IDYuI
         J/tWUrm+56xW3X1r8SCx/X8NSdEnTSo6qeyN6Wt0AbxsQZMbBd0Ay7ECEZx2Btt8I+ta
         wa+nnPBGdgbrxV8XJqCqrXQACOEZWJDhX0BRzI85kmdjkayjJFcA/3uWiT0cN6vLq0O1
         YbzZqDbFEtWpFBfuK8VYoNUfDp4mUt78vIE+DkvNhWzme1wQXtzg+CNpYtCMQYBUJc1Q
         tV5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from;
        bh=+9MEesuIzPiKW7yRd6viT+xrQDda+KW+dkLlt8DKEw8=;
        b=GTsA8W4xnIVpbicPf6T9opLtHCyDp0x8DzM/njYLyVRxlZZ30qamguGdxvzocpl8BH
         6B7jD5angcAcF/Uv9OGO7hBMl6j9wodgOKcAvWojH6Gf/3NLC7D0ITr6i6CpQBViioFi
         nnRZz8dPZaPJNrEHv6/wCBwgL/08Hy6EkgSJ3+prEy+vvg6e/y4eQMa/sUMs2/bOuB3K
         eYseT/xjhP/OSVAkBDG6wMbuVqQjP+qHcEclSxuDFJ9wB+cU/sNra2/970mgGZGwWh95
         8Vi5kepIR5c1fBM2nbdgORe7b01JjRbVFvq4CjyapXsQfcjDx0icxYDMmKJ8tGV7ikmf
         n+DA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id t25si3014795oth.275.2019.01.16.01.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 01:33:14 -0800 (PST)
Received-SPF: pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) client-ip=114.179.232.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of n-horiguchi@ah.jp.nec.com designates 114.179.232.161 as permitted sender) smtp.mailfrom=n-horiguchi@ah.jp.nec.com
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x0G9X4BV021404
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 16 Jan 2019 18:33:04 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x0G9X45g021398;
	Wed, 16 Jan 2019 18:33:04 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x0G9WWcY000507;
	Wed, 16 Jan 2019 18:33:04 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.152] [10.38.151.152]) by mail01b.kamome.nec.co.jp with ESMTP id BT-MMP-1507344; Wed, 16 Jan 2019 18:30:47 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC24GP.gisp.nec.co.jp ([10.38.151.152]) with mapi id 14.03.0319.002; Wed,
 16 Jan 2019 18:30:47 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Dan Williams <dan.j.williams@intel.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>
CC: Jane Chu <jane.chu@oracle.com>, linux-nvdimm <linux-nvdimm@lists.01.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: [PATCH] mm: hwpoison: use do_send_sig_info() instead of force_sig()
 (Re: PMEM error-handling forces SIGKILL causes kernel panic)
Thread-Topic: [PATCH] mm: hwpoison: use do_send_sig_info() instead of
 force_sig() (Re: PMEM error-handling forces SIGKILL causes kernel panic)
Thread-Index: AQHUrX4o7Slk8dv5sk2r4phfic2oGA==
Date: Wed, 16 Jan 2019 09:30:46 +0000
Message-ID: <20190116093046.GA29835@hori1.linux.bs1.fc.nec.co.jp>
References: <e3c4c0e0-1434-4353-b893-2973c04e7ff7@oracle.com>
 <CAPcyv4j67n6H7hD6haXJqysbaauci4usuuj5c+JQ7VQBGngO1Q@mail.gmail.com>
 <20190111081401.GA5080@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20190111081401.GA5080@hori1.linux.bs1.fc.nec.co.jp>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.51.8.80]
Content-Type: text/plain; charset="UTF-8"
Content-ID: <BD3F5D9C9DFE744584823ED995CFB4AB@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116093046.Sk51uHsImk990fHMlLWWHELQmAkTQxE2ChFUeT_lx2k@z>

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
From 16dbf6105ff4831f73276d79d5df238ab467de76 Mon Sep 17 00:00:00 2001
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


