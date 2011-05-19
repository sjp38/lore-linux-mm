Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD6C6B0011
	for <linux-mm@kvack.org>; Wed, 18 May 2011 21:54:41 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p4J1sdLx030206
	for <linux-mm@kvack.org>; Wed, 18 May 2011 18:54:39 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by kpbe16.cbf.corp.google.com with ESMTP id p4J1scog006869
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 May 2011 18:54:38 -0700
Received: by pzk37 with SMTP id 37so1261533pzk.15
        for <linux-mm@kvack.org>; Wed, 18 May 2011 18:54:37 -0700 (PDT)
Date: Wed, 18 May 2011 18:54:41 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH mmotm] add the pagefault count into memcg stats: shmem
 fix
In-Reply-To: <20110519093839.38820e23.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1105181836110.1690@sister.anvils>
References: <alpine.LSU.2.00.1105171120220.29593@sister.anvils> <20110518144349.a44ae926.nishimura@mxp.nes.nec.co.jp> <alpine.LSU.2.00.1105181102050.4087@sister.anvils> <20110519093839.38820e23.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org

On Thu, 19 May 2011, KAMEZAWA Hiroyuki wrote:
> On Wed, 18 May 2011 11:25:48 -0700 (PDT)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > On Wed, 18 May 2011, Daisuke Nishimura wrote:
> > > On Tue, 17 May 2011 11:24:40 -0700 (PDT)
> > > Hugh Dickins <hughd@google.com> wrote:
> > > 
> > > > mem_cgroup_count_vm_event() should update the PGMAJFAULT count for the
> > > > target mm, not for current mm (but of course they're usually the same).
> > > > 
> > > hmm, why ?
> > > In shmem_getpage(), we charge the page to the memcg where current mm belongs to,
> > 
> > (In the case when it's this fault which is creating the page.
> > Just as when filemap_fault() reads in the page, add_to_page_cache
> > will charge it to the current->mm's memcg, yes.  Arguably correct.)
> > 
> > > so I think counting vm events of the memcg is right.
> > 
> > It should be consistent with which task gets the maj_flt++, and
> > it should be consistent with filemap_fault(), and it should be a
> > subset of what's counted by mem_cgroup_count_vm_event(mm, PGFAULT).
> > 
> > In each case, those work on target mm rather than current->mm.
> > 
> 
> Hmm, I have no strong opinion on this but yes, it makes sense to account
> PGMAJFLT to the process whose mm->maj_flt++.

mm->maj_flt++ would be yet another story!  But it's tsk->maj_flt++.

> BTW,  do you think memcg should
> account shmem into vma->vm_mm rather than current->mm ? When vma->vm_mm
> is different from current ? At get_user_pages() + MAJFLT ?

If what we have at present works well enough, I don't think we should
risk breaking it with a funny change like that.

Is there a reason to treat shmem differently from filemap there?
You can argue that if it's shm then yes, but if it's tmpfs then no.

I suppose shmem.c does usually know the difference (by VM_NORESERVE),
but does not export it; and I'd prefer to keep it that way.

Unless we've got a real bug to fix here, let's not mess with it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
