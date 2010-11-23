Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2B9F76B0088
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 02:17:00 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAN7GvaI028355
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Nov 2010 16:16:57 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5ACE545DE51
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AB1645DE4C
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:57 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CF321DB8012
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B407B1DB8015
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 16:16:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUG?] [Ext4] INFO: suspicious rcu_dereference_check() usage
In-Reply-To: <20101121173726.GG23423@thunk.org>
References: <20101121153949.GD20947@barrios-desktop> <20101121173726.GG23423@thunk.org>
Message-Id: <20101122174516.E24A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Nov 2010 16:16:56 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ted Ts'o <tytso@mit.edu>, Minchan Kim <minchan.kim@gmail.com>, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andreas Dilger <adilger.kernel@dilger.ca>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Eric Sandeen <sandeen@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> On Mon, Nov 22, 2010 at 12:39:49AM +0900, Minchan Kim wrote:
> > 
> > I think it's no problem. 
> > 
> > That's because migration always holds lock_page on the file page.
> > So the page couldn't remove from radix. 
> 
> It may be "ok" in that it won't cause a race, but it still leaves an
> unsightly warning if LOCKDEP is enabled, and LOCKDEP warnings will
> cause /proc_lock_stat to be disabled.  So I think it still needs to be
> fixed by adding rcu_read_lock()/rcu_read_unlock() to
> migrate_page_move_mapping().

Hi Ted,

Current mmotm has following patch and I think it should be fixed your
issue.

Thanks.




From: Zeng Zhaoming <zengzm.kernel@gmail.com>

find_task_by_vpid() should be protected by rcu_read_lock(), to prevent
free_pid() reclaiming pid.

Signed-off-by: Zeng Zhaoming <zengzm.kernel@gmail.com>
Cc: "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/mempolicy.c |    3 +++
 1 file changed, 3 insertions(+)

diff -puN mm/mempolicy.c~mm-mempolicyc-add-rcu-read-lock-to-protect-pid-structure mm/mempolicy.c
--- a/mm/mempolicy.c~mm-mempolicyc-add-rcu-read-lock-to-protect-pid-structure
+++ a/mm/mempolicy.c
@@ -1307,15 +1307,18 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pi
                goto out;

        /* Find the mm_struct */
+       rcu_read_lock();
        read_lock(&tasklist_lock);
        task = pid ? find_task_by_vpid(pid) : current;
        if (!task) {
                read_unlock(&tasklist_lock);
+               rcu_read_unlock();
                err = -ESRCH;
                goto out;
        }
        mm = get_task_mm(task);
        read_unlock(&tasklist_lock);
+       rcu_read_unlock();


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
