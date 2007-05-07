Message-ID: <463FACF9.2080301@users.sourceforge.net>
From: Andrea Righi <righiandr@users.sourceforge.net>
Reply-To: righiandr@users.sourceforge.net
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] VM: per-user overcommit policy
References: <463F764E.5050009@users.sourceforge.net> <20070507212322.6d60210b@the-village.bc.nu>
In-Reply-To: <20070507212322.6d60210b@the-village.bc.nu>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Date: Tue,  8 May 2007 00:49:57 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
>> - allow uid=1001 and uid=1002 (common users) to allocate memory only if the
>>   total committed space is below the 50% of the physical RAM + the size of
>>   swap:
>> root@host # echo 1001:2:50 > /proc/overcommit_uid
>> root@host # echo 1002:2:50 > /proc/overcommit_uid
> 
> There are some fundamental problems with this model - the moment you mix
> strict overcommit with anything else it ceases to be a strict overcommit
> and you might as well use existing overcommit rules for most stuff
> 
> The other thing you are sort of faking is per user resource management -
> which is a subset of per group of users resource management which is
> useful - eg "students can't hog the machine"
> 
> I don't see that this is the right approach compared with the container
> work and openvz work that is currently active and far more flexible.
> 

Obviously I was not proposing a nice theoretical model, my work is more similar
to a quick and dirty hack that could resolve some problems (at least in my case)
like the crash of critical services due to OOM-killing (or due to the failure of
a malloc() when OOM-killer is disabled).

When $VERY_CRITICAL_DAEMON dies *all* the users blame the sysadmin [me]. If a
user application dies because a malloc() returns NULL, the sysadmin [I] can
blame the user saying: "hey! _you_ tried to hog the machine and _your_
application is not able to handle the NULL result of the malloc()s!"... :-)

A solution could be to define the critical processes unkillable via
/proc/<pid>/oom_adj, but the per-process approach doesn't resolve all the
possible cases and it's quite difficult to manage in big environments, like HPC
clusters.

Anyway, it seems that I need to deepen my knowledge about the recent development
of process containers and openvz...

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
