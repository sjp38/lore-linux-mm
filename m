Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1114F6B005A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 19:33:40 -0400 (EDT)
Date: Wed, 5 Aug 2009 16:33:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] oom: fix oom_adjust_write() input sanity check.
Message-Id: <20090805163325.14a4a77f.akpm@linux-foundation.org>
In-Reply-To: <20090804192721.6A49.A69D9226@jp.fujitsu.com>
References: <20090804191031.6A3D.A69D9226@jp.fujitsu.com>
	<20090804192721.6A49.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue,  4 Aug 2009 19:28:03 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Subject: [PATCH] oom: fix oom_adjust_write() input sanity check.
> 
> Andrew Morton pointed out oom_adjust_write() has very strange EIO
> and new line handling. this patch fixes it.
> 
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Paul Menage <menage@google.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Rik van Riel <riel@redhat.com>,
> Cc: Andrew Morton <akpm@linux-foundation.org>,
> ---
>  fs/proc/base.c |   12 +++++++-----
>  1 file changed, 7 insertions(+), 5 deletions(-)
> 
> Index: b/fs/proc/base.c
> ===================================================================
> --- a/fs/proc/base.c
> +++ b/fs/proc/base.c
> @@ -1033,12 +1033,15 @@ static ssize_t oom_adjust_write(struct f
>  		count = sizeof(buffer) - 1;
>  	if (copy_from_user(buffer, buf, count))
>  		return -EFAULT;
> +
> +	strstrip(buffer);

+1 for using strstrip()

-1 for using it wrongly.  If it strips leading whitespace it will
return a new address for the caller to use.

We could mark it __must_check() to prevent reoccurences of this error.

How does this look?

--- a/fs/proc/base.c~oom-fix-oom_adjust_write-input-sanity-check-fix
+++ a/fs/proc/base.c
@@ -1033,8 +1033,7 @@ static ssize_t oom_adjust_write(struct f
 	if (copy_from_user(buffer, buf, count))
 		return -EFAULT;
 
-	strstrip(buffer);
-	oom_adjust = simple_strtol(buffer, &end, 0);
+	oom_adjust = simple_strtol(strstrip(buffer), &end, 0);
 	if (*end)
 		return -EINVAL;
 	if ((oom_adjust < OOM_ADJUST_MIN || oom_adjust > OOM_ADJUST_MAX) &&


>  	oom_adjust = simple_strtol(buffer, &end, 0);

That should've used strict_strtoul() but it's too late to fix it now.

> +	if (*end)
> +		return -EINVAL;
>  	if ((oom_adjust < OOM_ADJUST_MIN || oom_adjust > OOM_ADJUST_MAX) &&
>  	     oom_adjust != OOM_DISABLE)
>  		return -EINVAL;
> -	if (*end == '\n')
> -		end++;
> +
>  	task = get_proc_task(file->f_path.dentry->d_inode);
>  	if (!task)
>  		return -ESRCH;
> @@ -1057,9 +1060,8 @@ static ssize_t oom_adjust_write(struct f
>  	task->signal->oom_adj = oom_adjust;
>  	unlock_task_sighand(task, &flags);
>  	put_task_struct(task);
> -	if (end - buffer == 0)
> -		return -EIO;
> -	return end - buffer;
> +
> +	return count;
>  }
>  
>  static const struct file_operations proc_oom_adjust_operations = {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
