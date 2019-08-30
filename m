Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70224C3A5A4
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 10:35:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1192621670
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 10:35:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1192621670
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42DF66B0006; Fri, 30 Aug 2019 06:35:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DD956B0008; Fri, 30 Aug 2019 06:35:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F40D6B000A; Fri, 30 Aug 2019 06:35:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0254.hostedemail.com [216.40.44.254])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7186B0006
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 06:35:09 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id A9801180AD7C3
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 10:35:08 +0000 (UTC)
X-FDA: 75878736696.27.roof60_2cbd21c850c26
X-HE-Tag: roof60_2cbd21c850c26
X-Filterd-Recvd-Size: 4459
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 10:35:07 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3EBD3AB9D;
	Fri, 30 Aug 2019 10:35:05 +0000 (UTC)
Date: Fri, 30 Aug 2019 12:35:04 +0200
From: Michal Hocko <mhocko@suse.com>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Petr Mladek <pmladek@suse.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Edward Chron <echron@arista.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>,
	Shakeel Butt <shakeelb@google.com>
Subject: Re: [PATCH] mm,oom: Defer dump_tasks() output.
Message-ID: <20190830103504.GA28313@dhcp22.suse.cz>
References: <1567159493-5232-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1567159493-5232-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri 30-08-19 19:04:53, Tetsuo Handa wrote:
> If /proc/sys/vm/oom_dump_tasks != 0, dump_header() can become very slow
> because dump_tasks() synchronously reports all OOM victim candidates, and
> as a result ratelimit test for dump_header() cannot work as expected.
> 
> This patch defers dump_tasks() till oom_mutex is released. As a result of
> this patch, the latency between out_of_memory() is called and SIGKILL is
> sent (and the OOM reaper starts reclaiming memory) will be significantly
> reduced.
> 
> Since CONFIG_PRINTK_CALLER was introduced, concurrent printk() became less
> problematic. But we still need to correlate synchronously printed messages
> and asynchronously printed messages if we defer dump_tasks() messages.
> Thus, this patch also prefixes OOM killer messages using "OOM[$serial]:"
> format. As a result, OOM killer messages would look like below.
> 
>   [   31.935015][   T71] OOM[1]: kworker/4:1 invoked oom-killer: gfp_mask=0xcc0(GFP_KERNEL), order=-1, oom_score_adj=0
>   (...snipped....)
>   [   32.052635][   T71] OOM[1]: oom-kill:constraint=CONSTRAINT_NONE,nodemask=(null),global_oom,task_memcg=/,task=firewalld,pid=737,uid=0
>   [   32.056886][   T71] OOM[1]: Out of memory: Killed process 737 (firewalld) total-vm:358672kB, anon-rss:22640kB, file-rss:12328kB, shmem-rss:0kB, UID:0 pgtables:421888kB oom_score_adj:0
>   [   32.064291][   T71] OOM[1]: Tasks state (memory values in pages):
>   [   32.067807][   T71] OOM[1]: [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
>   [   32.070057][   T54] oom_reaper: reaped process 737 (firewalld), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
>   [   32.072417][   T71] OOM[1]: [    548]     0   548     9772     1172   110592        0             0 systemd-journal
>   (...snipped....)
>   [   32.139566][   T71] OOM[1]: [    737]     0   737    89668     8742   421888        0             0 firewalld
>   (...snipped....)
>   [   32.221990][   T71] OOM[1]: [   1300]    48  1300    63025     1788   532480        0             0 httpd
> 
> This patch might affect panic behavior triggered by panic_on_oom or no
> OOM-killable tasks, for dump_header(oc, NULL) will not report OOM victim
> candidates if there are not-yet-reported OOM victim candidates from past
> rounds of OOM killer invocations. I don't know if that matters.
> 
> For now this patch embeds "struct oom_task_info" into each
> "struct task_struct". In order to avoid bloating "struct task_struct",
> future patch might detach from "struct task_struct" because one
> "struct oom_task_info" for one "struct signal_struct" will be enough.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> ---
>  include/linux/sched.h |  17 +++++-
>  mm/oom_kill.c         | 149 +++++++++++++++++++++++++++++++++++---------------
>  2 files changed, 121 insertions(+), 45 deletions(-)

This is adding a lot of code for something that might be simply worked
around by disabling dump_tasks. Unless there is a real world workload
that suffers from the latency and depends on the eligible task list then
I do not think this is mergeable.
-- 
Michal Hocko
SUSE Labs

