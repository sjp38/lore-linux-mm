Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 1C2D96B005A
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 14:39:36 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so7008710pad.14
        for <linux-mm@kvack.org>; Tue, 16 Oct 2012 11:39:35 -0700 (PDT)
Date: Tue, 16 Oct 2012 11:39:33 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom, memcg: handle sysctl oom_kill_allocating_task while
 memcg oom happening
In-Reply-To: <20121016133439.GI13991@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.00.1210161136470.2910@chino.kir.corp.google.com>
References: <1350382328-28977-1-git-send-email-handai.szj@taobao.com> <20121016133439.GI13991@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Sha Zhengju <handai.szj@gmail.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

On Tue, 16 Oct 2012, Michal Hocko wrote:

> The primary motivation for oom_kill_allocating_task AFAIU was to reduce
> search over huge tasklists and reduce task_lock holding times. I am not
> sure whether the original concern is still valid since 6b0c81b (mm,
> oom: reduce dependency on tasklist_lock) as the tasklist_lock usage has
> been reduced conciderably in favor of RCU read locks is taken but maybe
> even that can be too disruptive?
> David?
> 

When the oom killer became serialized, the folks from SGI requested this 
tunable to be able to avoid the expensive tasklist scan on their systems 
and to be able to avoid killing threads that aren't allocating memory at 
all in a steady state.  It wasn't necessarily about tasklist_lock holding 
time but rather the expensive iteration over such a large number of 
processes.

> Moreover memcg oom killer doesn't iterate over tasklist (it uses
> cgroup_iter*) so this shouldn't cause the performance problem like
> for the global case.

Depends on how many threads are attached to a memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
