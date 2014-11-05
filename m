Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 870FF6B0075
	for <linux-mm@kvack.org>; Wed,  5 Nov 2014 07:46:25 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id n15so556596lbi.20
        for <linux-mm@kvack.org>; Wed, 05 Nov 2014 04:46:24 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id am6si5820249lac.124.2014.11.05.04.46.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Nov 2014 04:46:23 -0800 (PST)
Date: Wed, 5 Nov 2014 13:46:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/4] OOM, PM: OOM killed task shouldn't escape PM suspend
Message-ID: <20141105124620.GB4527@dhcp22.suse.cz>
References: <1413876435-11720-1-git-send-email-mhocko@suse.cz>
 <2156351.pWp6MNRoWm@vostro.rjw.lan>
 <20141021141159.GE9415@dhcp22.suse.cz>
 <4766859.KSKPTm3b0x@vostro.rjw.lan>
 <20141021142939.GG9415@dhcp22.suse.cz>
 <20141104192705.GA22163@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141104192705.GA22163@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux PM list <linux-pm@vger.kernel.org>

On Tue 04-11-14 14:27:05, Tejun Heo wrote:
> Hello,
> 
> Sorry about the delay.
> 
> On Tue, Oct 21, 2014 at 04:29:39PM +0200, Michal Hocko wrote:
> > Reduce the race window by checking all tasks after OOM killer has been
> 
> Ugh... this is never a good direction to take.  It often just ends up
> making bugs harder to reproduce and track down.

As I've said I wasn't entirely happy with this half solution but it helped
the current situation at the time. The full solution would require to
fully synchronize OOM path with the freezer. The patch below is doing
that.

> > disabled. This is still not race free completely unfortunately because
> > oom_killer_disable cannot stop an already ongoing OOM killer so a task
> > might still wake up from the fridge and get killed without
> > freeze_processes noticing. Full synchronization of OOM and freezer is,
> > however, too heavy weight for this highly unlikely case.
> 
> Both oom killing and PM freezing are exremely rare events and I have
> difficult time why their exclusion would be heavy weight.  Care to
> elaborate

You are right that the allocation OOM path is extremely slow and so an
additional locking shouldn't matter much. I originally thought that
any locking would require more changes in the allocation path. In the
end it looks much easier than I hoped. I haven't tested it so I might be
just missing some subtle issues now.

Anyway I cannot say I would be happy to expose a lock which can block
OOM to happen because this calls for troubles. It is true that we
already have that ugly oom_killer_disabled hack but that only causes
allocation to fail rather than block the OOM path altogether if
something goes wrong. Maybe I am just too paranoid...

So my original intention was to provide a mechanism which would be safe
from OOM point of view and as good as possible from PM POV. The race is
really unlikely and even if it happened there would be an OOM message in
the log which would give us a hint (I can add a special note that oom is
disabled but we are killing a task regardless to make it more obvious if
you prefer).

> Overall, this is a lot of complexity for something which doesn't
> really fix the problem and the comments while referring to the race
> don't mention that the implemented "fix" is broken, which is pretty
> bad as it gives readers of the code a false sense of security and
> another hurdle to overcome in actually tracking down what went wrong
> if this thing ever shows up as an actual breakage.

The patch description mentions that the race is not closed completely.
It is true that the comments in the code could have been more clear
about it.

> I'd strongly recommend implementing something which is actually
> correct.

I think the patch below should be safe. Would you prefer this solution
instead? It is race free but there is the risk that exposing a lock which
completely blocks OOM killer from the allocation path will kick us
later.
---
