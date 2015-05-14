Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 89B8D6B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 07:56:44 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so13304525wic.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 04:56:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hw1si12182839wjb.150.2015.05.14.04.56.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 04:56:42 -0700 (PDT)
Date: Thu, 14 May 2015 13:56:41 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Possible bug - LTP failure for memcg
Message-ID: <20150514115641.GE6799@dhcp22.suse.cz>
References: <55536DC9.90200@kyup.com>
 <20150514092145.GA6799@dhcp22.suse.cz>
 <20150514103148.GA5066@rei.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150514103148.GA5066@rei.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyril Hrubis <chrubis@suse.cz>
Cc: Nikolay Borisov <kernel@kyup.com>, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Thu 14-05-15 12:31:49, Cyril Hrubis wrote:
[...]
> Looking at the code, it does two more things here:
> 
> echo $pid > tasks
> kill -s USR1 $pid 2> /dev/null
> 
> Sending SIGUSR1 to the memcg_process causes it to repeat the allocation
> that has been passed to it by the command line parameters.
> 
> So my guess is that it expect the force_empty to fail if the process has
> allocated some memory after it has been moved to the current cgroup.

force_empty fails if the memcg cannot be reclaimed down to 0. The memory
charged after the task has moved to the group is easily reclaimable so
I do not see any reason why we would fail here.

> The previous testcases does exactly this but moves the process to the
> parent with:
> 
> echo $pid > ../tasks
> 
> Before it tries the force_empty and expects it to succeed.
> 
> Was this some old implementation limitation that has been lifted
> meanwhile?

OK, now I remember... f61c42a7d911 ("memcg: remove tasks/children test
from mem_cgroup_force_empty()") which goes back to 3.16. So the test
case is invalid.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
