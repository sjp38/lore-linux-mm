Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 67F546B01B4
	for <linux-mm@kvack.org>; Fri, 28 May 2010 10:36:30 -0400 (EDT)
Received: by ywh33 with SMTP id 33so894459ywh.11
        for <linux-mm@kvack.org>; Fri, 28 May 2010 07:36:29 -0700 (PDT)
Date: Fri, 28 May 2010 11:36:17 -0300
From: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>
Subject: Re: [RFC] oom-kill: give the dying task a higher priority
Message-ID: <20100528143617.GF11364@uudg.org>
References: <20100528143605.7E2A.A69D9226@jp.fujitsu.com>
 <AANLkTikB-8Qu03VrA5Z0LMXM_alSV7SLqzl-MmiLmFGv@mail.gmail.com>
 <20100528145329.7E2D.A69D9226@jp.fujitsu.com>
 <20100528125305.GE11364@uudg.org>
 <20100528140623.GA11041@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100528140623.GA11041@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, williams@redhat.com
List-ID: <linux-mm.kvack.org>

On Fri, May 28, 2010 at 11:06:23PM +0900, Minchan Kim wrote:
| On Fri, May 28, 2010 at 09:53:05AM -0300, Luis Claudio R. Goncalves wrote:
| > On Fri, May 28, 2010 at 02:59:02PM +0900, KOSAKI Motohiro wrote:
...
| > | As far as my observation, RT-function always have some syscall. because pure
| > | calculation doesn't need deterministic guarantee. But _if_ you are really
| > | using such priority design. I'm ok maximum NonRT priority instead maximum
| > | RT priority too.
| > 
| > I confess I failed to distinguish memcg OOM and system OOM and used "in
| > case of OOM kill the selected task the faster you can" as the guideline.
| > If the exit code path is short that shouldn't be a problem.
| > 
| > Maybe the right way to go would be giving the dying task the biggest
| > priority inside that memcg to be sure that it will be the next process from
| > that memcg to be scheduled. Would that be reasonable?
| 
| Hmm. I can't understand your point. 
| What do you mean failing distinguish memcg and system OOM?
| 
| We already have been distinguish it by mem_cgroup_out_of_memory.
| (but we have to enable CONFIG_CGROUP_MEM_RES_CTLR). 
| So task selected in select_bad_process is one out of memcg's tasks when 
| memcg have a memory pressure. 

The approach of giving the highest priority to the dying task makes sense
in a system wide OOM situation. I though that would also be good for the
memcg OOM case.

After Balbir Singh's comment, I understand that in a memcg OOM the dying
task should have a priority just above the priority of the main task of
that memcg, in order to avoid interfering in the rest of the system.

That is the point where I failed to distinguish between memcg and system OOM.

Should I pursue that new idea of looking for the right priority inside the
memcg or is it overkill? I really don't have a clear view of the impact of
a memcg OOM on system performance - don't know if it is better to solve the
issue sooner (highest RT priority) or leave it to be solved later (highest
prio on the memcg). I have the impression the general case points to the
simpler solution.

Luis
-- 
[ Luis Claudio R. Goncalves                    Bass - Gospel - RT ]
[ Fingerprint: 4FDD B8C4 3C59 34BD 8BE9  2696 7203 D980 A448 C8F8 ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
