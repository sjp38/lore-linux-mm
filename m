Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id BEBC06B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 05:31:29 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so11265550wic.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 02:31:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gj20si3830538wic.95.2015.09.04.02.31.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Sep 2015 02:31:28 -0700 (PDT)
Date: Fri, 4 Sep 2015 11:31:26 +0200
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [RFC PATCH 09/14] ring_buffer: Initialize completions statically
 in the benchmark
Message-ID: <20150904093126.GH22739@pathway.suse.cz>
References: <1438094371-8326-1-git-send-email-pmladek@suse.com>
 <1438094371-8326-10-git-send-email-pmladek@suse.com>
 <20150803143109.0b13925b@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150803143109.0b13925b@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, live-patching@vger.kernel.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 2015-08-03 14:31:09, Steven Rostedt wrote:
> On Tue, 28 Jul 2015 16:39:26 +0200
> Petr Mladek <pmladek@suse.com> wrote:
> 
> > It looks strange to initialize the completions repeatedly.
> > 
> > This patch uses static initialization. It simplifies the code
> > and even helps to get rid of two memory barriers.
> 
> There was a reason I did it this way and did not use static
> initializers. But I can't recall why I did that. :-/
> 
> I'll have to think about this some more.

Heh, the parallel programming is a real fun. I tried to understand
the code in more details and sometimes felt like Duane Dibbley.

Anyway, I found few possible races related to the completions.
One scenario was opened by my previous fix b44754d8262d3aab8429
("ring_buffer: Allow to exit the ring buffer benchmark immediately")

The races can be fixed by the patch below. I still do not see any
scenario where the extra initialization of the two completions
is needed but I am not brave enough to remove it after all ;-)
