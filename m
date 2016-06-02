Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DBC406B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 07:21:00 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e3so25711146wme.3
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 04:21:00 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id he4si40411wjb.207.2016.06.02.04.20.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 04:20:59 -0700 (PDT)
Received: by mail-wm0-f43.google.com with SMTP id a20so62995391wma.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 04:20:59 -0700 (PDT)
Date: Thu, 2 Jun 2016 13:20:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm, oom: skip vforked tasks from being selected
Message-ID: <20160602112057.GI1995@dhcp22.suse.cz>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-5-git-send-email-mhocko@kernel.org>
 <201606012312.BIF26006.MLtFVQSJOHOFOF@I-love.SAKURA.ne.jp>
 <20160601142502.GY26601@dhcp22.suse.cz>
 <201606021945.AFH26572.OJMVLFOHFFtOSQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606021945.AFH26572.OJMVLFOHFFtOSQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

On Thu 02-06-16 19:45:00, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 01-06-16 23:12:20, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > vforked tasks are not really sitting on any memory. They are sharing
> > > > the mm with parent until they exec into a new code. Until then it is
> > > > just pinning the address space. OOM killer will kill the vforked task
> > > > along with its parent but we still can end up selecting vforked task
> > > > when the parent wouldn't be selected. E.g. init doing vfork to launch
> > > > a task or vforked being a child of oom unkillable task with an updated
> > > > oom_score_adj to be killable.
> > > > 
> > > > Make sure to not select vforked task as an oom victim by checking
> > > > vfork_done in oom_badness.
> > > 
> > > While vfork()ed task cannot modify userspace memory, can't such task
> > > allocate significant amount of kernel memory inside execve() operation
> > > (as demonstrated by CVE-2010-4243 64bit_dos.c )?
> > > 
> > > It is possible that killing vfork()ed task releases a lot of memory,
> > > isn't it?
> > 
> > I am not familiar with the above CVE but doesn't that allocated memory
> > come after flush_old_exec (and so mm_release)?
> 
> That memory is allocated as of copy_strings() in do_execveat_common().
> 
> An example shown below (based on https://grsecurity.net/~spender/exploits/64bit_dos.c )
> can consume nearly 50% of 2GB RAM while execve() from vfork(). That is, selecting
> vfork()ed task as an OOM victim might release nearly 50% of 2GB RAM.
> 
> ----------
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <unistd.h>
> 
> #define NUM_ARGS 8000 /* Nearly 50% of 2GB RAM */
> 
> int main(void)
> {
>         /* Be sure to do "ulimit -s unlimited" before run. */
>         char **args;
>         char *str;
>         int i;
>         str = malloc(128 * 1024);
>         memset(str, ' ', 128 * 1024 - 1);
>         str[128 * 1024 - 1] = '\0';
>         args = malloc(NUM_ARGS * sizeof(char *));
>         for (i = 0; i < (NUM_ARGS - 1); i++)
>                 args[i] = str;
>         args[i] = NULL;
>         if (vfork() == 0) {
>                 execve("/bin/true", args, NULL);
>                 _exit(1);
>         }
>         return 0;
> }

OK, but the memory is allocated on behalf of the parent already, right?
And the patch doesn't prevent parent from being selected and the vfroked
child being killed along the way as sharing the mm with it. So what
exactly this patch changes for this test case? What am I missing?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
