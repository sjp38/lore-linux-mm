Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id BABD86B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 14:26:58 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id i8-v6so2317262plt.8
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 11:26:58 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id f8si9884090pgt.243.2018.04.16.11.26.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 11:26:57 -0700 (PDT)
Date: Mon, 16 Apr 2018 14:26:53 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH AUTOSEL for 4.14 015/161] printk: Add console owner and
 waiter logic to load balance console writes
Message-ID: <20180416142653.0f017647@gandalf.local.home>
In-Reply-To: <20180416174236.GL2341@sasha-vm>
References: <20180416153031.GA5039@amd>
	<20180416155031.GX2341@sasha-vm>
	<20180416160608.GA7071@amd>
	<20180416122019.1c175925@gandalf.local.home>
	<20180416162757.GB2341@sasha-vm>
	<20180416163952.GA8740@amd>
	<20180416164310.GF2341@sasha-vm>
	<20180416125307.0c4f6f28@gandalf.local.home>
	<20180416170936.GI2341@sasha-vm>
	<20180416133321.40a166a4@gandalf.local.home>
	<20180416174236.GL2341@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <Alexander.Levin@microsoft.com>
Cc: Pavel Machek <pavel@ucw.cz>, Linus Torvalds <torvalds@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Byungchul Park <byungchul.park@lge.com>, Tejun Heo <tj@kernel.org>, Greg KH <gregkh@linuxfoundation.org>

On Mon, 16 Apr 2018 17:42:38 +0000
Sasha Levin <Alexander.Levin@microsoft.com> wrote:

> >> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/commit?id=a918d2bcea6aab6e671bfb0901cbecc3cf68fca1  
> >
> >Sure. Even if it has a subtle regression, that's a critical bug being
> >fixed.  
> 
> This was later reverted, in -stable:
> 
> """
> Commit d63c7dd5bcb9 ("ipr: Fix out-of-bounds null overwrite") removed
> the end of line handling when storing the update_fw sysfs attribute.
> This changed the userpace API because it started refusing writes
> terminated by a line feed, which broke the update tools we already have.
> """

I hope it wasn't reverted. It did fix a critical bug.

The problem is that it only fixed a critical bug, but didn't go far
enough to keep the bug fix from breaking API. I see this as two bugs
being fixed. Even though the second bug was "caused" by the first fix.
the first fix was still necessary. The second bug was relying on broken
code. This hasn't changed my position on that patch from being
backported. I would not even mark this as a regression. I would say the
original code was broken too much, and fixing part of it just showed
revealed another broken part.


> 
> >> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/commit?id=b1999fa6e8145305a6c8bda30ea20783717708e6  
> >
> >I would consider unlocking a mutex that one didn't lock a critical bug,
> >so yes.
> >
> >Again, things that deal with locking or buffer overflows, I would take
> >the fix, as those are critical. But other behavior issues where it's
> >not critical, I would leave be unless told further by someone else.  
> 
> This too, was reverted:
> 
> """
> It causes run-time breakage in the 4.4-stable tree and more patches are
> needed to be applied first before this one in order to resolve the
> issue.
> """

It wasn't reverted in mainline. Looks like there was some subtle issues
with the different stable versions. Perhaps the "fixes" was wrong.

> 
> This is how fun it is reviewing AUTOSEL commits :)
> 
> Even the small "trivial", "obviously correct" patches have room for
> errors for various reasons.

And that's fine. Any code written can have bugs in it. That's just a
given. Which pushes for why we should be extremely picky about what we
backport.

> 
> Also note that all of these patches were tagged for stable and actually
> ended up in at least one tree.
> 
> This is why I'm basing a lot of my decision making on the rejection rate.
> If the AUTOSEL process does the job well enough as the "regular"
> process did before, why push it back?

Because I think we are adding too many patches to stable. And
automating it may just make things worse. Your examples above back my
argument more than they refute it. If people can't determine what is
"obviously correct" how is automation going to do any better?

-- Steve
