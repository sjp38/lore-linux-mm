Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 261866B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:57:55 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id e8-v6so4033733plb.5
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:57:55 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j12si10179732pgf.678.2018.04.16.11.57.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 11:57:53 -0700 (PDT)
Date: Mon, 16 Apr 2018 14:57:49 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416145749.07075366@gandalf.local.home>
In-Reply-To: <20180416183542.GN2341@sasha-vm>
References: <20180416160608.GA7071@amd>
	<20180416122019.1c175925@gandalf.local.home>
	<20180416162757.GB2341@sasha-vm>
	<20180416163952.GA8740@amd>
	<20180416164310.GF2341@sasha-vm>
	<20180416125307.0c4f6f28@gandalf.local.home>
	<20180416170936.GI2341@sasha-vm>
	<20180416133321.40a166a4@gandalf.local.home>
	<20180416174236.GL2341@sasha-vm>
	<20180416142653.0f017647@gandalf.local.home>
	<20180416183542.GN2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, 16 Apr 2018 18:35:44 +0000
Sasha Levin <Alexander.Levin@microsoft.com> wrote:

> If I were to tell you that I have a crack team of 10 kernel hackers who
> dig through all mainline commits to find commits that should be
> backported to stable, and they do it with less mistakes than
> authors/maintainers make when they tag their own commits, would I get the
> same level of objection?

Probably ;-)

I've been struggling with my own stable tags, and been thinking that I
too suffer from tagging too much for stable, because there's code I
fix, and think "hmm, this could have some unwanted side effects". I'm
actually worried that my own fixes could cause an API breakage that I'm
unaware of.

What I'm staying is, I think we should start looking at fixes that fix
bugs we consider critical. Those being:

 * off-by-one
 * memory overflow
 * locking mismatch
 * API regressions

For my sub-system

 * wrong data coming out

Which can be a critical issue. Wrong data is worse than no data. But
then, there's the times a bug will produce no data, and considering
what it is, and how much of an effort it takes to fix it, I may or may
not label "no data" issues for stable. The cases where I enable
something with a bunch of parameters, and because of some mishandling
of the parameter it just screws up totally (where it's obvious that it
screwed up), I only mark those for stable if it doesn't require a
redesign of the code to fix it. There's been some cases where a
redesign was required, and I didn't mark it for stable.

The fixes for tracing that I don't usually tag for stable is when doing
complex tracing simply doesn't work and produces no data or errors
incorrectly. Depending on how complex the fix is, I mark it for stable,
otherwise, I think the fix is more likely to break something else that
is more common, then this hardly ever used feature.

The fact that nobody noticed, or hasn't complained about it usually
plays a lot in that decision. If someone complained to me about
breakage, I'm more likely to label it for stable. But if I discover it
myself, as I probably use the tracing system differently than others as
I wrote the code, then I don't usually mark it.

-- Steve
