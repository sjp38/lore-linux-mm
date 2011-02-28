Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E7C2F8D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:56:10 -0500 (EST)
Date: Mon, 28 Feb 2011 15:55:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] cpuset: Add a missing unlock in cpuset_write_resmask()
Message-Id: <20110228155524.6d7563e0.akpm@linux-foundation.org>
In-Reply-To: <4D6601B2.1090207@cn.fujitsu.com>
References: <4D6601B2.1090207@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, =?UTF-8?Q?=E7=BC=AA_=E5=8B=B0?= <miaox@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, 24 Feb 2011 14:58:58 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> Don't forget to release cgroup_mutex if alloc_trial_cpuset() fails.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> ---
>  kernel/cpuset.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
> index 1ca786a..6272503 100644
> --- a/kernel/cpuset.c
> +++ b/kernel/cpuset.c
> @@ -1561,8 +1561,10 @@ static int cpuset_write_resmask(struct cgroup *cgrp, struct cftype *cft,
>  		return -ENODEV;
>  
>  	trialcs = alloc_trial_cpuset(cs);
> -	if (!trialcs)
> +	if (!trialcs) {
> +		cgroup_unlock();
>  		return -ENOMEM;
> +	}
>  
>  	switch (cft->private) {
>  	case FILE_CPULIST:

It would be better to avoid multiple returns - it leads to more
maintainable code and often shorter code:

--- a/kernel/cpuset.c~cpuset-add-a-missing-unlock-in-cpuset_write_resmask-fix
+++ a/kernel/cpuset.c
@@ -1562,8 +1562,8 @@ static int cpuset_write_resmask(struct c
 
 	trialcs = alloc_trial_cpuset(cs);
 	if (!trialcs) {
-		cgroup_unlock();
-		return -ENOMEM;
+		retval = -ENOMEM;
+		goto out;
 	}
 
 	switch (cft->private) {
@@ -1579,6 +1579,7 @@ static int cpuset_write_resmask(struct c
 	}
 
 	free_trial_cpuset(trialcs);
+out:
 	cgroup_unlock();
 	return retval;
 }
_

also, alloc_trial_cpuset() is a fairly slow-looking function. 
cpuset_write_resmask() could run alloc_trial_cpuset() before running
cgroup_lock_live_group(), thereby reducing lock hold times.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
