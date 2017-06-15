Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 516C26B02C3
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 18:12:41 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 70so1480435wme.7
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 15:12:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c62si423722wmc.161.2017.06.15.15.12.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 15:12:40 -0700 (PDT)
Date: Fri, 16 Jun 2017 00:12:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is
 freed
Message-ID: <20170615221236.GB22341@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com>
 <20170615103909.GG1486@dhcp22.suse.cz>
 <alpine.DEB.2.10.1706151420300.95906@chino.kir.corp.google.com>
 <20170615214133.GB20321@dhcp22.suse.cz>
 <alpine.DEB.2.10.1706151459530.64172@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1706151459530.64172@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 15-06-17 15:03:17, David Rientjes wrote:
> On Thu, 15 Jun 2017, Michal Hocko wrote:
> 
> > > Yes, quite a bit in testing.
> > > 
> > > One oom kill shows the system to be oom:
> > > 
> > > [22999.488705] Node 0 Normal free:90484kB min:90500kB ...
> > > [22999.488711] Node 1 Normal free:91536kB min:91948kB ...
> > > 
> > > followed up by one or more unnecessary oom kills showing the oom killer 
> > > racing with memory freeing of the victim:
> > > 
> > > [22999.510329] Node 0 Normal free:229588kB min:90500kB ...
> > > [22999.510334] Node 1 Normal free:600036kB min:91948kB ...
> > > 
> > > The patch is absolutely required for us to prevent continuous oom killing 
> > > of processes after a single process has been oom killed and its memory is 
> > > in the process of being freed.
> > 
> > OK, could you play with the patch/idea suggested in
> > http://lkml.kernel.org/r/20170615122031.GL1486@dhcp22.suse.cz?
> > 
> 
> I cannot, I am trying to unblock a stable kernel release to my production 
> that is obviously fixed with this patch and cannot experiment with 
> uncompiled and untested patches that introduce otherwise unnecessary 
> locking into the __mmput() path and is based on speculation rather than 
> hard data that __mmput() for some reason stalls for the oom victim's mm.  
> I was hoping that this fix could make it in time for 4.12 since 4.12 kills 
> 1-4 processes unnecessarily for each oom condition and then can review any 
> tested solution you may propose at a later time.

I am sorry but I have really hard to make the oom reaper a reliable way
to stop all the potential oom lockups go away. I do not want to
reintroduce another potential lockup now. I also do not see why any
solution should be rushed into. I have proposed a way to go and unless
it is clear that this is not a way forward then I simply do not agree
with any partial workarounds or shortcuts.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
