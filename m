Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 164016B0012
	for <linux-mm@kvack.org>; Sat, 11 Jun 2011 14:44:25 -0400 (EDT)
Date: Sat, 11 Jun 2011 20:44:16 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] [BUGFIX] update mm->owner even if no next owner.
Message-ID: <20110611184416.GB3238@redhat.com>
References: <BANLkTikF7=qfXAmrNzyMSmWm7Neh6yMAB8EbBp7oLcfQmrbDjA@mail.gmail.com>
 <20110610091355.2ce38798.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1106091812030.4904@sister.anvils>
 <20110610113311.409bb423.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610121949.622e4629.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610125551.385ea7ed.kamezawa.hiroyu@jp.fujitsu.com>
 <20110610133021.2eaaf0da.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1106101425400.28334@sister.anvils>
 <20110610235442.GA21413@cmpxchg.org>
 <20110611175136.GA31154@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110611175136.GA31154@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Sat, Jun 11, 2011 at 07:51:36PM +0200, Johannes Weiner wrote:
> This is a problem with the patch, but I think Kame's analysis and
> approach to fix it are still correct.

I agree with Kame's analysis too. This explains why removing the
mmap_sem read mode introduced the problem, it was quite some
unexpected subtleness not apparent to the naked eye, as memcg didn't
explicitly relay on mmap_sem but it did implicitly during exit because
of the __khugepaged_exit waiting if we were collapsing an hugepage...

So the fix is safe because the task struct is freed with
delayed_put_task_struct and that won't run until we rcu_read_unlock
after mem_cgroup_from_task.

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
