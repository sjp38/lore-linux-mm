Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 582E96B01D9
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 16:00:38 -0400 (EDT)
Date: Tue, 8 Jun 2010 13:00:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 04/18] oom: PF_EXITING check should take mm into account
Message-Id: <20100608130030.0ed9f4f4.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061523520.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061523520.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:15 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> From: Oleg Nesterov <oleg@redhat.com>
> 
> select_bad_process() checks PF_EXITING to detect the task which is going
> to release its memory, but the logic is very wrong.
> 
> 	- a single process P with the dead group leader disables
> 	  select_bad_process() completely, it will always return
> 	  ERR_PTR() while P can live forever
> 
> 	- if the PF_EXITING task has already released its ->mm
> 	  it doesn't make sense to expect it is goiing to free
> 	  more memory (except task_struct/etc)
> 
> Change the code to ignore the PF_EXITING tasks without ->mm.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -300,7 +300,7 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  		 * the process of exiting and releasing its resources.
>  		 * Otherwise we could get an easy OOM deadlock.
>  		 */
> -		if (p->flags & PF_EXITING) {
> +		if ((p->flags & PF_EXITING) && p->mm) {
>  			if (p != current)
>  				return ERR_PTR(-1UL);

Looks good to me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
