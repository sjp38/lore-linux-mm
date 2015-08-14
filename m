Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 50D2B6B0038
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 03:27:21 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so54896905pac.3
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 00:27:21 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id wm7si7614490pbc.49.2015.08.14.00.27.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Aug 2015 00:27:20 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hwpoison: fix race between soft_offline_page and
 unpoison_memory
Date: Fri, 14 Aug 2015 07:26:50 +0000
Message-ID: <20150814072649.GA31021@hori1.linux.bs1.fc.nec.co.jp>
References: <BLU436-SMTP256072767311DFB0FD3AE1B807D0@phx.gbl>
 <20150813085332.GA30163@hori1.linux.bs1.fc.nec.co.jp>
 <BLU437-SMTP1006340696EDBC91961809807D0@phx.gbl>
 <20150813100407.GA2993@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP1366B3FB4A3904EBDAE6BF9807D0@phx.gbl>
 <20150814041939.GA9951@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP110412F310BD1723C6F1C3E807C0@phx.gbl>
In-Reply-To: <BLU436-SMTP110412F310BD1723C6F1C3E807C0@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <18B031F9C05A5042B6C3006E24555CCA@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Aug 14, 2015 at 01:03:53PM +0800, Wanpeng Li wrote:
> On 8/14/15 12:19 PM, Naoya Horiguchi wrote:
...
> >>>>> If I read correctly, the old migratetype approach has a few problem=
s:
> >>>>>   1) it doesn't fix the problem completely, because
> >>>>>      set_migratetype_isolate() can fail to set MIGRATE_ISOLATE to t=
he
> >>>>>      target page if the pageblock of the page contains one or more
> >>>>>      unmovable pages (i.e. has_unmovable_pages() returns true).
> >>>>>   2) the original code changes migratetype to MIGRATE_ISOLATE forci=
bly,
> >>>>>      and sets it to MIGRATE_MOVABLE forcibly after soft offline, re=
gardless
> >>>>>      of the original migratetype state, which could impact other su=
bsystems
> >>>>>      like memory hotplug or compaction.
> >>>> Maybe we can add a "FIXME" comment on the Migratetype stuff, since t=
he
> >>>> current linus tree calltrace and it should be fixed immediately, and=
 I
> >>>> don't see obvious bugs appear on migratetype stuffs at least current=
ly,
> >>>> so "FIXME" is enough. :-)
> >>> Sorry if confusing, but my intention in saying about "FIXME" comment =
was
> >>> that we can find another solution for this race rather than just reve=
rting,
> >>> so adding comment about the reported bug in current code (keeping cod=
e from
> >>> 4491f712606) is OK for very short term.
> >>> I understand that leaving a race window of BUG_ON is not the best thi=
ng, but
> >>> as I said, this race shouldn't affect end-users, so this is not an ur=
gent bug.
> >>> # It's enough if testers know this.
> >> The 4.2 is coming, this patch can be applied as a temporal solution in
> >> order to fix the broken linus tree, and the any final solution can be
> >> figured out later.
> > I didn't reproduce this problem yet in my environment, but from code re=
ading
> > I guess that checking PageHWPoison flag in unmap_and_move() like below =
could
> > avoid the problem. Could you testing with this, please?
>=20
> I have already try to modify unmap_and_move() the same as what you do
> before I post migratetype stuff. It doesn't work and have other calltrace=
.

OK, then I rethink of handling the race in unpoison_memory().

Currently properly contained/hwpoisoned pages should have page refcount 1
(when the memory error hits LRU pages or hugetlb pages) or refcount 0
(when the memory error hits the buddy page.) And current unpoison_memory()
implicitly assumes this because otherwise the unpoisoned page has no place
to go and it's just leaked.
So to avoid the kernel panic, adding prechecks of refcount and mapcount
to limit the page to unpoison for only unpoisonable pages looks OK to me.
The page under soft offlining always has refcount >=3D2 and/or mapcount > 0=
,
so such pages should be filtered out.

Here's a patch. In my testing (run soft offline stress testing then repeat
unpoisoning in background,) the reported (or similar) bug doesn't happen.
Can I have your comments?

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm/hwpoison: don't unpoison for pinned or mapped page

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d1f85f6278ee..c6f14d2cd919 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1442,6 +1442,16 @@ int unpoison_memory(unsigned long pfn)
 		return 0;
 	}
=20
+	if (page_count(page) > 1) {
+		pr_info("MCE: Someone grabs the hwpoison page %#lx\n", pfn);
+		return 0;
+	}
+
+	if (page_mapped(page)) {
+		pr_info("MCE: Someone maps the hwpoison page %#lx\n", pfn);
+		return 0;
+	}
+
 	/*
 	 * unpoison_memory() can encounter thp only when the thp is being
 	 * worked by memory_failure() and the page lock is not held yet.
--=20
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
