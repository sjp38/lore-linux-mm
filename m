Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id F050A6B0174
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 07:35:05 -0400 (EDT)
Message-ID: <4E60BF60.7090003@nokia.com>
Date: Fri, 02 Sep 2011 14:34:56 +0300
From: Viktor Rosendahl <viktor.rosendahl@nokia.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Enable OOM when moving processes between cgroups?
References: <1314811941-14587-1-git-send-email-viktor.rosendahl@nokia.com> <20110831175422.GB21571@redhat.com>
In-Reply-To: <20110831175422.GB21571@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ext Johannes Weiner <jweiner@redhat.com>
Cc: linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>

On 08/31/2011 08:54 PM, ext Johannes Weiner wrote:
> On Wed, Aug 31, 2011 at 08:32:21PM +0300, Viktor Rosendahl wrote:
>>
>> In my testing (2.6.32 kernel with some backported cgroups patches), it improves
>> the case when there isn't room for the task in the target cgroup.
>
> Tasks are moved directly on behalf of a request from userspace.  We
> would much prefer denying that single request than invoking the
> oom-killer on the whole group.
>

I can agree that in general this is a better policy, because in the 
general case it's not known if the userspace entity that requested the 
move prefers to cancel the move or kill something in the target group.

In my specific system it's known that we always want to kill something 
in the group, so probably this need to be a local patch.

Are there any known performance or reliability problems if OOM is 
enabled in that code patch?

> Quite a lot changed in the trycharge-reclaim-retry path since 2009.
> Nowadays, charging is retried as long as reclaim is making any
> progress at all, so I don't see that it would give up moving a task
> too lightly, even without the extra OOM looping.
>

The problem isn't really that the task moving is given up too easily; it 
seems more like it is trying too hard. The system is becoming very slow 
and unresponsive when moving the task. Our system is meant to be fairly 
interactive and responsive, that's why we would like to enable the OOM 
killer.

> Is there any chance you could retry with a more recent kernel?

Probably not with our production environment because it's an ARM based 
embedded system. If I tried to update the kernel, I would most likely 
end up with a ton of broken drivers.

Making some synthetic test case on a PC would of course be possible but 
I am not sure if it would tell that much.

best regards,

Viktor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
