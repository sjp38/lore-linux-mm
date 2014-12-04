Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 868EF6B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 12:18:25 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y19so23238231wgg.28
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 09:18:25 -0800 (PST)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id e9si60778589wiv.77.2014.12.04.09.18.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 09:18:24 -0800 (PST)
Received: by mail-wg0-f47.google.com with SMTP id n12so23414545wgh.34
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 09:18:24 -0800 (PST)
Date: Thu, 4 Dec 2014 18:18:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 2/2] OOM, PM: make OOM detection in the freezer path
 raceless
Message-ID: <20141204171822.GE25001@dhcp22.suse.cz>
References: <20141118210833.GE23640@dhcp22.suse.cz>
 <1416345006-8284-1-git-send-email-mhocko@suse.cz>
 <1416345006-8284-2-git-send-email-mhocko@suse.cz>
 <20141202220804.GS10918@htj.dyndns.org>
 <20141204141623.GA25001@dhcp22.suse.cz>
 <20141204144454.GB15219@htj.dyndns.org>
 <20141204165601.GD25001@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141204165601.GD25001@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-pm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>

On Thu 04-12-14 17:56:01, Michal Hocko wrote:
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1d55ab12792f..032be9d2a239 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -408,7 +408,7 @@ static void dump_header(struct task_struct *p, gfp_t gfp_mask, int order,
>   * Number of OOM victims in flight
>   */
>  static atomic_t oom_victims = ATOMIC_INIT(0);
> -static DECLARE_COMPLETION(oom_victims_wait);
> +static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
>  
>  bool oom_killer_disabled __read_mostly;
>  static DECLARE_RWSEM(oom_sem);
> @@ -435,7 +435,7 @@ void unmark_tsk_oom_victim(void)
>  	 * is nobody who cares.
>  	 */
>  	if (!atomic_dec_return(&oom_victims) && oom_killer_disabled)
> -		complete_all(&oom_victims_wait);
> +		wake_up_all(&oom_victims_wait);
>  	up_read(&oom_sem);
>  }
>  
> @@ -464,16 +464,11 @@ bool oom_killer_disable(void)
>  		return false;
>  	}
>  
> -	/* unmark_tsk_oom_victim is calling complete_all */
> -	if (!oom_killer_disable)
> -		reinit_completion(&oom_victims_wait);
> -
>  	oom_killer_disabled = true;
> -	count = atomic_read(&oom_victims);
>  	up_write(&oom_sem);
>  
>  	if (count)

whithout this count test obviously

> -		wait_for_completion(&oom_victims_wait);
> +		wait_event(oom_victims_wait, atomic_read(&oom_victims));
>  
>  	return true;
>  }
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
