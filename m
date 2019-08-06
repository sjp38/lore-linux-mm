Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FC32C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:36:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED4662075B
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 08:36:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED4662075B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 957966B0269; Tue,  6 Aug 2019 04:36:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 907526B026A; Tue,  6 Aug 2019 04:36:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D0D56B026B; Tue,  6 Aug 2019 04:36:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7D86B0269
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 04:36:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so53354630edv.16
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 01:36:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=b+V8DQAbpNdgLAyXYiZw06kEN5mFkKHhR0gv7dh4JGI=;
        b=bqa7+vCozU7VGuUQxXKaAlQz4A+mqH/FWcCz3Im1z/HjwqYo25iIDJnRooh8pvK7Ag
         EJx+v7HojRKDuIoSJylJoL2Yr2Wci2qlDeHqjKKC5A4D11wTI1BgTjXfm2E72k2NnE+V
         3rDOWc/zElPj6EJIxQ5KakWPlBK/7uyMPHtyfXcfuhOI9Xxe6A0751HRh9psYPqWLUum
         TzcgMRuKMF6XiMQORh3sTWY8iVpSue3arA6xi+2uM5Z2TQq/XXKFT86bQeIMKCibjs/e
         4FrOpwMuLHrM8CwzlkkS1deoNTjnujfFAWdq4qkPalBYqUDjcD9H5vpPzERDAHGXP3IH
         LB0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAU/4xMRO8Wy99/RDpmt0cHvwGV3+ZZHLpm+3d3mEiyVQXi95EYZ
	y5HQxugpzyJLp1MTHvdGRFt4rDUTRhSYVuEUx1pqKMpxkExdejj6uTd0T1QnuUwJyqPFtKXfBZT
	VOiFiILiqtUrQziz9gRuN7mNWUrPvplml6YYCD2nTpiBhrAPeChE9UQzxy6pUwO1c0Q==
X-Received: by 2002:a17:906:802:: with SMTP id e2mr1978366ejd.59.1565080607756;
        Tue, 06 Aug 2019 01:36:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxkL5hPAJrLmKyPStU2/fy6i9+4VUAV1YrJboKW6SkWvRSeBHXsqkER7Shg+gkUBTO9LEwN
X-Received: by 2002:a17:906:802:: with SMTP id e2mr1978324ejd.59.1565080607025;
        Tue, 06 Aug 2019 01:36:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565080607; cv=none;
        d=google.com; s=arc-20160816;
        b=TNoLNvNIpyXXGBQAz/NzezYPgJwBPpfmPuLpUO1weqa4e28/pbxKeJ6T/hj9ORb1vZ
         V/T/jF/yqdQJZIM5r0IKiysclfEq6tTmXrcuvohfWbznBrGrxbmsy1r/wD+oBXooK2VY
         Tje6DUzLh19cqvb4YzXdY6vDlyFv3P8Ouqe4doXUVcENW+32/1eg5KU9KILcV16vrWcP
         e/hTgDFWAkJ+RTv6sn6CWyHm5gx09pugfNIdoyMxixT9ZJwt37T4b9dM8oiw8X/8ERb7
         7Ou0ShxGvRagJeRYXcEDrz57Le4FTySRngnzA7MwMx90F3zKL2PNT7qKoInBmVu83/B+
         scPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=b+V8DQAbpNdgLAyXYiZw06kEN5mFkKHhR0gv7dh4JGI=;
        b=c8bobn/J/LEMiBFL3Ud9Q0VFp6LSDR9ouDlY/HCSdtakuQcXu784Vvrsp3bZOE9sJ6
         48LfsL+BsD8jjrQkACBavecG9ilkq+Li+bmfC6fWnCf8s6cMEq3kUEmLqD24WUNrENPO
         cXZMfkcWJoljsxFo8h27wh58DNcfqWqvT9qdVMUDxloLnTqGCcX0+N9mmBYaxORphCyl
         fgOHb2o6+hbQApdwL4PauxzxN6UDcJnwyOlWsdX6z+4t5uTEBb9q4i8n74fRMYdEIv2i
         kxChitXyHrV9ifXD9lKEm3OYamKW93Vr1zQLLwwmaMW53DfNZYg08hS7SPfJiOaNZq1a
         R9cQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e24si28355174ejc.241.2019.08.06.01.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 01:36:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A0BBEAF90;
	Tue,  6 Aug 2019 08:36:46 +0000 (UTC)
Subject: Re: [PATCH] mm/mempolicy.c: Remove unnecessary nodemask check in
 kernel_migrate_pages()
To: Kefeng Wang <wangkefeng.wang@huawei.com>,
 Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>,
 Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
 Linux API <linux-api@vger.kernel.org>,
 "linux-man@vger.kernel.org" <linux-man@vger.kernel.org>
References: <20190806023634.55356-1-wangkefeng.wang@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <80f8da83-f425-1aab-f47e-8da41ec6dcbf@suse.cz>
Date: Tue, 6 Aug 2019 10:36:40 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190806023634.55356-1-wangkefeng.wang@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/19 4:36 AM, Kefeng Wang wrote:
> 1) task_nodes = cpuset_mems_allowed(current);
>    -> cpuset_mems_allowed() guaranteed to return some non-empty
>       subset of node_states[N_MEMORY].

Right, there's an explicit guarantee.

> 2) nodes_and(*new, *new, task_nodes);
>    -> after nodes_and(), the 'new' should be empty or appropriate
>       nodemask(online node and with memory).
> 
> After 1) and 2), we could remove unnecessary check whether the 'new'
> AND node_states[N_MEMORY] is empty.

Yeah looks like the check is there due to evolution of the code, where initially
it was added to prevent calling the syscall with bogus nodes, but now that's
achieved by cpuset_mems_allowed().

> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: linux-mm@kvack.org
> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
> 
> [QUESTION]
> 
> SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
>                 const unsigned long __user *, old_nodes,
>                 const unsigned long __user *, new_nodes)
> {
>         return kernel_migrate_pages(pid, maxnode, old_nodes, new_nodes);
> }
> 
> The migrate_pages() takes pid argument, witch is the ID of the process
> whose pages are to be moved. should the cpuset_mems_allowed(current) be
> cpuset_mems_allowed(task)?

The check for cpuset_mems_allowed(task) is just above the code you change, so
the new nodes have to be subset of the target task's cpuset.
But they also have to be allowed by the calling task's cpuset. In manpage of
migrate_pages(2), this is hinted by the NOTES "Use get_mempolicy(2) with the
MPOL_F_MEMS_ALLOWED flag to obtain the set of nodes that are allowed by the
calling process's cpuset..."

But perhaps the manpage should be better clarified:

- the EINVAL case includes "Or, none of the node IDs specified by new_nodes are
on-line and allowed by the process's current cpuset context, or none of the
specified nodes contain memory." - this should probably say "calling process" to
disambiguate
- the EPERM case should mention that new_nodes have to be subset of the target
process' cpuset context. The caller should also have CAP_SYS_NICE and
ptrace_may_access()

>  mm/mempolicy.c | 4 ----
>  1 file changed, 4 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index f48693f75b37..fceb44066184 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1467,10 +1467,6 @@ static int kernel_migrate_pages(pid_t pid, unsigned long maxnode,
>  	if (nodes_empty(*new))
>  		goto out_put;
>  
> -	nodes_and(*new, *new, node_states[N_MEMORY]);
> -	if (nodes_empty(*new))
> -		goto out_put;
> -
>  	err = security_task_movememory(task);
>  	if (err)
>  		goto out_put;
> 

