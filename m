Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B0126828DF
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 19:51:45 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id uo6so332064710pac.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 16:51:45 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id fm8si5803209pab.17.2016.01.12.16.51.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 16:51:45 -0800 (PST)
Received: by mail-pa0-x231.google.com with SMTP id uo6so332064621pac.1
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 16:51:45 -0800 (PST)
Date: Tue, 12 Jan 2016 16:51:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 3/3] oom: Do not try to sacrifice small children
In-Reply-To: <1452632425-20191-4-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1601121646410.28831@chino.kir.corp.google.com>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org> <1452632425-20191-4-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 12 Jan 2016, Michal Hocko wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 8bca0b1e97f7..b5c0021c6462 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -721,8 +721,16 @@ try_to_sacrifice_child(struct oom_control *oc, struct task_struct *victim,
>  	if (!child_victim)
>  		goto out;
>  
> -	put_task_struct(victim);
> -	victim = child_victim;
> +	/*
> +	 * Protecting the parent makes sense only if killing the child
> +	 * would release at least some memory (at least 1MB).
> +	 */
> +	if (K(victim_points) >= 1024) {
> +		put_task_struct(victim);
> +		victim = child_victim;
> +	} else {
> +		put_task_struct(child_victim);
> +	}
>  
>  out:
>  	return victim;

The purpose of sacrificing a child has always been to prevent a process 
that has been running with a substantial amount of work done from being 
terminated and losing all that work if it can be avoided.  This happens a 
lot: imagine a long-living front end client forking a child which simply 
collects stats and malloc information at a regular intervals and writes 
them out to disk or over the network.  These processes may be quite small, 
and we're willing to happily sacrifice them if it will save the parent.  
This was, and still is, the intent of the sacrifice in the first place.

We must be able to deal with oom victims that are very small, since 
userspace has complete control in prioritizing these processes in the 
first place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
