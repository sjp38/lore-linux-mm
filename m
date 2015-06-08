Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5176B0038
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 19:06:10 -0400 (EDT)
Received: by igbzc4 with SMTP id zc4so135496igb.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 16:06:09 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id hx4si1571804igb.43.2015.06.08.16.06.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 16:06:09 -0700 (PDT)
Received: by igbpi8 with SMTP id pi8so111068igb.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 16:06:09 -0700 (PDT)
Date: Mon, 8 Jun 2015 16:06:07 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: split out forced OOM killer
In-Reply-To: <20150608210621.GA18360@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1506081558270.17040@chino.kir.corp.google.com>
References: <1433235187-32673-1-git-send-email-mhocko@suse.cz> <alpine.DEB.2.10.1506041557070.16555@chino.kir.corp.google.com> <557187F9.8020301@gmail.com> <alpine.DEB.2.10.1506081059200.10521@chino.kir.corp.google.com> <5575E5E6.20908@gmail.com>
 <alpine.DEB.2.10.1506081237350.13272@chino.kir.corp.google.com> <20150608210621.GA18360@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 8 Jun 2015, Michal Hocko wrote:

> > This patch is not a functional change, so I don't interpret your feedback 
> > as any support of it being merged.
> 
> David, have you actually read the patch? The changelog is mentioning this:
> "
>     check_panic_on_oom on the other hand will work and that is kind of
>     unexpected because sysrq+f should be usable to kill a mem hog whether
>     the global OOM policy is to panic or not.
>     It also doesn't make much sense to panic the system when no task cannot
>     be killed because admin has a separate sysrq for that purpose.
> "
> and the patch exludes panic_on_oom from the sysrq path.
> 

Yes, and that's why I believe we should pursue that direction without the 
associated "cleanup" that adds 35 lines of code to supress a panic.  In 
other words, there's no reason to combine a patch that suppresses the 
panic even with panic_on_oom, which I support, and a "cleanup" that I 
believe just obfuscates the code.

It's a one-liner change: just test for force_kill and suppress the panic; 
we don't need 35 new lines that create even more unique entry paths.

> > That said, you raise an interesting point of whether sysrq+f should ever 
> > trigger a panic due to panic_on_oom.  The case can be made that it should 
> > ignore panic_on_oom and require the use of another sysrq to panic the 
> > machine instead.  Sysrq+f could then be used to oom kill a process, 
> > regardless of panic_on_oom, and the panic only occurs if userspace did not 
> > trigger the kill or the kill itself will fail.
> 
> Why would it panic the system if there is no killable task? Shoudln't
> be admin able to do additional steps after the explicit oom killer failed
> and only then panic by sysrq?
> 

Today it panics, I don't think it should panic when there are no killable 
processes because it's inherently racy with userspace.  It's similar to 
suppressing panic_on_oom for sysrq+f, but for a different reason, so it 
should probably be a separate patch with its own changelog (and update to 
documentation for both patches to make this explicit).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
