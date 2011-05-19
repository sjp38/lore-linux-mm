Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D19636B0011
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:45:27 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 1DF713EE0B5
	for <linux-mm@kvack.org>; Thu, 19 May 2011 09:45:21 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0338445DE58
	for <linux-mm@kvack.org>; Thu, 19 May 2011 09:45:21 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DE20A45DE5A
	for <linux-mm@kvack.org>; Thu, 19 May 2011 09:45:20 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D0887EF8001
	for <linux-mm@kvack.org>; Thu, 19 May 2011 09:45:20 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D037E08002
	for <linux-mm@kvack.org>; Thu, 19 May 2011 09:45:20 +0900 (JST)
Date: Thu, 19 May 2011 09:38:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH mmotm] add the pagefault count into memcg stats: shmem
 fix
Message-Id: <20110519093839.38820e23.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1105181102050.4087@sister.anvils>
References: <alpine.LSU.2.00.1105171120220.29593@sister.anvils>
	<20110518144349.a44ae926.nishimura@mxp.nes.nec.co.jp>
	<alpine.LSU.2.00.1105181102050.4087@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org

On Wed, 18 May 2011 11:25:48 -0700 (PDT)
Hugh Dickins <hughd@google.com> wrote:

> On Wed, 18 May 2011, Daisuke Nishimura wrote:
> > On Tue, 17 May 2011 11:24:40 -0700 (PDT)
> > Hugh Dickins <hughd@google.com> wrote:
> > 
> > > mem_cgroup_count_vm_event() should update the PGMAJFAULT count for the
> > > target mm, not for current mm (but of course they're usually the same).
> > > 
> > hmm, why ?
> > In shmem_getpage(), we charge the page to the memcg where current mm belongs to,
> 
> (In the case when it's this fault which is creating the page.
> Just as when filemap_fault() reads in the page, add_to_page_cache
> will charge it to the current->mm's memcg, yes.  Arguably correct.)
> 
> > so I think counting vm events of the memcg is right.
> 
> It should be consistent with which task gets the maj_flt++, and
> it should be consistent with filemap_fault(), and it should be a
> subset of what's counted by mem_cgroup_count_vm_event(mm, PGFAULT).
> 
> In each case, those work on target mm rather than current->mm.
> 

Hmm, I have no strong opinion on this but yes, it makes sense to account
PGMAJFLT to the process whose mm->maj_flt++. BTW,  do you think memcg should
account shmem into vma->vm_mm rather than current->mm ? When vma->vm_mm
is different from current ? At get_user_pages() + MAJFLT ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
