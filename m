Return-Path: <SRS0=zrK/=W7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0D84C3A5A7
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 08:13:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66E6F20674
	for <linux-mm@archiver.kernel.org>; Wed,  4 Sep 2019 08:13:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66E6F20674
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3C5F6B0003; Wed,  4 Sep 2019 04:13:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEBDC6B0006; Wed,  4 Sep 2019 04:13:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E01326B0007; Wed,  4 Sep 2019 04:13:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0134.hostedemail.com [216.40.44.134])
	by kanga.kvack.org (Postfix) with ESMTP id B68FF6B0003
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 04:13:11 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 620E38E61
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 08:13:11 +0000 (UTC)
X-FDA: 75896522982.29.gold41_730c146b42f47
X-HE-Tag: gold41_730c146b42f47
X-Filterd-Recvd-Size: 4695
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed,  4 Sep 2019 08:13:10 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9E0FFAE04;
	Wed,  4 Sep 2019 08:13:08 +0000 (UTC)
Date: Wed, 4 Sep 2019 10:13:07 +0200
From: Petr Mladek <pmladek@suse.com>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Michal Hocko <mhocko@suse.com>, Edward Chron <echron@arista.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>,
	David Rientjes <rientjes@google.com>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] mm,oom: Defer dump_tasks() output.
Message-ID: <20190904081307.36eucg7zhp3t5xb7@pathway.suse.cz>
References:<1567159493-5232-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190830103504.GA28313@dhcp22.suse.cz>
 <f69d1b83-aee4-8b00-81f6-adbe6121eb99@i-love.sakura.ne.jp>
 <20190902060638.GA14028@dhcp22.suse.cz>
 <cba675c7-88a2-0c5b-c97b-8d5c77eaa8ef@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To:<cba675c7-88a2-0c5b-c97b-8d5c77eaa8ef@i-love.sakura.ne.jp>
User-Agent: NeoMutt/20170912 (1.9.0)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 2019-09-03 23:20:48, Tetsuo Handa wrote:
> On 2019/09/02 15:06, Michal Hocko wrote:
> > On Sat 31-08-19 10:03:18, Tetsuo Handa wrote:
> >> On 2019/08/30 19:35, Michal Hocko wrote:
> >>> On Fri 30-08-19 19:04:53, Tetsuo Handa wrote:
> >>>> If /proc/sys/vm/oom_dump_tasks != 0, dump_header() can become very slow
> >>>> because dump_tasks() synchronously reports all OOM victim candidates, and
> >>>> as a result ratelimit test for dump_header() cannot work as expected.
> >>>>
> >>>> This patch defers dump_tasks() till oom_mutex is released. As a result of
> >>>> this patch, the latency between out_of_memory() is called and SIGKILL is
> >>>> sent (and the OOM reaper starts reclaiming memory) will be significantly
> >>>> reduced.
> >>>
> >>> This is adding a lot of code for something that might be simply worked
> >>> around by disabling dump_tasks. Unless there is a real world workload
> >>> that suffers from the latency and depends on the eligible task list then
> >>> I do not think this is mergeable.
> >>>
> >>
> >> People had to use /proc/sys/vm/oom_dump_tasks == 0 (and give up obtaining some
> >> clue) because they worried stalls caused by /proc/sys/vm/oom_dump_tasks != 0
> >> while they have to use /proc/sys/vm/panic_on_oom == 0 because they don't want the
> >> down time caused by rebooting.
> > 
> > The main qustion is whether disabling that information is actually
> > causing any real problems.
> 
> I can't interpret your question.
> If there is no real problem with forcing /proc/sys/vm/oom_dump_tasks == 0,
> you had better remove dump_tasks().
> 
> > 
> >> This patch avoids stalls (and gives them some clue).
> >> This patch also helps mitigating __ratelimit(&oom_rs) == "always true" problem.
> >> A straightforward improvement.
> > 
> > This is a wrong approach to mitigate that problem. Ratelimiting doesn't
> > really work for any operation that takes a longer time. Solving that
> > problem sounds usef in a generic way.
> 
> Even if printk() is able to become asynchronous, a problem that "a lot of
> printk() messages might be pending inside the printk buffer when we have to
> write emergency messages to consoles due to entering critical situation" will remain.
> This patch prevents dump_tasks() messages (which can become e.g. 32000 lines) from
> pending in the printk buffer. Sergey and Petr, any comments to add?

I am not sure that I understand. If OOM messages are critical then
they should get printed synchronously. It they are not critical
then they can get deferred.

John Ogness has a proposal[1] to introduce one more console loglevel
that would split messages into two groups. Emergency messages would
get printed synchronously and the rest might get deferred.

But there are many prerequisites and questions about it:

  + lockless consoles to print emergency messages immediately
  + offload mechanism
  + user space support to sort the messages by timestamps
  + usage and code complexity vs. the gain

Anyway, this is a generic way how to solve these problems.

[1] https://lkml.kernel.org/r/20190212143003.48446-1-john.ogness@linutronix.de

Best Regards,
Petr

