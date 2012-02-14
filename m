Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id BB05F6B13F3
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 02:23:10 -0500 (EST)
Received: by mail-vw0-f41.google.com with SMTP id p1so5287539vbi.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 23:23:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120214121631.782352f2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20120214120414.025625c2.kamezawa.hiroyu@jp.fujitsu.com> <20120214121631.782352f2.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Mon, 13 Feb 2012 23:22:50 -0800
Message-ID: <CAHH2K0baOnU6BE5c16cR0KiMvM3Hz+ngcBCs5e4+xJ_dcoeOww@mail.gmail.com>
Subject: Re: [PATCH 6/6 v4] memcg: fix performance of mem_cgroup_begin_update_page_stat()
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>

On Mon, Feb 13, 2012 at 7:16 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From 3377fd7b6e23a5d2a368c078eae27e2b49c4f4aa Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Mon, 6 Feb 2012 12:14:47 +0900
> Subject: [PATCH 6/6] memcg: fix performance of mem_cgroup_begin_update_pa=
ge_stat()
>
> mem_cgroup_begin_update_page_stat() should be very fast because
> it's called very frequently. Now, it needs to look up page_cgroup
> and its memcg....this is slow.
>
> This patch adds a global variable to check "a memcg is moving or not".

s/a memcg/any memcg/

> By this, the caller doesn't need to visit page_cgroup and memcg.

s/By/With/

> Here is a test result. A test program makes page faults onto a file,
> MAP_SHARED and makes each page's page_mapcount(page) > 1, and free
> the range by madvise() and page fault again. =A0This program causes
> 26214400 times of page fault onto a file(size was 1G.) and shows
> shows the cost of mem_cgroup_begin_update_page_stat().

Out of curiosity, what is the performance of the mmap program before
this series?

> Before this patch for mem_cgroup_begin_update_page_stat()
> [kamezawa@bluextal test]$ time ./mmap 1G
>
> real =A0 =A00m21.765s
> user =A0 =A00m5.999s
> sys =A0 =A0 0m15.434s
>
> =A0 =A027.46% =A0 =A0 mmap =A0mmap =A0 =A0 =A0 =A0 =A0 =A0 =A0 [.] reader
> =A0 =A021.15% =A0 =A0 mmap =A0[kernel.kallsyms] =A0[k] page_fault
> =A0 =A0 9.17% =A0 =A0 mmap =A0[kernel.kallsyms] =A0[k] filemap_fault
> =A0 =A0 2.96% =A0 =A0 mmap =A0[kernel.kallsyms] =A0[k] __do_fault
> =A0 =A0 2.83% =A0 =A0 mmap =A0[kernel.kallsyms] =A0[k] __mem_cgroup_begin=
_update_page_stat
>
> After this patch
> [root@bluextal test]# time ./mmap 1G
>
> real =A0 =A00m21.373s
> user =A0 =A00m6.113s
> sys =A0 =A0 0m15.016s
>
> In usual path, calls to __mem_cgroup_begin_update_page_stat() goes away.
>
> Note: we may be able to remove this optimization in future if
> =A0 =A0 =A0we can get pointer to memcg directly from struct page.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: Greg Thelen <gthelen@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
