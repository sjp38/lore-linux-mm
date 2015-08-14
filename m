Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E0B546B0038
	for <linux-mm@kvack.org>; Fri, 14 Aug 2015 04:09:48 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so55286503pac.2
        for <linux-mm@kvack.org>; Fri, 14 Aug 2015 01:09:48 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id fu2si7758263pbb.175.2015.08.14.01.09.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 14 Aug 2015 01:09:48 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hwpoison: fix race between soft_offline_page and
 unpoison_memory
Date: Fri, 14 Aug 2015 08:02:37 +0000
Message-ID: <20150814080237.GA6956@hori1.linux.bs1.fc.nec.co.jp>
References: <BLU436-SMTP256072767311DFB0FD3AE1B807D0@phx.gbl>
 <20150813085332.GA30163@hori1.linux.bs1.fc.nec.co.jp>
 <BLU437-SMTP1006340696EDBC91961809807D0@phx.gbl>
 <20150813100407.GA2993@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP1366B3FB4A3904EBDAE6BF9807D0@phx.gbl>
 <20150814041939.GA9951@hori1.linux.bs1.fc.nec.co.jp>
 <BLU436-SMTP110412F310BD1723C6F1C3E807C0@phx.gbl>
 <20150814072649.GA31021@hori1.linux.bs1.fc.nec.co.jp>
 <BLU437-SMTP24AA9CF28EF66D040D079B807C0@phx.gbl>
In-Reply-To: <BLU437-SMTP24AA9CF28EF66D040D079B807C0@phx.gbl>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <2C260AACEE378C48BAED78CFC160ED87@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Aug 14, 2015 at 03:54:36PM +0800, Wanpeng Li wrote:
> On 8/14/15 3:26 PM, Naoya Horiguchi wrote:
> > On Fri, Aug 14, 2015 at 01:03:53PM +0800, Wanpeng Li wrote:
> >> On 8/14/15 12:19 PM, Naoya Horiguchi wrote:
> > ...
> >>>>>>> If I read correctly, the old migratetype approach has a few probl=
ems:
> >>>>>>>   1) it doesn't fix the problem completely, because
> >>>>>>>      set_migratetype_isolate() can fail to set MIGRATE_ISOLATE to=
 the
> >>>>>>>      target page if the pageblock of the page contains one or mor=
e
> >>>>>>>      unmovable pages (i.e. has_unmovable_pages() returns true).
> >>>>>>>   2) the original code changes migratetype to MIGRATE_ISOLATE for=
cibly,
> >>>>>>>      and sets it to MIGRATE_MOVABLE forcibly after soft offline, =
regardless
> >>>>>>>      of the original migratetype state, which could impact other =
subsystems
> >>>>>>>      like memory hotplug or compaction.
> >>>>>> Maybe we can add a "FIXME" comment on the Migratetype stuff, since=
 the
> >>>>>> current linus tree calltrace and it should be fixed immediately, a=
nd I
> >>>>>> don't see obvious bugs appear on migratetype stuffs at least curre=
ntly,
> >>>>>> so "FIXME" is enough. :-)
> >>>>> Sorry if confusing, but my intention in saying about "FIXME" commen=
t was
> >>>>> that we can find another solution for this race rather than just re=
verting,
> >>>>> so adding comment about the reported bug in current code (keeping c=
ode from
> >>>>> 4491f712606) is OK for very short term.
> >>>>> I understand that leaving a race window of BUG_ON is not the best t=
hing, but
> >>>>> as I said, this race shouldn't affect end-users, so this is not an =
urgent bug.
> >>>>> # It's enough if testers know this.
> >>>> The 4.2 is coming, this patch can be applied as a temporal solution =
in
> >>>> order to fix the broken linus tree, and the any final solution can b=
e
> >>>> figured out later.
> >>> I didn't reproduce this problem yet in my environment, but from code =
reading
> >>> I guess that checking PageHWPoison flag in unmap_and_move() like belo=
w could
> >>> avoid the problem. Could you testing with this, please?
> >> I have already try to modify unmap_and_move() the same as what you do
> >> before I post migratetype stuff. It doesn't work and have other calltr=
ace.
> > OK, then I rethink of handling the race in unpoison_memory().
> >
> > Currently properly contained/hwpoisoned pages should have page refcount=
 1
> > (when the memory error hits LRU pages or hugetlb pages) or refcount 0
> > (when the memory error hits the buddy page.) And current unpoison_memor=
y()
> > implicitly assumes this because otherwise the unpoisoned page has no pl=
ace
> > to go and it's just leaked.
> > So to avoid the kernel panic, adding prechecks of refcount and mapcount
> > to limit the page to unpoison for only unpoisonable pages looks OK to m=
e.
> > The page under soft offlining always has refcount >=3D2 and/or mapcount=
 > 0,
> > so such pages should be filtered out.
> >
> > Here's a patch. In my testing (run soft offline stress testing then rep=
eat
> > unpoisoning in background,) the reported (or similar) bug doesn't happe=
n.
> > Can I have your comments?
>=20
> As page_action() prints out page maybe still referenced by some users,
> however, PageHWPoison has already set. So you will leak many poison pages=
.

Right, but it isn't a problem, because error handling doesn't always succee=
d.
Our basic policy for such case is to leak the page intentionally. IOW, the
memory leakage happen even in current kernel (unpoison doesn't work because
leaked page never return to buddy.) So my suggestion doesn't make things wo=
rse.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
