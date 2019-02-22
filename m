Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C88AC10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 07:10:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3CD79207E0
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 07:10:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3CD79207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79E458E00ED; Fri, 22 Feb 2019 02:10:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74DBA8E00E0; Fri, 22 Feb 2019 02:10:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 664B18E00ED; Fri, 22 Feb 2019 02:10:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB308E00E0
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 02:10:08 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d8so541754edi.6
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 23:10:08 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2kKf8y+ffkNPE88Rc4WXNgZiqrMhzuyfy2Zdnp8/vK0=;
        b=MqbdWt2VIYpFA/mJWiymwBkdvjlplDp3pQ/kDdPDG3go4ezmtwfFuESxJVDnjXEkjN
         bEpwS2kuNPhDbIwWZIHARrSbup22FqwfnH/xQhW9lkqY/L9pEJ7Nac0fglMx7az2vxdo
         ak6KwE+H8seGfuZ5n9luZe1v2vhHR5RVLoDjv1bgBhQsiJUAzBRwUMJclD/9TYpaLFG8
         bAUmsic3kP5dJMqvYBRPDdJdVt9OO7Y5FFApnz5/16C4bOEasg+ZNc5ffpUyp+DBIrlk
         XpyqiOEJWiQVxAIuQGhRc0qLVmp/RTl8Sl4t2QBfsWjs+jllR0c0ofcKVt5heBN8TSGT
         BBrA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubLqsgfu2wXViA09GN57+c2gIYcXdG/ftUMm72tQx734YBGrE0E
	ZgHSC2svm42hJphZZawlUKTRPtE1lJxt/Q/7VLxgSVsLurb9SYpC2VruCC89IRkmnjDhEQJRpN3
	ghZhqaMckSVxreh93Z6Z51uFXHljGqW8XdG5YSCl5lfpMqVQsrSL6O8NCp2CjSpI=
X-Received: by 2002:a50:9857:: with SMTP id h23mr2005117edb.66.1550819407466;
        Thu, 21 Feb 2019 23:10:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IazS9LaJIA3Sl/VGTAsbJo6oS3b+RomWM+/hKv08ay9N425bSPnzyGu5zh/PwIQwRe1xkHh
X-Received: by 2002:a50:9857:: with SMTP id h23mr2005040edb.66.1550819406067;
        Thu, 21 Feb 2019 23:10:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550819406; cv=none;
        d=google.com; s=arc-20160816;
        b=r6EH0CgJvwiIYEk6hgQiVjSXbzfphsvjovNB5/5bbZ3JDZ1rUufE6j3MEbYCqLgl98
         HM5BxA5LwN0lJ0lB/yCX/Kpp7hX+AExEdjBHnh790UwxcwQYOKDHWNjQmb0YUdRV0dpp
         FB8PSVxWLyMFiJY9/MUuRE5moYL/P6okWNQNM1Mzc1AN/vwBbVOD2K38gM+omXWibJAt
         Jm4aNebWRf5m66ZNtNsC3he/ku3YU0CGwaVF/JfCm/6cImbjHrBGVxCAlkFexXV6Mh9Q
         6KUkw/yyy3v/1p5Lj2fozhAJwKz2IqljwSL63qqXq6I35FvTJQyyyIe2X0B7dnLCNsgT
         xOYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2kKf8y+ffkNPE88Rc4WXNgZiqrMhzuyfy2Zdnp8/vK0=;
        b=pcUyDBzty1xwahxBlvA0O/D1IOBGQQj0mHJIZE7gFgi2KB+a8N3+nLhrKVAuqAx+nl
         dz6v3V8jdb3RFQjHQ/Go4Qm+YWmgBOORY9GKUnETrflD7cY53p/XC/Xjlq4/tZ+rn5ye
         RzYjC3R5iuUlnK60epcg/r8fgBGe1OqTKRJBFPZ43D5dEceoqa1nP5TbvO21z3sFqBck
         4t5A+pz8v/0w1LJb0Pgm1xZqnMD+VX95ipbjNHEm/W85tL7aqor3+Ia+pzgQzAq5mAwh
         1J0HZOa7Zyx0dwaQR8Z47zhLiueLuQUh58XtyeLJzqQ6OGGFYAALSbVmskzODXk//dsg
         2Rpw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r16si315309eds.155.2019.02.21.23.10.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 23:10:06 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A9767AB98;
	Fri, 22 Feb 2019 07:10:04 +0000 (UTC)
Date: Fri, 22 Feb 2019 08:10:01 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Junil Lee <junil0814.lee@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, willy@infradead.org,
	pasha.tatashin@oracle.com, kirill.shutemov@linux.intel.com,
	jrdr.linux@gmail.com, dan.j.williams@intel.com,
	alexander.h.duyck@linux.intel.com, andreyknvl@google.com,
	arunks@codeaurora.org, keith.busch@intel.com, guro@fb.com,
	hannes@cmpxchg.org, rientjes@google.com,
	penguin-kernel@I-love.SAKURA.ne.jp, shakeelb@google.com,
	yuzhoujian@didichuxing.com
Subject: Re: [PATCH] mm, oom: OOM killer use rss size without shmem
Message-ID: <20190222071001.GA10588@dhcp22.suse.cz>
References: <1550810253-152925-1-git-send-email-junil0814.lee@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1550810253-152925-1-git-send-email-junil0814.lee@lge.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 22-02-19 13:37:33, Junil Lee wrote:
> The oom killer use get_mm_rss() function to estimate how free memory
> will be reclaimed when the oom killer select victim task.
> 
> However, the returned rss size by get_mm_rss() function was changed from
> "mm, shmem: add internal shmem resident memory accounting" commit.
> This commit makes the get_mm_rss() return size including SHMEM pages.

This was actually the case even before eca56ff906bdd because SHMEM was
just accounted to MM_FILEPAGES so this commit hasn't changed much
really.

Besides that we cannot really rule out SHMEM pages simply. They are
backing MAP_ANON|MAP_SHARED which might be unmapped and freed during the
oom victim exit. Moreover this is essentially the same as file backed
pages or even MAP_PRIVATE|MAP_ANON pages. Bothe can be pinned by other
processes e.g. via private pages via CoW mappings and file pages by
filesystem or simply mlocked by another process. So this really gross
evaluation will never be perfect. We would basically have to do exact
calculation of the freeable memory of each process and that is just not
feasible.

That being said, I do not think the patch is an improvement in that
direction. It just turnes one fuzzy evaluation by another that even
misses a lot of memory potentially.

> The oom killer can't get free memory from SHMEM pages directly after
> kill victim process, it leads to mis-calculate victim points.
> 
> Therefore, make new API as get_mm_rss_wo_shmem() which returns the rss
> value excluding SHMEM_PAGES.
> 
> Signed-off-by: Junil Lee <junil0814.lee@lge.com>
> ---
>  include/linux/mm.h | 6 ++++++
>  mm/oom_kill.c      | 4 ++--
>  2 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 2d483db..bca3acc 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1701,6 +1701,12 @@ static inline int mm_counter(struct page *page)
>  	return mm_counter_file(page);
>  }
>  
> +static inline unsigned long get_mm_rss_wo_shmem(struct mm_struct *mm)
> +{
> +	return get_mm_counter(mm, MM_FILEPAGES) +
> +		get_mm_counter(mm, MM_ANONPAGES);
> +}
> +
>  static inline unsigned long get_mm_rss(struct mm_struct *mm)
>  {
>  	return get_mm_counter(mm, MM_FILEPAGES) +
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 3a24848..e569737 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -230,7 +230,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  	 * The baseline for the badness score is the proportion of RAM that each
>  	 * task's rss, pagetable and swap space use.
>  	 */
> -	points = get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
> +	points = get_mm_rss_wo_shmem(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS) +
>  		mm_pgtables_bytes(p->mm) / PAGE_SIZE;
>  	task_unlock(p);
>  
> @@ -419,7 +419,7 @@ static void dump_tasks(struct mem_cgroup *memcg, const nodemask_t *nodemask)
>  
>  		pr_info("[%7d] %5d %5d %8lu %8lu %8ld %8lu         %5hd %s\n",
>  			task->pid, from_kuid(&init_user_ns, task_uid(task)),
> -			task->tgid, task->mm->total_vm, get_mm_rss(task->mm),
> +			task->tgid, task->mm->total_vm, get_mm_rss_wo_shmem(task->mm),
>  			mm_pgtables_bytes(task->mm),
>  			get_mm_counter(task->mm, MM_SWAPENTS),
>  			task->signal->oom_score_adj, task->comm);
> -- 
> 2.6.2
> 

-- 
Michal Hocko
SUSE Labs

