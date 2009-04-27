Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4B96B00B3
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 12:15:28 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3RGCWoO011992
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 10:12:32 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3RGFLVF038918
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 10:15:21 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3RGFKsf017335
	for <linux-mm@kvack.org>; Mon, 27 Apr 2009 10:15:21 -0600
Subject: Re: [PATCH] Display 0 in meminfo for Committed_AS when value
	underflows
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1240848620-16751-1-git-send-email-ebmunson@us.ibm.com>
References: <1240848620-16751-1-git-send-email-ebmunson@us.ibm.com>
Content-Type: text/plain
Date: Mon, 27 Apr 2009 09:15:14 -0700
Message-Id: <1240848914.29485.52.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@csn.ul.ie, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-04-27 at 17:10 +0100, Eric B Munson wrote:
> Splitting this patch from the chunk that addresses the cause of the underflow
> because the solution still requires some discussion.
> 
> Dave Hansen reported that under certain cirumstances the Committed_AS value
> can underflow which causes extremely large numbers to be displayed in
> meminfo.  This patch adds an underflow check to meminfo_proc_show() for the
> Committed_AS value.  Most fields in /proc/meminfo already have an underflow
> check, this brings Committed_AS into line.

Yeah, this is the right fix for now until we can iron out the base
issues.  Eric, I think this may also be a candidate for -stable.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
> ---
>  fs/proc/meminfo.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 74ea974..facb9fb 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -22,7 +22,7 @@ void __attribute__((weak)) arch_report_meminfo(struct seq_file *m)
>  static int meminfo_proc_show(struct seq_file *m, void *v)
>  {
>  	struct sysinfo i;
> -	unsigned long committed;
> +	long committed;
>  	unsigned long allowed;
>  	struct vmalloc_info vmi;
>  	long cached;
> @@ -36,6 +36,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>  	si_meminfo(&i);
>  	si_swapinfo(&i);
>  	committed = atomic_long_read(&vm_committed_space);
> +	if (committed < 0)
> +		committed = 0;
>  	allowed = ((totalram_pages - hugetlb_total_pages())
>  		* sysctl_overcommit_ratio / 100) + total_swap_pages;
> 
-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
