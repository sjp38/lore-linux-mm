Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C42D6B78AD
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 08:16:05 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z30-v6so3609511edd.19
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 05:16:05 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h26-v6si522574edj.421.2018.09.06.05.16.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 05:16:04 -0700 (PDT)
Date: Thu, 6 Sep 2018 14:16:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: Introduce time limit for dump_tasks duration.
Message-ID: <20180906121601.GU14951@dhcp22.suse.cz>
References: <0252ad5d-46e6-0d7f-ef91-4e316657a83d@i-love.sakura.ne.jp>
 <CACT4Y+Yp6ZbusCWg5C1zaJpcS8=XnGPboKgWfyxVk1axQA2nbw@mail.gmail.com>
 <201809060553.w865rmpj036017@www262.sakura.ne.jp>
 <CACT4Y+YKJWJr-5rBQidt6nY7+VF=BAsvHyh+XTaf8spwNy3qPA@mail.gmail.com>
 <58aa0543-86d0-b2ad-7fb9-9bed7c6a1f6c@i-love.sakura.ne.jp>
 <20180906112306.GO14951@dhcp22.suse.cz>
 <1611e45d-235e-67e9-26e3-d0228255fa2f@i-love.sakura.ne.jp>
 <20180906115320.GS14951@dhcp22.suse.cz>
 <CACT4Y+byA7dLar5=9y+7RApT2WdxgVA9c29q83NEVkd5KCLgjg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+byA7dLar5=9y+7RApT2WdxgVA9c29q83NEVkd5KCLgjg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, syzbot <syzbot+f0fc7f62e88b1de99af3@syzkaller.appspotmail.com>, 'Dmitry Vyukov' via syzkaller-upstream-moderation <syzkaller-upstream-moderation@googlegroups.com>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>

Ccing Oleg.

On Thu 06-09-18 14:08:43, Dmitry Vyukov wrote:
[...]
> So does anybody know if it can live lock picking up new tasks all the
> time? That's what it looks like at first glance. I also don't remember
> seeing anything similar in the past.

That is an interesting question. I find it unlikely here because it is
quite hard to get new tasks spawned while you are genuinely OOM. But we
do have these for_each_process loops at other places as well. Some of
them even controlled from the userspace. Some of them like exit path
(zap_threads) sound even more interesting even when that is a rare path.

So a question for Oleg I guess. Is it possible that for_each_process
live locks (or stalls for way too long/unbounded amount of time) under
heavy fork/exit loads? Is there any protection from that?

> If it's a live lock and we resolve it, then we don't need to solve the
> problem of too many tasks here.

-- 
Michal Hocko
SUSE Labs
