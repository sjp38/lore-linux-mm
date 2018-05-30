Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 54D616B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 16:43:02 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w6-v6so9963663plp.14
        for <linux-mm@kvack.org>; Wed, 30 May 2018 13:43:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q75-v6si35649163pfk.268.2018.05.30.13.42.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 May 2018 13:42:57 -0700 (PDT)
Date: Wed, 30 May 2018 13:42:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4] Print the memcg's name when system-wide OOM happened
Message-Id: <20180530134256.bbf7a8639571a3f8910b6a05@linux-foundation.org>
In-Reply-To: <1526870386-2439-1-git-send-email-ufo19890607@gmail.com>
References: <1526870386-2439-1-git-send-email-ufo19890607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607 <ufo19890607@gmail.com>
Cc: mhocko@suse.com, rientjes@google.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian <yuzhoujian@didichuxing.com>

On Mon, 21 May 2018 03:39:46 +0100 ufo19890607 <ufo19890607@gmail.com> wrote:

> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> The dump_header does not print the memcg's name when the system
> oom happened. So users cannot locate the certain container which
> contains the task that has been killed by the oom killer.
> 
> System oom report will print the memcg's name after this patch,
> so users can get the memcg's path from the oom report and check
> the certain container more quickly.

lkp-robot is reporting an oops.

> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -433,6 +433,7 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
>  	if (is_memcg_oom(oc))
>  		mem_cgroup_print_oom_info(oc->memcg, p);
>  	else {
> +		mem_cgroup_print_oom_memcg_name(oc->memcg, p);
>  		show_mem(SHOW_MEM_FILTER_NODES, oc->nodemask);
>  		if (is_dump_unreclaim_slabs())
>  			dump_unreclaimable_slab();

static inline bool is_memcg_oom(struct oom_control *oc)
{
	return oc->memcg != NULL;
}

So in the mem_cgroup_print_oom_memcg_name() call which this patch adds,
oc->memcg is known to be NULL.  How can this possibly work?  
