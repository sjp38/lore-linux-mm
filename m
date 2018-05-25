Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 290BF6B0008
	for <linux-mm@kvack.org>; Fri, 25 May 2018 15:48:57 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p189-v6so3484496pfp.2
        for <linux-mm@kvack.org>; Fri, 25 May 2018 12:48:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f82-v6sor9200275pfd.122.2018.05.25.12.48.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 May 2018 12:48:56 -0700 (PDT)
Date: Fri, 25 May 2018 12:48:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v5] Refactor part of the oom report in dump_header
In-Reply-To: <1527213613-7922-1-git-send-email-ufo19890607@gmail.com>
Message-ID: <alpine.DEB.2.21.1805251245210.158701@chino.kir.corp.google.com>
References: <1527213613-7922-1-git-send-email-ufo19890607@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ufo19890607 <ufo19890607@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, aarcange@redhat.com, penguin-kernel@i-love.sakura.ne.jp, guro@fb.com, yang.s@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yuzhoujian <yuzhoujian@didichuxing.com>

On Fri, 25 May 2018, ufo19890607 wrote:

> From: yuzhoujian <yuzhoujian@didichuxing.com>
> 
> The dump_header does not print the memcg's name when the system
> oom happened, so users cannot locate the certain container which
> contains the task that has been killed by the oom killer.
> 
> I follow the advices of David Rientjes and Michal Hocko, and refactor
> part of the oom report in a backwards compatible way. After this patch,
> users can get the memcg's path from the oom report and check the certain
> container more quickly.
> 

I like the direction you are taking.  A couple notes:

 - you may find it easier to declare an array of const char * for each
   constraint:

	static const char * const oom_constraint_text[] = {
		[CONSTRAINT_NONE] = "CONSTRAINT_NONE",
		[CONSTRAINT_CPUSET] = "CONSTRAINT_CPUSET",
		[CONSTRAINT_MEMORY_POLICY] = "CONSTRAINT_MEMORY_POLICY",
		[CONSTRAINT_MEMCG] = "CONSTRAINT_MEMCG",
	};

 - we need to eliminate all the usage of pr_cont() because otherwise we
   can still get interleaving in the kernel log (the single line output
   should always be a complete single line that can be parsed by
   userspace).

 - to generate a single line output, I think you need a call to a
   function in mm/memcontrol.c when is_memcg_oom(oc) is true and
   otherwise a function in mm/oom_kill.c when false.   
