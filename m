Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5884C6B0023
	for <linux-mm@kvack.org>; Thu,  5 May 2011 18:06:11 -0400 (EDT)
Date: Thu, 5 May 2011 15:06:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] coredump: use task comm instead of (unknown)
Message-Id: <20110505150601.a4457970.akpm@linux-foundation.org>
In-Reply-To: <1304494354-21487-1-git-send-email-jslaby@suse.cz>
References: <4DC0FFAB.1000805@gmail.com>
	<1304494354-21487-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, jirislaby@gmail.com, Alan Cox <alan@lxorguk.ukuu.org.uk>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <andi@firstfloor.org>, John Stultz <john.stultz@linaro.org>

On Wed,  4 May 2011 09:32:34 +0200
Jiri Slaby <jslaby@suse.cz> wrote:

> If we don't know the file corresponding to the binary (i.e. exe_file
> is unknown), use "task->comm (path unknown)" instead of simple
> "(unknown)" as suggested by ak.
> 
> The fallback is the same as %e except it will append "(path unknown)".
> 
> Signed-off-by: Jiri Slaby <jslaby@suse.cz>
> Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Cc: Andi Kleen <andi@firstfloor.org>
> ---
>  fs/exec.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> index 5ee7562..0a4d281 100644
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -1555,7 +1555,7 @@ static int cn_print_exe_file(struct core_name *cn)
>  
>  	exe_file = get_mm_exe_file(current->mm);
>  	if (!exe_file)
> -		return cn_printf(cn, "(unknown)");
> +		return cn_printf(cn, "%s (path unknown)", current->comm);
>  
>  	pathbuf = kmalloc(PATH_MAX, GFP_TEMPORARY);
>  	if (!pathbuf) {

Direct access to current->comm is racy since we added
prctl(PR_SET_NAME).

Hopefully John Stultz will soon be presenting us with a %p modifier for
displaying task_struct.comm.

But we should get this settled pretty promptly as this is a form of
userspace-visible API.  Use get_task_comm() for now.

Also, there's nothing which prevents userspace from rewriting
task->comm to something which contains slashes (this seems bad).  If
that is done, your patch will do Bad Things - it should be modified to
use cn_print_exe_file()'s slash-overwriting codepath.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
