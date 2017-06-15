Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 318886B0279
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 18:03:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r70so22192127pfb.7
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 15:03:21 -0700 (PDT)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id b80si316432pfb.79.2017.06.15.15.03.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 15:03:20 -0700 (PDT)
Received: by mail-pf0-x232.google.com with SMTP id s66so13321810pfs.1
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 15:03:19 -0700 (PDT)
Date: Thu, 15 Jun 2017 15:03:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is
 freed
In-Reply-To: <20170615214133.GB20321@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1706151459530.64172@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com> <20170615103909.GG1486@dhcp22.suse.cz> <alpine.DEB.2.10.1706151420300.95906@chino.kir.corp.google.com> <20170615214133.GB20321@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 15 Jun 2017, Michal Hocko wrote:

> > Yes, quite a bit in testing.
> > 
> > One oom kill shows the system to be oom:
> > 
> > [22999.488705] Node 0 Normal free:90484kB min:90500kB ...
> > [22999.488711] Node 1 Normal free:91536kB min:91948kB ...
> > 
> > followed up by one or more unnecessary oom kills showing the oom killer 
> > racing with memory freeing of the victim:
> > 
> > [22999.510329] Node 0 Normal free:229588kB min:90500kB ...
> > [22999.510334] Node 1 Normal free:600036kB min:91948kB ...
> > 
> > The patch is absolutely required for us to prevent continuous oom killing 
> > of processes after a single process has been oom killed and its memory is 
> > in the process of being freed.
> 
> OK, could you play with the patch/idea suggested in
> http://lkml.kernel.org/r/20170615122031.GL1486@dhcp22.suse.cz?
> 

I cannot, I am trying to unblock a stable kernel release to my production 
that is obviously fixed with this patch and cannot experiment with 
uncompiled and untested patches that introduce otherwise unnecessary 
locking into the __mmput() path and is based on speculation rather than 
hard data that __mmput() for some reason stalls for the oom victim's mm.  
I was hoping that this fix could make it in time for 4.12 since 4.12 kills 
1-4 processes unnecessarily for each oom condition and then can review any 
tested solution you may propose at a later time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
