Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id B6CA96B0071
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 03:37:29 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so28889230wgb.3
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 00:37:29 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dx2si7949157wib.2.2015.06.10.00.37.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 10 Jun 2015 00:37:27 -0700 (PDT)
Date: Wed, 10 Jun 2015 09:37:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: split out forced OOM killer
Message-ID: <20150610073726.GB4501@dhcp22.suse.cz>
References: <1433235187-32673-1-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.10.1506041557070.16555@chino.kir.corp.google.com>
 <557187F9.8020301@gmail.com>
 <alpine.DEB.2.10.1506081059200.10521@chino.kir.corp.google.com>
 <5575E5E6.20908@gmail.com>
 <alpine.DEB.2.10.1506081237350.13272@chino.kir.corp.google.com>
 <20150608210621.GA18360@dhcp22.suse.cz>
 <alpine.DEB.2.10.1506081558270.17040@chino.kir.corp.google.com>
 <20150609093659.GA29057@dhcp22.suse.cz>
 <alpine.DEB.2.10.1506091542120.30516@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506091542120.30516@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 09-06-15 15:45:35, David Rientjes wrote:
> On Tue, 9 Jun 2015, Michal Hocko wrote:
> 
> > > Yes, and that's why I believe we should pursue that direction without the 
> > > associated "cleanup" that adds 35 lines of code to supress a panic.  In 
> > > other words, there's no reason to combine a patch that suppresses the 
> > > panic even with panic_on_oom, which I support, and a "cleanup" that I 
> > > believe just obfuscates the code.
> > > 
> > > It's a one-liner change: just test for force_kill and suppress the panic; 
> > > we don't need 35 new lines that create even more unique entry paths.
> > 
> > I completely detest yet another check in out_of_memory. And there is
> > even no reason to do that. Forced kill and genuine oom have different
> > objectives and combining those two just makes the code harder to read
> > (one has to go to check the syrq callback to realize that the forced
> > path is triggered from the workqueue context and that current->mm !=
> > NULL check will prevent some heuristics. This is just too ugly to
> > live). So why the heck are you pushing for keeping everything in a
> > single path?
> > 
> 
> Perhaps if you renamed "force_kill" to "sysrq" it would make more sense to 
> you?

The naming is not _the_ problem.

> I don't think the oom killer needs multiple entry points that duplicates 
> code and adds more than twice the lines it removes.  It would make sense 
> if that was an optimization in a hot path, or a warm path, or even a 
> luke-warm path, but not an icy cold path like the oom killer.  

This is not trying to optimize for speed. It is a clean up for
_readability_ and _maintainability_ which is considerably better after
the patch because responsibilities of both paths are clear and sysrq
path doesn't have to care about whatever special handling the oom path
wants to care. It is _that_ simple.

> check_panic_on_oom() can simply do

> 
> 	if (sysrq)
> 		return;

and then do the same thing for panic on no killable task and then for
all other cases which are of no relevance for the sysrq path which we
come up later potentially.

This level of argumentation is just ridiculous. You are blocking a
useful cleanup which also fixes a really non-intuitive behavior. I admit
that nobody was complaining about this behavior so this is nothing
urgent but if we go with panic_on_oom_timeout proposal posted in other
email thread then I expect panic_on_oom would be usable much more and
then it would matter much more.

> It's not hard and it's very clear.  We don't need 35 more lines of code to 
> do this.

Sure we do not _need_ it and we definitely can _clutter_ the code even
more.

I do not think your objections are justified. It is natural and a good
practice to split code paths which have different requirements rather
than differentiate them with multiple checks in the common path (some of
them even very subtle). It is a common practice to split up common
infrastructure in helper functions and reuse them when needed. But I
guess I do not have teach you this trivial things...

</bunfight> from my side

Andrew do whatever you like with the patch but I find the level of
argumentation in this thread as not reasonable (I would even consider it
trolling at some parts) and not sufficient for a nack.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
