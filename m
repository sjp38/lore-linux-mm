Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CC036B0003
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 02:10:25 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id m4-v6so21738543pgv.15
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 23:10:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o18-v6sor9753597pgv.19.2018.10.17.23.10.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Oct 2018 23:10:24 -0700 (PDT)
Date: Thu, 18 Oct 2018 15:10:18 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3] mm: memcontrol: Don't flood OOM messages with no
 eligible task.
Message-ID: <20181018061018.GB650@jagdpanzerIV>
References: <201810180246.w9I2koi3011358@www262.sakura.ne.jp>
 <20181018042739.GA650@jagdpanzerIV>
 <201810180526.w9I5QvVn032670@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201810180526.w9I5QvVn032670@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>

On (10/18/18 14:26), Tetsuo Handa wrote:
> Sergey Senozhatsky wrote:
> > To my personal taste, "baud rate of registered and enabled consoles"
> > approach is drastically more relevant than hard coded 10 * HZ or
> > 60 * HZ magic numbers... But not in the form of that "min baud rate"
> > brain fart, which I have posted.
> 
> I'm saying that my 60 * HZ is "duration which the OOM killer keeps refraining
>  from calling printk()". Such period is required for allowing console users
> to do their operations without being disturbed by the OOM killer.
> 

Got you. I'm probably not paying too much attention to this discussion.
You start your commit message with "RCU stalls" and end with a compleely
different problem "admin interaction". I skipped the last part of the
commit message.

OK. That makes sense if any user intervention/interaction actually happens.
I'm not sure that someone at facebook or google logins to every server
that is under OOM to do something critically important there. Net console
logs and postmortem analysis, *perhaps*, would be their choice. I believe
it was Johannes who said that his net console is capable of keeping up
with the traffic and that 60 * HZ is too long for him. So I can see why
people might not be happy with your patch. I don't think that 60 * HZ
enforcement will go anywhere.

Now, if your problem is
     "I'm actually logged in, and want to do something
      sane, how do I stop this OOM report flood because
      it wipes out everything I have on my console?"

then let's formulate it as
     "I'm actually logged in, and want to do something
      sane, how do I stop this OOM report flood because
      it wipes out everything I have on my console?"

and let's hear from MM people what they can suggest.

Michal, Andrew, Johannes, any thoughts?

For instance,
   change /proc/sys/kernel/printk and suppress most of the warnings?

   // not only OOM but possibly other printk()-s that can come from
   // different CPUs

If your problem is "syzbot hits RCU stalls" then let's have a baud rate
based ratelimiting; I think we can get more or less reasonable timeout
values.

	-ss
