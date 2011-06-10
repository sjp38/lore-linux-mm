Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 072276B0012
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 19:54:58 -0400 (EDT)
Date: Sat, 11 Jun 2011 01:54:42 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] [BUGFIX] update mm->owner even if no next owner.
Message-ID: <20110610235442.GA21413@cmpxchg.org>
References: <20110609212956.GA2319@redhat.com>
 <BANLkTikCfWhoLNK__ringzy7KjKY5ZEtNb3QTuX1jJ53wNNysA@mail.gmail.com>
 <BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com>
 <20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1106091812030.4904@sister.anvils>
 <20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1106101425400.28334@sister.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1106101425400.28334@sister.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Fri, Jun 10, 2011 at 02:49:35PM -0700, Hugh Dickins wrote:
> On Fri, 10 Jun 2011, KAMEZAWA Hiroyuki wrote:
> > 
> > I think this can be a fix. 
> 
> Sorry, I think not: I've not digested your rationale,
> but three things stand out:
> 
> 1. Why has this only just started happening?  I may not have run that
>    test on 3.0-rc1, but surely I ran it for hours with 2.6.39;
>    maybe not with khugepaged, but certainly with ksmd.
> 
> 2. Your hunk below:
> > -	if (!mm_need_new_owner(mm, p))
> > +	if (!mm_need_new_owner(mm, p)) {
> > +		rcu_assign_pointer(mm->owner, NULL);
>    is now setting mm->owner to NULL at times when we were sure it did not
>    need updating before (task is not the owner): you're damaging mm->owner.
> 
> 3. There's a patch from Andrea in 3.0-rc1 which looks very likely to be
>    relevant, 692e0b35427a "mm: thp: optimize memcg charge in khugepaged".
>    I'll try reproducing without that tonight (I crashed in 20 minutes
>    this morning, so it's not too hard).

It looks likely.  This change moved the memcg charge out of the
mmap_sem read section, which kept the last task of the mm from
exiting:

	do_exit
	  exit_mm
	    mmput
	      khugepaged_exit
	        down_write(&mm->mmap_sem);
		up_write(&mm->mmap_sem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
