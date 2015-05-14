Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2496B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 06:32:24 -0400 (EDT)
Received: by wizk4 with SMTP id k4so235106140wiz.1
        for <linux-mm@kvack.org>; Thu, 14 May 2015 03:32:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fk8si4148630wib.21.2015.05.14.03.32.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 14 May 2015 03:32:22 -0700 (PDT)
Date: Thu, 14 May 2015 12:31:49 +0200
From: Cyril Hrubis <chrubis@suse.cz>
Subject: Re: Possible bug - LTP failure for memcg
Message-ID: <20150514103148.GA5066@rei.suse.de>
References: <55536DC9.90200@kyup.com>
 <20150514092145.GA6799@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150514092145.GA6799@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Nikolay Borisov <kernel@kyup.com>, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

Hi!
> > The failing test cases 14, 22, 23, 24 and 30 test respectively:
> > 
> > 14: Hogging memory like so: mmap(NULL, memsize, PROT_WRITE | PROT_READ,
> > MAP_PRIVATE | MAP_ANONYMOUS | MAP_LOCKED, 0, 0);
> 
> MAP_LOCKED will not trigger the OOM killer as explained
> http://marc.info/?l=linux-mm&m=142122902313315&w=2. So this is expected
> and Cyril is working on fixing the test case.

It's on my TODO, I should get to this i a few weeks. Till then just
ignore the failure.

> > # Case 22 - 24: Test limit_in_bytes will be aligned to PAGESIZE - The
> > output clearly indicates that the limits in bytes is not being page
> > aligned?
> 
> I can see
> > memcg_function_test   22  TFAIL  :  ltpapicmd.c:190: input=4095,
> > limit_in_bytes=0
> > memcg_function_test   23  TFAIL  :  ltpapicmd.c:190: input=4097,
> > limit_in_bytes=4096
> > memcg_function_test   24  TFAIL  :  ltpapicmd.c:190: input=1,
> > limit_in_bytes=0
> 
> So limit_in_bytes _is_ page aligned but we round down rather than up.
> 
> > Is this desired behavior, in which case ltp is broken or is it
> > a genuine bug?
> 
> This behavior has changed by 3e32cb2e0a12 ("mm: memcontrol: lockless
> page counters") introduced in 3.19. The change in rounding has been
> pointed out during the review
> http://marc.info/?l=linux-mm&m=141207518827336&w=2 but the conclusion
> was that the original round up wasn't really much better
> http://marc.info/?l=linux-mm&m=141226210316376&w=2 resp.
> http://marc.info/?l=linux-mm&m=141234785111200&w=2
> 
> I will post fix for ltp in the reply
> 
> > 30: Again, it locks memory with mmap and then tries to see if
> > force_empty would succeed. Expecting it to fail, but in this particular
> > case it succeeds?
> 
> I am not sure I understand this testcase. It does:
> 	TEST_PATH/memcg_process --mmap-anon -s $PAGESIZE
> 	[...]

Looking at the code, it does two more things here:

echo $pid > tasks
kill -s USR1 $pid 2> /dev/null

Sending SIGUSR1 to the memcg_process causes it to repeat the allocation
that has been passed to it by the command line parameters.

So my guess is that it expect the force_empty to fail if the process has
allocated some memory after it has been moved to the current cgroup.

The previous testcases does exactly this but moves the process to the
parent with:

echo $pid > ../tasks

Before it tries the force_empty and expects it to succeed.

Was this some old implementation limitation that has been lifted
meanwhile?

-- 
Cyril Hrubis
chrubis@suse.cz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
