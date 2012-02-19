Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id B23616B002C
	for <linux-mm@kvack.org>; Sun, 19 Feb 2012 18:54:10 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7E1C33EE0C1
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 08:54:08 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 62C6745DE55
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 08:54:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 356F945DE58
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 08:54:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 245691DB8055
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 08:54:08 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D237A1DB8050
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 08:54:07 +0900 (JST)
Date: Mon, 20 Feb 2012 08:52:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/6] memcg: remove PCG_FILE_MAPPED
Message-Id: <20120220085238.606dc435.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CAJd=RBD=U1Uy_MnO9wL_Ag6M7tYUOfs=aSXV+sJabHWRNSSudQ@mail.gmail.com>
References: <20120217182426.86aebfde.kamezawa.hiroyu@jp.fujitsu.com>
	<20120217182818.f3e7fe28.kamezawa.hiroyu@jp.fujitsu.com>
	<20120218133904.GA1678@cmpxchg.org>
	<CAJd=RBD=U1Uy_MnO9wL_Ag6M7tYUOfs=aSXV+sJabHWRNSSudQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>

On Sat, 18 Feb 2012 22:43:58 +0800
Hillf Danton <dhillf@gmail.com> wrote:

> On Sat, Feb 18, 2012 at 9:39 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Fri, Feb 17, 2012 at 06:28:18PM +0900, KAMEZAWA Hiroyuki wrote:
> >> @@ -2559,7 +2555,7 @@ static int mem_cgroup_move_account(struct page *page,
> >>
> >> A  A  A  move_lock_mem_cgroup(from, &flags);
> >>
> >> - A  A  if (PageCgroupFileMapped(pc)) {
> >> + A  A  if (page_mapped(page)) {
> >
> > As opposed to update_page_stat(), this runs against all types of
> > pages, so I think it should be
> >
> > A  A  A  A if (!PageAnon(page) && page_mapped(page))
> >
> > instead.
> >
> Perhaps the following helper or similar needed,
> along with page_mapped()
> 
> static inline bool page_is_file_mapping(struct page *page)
> {
> 	struct address_space *mapping = page_mapping(page);
> 
> 	return mapping && mapping != &swapper_space &&
> 		((unsigned long)mapping & PAGE_MAPPING_FLAGS) == 0;
> }
> 

Ah, thank you. I'll post a fix soon.

Ragard,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
