Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 83A226B0044
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 04:18:04 -0400 (EDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
Date: Sun, 29 Apr 2012 01:22:06 -0700
In-Reply-To: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com> (Sasha
	Levin's message of "Sun, 29 Apr 2012 08:45:24 +0200")
Message-ID: <m1haw33q35.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: Re: [PATCH 01/14] sysctl: provide callback for write into ctl_table entry
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: viro@zeniv.linux.org.uk, rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com, a.p.zijlstra@chello.nl, paulus@samba.org, acme@ghostprotocols.net, james.l.morris@oracle.com, akpm@linux-foundation.org, tglx@linutronix.de, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org

Sasha Levin <levinsasha928@gmail.com> writes:

> Provide a callback that will be called when writing to a ctl_table
> entry after the user input has been validated.
>
> This will simplify user input checks since now it will be possible to
> remove them out of the proc_handler.

Ick No.

You are simplifying things by taking updates out of locks, and
introducing races.

Your naming of the callback "callback" is much too generic.

I think the current function call mechanism of sysctl can be improved
but I don't think you have come up with the right combination of things.

Eric


> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> ---
>  fs/proc/proc_sysctl.c  |    4 ++++
>  include/linux/sysctl.h |    1 +
>  2 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
> index 21d836f..190db28 100644
> --- a/fs/proc/proc_sysctl.c
> +++ b/fs/proc/proc_sysctl.c
> @@ -507,6 +507,10 @@ static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
>  	error = table->proc_handler(table, write, buf, &res, ppos);
>  	if (!error)
>  		error = res;
> +
> +	if (!error && write && table->callback)
> +		error = table->callback();
> +
>  out:
>  	sysctl_head_finish(head);
>  
> diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
> index c34b4c8..27c14cf 100644
> --- a/include/linux/sysctl.h
> +++ b/include/linux/sysctl.h
> @@ -1022,6 +1022,7 @@ struct ctl_table
>  	struct ctl_table_poll *poll;
>  	void *extra1;
>  	void *extra2;
> +	int (*callback)(void);		/* Called when entry is written to */
>  };
>  
>  struct ctl_node {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
