Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 86A686B026B
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 09:27:09 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 191so2567314pgd.0
        for <linux-mm@kvack.org>; Wed, 01 Nov 2017 06:27:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r28si1068159pfk.101.2017.11.01.06.27.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Nov 2017 06:27:03 -0700 (PDT)
Date: Wed, 1 Nov 2017 14:27:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm,oom: Move last second allocation to inside the
 OOM killer.
Message-ID: <20171101132700.qf4exnqezaepjgat@dhcp22.suse.cz>
References: <1509537268-4726-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509537268-4726-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

I would really suggest you to stick with the changelog I have suggested.

On Wed 01-11-17 20:54:27, Tetsuo Handa wrote:
[...]
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 26add8a..118ecdb 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -870,6 +870,19 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	}
>  	task_unlock(p);
>  
> +	/*
> +	 * Try really last second allocation attempt after we selected an OOM
> +	 * victim, for somebody might have managed to free memory while we were
> +	 * selecting an OOM victim which can take quite some time.
> +	 */
> +	if (oc->ac) {
> +		oc->page = alloc_pages_before_oomkill(oc);

I would stick the oc->ac check inside alloc_pages_before_oomkill.

> +		if (oc->page) {
> +			put_task_struct(p);
> +			return;
> +		}
> +	}
> +
>  	if (__ratelimit(&oom_rs))
>  		dump_header(oc, p);
>  
> @@ -1081,6 +1094,16 @@ bool out_of_memory(struct oom_control *oc)
>  	select_bad_process(oc);
>  	/* Found nothing?!?! Either we hang forever, or we panic. */
>  	if (!oc->chosen && !is_sysrq_oom(oc) && !is_memcg_oom(oc)) {
> +		/*
> +		 * Try really last second allocation attempt, for somebody
> +		 * might have managed to free memory while we were trying to
> +		 * find an OOM victim.
> +		 */
> +		if (oc->ac) {
> +			oc->page = alloc_pages_before_oomkill(oc);
> +			if (oc->page)
> +				return true;
> +		}
>  		dump_header(oc, NULL);
>  		panic("Out of memory and no killable processes...\n");
>  	}

Also, is there any strong reason to not do the last allocation after
select_bad_process rather than having two call sites? I would understand
that if you wanted to catch for_each_thread inside oom_kill_process but
you are not doing that.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
