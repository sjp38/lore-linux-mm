Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id B49A16B0032
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 05:37:02 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so8437819wgb.3
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 02:37:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e17si2205746wic.4.2015.06.09.02.36.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 02:37:00 -0700 (PDT)
Date: Tue, 9 Jun 2015 11:36:59 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: split out forced OOM killer
Message-ID: <20150609093659.GA29057@dhcp22.suse.cz>
References: <1433235187-32673-1-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.10.1506041557070.16555@chino.kir.corp.google.com>
 <557187F9.8020301@gmail.com>
 <alpine.DEB.2.10.1506081059200.10521@chino.kir.corp.google.com>
 <5575E5E6.20908@gmail.com>
 <alpine.DEB.2.10.1506081237350.13272@chino.kir.corp.google.com>
 <20150608210621.GA18360@dhcp22.suse.cz>
 <alpine.DEB.2.10.1506081558270.17040@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506081558270.17040@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 08-06-15 16:06:07, David Rientjes wrote:
> On Mon, 8 Jun 2015, Michal Hocko wrote:
> 
> > > This patch is not a functional change, so I don't interpret your feedback 
> > > as any support of it being merged.
> > 
> > David, have you actually read the patch? The changelog is mentioning this:
> > "
> >     check_panic_on_oom on the other hand will work and that is kind of
> >     unexpected because sysrq+f should be usable to kill a mem hog whether
> >     the global OOM policy is to panic or not.
> >     It also doesn't make much sense to panic the system when no task cannot
> >     be killed because admin has a separate sysrq for that purpose.
> > "
> > and the patch exludes panic_on_oom from the sysrq path.
> > 
> 
> Yes, and that's why I believe we should pursue that direction without the 
> associated "cleanup" that adds 35 lines of code to supress a panic.  In 
> other words, there's no reason to combine a patch that suppresses the 
> panic even with panic_on_oom, which I support, and a "cleanup" that I 
> believe just obfuscates the code.
> 
> It's a one-liner change: just test for force_kill and suppress the panic; 
> we don't need 35 new lines that create even more unique entry paths.

I completely detest yet another check in out_of_memory. And there is
even no reason to do that. Forced kill and genuine oom have different
objectives and combining those two just makes the code harder to read
(one has to go to check the syrq callback to realize that the forced
path is triggered from the workqueue context and that current->mm !=
NULL check will prevent some heuristics. This is just too ugly to
live). So why the heck are you pushing for keeping everything in a
single path?

That being said, I have no problem to do 3 patches, where two of them
would add force check for check_panic_on_oom and panic on no killable
task and only then pull out force_out_of_memory to make it readable
again and drop force checks but I do not see much point in this
juggling.

> > > That said, you raise an interesting point of whether sysrq+f should ever 
> > > trigger a panic due to panic_on_oom.  The case can be made that it should 
> > > ignore panic_on_oom and require the use of another sysrq to panic the 
> > > machine instead.  Sysrq+f could then be used to oom kill a process, 
> > > regardless of panic_on_oom, and the panic only occurs if userspace did not 
> > > trigger the kill or the kill itself will fail.
> > 
> > Why would it panic the system if there is no killable task? Shoudln't
> > be admin able to do additional steps after the explicit oom killer failed
> > and only then panic by sysrq?
> > 
> 
> Today it panics, I don't think it should panic when there are no killable 
> processes because it's inherently racy with userspace.  It's similar to 
> suppressing panic_on_oom for sysrq+f, but for a different reason, so it 
> should probably be a separate patch with its own changelog (and update to 
> documentation for both patches to make this explicit).

I have no problem to be more explicit about the behavior of course. I
can fold it to the original patch.
---
