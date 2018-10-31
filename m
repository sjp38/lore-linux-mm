Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D08416B026A
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 09:50:52 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id u6-v6so11132847eds.10
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 06:50:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c19si3821149edv.143.2018.10.31.06.50.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 06:50:51 -0700 (PDT)
Date: Wed, 31 Oct 2018 14:50:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v15 1/2] Reorganize the oom report in dump_header
Message-ID: <20181031135049.GO32673@dhcp22.suse.cz>
References: <1538226387-16600-1-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1538226387-16600-1-git-send-email-ufo19890607@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607@gmail.com
Cc: akpm@linux-foundation.org, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian@didichuxing.com

On Sat 29-09-18 21:06:26, ufo19890607@gmail.com wrote:
[...]
> Changes since v14:
> - add the dump_oom_summary for the single line output of oom context.
> - fix the null pointer in the dump_header.

I do not remember details about this null ptr but the fix you seemed to
have done is
[...]
> +static void dump_oom_summary(struct oom_control *oc, struct task_struct *victim)
> +{
> +	/* one line summary of the oom killer context. */
> +	pr_info("oom-kill:constraint=%s,nodemask=%*pbl",
> +			oom_constraint_text[oc->constraint],
> +			nodemask_pr_args(oc->nodemask));
> +	cpuset_print_current_mems_allowed();
> +	pr_cont(",task=%s,pid=%d,uid=%d\n", victim->comm, victim->pid,
> +		from_kuid(&init_user_ns, task_uid(victim)));
> +}
> +
>  /*
>   * Number of OOM victims in flight
>   */
> @@ -951,6 +960,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  
>  	if (__ratelimit(&oom_rs))
>  		dump_header(oc, p);
> +	if (oc)
> +		dump_oom_summary(oc, victim);
>  

this? If yes then this is bogus because oc is never NULL. Besides that,
you used to have this one line summary in dump_header which looks much
better fit to me than oom_kill_process.

-- 
Michal Hocko
SUSE Labs
