Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B625E8D0001
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 07:28:54 -0400 (EDT)
From: pageexec@freemail.hu
Date: Mon, 25 Oct 2010 13:28:27 +0200
MIME-Version: 1.0
Subject: Re: [resend][PATCH 4/4] oom: don't ignore rss in nascent mm
Reply-to: pageexec@freemail.hu
Message-ID: <4CC569DB.17734.314BBE7A@pageexec.freemail.hu>
In-reply-to: <20101025122914.9173.A69D9226@jp.fujitsu.com>
References: <20101025122538.9167.A69D9226@jp.fujitsu.com>, <20101025122914.9173.A69D9226@jp.fujitsu.com>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Oleg Nesterov <oleg@redhat.com>, Roland McGrath <roland@redhat.com>
List-ID: <linux-mm.kvack.org>

On 25 Oct 2010 at 12:29, KOSAKI Motohiro wrote:

hi,

i've got a few comments/questions about the whole approach, see them inline.

> index 0644a15..a85b196 100644
> --- a/fs/compat.c
> +++ b/fs/compat.c
> @@ -1567,8 +1567,10 @@ int compat_do_execve(char * filename,
>  	return retval;
>  
>  out:
> -	if (bprm->mm)
> +	if (bprm->mm) {
> +		set_exec_mm(NULL);
>  		mmput(bprm->mm);
> +	}
>  
>  out_file:
>  	if (bprm->file) {
> diff --git a/fs/exec.c b/fs/exec.c
> index 94dabd2..2395d10 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -347,6 +347,8 @@ int bprm_mm_init(struct linux_binprm *bprm)
>  	if (err)
>  		goto err;
>  
> +	set_exec_mm(mm);
> +
>  	return 0;
>  
>  err:
> @@ -1416,8 +1428,10 @@ int do_execve(const char * filename,
>  	return retval;
>  
>  out:
> -	if (bprm->mm)
> +	if (bprm->mm) {
> +		set_exec_mm(NULL);
>  		mmput (bprm->mm);
> +	}
>  
>  out_file:
>  	if (bprm->file) {

what happens when two (or more) threads in the same process call execve? the
above set_exec_mm calls will race (de_thread doesn't happen until much later
in execve) and overwrite each other's ->in_exec_mm which will still lead to
problems since there will be at most one temporary mm accounted for in the
oom killer.

[update: since i don't seem to have been cc'd on the other patch that
serializes execve, the above point is moot ;)]

worse, even if each temporary mm was tracked separately there'd still be a
race where the oom killer can get triggered with the culprit thread long
gone (and reset ->in_exec_mm) and never to be found, so the oom killer would
find someone else as guilty.

now all this leads me to suggest a simpler solution, at least for the first
problem mentioned above (i don't know what to do with the second one yet as
it seems to be a generic issue with the oom killer, probably it should verify
the oom situation once again after it took the task_list lock).

[update: while the serialized execve solves the first problem, i still think
that my idea is simpler and worth considering, so i leave it here even if for
just documentation purposes ;)]

given that all the oom killer needs from the mm struct is either ->total_pages
(in .35 and before, so be careful with the stable backport) or some ->rss_stat
counters, wouldn't it be much easier to simply transfer the bprm->mm counters
into current->mm for the duration of the execve (say, add them in get_arg_page
and remove them when bprm->mm is mmput in the do_execve failure path, etc)? the
transfer can be either to the existing counters or to new ones (obviously in
the latter case the oom code needs a small change to take the new counters into
account as well).

cheers,

 PaX Team

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
