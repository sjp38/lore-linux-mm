Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f47.google.com (mail-bk0-f47.google.com [209.85.214.47])
	by kanga.kvack.org (Postfix) with ESMTP id 998526B0095
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 12:15:41 -0500 (EST)
Received: by mail-bk0-f47.google.com with SMTP id w10so337311bkz.34
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 09:15:40 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id nr7si8375559bkb.71.2014.02.25.09.15.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 09:15:39 -0800 (PST)
Date: Tue, 25 Feb 2014 12:15:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] ksm: Expose configuration via sysctl
Message-ID: <20140225171528.GJ4407@cmpxchg.org>
References: <1393284484-27637-1-git-send-email-agraf@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1393284484-27637-1-git-send-email-agraf@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Graf <agraf@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, Feb 25, 2014 at 12:28:04AM +0100, Alexander Graf wrote:
> Configuration of tunables and Linux virtual memory settings has traditionally
> happened via sysctl. Thanks to that there are well established ways to make
> sysctl configuration bits persistent (sysctl.conf).
> 
> KSM introduced a sysfs based configuration path which is not covered by user
> space persistent configuration frameworks.
> 
> In order to make life easy for sysadmins, this patch adds all access to all
> KSM tunables via sysctl as well. That way sysctl.conf works for KSM as well,
> giving us a streamlined way to make KSM configuration persistent.
> 
> Reported-by: Sasche Peilicke <speilicke@suse.com>
> Signed-off-by: Alexander Graf <agraf@suse.de>
> ---
>  kernel/sysctl.c |   10 +++++++
>  mm/ksm.c        |   78 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 88 insertions(+), 0 deletions(-)
> 
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 332cefc..2169a00 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -217,6 +217,9 @@ extern struct ctl_table random_table[];
>  #ifdef CONFIG_EPOLL
>  extern struct ctl_table epoll_table[];
>  #endif
> +#ifdef CONFIG_KSM
> +extern struct ctl_table ksm_table[];
> +#endif
>  
>  #ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
>  int sysctl_legacy_va_layout;
> @@ -1279,6 +1282,13 @@ static struct ctl_table vm_table[] = {
>  	},
>  
>  #endif /* CONFIG_COMPACTION */
> +#ifdef CONFIG_KSM
> +	{
> +		.procname	= "ksm",
> +		.mode		= 0555,
> +		.child		= ksm_table,
> +	},
> +#endif

ksm can be a module, so this won't work.

Can we make those controls proper module parameters instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
