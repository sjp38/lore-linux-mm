Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id E170F6B006E
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 17:06:25 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so98881641wiw.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 14:06:25 -0700 (PDT)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id ez11si3673736wid.43.2015.06.08.14.06.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 14:06:24 -0700 (PDT)
Received: by wgv5 with SMTP id 5so112862832wgv.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 14:06:23 -0700 (PDT)
Date: Mon, 8 Jun 2015 23:06:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] oom: split out forced OOM killer
Message-ID: <20150608210621.GA18360@dhcp22.suse.cz>
References: <1433235187-32673-1-git-send-email-mhocko@suse.cz>
 <alpine.DEB.2.10.1506041557070.16555@chino.kir.corp.google.com>
 <557187F9.8020301@gmail.com>
 <alpine.DEB.2.10.1506081059200.10521@chino.kir.corp.google.com>
 <5575E5E6.20908@gmail.com>
 <alpine.DEB.2.10.1506081237350.13272@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506081237350.13272@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 08-06-15 12:41:48, David Rientjes wrote:
> On Mon, 8 Jun 2015, Austin S Hemmelgarn wrote:
> 
> > I believe so (haven't actually read the patch itself, just the changelog),
> > although it is only a change for certain configurations to a very specific and
> > (I hope infrequently) used piece of functionality. Like I said above, if I
> > wanted to crash my system, I'd be using sysrq-c; and if I'm using sysrq-f, I
> > want _some_ task to die _now_.
> > 
> 
> This patch is not a functional change, so I don't interpret your feedback 
> as any support of it being merged.

David, have you actually read the patch? The changelog is mentioning this:
"
    check_panic_on_oom on the other hand will work and that is kind of
    unexpected because sysrq+f should be usable to kill a mem hog whether
    the global OOM policy is to panic or not.
    It also doesn't make much sense to panic the system when no task cannot
    be killed because admin has a separate sysrq for that purpose.
"
and the patch exludes panic_on_oom from the sysrq path.

> That said, you raise an interesting point of whether sysrq+f should ever 
> trigger a panic due to panic_on_oom.  The case can be made that it should 
> ignore panic_on_oom and require the use of another sysrq to panic the 
> machine instead.  Sysrq+f could then be used to oom kill a process, 
> regardless of panic_on_oom, and the panic only occurs if userspace did not 
> trigger the kill or the kill itself will fail.

Why would it panic the system if there is no killable task? Shoudln't
be admin able to do additional steps after the explicit oom killer failed
and only then panic by sysrq?

> I think we should pursue that direction.
> 
> This patch also changes the text which is output to the kernel log on 
> panic, which we use to parse for machines that have crashed due to no 
> killable memcg processes, so NACK on this patch. 

Could you point to the code snippet which does that? Because the only
change to the output is for the forced oom killer.

> There's also no reason 
> to add more source code to try to make things cleaner when it just 
> obfuscates the oom killer code more than it needs to (we don't need to 
> optimize or have multiple entry points).

I am not sure I understand your objection here. The forced oom killer
path is now clear (__oom_kill_process does the dirty job while
oom_kill_process can do heuristics to prevent from pointless killing),
easier to follow and thus more maintainable from my POV.
I could understand your objection if this has added a lot of code but
 4 files changed, 58 insertions(+), 23 deletions(-)

which seems appropriate to me.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
