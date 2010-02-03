Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 110916001DA
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 17:55:04 -0500 (EST)
From: Lubos Lunak <l.lunak@suse.cz>
Subject: Re: Improving OOM killer
Date: Wed, 3 Feb 2010 23:54:58 +0100
References: <201002012302.37380.l.lunak@suse.cz> <201002022210.06760.l.lunak@suse.cz> <alpine.DEB.2.00.1002021643240.3393@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002021643240.3393@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002032354.58352.l.lunak@suse.cz>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>


 Given that the badness() proposal I see in your another mail uses 
get_mm_rss(), I take it that you've meanwhile changed your mind on the VmSize 
vs VmRSS argument and considered that argument irrelevant now. I will comment 
only on the suggested use of oom_adj on the desktop here. And actually I hope 
that if something reasonably similar to your badness() proposal replaces the 
current one it will make any use of oom_adj not needed on the desktop in the 
usual case, so this may be irrelevant as well.

On Wednesday 03 of February 2010, David Rientjes wrote:
> On Tue, 2 Feb 2010, Lubos Lunak wrote:
> >  Not that it really matters - the net result is that OOM killer usually
> > decides to kill kdeinit or ksmserver, starts killing their children,
> > vital KDE processes, and since the offenders are not among them, it ends
> > up either terminating the whole session by killing ksmserver or killing
> > enough vital processes there to free enough memory for the offenders to
> > finish their work cleanly.
>
> The kernel cannot possibly know what you consider a "vital" process, for
> that understanding you need to tell it using the very powerful
> /proc/pid/oom_adj tunable.  I suspect if you were to product all of
> kdeinit's children by patching it to be OOM_DISABLE so that all threads it
> forks will inherit that value you'd actually see much improved behavior.

 No. Almost everything in KDE is spawned by kdeinit, so everything would get 
the adjustment, which means nothing would in practice get the adjustment.

> I'd also encourage you to talk to the KDE developers to ensure that proper
> precautions are taken to protect it in such conditions since people who
> use such desktop environments typically don't want them to be sacrificed
> for memory.

 I am a KDE developer, it's written in my signature. And I've already talked 
enough to the KDE developer who has done the oom_adj code that's already 
there, as that's also me. I don't know kernel internals, but that doesn't 
mean I'm completely clueless about the topic of the discussion I've started.

> >  Worse, it worked for about a year or two and now it has only shifted the
> > problem elsewhere and that's it. We now protect kdeinit, which means the
> > OOM killer's choice will very likely ksmserver then. Ok, so let's say now
> > we start protecting also ksmserver, that's some additional hassle setting
> > it up, but that's doable. Now there's a good chance the OOM killer's
> > choice will be kwin (as a compositing manager it can have quite large
> > mappings because of graphics drivers). So ok, we need to protect the
> > window manager, but since that's not a hardcoded component like
> > ksmserver, that's even more hassle.
>
> No, you don't need to protect every KDE process from the oom killer unless
> it is going to be a contender for selection.  You could certainly do so
> for completeness, but it shouldn't be required unless the nature of the
> thread demands it such that it forks many vital tasks (kdeinit) or its
> first-generation children's memory consumption can't be known either
> because it depends on how many children it can fork or their memory
> consumption is influenced by the user's work.

 1) I think you missed that I said that every KDE application with the current 
algorithm can be potentially a contender for selection, and I provided 
numbers to demonstrate that in a selected case. Just because such application 
is not vital does not mean it's good for it to get killed instead of an 
obvious offender.

 2) You probably do not realize the complexity involved in using oom_adj in a 
desktop. Even when doing that manually I would have some difficulty finding 
the right setup for my own desktop use. It'd be probably virtually impossible 
to write code that would do it at least somewhat right with all the widely 
differing various desktop setups that dynamically change.

 3) oom_adj is ultimately just a kludge to handle special cases where the 
heuristic doesn't get it right for whatever strange reason. But even you 
yourself in another mail presented a heuristic that I believe would make any 
use of oom_adj on the desktop unnecessary in the usual cases. The usual 
desktop is not a special case.

> The heuristics are always well debated in this forum and there's little
> chance that we'll ever settle on a single formula that works for all
> possible use cases.  That makes oom_adj even more vital to the overall
> efficiency of the oom killer, I really hope you start to use it to your
> advantage.

 I really hope your latest badness() heuristics proposal allows us to dump 
even the oom_adj use we already have.

-- 
 Lubos Lunak
 openSUSE Boosters team, KDE developer
 l.lunak@suse.cz , l.lunak@kde.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
