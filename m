Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E6FA96B006E
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 06:00:14 -0500 (EST)
Received: by faas10 with SMTP id s10so7710636faa.14
        for <linux-mm@kvack.org>; Mon, 21 Nov 2011 03:00:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20111117103308.063f78df.kamezawa.hiroyu@jp.fujitsu.com>
References: <20111117103308.063f78df.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 21 Nov 2011 16:30:11 +0530
Message-ID: <CAKTCnzk81UiqVHGcTcN_0iyG8dw=-wC6jo8ME7g303PQFKDM3w@mail.gmail.com>
Subject: Re: [PATCH] fix mem_cgroup_split_huge_fixup to work efficiently.
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, mhocko@suse.cz, Andrea Arcangeli <aarcange@redhat.com>

On Thu, Nov 17, 2011 at 7:03 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> I'll send this again when mm is shipped.
> I sometimes see mem_cgroup_split_huge_fixup() in perf report and noticed
> it's very slow. This fixes it. Any comments are welcome.
>

How do you see this - what tests?

> =3D=3D
> Subject: [PATCH] fix mem_cgroup_split_huge_fixup to work efficiently.
>
> at split_huge_page(), mem_cgroup_split_huge_fixup() is called to
> handle page_cgroup modifcations. It takes move_lock_page_cgroup()
> and modify page_cgroup and LRU accounting jobs and called
> HPAGE_PMD_SIZE - 1 times.
>
> But thinking again,
> =A0- compound_lock() is held at move_accout...then, it's not necessary
> =A0 =A0to take move_lock_page_cgroup().
> =A0- LRU is locked and all tail pages will go into the same LRU as
> =A0 =A0head is now on.
> =A0- page_cgroup is contiguous in huge page range.
>
> This patch fixes mem_cgroup_split_huge_fixup() as to be called once per
> hugepage and reduce costs for spliting.

The change seems reasonable, I am working on a test setup and hope to
test it soon

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
