Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 54C126B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 16:08:36 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id l18so7537840wgh.2
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 13:08:36 -0800 (PST)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id lp5si68628722wjb.25.2014.11.18.13.08.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 13:08:35 -0800 (PST)
Received: by mail-wi0-f175.google.com with SMTP id l15so3300186wiw.14
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 13:08:35 -0800 (PST)
Date: Tue, 18 Nov 2014 22:08:33 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/4] OOM vs PM freezer fixes
Message-ID: <20141118210833.GE23640@dhcp22.suse.cz>
References: <20141110163055.GC18373@dhcp22.suse.cz>
 <1415818732-27712-1-git-send-email-mhocko@suse.cz>
 <20141114201419.GI25889@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141114201419.GI25889@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-pm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "\\\"Rafael J. Wysocki\\\"" <rjw@rjwysocki.net>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Cong Wang <xiyou.wangcong@gmail.com>

On Fri 14-11-14 15:14:19, Tejun Heo wrote:
> On Wed, Nov 12, 2014 at 07:58:48PM +0100, Michal Hocko wrote:
> > Hi,
> > here is another take at OOM vs. PM freezer interaction fixes/cleanups.
> > First three patches are fixes for an unlikely cases when OOM races with
> > the PM freezer which should be closed completely finally. The last patch
> > is a simple code enhancement which is not needed strictly speaking but
> > it is nice to have IMO.
> > 
> > Both OOM killer and PM freezer are quite subtle so I hope I haven't
> > missing anything. Any feedback is highly appreciated. I am also
> > interested about feedback for the used approach. To be honest I am not
> > really happy about spreading TIF_MEMDIE checks into freezer (patch 1)
> > but I didn't find any other way for detecting OOM killed tasks.
> 
> I really don't get why this is structured this way.  Can't you just do
> the following?

Well, I liked how simple this was and localized at the only place which
matters. When I was thinking about a solution which you are describing
below it was more complicated and more subtle (e.g. waiting for an OOM
victim might be tricky if it stumbles over a lock which is held by a
frozen thread which uses try_to_freeze_unsafe). Anyway I gave it another
try and will post the two patches as a reply to this email. I hope the
both interface and implementation is cleaner.

> 1. Freeze all freezables.  Don't worry about PF_MEMDIE.
> 
> 2. Disable OOM killer.  This should be contained in the OOM killer
>    proper.  Lock out the OOM killer and disable it.
> 
> 3. At this point, we know that no one will create more freezable
>    threads and no new process will be OOM kliled.  Wait till there's
>    no process w/ PF_MEMDIE set.
> 
> There's no reason to lock out or disable OOM killer while the system
> is not in the quiescent state, which is a big can of worms.  Bring
> down the system to the quiescent state, disable the OOM killer and
> then drain PF_MEMDIEs.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
