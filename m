Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 11BEB6B0032
	for <linux-mm@kvack.org>; Mon, 30 Mar 2015 10:00:04 -0400 (EDT)
Received: by pactp5 with SMTP id tp5so1725488pac.1
        for <linux-mm@kvack.org>; Mon, 30 Mar 2015 07:00:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id w1si14934793pdh.80.2015.03.30.07.00.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Mar 2015 07:00:02 -0700 (PDT)
Date: Mon, 30 Mar 2015 15:59:48 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC] vmstat: Avoid waking up idle-cpu to service shepherd work
Message-ID: <20150330135948.GY23123@twins.programming.kicks-ass.net>
References: <20150327091613.GE27490@worktop.programming.kicks-ass.net>
 <20150327093023.GA32047@worktop.ger.corp.intel.com>
 <CAOh2x=nbisppmuBwfLWndyCPKem1N_KzoTxyAYcQuL77T_bJfw@mail.gmail.com>
 <20150328095322.GH27490@worktop.programming.kicks-ass.net>
 <55169723.3070006@linaro.org>
 <20150328134457.GK27490@worktop.programming.kicks-ass.net>
 <20150329102440.GC32047@worktop.ger.corp.intel.com>
 <CAKohpon2GSpk+6pNuHEsDC55hHtowwfGJivPM0Gh0wt1A2cd-w@mail.gmail.com>
 <20150330124746.GI21418@twins.programming.kicks-ass.net>
 <CAKohpo=2_v8n+tnrEbb4bYAxU8cgA+OWpTNe8XX3yjpzL4ySGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKohpo=2_v8n+tnrEbb4bYAxU8cgA+OWpTNe8XX3yjpzL4ySGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viresh Kumar <viresh.kumar@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Linaro Kernel Mailman List <linaro-kernel@lists.linaro.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, vinmenon@codeaurora.org, shashim@codeaurora.org, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, dave@stgolabs.net, Konstantin Khlebnikov <koct9i@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Mar 30, 2015 at 06:44:22PM +0530, Viresh Kumar wrote:
> On 30 March 2015 at 18:17, Peter Zijlstra <peterz@infradead.org> wrote:
> > No, I means something else with that. We can remove the
> > tvec_base::running_timer field. Everything that uses that can use
> > tbase_running() AFAICT.
> 
> Okay, there is one instance which still needs it.
> 
> migrate_timers():
> 
>         BUG_ON(old_base->running_timer);
> 
> What I wasn't sure about it is if we get can drop this statement or not.
> If we decide not to drop it, then we can convert running_timer into a bool.

Yeah, so that _should_ not trigger (obviously), and while I agree with
the sentiment of sanity checks, I'm not sure its worth keeping that
variable around just for that.

Anyway, while I'm looking at struct tvec_base I notice the cpu member
should be second after the lock, that'll save 8 bytes on the structure
on 64bit machines.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
