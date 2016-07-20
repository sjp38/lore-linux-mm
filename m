Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7B826B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 09:33:40 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so32796486lfi.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 06:33:40 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id si9si985836wjb.162.2016.07.20.06.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 06:33:39 -0700 (PDT)
Date: Wed, 20 Jul 2016 09:33:37 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: oom-reaper choosing wrong processes.
Message-ID: <20160720133337.GA12457@codemonkey.org.uk>
References: <20160718231850.GA23178@codemonkey.org.uk>
 <20160719090857.GB9490@dhcp22.suse.cz>
 <20160719153335.GA11863@codemonkey.org.uk>
 <20160720070923.GC11249@dhcp22.suse.cz>
 <20160720132304.GA11434@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160720132304.GA11434@codemonkey.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

On Wed, Jul 20, 2016 at 09:23:04AM -0400, Dave Jones wrote:
 
 >  > so this task has been already oom reaped and so oom_badness will ignore
 >  > it (it simply doesn't make any sense to select this task because it
 >  > has been already killed or exiting and oom reaped as well). Others might
 >  > be in a similar position or they might have passed exit_mm->tsk->mm = NULL
 >  > so they are ignored by the oom killer as well.
 > 
 > I feel like I'm still missing something.  Why isn't "wait for the already reaped trinity tasks to exit"
 > the right thing to do here (as my diff forced it to do), instead of "pick even more victims even
 > though we've already got some reaped processes that haven't exited"
 > 
 > Not killing systemd-journald allowed the machine to keep running just fine.
 > If I hadn't have patched that out, it would have been killed unnecessarily.

nm, I figured it out. As Tetsuo pointed out, I was leaking a task struct,
so those already reaped trinity processes would never truly 'exit'.

Mea culpa, thanks.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
