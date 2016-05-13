Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 664C46B007E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 07:44:33 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id m64so67462242lfd.1
        for <linux-mm@kvack.org>; Fri, 13 May 2016 04:44:33 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id gp1si21795717wjb.59.2016.05.13.04.44.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 04:44:31 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r12so3186666wme.0
        for <linux-mm@kvack.org>; Fri, 13 May 2016 04:44:31 -0700 (PDT)
Date: Fri, 13 May 2016 13:44:29 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
Message-ID: <20160513114429.GJ20141@dhcp22.suse.cz>
References: <5731CC6E.3080807@laposte.net>
 <20160513080458.GF20141@dhcp22.suse.cz>
 <573593EE.6010502@free.fr>
 <20160513095230.GI20141@dhcp22.suse.cz>
 <5735AA0E.5060605@free.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5735AA0E.5060605@free.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mason <slash.tmp@free.fr>
Cc: Sebastian Frias <sf84@laposte.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 13-05-16 12:18:54, Mason wrote:
> On 13/05/2016 11:52, Michal Hocko wrote:
> > On Fri 13-05-16 10:44:30, Mason wrote:
> >> On 13/05/2016 10:04, Michal Hocko wrote:
> >>
> >>> On Tue 10-05-16 13:56:30, Sebastian Frias wrote:
> >>> [...]
> >>>> NOTE: I understand that the overcommit mode can be changed dynamically thru
> >>>> sysctl, but on embedded systems, where we know in advance that overcommit
> >>>> will be disabled, there's no reason to postpone such setting.
> >>>
> >>> To be honest I am not particularly happy about yet another config
> >>> option. At least not without a strong reason (the one above doesn't
> >>> sound that way). The config space is really large already.
> >>> So why a later initialization matters at all? Early userspace shouldn't
> >>> consume too much address space to blow up later, no?
> >>
> >> One thing I'm not quite clear on is: why was the default set
> >> to over-commit on?
> > 
> > Because many applications simply rely on large and sparsely used address
> > space, I guess.
> 
> What kind of applications are we talking about here?
> 
> Server apps? Client apps? Supercomputer apps?

It is all over the place. But some are worse than others (e.g. try to
run some larger java application).

Anyway, this is my laptop where I do not run anything really special
(xfce, browser, few consoles, git, mutt):
$ grep Commit /proc/meminfo 
CommitLimit:     3497288 kB
Committed_AS:    3560804 kB

I am running with the default overcommit setup so I do not care about
the limit but the Committed_AS will tell you how much is actually
committed. I am definitelly not out of memory:
$ free
              total        used        free      shared  buff/cache   available
Mem:        3922584     1724120      217336      105264     1981128     2036164
Swap:       1535996      386364     1149632

If you check the rss/vsize ratio of your processes (which is not precise
but give at least some clue) then you will see that I am quite below 10% on
my system in average:
$ ps -ao vsize,rss -ax | awk '{if ($1+0>0) printf "%d\n", $2*100/$1 }' | calc_min_max.awk 
min: 0.00 max: 44.00 avg: 6.16 std: 7.85 nr: 120

> I heard some HPC software use large sparse matrices, but is it a common
> idiom to request large allocations, only to use a fraction of it?
> 
> If you'll excuse the slight trolling, I'm sure many applications don't
> expect being randomly zapped by the OOM killer ;-)

No, neither banks (and their customers) are prepared for a default
aren't they ;).

But more seriously. Overcommit is simply a reality these days. It would
be quite naive to think that enabling the overcommit protection would
guarantee that no OOM will trigger. The kernel can consume a lot of
memory as well which might be unreclaimable.
 
> > That's why the default is GUESS where we ignore the cumulative
> > charges and simply check the current state and blow up only when
> > the current request is way too large.
> 
> I wouldn't call denying a request "blowing up". Application will
> receive NULL, and is supposed to handle it gracefully.

Sure they will handle ENOMEM (in better case) but in reality it would
basically mean that they will fail eventually because there is hardly a
fallback. And it really sucks to fail with "Not enough memory" when you
check and your memory is mostly free/reclaimable (see the example above
from my running system).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
