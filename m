Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E49D26B02C3
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 05:44:46 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id u101so4338260wrc.2
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 02:44:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e62si5445088wmf.81.2017.06.08.02.44.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 02:44:45 -0700 (PDT)
Date: Thu, 8 Jun 2017 11:44:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/oom_kill: count global and memory cgroup oom kills
Message-ID: <20170608094441.GD19866@dhcp22.suse.cz>
References: <149570810989.203600.9492483715840752937.stgit@buzz>
 <20170605085011.GJ9248@dhcp22.suse.cz>
 <80c9060f-bf80-51fb-39c0-b36f273c0c9c@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <80c9060f-bf80-51fb-39c0-b36f273c0c9c@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Roman Guschin <guroan@gmail.com>, David Rientjes <rientjes@google.com>

On Mon 05-06-17 17:27:50, Konstantin Khlebnikov wrote:
> 
> 
> On 05.06.2017 11:50, Michal Hocko wrote:
> >On Thu 25-05-17 13:28:30, Konstantin Khlebnikov wrote:
[...]
> >>index 04c9143a8625..dd30a045ef5b 100644
> >>--- a/mm/oom_kill.c
> >>+++ b/mm/oom_kill.c
> >>@@ -876,6 +876,11 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >>  	/* Get a reference to safely compare mm after task_unlock(victim) */
> >>  	mm = victim->mm;
> >>  	mmgrab(mm);
> >>+
> >>+	/* Raise event before sending signal: reaper must see this */
> >>+	count_vm_event(OOM_KILL);
> >>+	mem_cgroup_count_vm_event(mm, OOM_KILL);
> >>+
> >>  	/*
> >>  	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
> >>  	 * the OOM victim from depleting the memory reserves from the user
> >
> >Why don't you count tasks which share mm with the oom victim?
> 
> Yes, this makes sense. But these kills are not logged thus counter
> will differs from logged events.

Yes they are not but does that matter? Do we want _all_ or only some oom
kills being counted.

> Also these tasks might live in different cgroups, so counting to mm
> owner isn't correct.

Well, the situation with mm shared between different memcgs is always
hairy. We try to charge mm->owner but I suspect we are not consistent in
that. I would have to double check because it's been a long ago since
I've investigated that. My point is that once you count OOM kills you
should count all the tasks IMHO.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
