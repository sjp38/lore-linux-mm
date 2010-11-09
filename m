Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 27F866B00F1
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 06:21:11 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA9BL8MO014467
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 20:21:09 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AD1DB45DE52
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 20:21:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A46345DE50
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 20:21:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 59EC61DB8043
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 20:21:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DBEAE08001
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 20:21:08 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/1][2nd resend] sys_unshare: remove the dead CLONE_THREAD/SIGHAND/VM code
In-Reply-To: <20101105174343.GB19469@redhat.com>
References: <20101105174142.GA19469@redhat.com> <20101105174343.GB19469@redhat.com>
Message-Id: <20101109201742.BCA1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Nov 2010 20:21:07 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roland McGrath <roland@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, JANAK DESAI <janak@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> Cleanup: kill the dead code which does nothing but complicates the code
> and confuses the reader.
> 
> sys_unshare(CLONE_THREAD/SIGHAND/VM) is not really implemented, and I doubt
> very much it will ever work. At least, nobody even tried since the original
> "unshare system call -v5: system call handler function" commit
> 99d1419d96d7df9cfa56bc977810be831bd5ef64 was applied more than 4 years ago.
> 
> And the code is not consistent. unshare_thread() always fails unconditionally,
> while unshare_sighand() and unshare_vm() pretend to work if there is nothing
> to unshare.
> 
> Remove unshare_thread(), unshare_sighand(), unshare_vm() helpers and related
> variables and add a simple CLONE_THREAD | CLONE_SIGHAND| CLONE_VM check into
> check_unshare_flags().
> 
> Also, move the "CLONE_NEWNS needs CLONE_FS" check from check_unshare_flags()
> to sys_unshare(). This looks more consistent and matches the similar
> do_sysvsem check in sys_unshare().
> 
> Note: with or without this patch "atomic_read(mm->mm_users) > 1" can give
> a false positive due to get_task_mm().
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> Acked-by: Roland McGrath <roland@redhat.com>
> ---
> 
>  kernel/fork.c |  123 +++++++++++-----------------------------------------------
>  1 file changed, 25 insertions(+), 98 deletions(-)
> 
> --- 2.6.37/kernel/fork.c~unshare-killcrap	2010-11-05 18:03:28.000000000 +0100
> +++ 2.6.37/kernel/fork.c	2010-11-05 18:09:52.000000000 +0100
> @@ -1522,38 +1522,24 @@ void __init proc_caches_init(void)
>  }
>  
>  /*
> - * Check constraints on flags passed to the unshare system call and
> - * force unsharing of additional process context as appropriate.
> + * Check constraints on flags passed to the unshare system call.
>   */
> -static void check_unshare_flags(unsigned long *flags_ptr)
> +static int check_unshare_flags(unsigned long unshare_flags)
>  {
> +	if (unshare_flags & ~(CLONE_THREAD|CLONE_FS|CLONE_NEWNS|CLONE_SIGHAND|
> +				CLONE_VM|CLONE_FILES|CLONE_SYSVSEM|
> +				CLONE_NEWUTS|CLONE_NEWIPC|CLONE_NEWNET))
> +		return -EINVAL;

Please put WARN_ON_ONCE() explicitly. That's good way to find hidden
user if exist and getting better bug report.

And, I've reveied this patch and I've found no fault. but I will not put
my ack because I think I haven't understand original intention perhaps.

Anyway, thanks Oleg.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
