Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id E6BBA6B0034
	for <linux-mm@kvack.org>; Fri, 31 May 2013 17:46:38 -0400 (EDT)
Date: Fri, 31 May 2013 14:46:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, memcg: add oom killer delay
Message-Id: <20130531144636.6b34c6ba48105482d1241a40@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1305291817280.520@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, 29 May 2013 18:18:10 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> Completely disabling the oom killer for a memcg is problematic if
> userspace is unable to address the condition itself, usually because it
> is unresponsive.  This scenario creates a memcg deadlock: tasks are
> sitting in TASK_KILLABLE waiting for the limit to be increased, a task to
> exit or move, or the oom killer reenabled and userspace is unable to do
> so.
> 
> An additional possible use case is to defer oom killing within a memcg
> for a set period of time, probably to prevent unnecessary kills due to
> temporary memory spikes, before allowing the kernel to handle the
> condition.
> 
> This patch adds an oom killer delay so that a memcg may be configured to
> wait at least a pre-defined number of milliseconds before calling the oom
> killer.  If the oom condition persists for this number of milliseconds,
> the oom killer will be called the next time the memory controller
> attempts to charge a page (and memory.oom_control is set to 0).  This
> allows userspace to have a short period of time to respond to the
> condition before deferring to the kernel to kill a task.
> 
> Admins may set the oom killer delay using the new interface:
> 
> 	# echo 60000 > memory.oom_delay_millisecs
> 
> This will defer oom killing to the kernel only after 60 seconds has
> elapsed by putting the task to sleep for 60 seconds.

How often is that delay actually useful, in the real world?

IOW, in what proportion of cases does the system just remain stuck for
60 seconds and then get an oom-killing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
