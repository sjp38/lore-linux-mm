Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4002E6B006C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 18:45:37 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so23202673igb.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 15:45:37 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id mw2si7468828icc.78.2015.06.09.15.45.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 15:45:36 -0700 (PDT)
Received: by igblz2 with SMTP id lz2so21398568igb.1
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 15:45:36 -0700 (PDT)
Date: Tue, 9 Jun 2015 15:45:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: split out forced OOM killer
In-Reply-To: <20150609093659.GA29057@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1506091542120.30516@chino.kir.corp.google.com>
References: <1433235187-32673-1-git-send-email-mhocko@suse.cz> <alpine.DEB.2.10.1506041557070.16555@chino.kir.corp.google.com> <557187F9.8020301@gmail.com> <alpine.DEB.2.10.1506081059200.10521@chino.kir.corp.google.com> <5575E5E6.20908@gmail.com>
 <alpine.DEB.2.10.1506081237350.13272@chino.kir.corp.google.com> <20150608210621.GA18360@dhcp22.suse.cz> <alpine.DEB.2.10.1506081558270.17040@chino.kir.corp.google.com> <20150609093659.GA29057@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 9 Jun 2015, Michal Hocko wrote:

> > Yes, and that's why I believe we should pursue that direction without the 
> > associated "cleanup" that adds 35 lines of code to supress a panic.  In 
> > other words, there's no reason to combine a patch that suppresses the 
> > panic even with panic_on_oom, which I support, and a "cleanup" that I 
> > believe just obfuscates the code.
> > 
> > It's a one-liner change: just test for force_kill and suppress the panic; 
> > we don't need 35 new lines that create even more unique entry paths.
> 
> I completely detest yet another check in out_of_memory. And there is
> even no reason to do that. Forced kill and genuine oom have different
> objectives and combining those two just makes the code harder to read
> (one has to go to check the syrq callback to realize that the forced
> path is triggered from the workqueue context and that current->mm !=
> NULL check will prevent some heuristics. This is just too ugly to
> live). So why the heck are you pushing for keeping everything in a
> single path?
> 

Perhaps if you renamed "force_kill" to "sysrq" it would make more sense to 
you?

I don't think the oom killer needs multiple entry points that duplicates 
code and adds more than twice the lines it removes.  It would make sense 
if that was an optimization in a hot path, or a warm path, or even a 
luke-warm path, but not an icy cold path like the oom killer.  
check_panic_on_oom() can simply do

	if (sysrq)
		return;

It's not hard and it's very clear.  We don't need 35 more lines of code to 
do this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
