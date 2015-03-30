Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 59E216B006C
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 11:08:24 -0400 (EDT)
Received: by wgra20 with SMTP id a20so177821977wgr.3
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 08:08:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r19si18559599wik.45.2015.03.30.08.08.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Mar 2015 08:08:22 -0700 (PDT)
Date: Mon, 30 Mar 2015 17:08:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150330150818.GE3909@dhcp22.suse.cz>
References: <359c926bc85cdf79650e39f2344c2083002545bb.1427347966.git.viresh.kumar@linaro.org>
 <20150326131822.fce6609efdd85b89ceb3f61c@linux-foundation.org>
 <CAKohpo=nTXutbVVf-7iAwtgya4zUL686XbG69ExQ3Pi=VQRE-A@mail.gmail.com>
 <20150327091613.GE27490@worktop.programming.kicks-ass.net>
 <20150327093023.GA32047@worktop.ger.corp.intel.com>
 <CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
 <20150328095322.GH27490@worktop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150328095322.GH27490@worktop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Viresh Kumar <viresh.kumar@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, hannes@cmpxchg.org, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, mgorman@suse.de, dave@stgolabs.net, koct9i@gmail.com, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Sat 28-03-15 10:53:22, Peter Zijlstra wrote:
[...]
> Alternatively the thing hocko suggests is an utter fail too. You cannot
> stuff that into hardirq context, that's insane.

I guess you are referring to
http://article.gmane.org/gmane.linux.kernel.mm/127569, right?

Why cannot we do something like refresh_cpu_vm_stats from the IRQ
context?  Especially the first zone stat part. The per-cpu pagesets is
more costly and it would need a special treatment, alright. A simple
way would be to splice the lists from the per-cpu context and then free
those pages from the kthread context.

I am still wondering why those two things were squashed into a single
place. Why kswapd is not doing the pcp cleanup?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
