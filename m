Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C66146B0012
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:28:53 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p4J0SkHV007594
	for <linux-mm@kvack.org>; Wed, 18 May 2011 17:28:49 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by wpaz29.hot.corp.google.com with ESMTP id p4J0Rv14014184
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 May 2011 17:28:45 -0700
Received: by pzk9 with SMTP id 9so1225440pzk.5
        for <linux-mm@kvack.org>; Wed, 18 May 2011 17:28:45 -0700 (PDT)
Date: Wed, 18 May 2011 17:28:46 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH mmotm] add the pagefault count into memcg stats: shmem
 fix
In-Reply-To: <BANLkTi=4YY6aJk+ZLiiF7UX73LZD=7+W2Q@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1105181709540.1282@sister.anvils>
References: <alpine.LSU.2.00.1105171120220.29593@sister.anvils> <BANLkTi=4YY6aJk+ZLiiF7UX73LZD=7+W2Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org

On Thu, 19 May 2011, Minchan Kim wrote:
> On Wed, May 18, 2011 at 3:24 AM, Hugh Dickins <hughd@google.com> wrote:
> > mem_cgroup_count_vm_event() should update the PGMAJFAULT count for the
> > target mm, not for current mm (but of course they're usually the same).
> >
> > We don't know the target mm in shmem_getpage(), so do it at the outer
> > level in shmem_fault(); and it's easier to follow if we move the
> > count_vm_event(PGMAJFAULT) there too.
> >
> > Hah, it was using __count_vm_event() before, sneaking that update into
> > the unpreemptible section under info->lock: well, it comes to the same
> > on x86 at least, and I still think it's best to keep these together.
> >
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> 
> It's good to me but I have a nitpick.
> 
> You are changing behavior a bit.
> Old behavior is to account FAULT although the operation got failed.
> But new one is to not account it.
> I think we have to account it regardless of whether it is successful or not.
> That's because it is fact fault happens.

That's a good catch: something I didn't think of at all.

However, it looks as if the patch remains correct, and is fixing
a bug (or inconsistency) that we hadn't noticed before.

If you look through filemap_fault() or do_swap_page() (or even
ncp_file_mmap_fault(), though I don't take that one as canonical!),
they clearly do not count the major fault on error (except in the
case where VM_FAULT_MAJOR needs VM_FAULT_RETRY, then gets
VM_FAULT_ERROR on the retry).

So, shmem.c was the odd one out before.  If you feel very strongly
about it ("it is fact fault happens") you could submit a patch to
change them all - but I think just leave them as is.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
