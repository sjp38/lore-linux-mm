Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BAD8B6B004D
	for <linux-mm@kvack.org>; Tue, 19 May 2009 02:38:52 -0400 (EDT)
Received: by bwz21 with SMTP id 21so4875026bwz.38
        for <linux-mm@kvack.org>; Mon, 18 May 2009 23:39:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090516090448.410032840@intel.com>
References: <20090516090005.916779788@intel.com>
	 <20090516090448.410032840@intel.com>
Date: Tue, 19 May 2009 09:39:27 +0300
Message-ID: <84144f020905182339o5fb1e78eved95c4c20fd9ffa7@mail.gmail.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class
	citizen
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi!

On Sat, May 16, 2009 at 12:00 PM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
> @@ -1272,28 +1273,40 @@ static void shrink_active_list(unsigned
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* page_referenced clears PageReferenced *=
/
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (page_mapping_inuse(page) &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_referenced(page, 0, sc->mem_cg=
roup, &vm_flags))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_referenced(page, 0, sc->mem_cg=
roup, &vm_flags)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgmoved++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Identify referenced, f=
ile-backed active pages and
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* give them one more tri=
p around the active list. So
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* that executable code g=
et better chances to stay in
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* memory under moderate =
memory pressure. =A0Anon pages
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* are ignored, since JVM=
 can create lots of anon
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* VM_EXEC pages.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((vm_flags & VM_EXEC) &&=
 !PageAnon(page)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_add(&p=
age->lru, &l_active);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 continue;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }

Why do we need to skip JIT'd code? There are plenty of desktop
applications that use Mono, for example, and it would be nice if we
gave them the same treatment as native applications. Likewise, I am
sure all browsers that use JIT for JavaScript need to be considered.

                                   Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
