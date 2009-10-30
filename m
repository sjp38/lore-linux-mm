Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3FBC66B004D
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 09:53:39 -0400 (EDT)
Received: by fg-out-1718.google.com with SMTP id d23so1334334fga.8
        for <linux-mm@kvack.org>; Fri, 30 Oct 2009 06:53:36 -0700 (PDT)
Message-ID: <4AEAEFDD.5060009@gmail.com>
Date: Fri, 30 Oct 2009 14:53:33 +0100
From: =?UTF-8?B?VmVkcmFuIEZ1cmHEjQ==?= <vedran.furac@gmail.com>
Reply-To: vedran.furac@gmail.com
MIME-Version: 1.0
Subject: Re: Memory overcommit
References: <hav57c$rso$1@ger.gmane.org> <20091013120840.a844052d.kamezawa.hiroyu@jp.fujitsu.com> <hb2cfu$r08$2@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com> <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com> <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <4AE846E8.1070303@gmail.com> <alpine.DEB.2.00.0910281307370.23279@chino.kir.corp.google.com> <4AE9068B.7030504@gmail.com> <alpine.DEB.2.00.0910290132320.11476@chino.kir.corp.google.com> <4AE97618.6060607@gmail.com> <alpine.DEB.2.00.0910291225460.27732@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.0910291225460.27732@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:

> Ok, so this is the forkbomb problem by adding half of each child's 
> total_vm into the badness score of the parent.  We should address this 
> completely seperately by addressing that specific part of the heuristic, 
> not changing what we consider to be a baseline.
> thunderbird.
>
> You're making all these claims and assertions based _solely_ on the theory 
> that killing the application with the most resident RAM is always the 
> optimal solution.  That's just not true, especially if we're just 
> allocating small numbers of order-0 memory.

Well, you are kernel hacker, not me. You know how linux mm works much
more than I do. I just reported a, what I think is a big problem, which
needs to be solved ASAP (2.6.33). I'm afraid that we'll just talk much
and nothing will be done with solution/fix postponed indefinitely. Not
sure if you are interested, but I tested this on windowsxp also, and
nothing bad happens there, system continues to function properly.

For 2-3 years I had memory overcommit turn off. I didn't get any OOM,
but sometimes Java didn't work and it seems that because of some kernel
weirdness (or misunderstanding on my part) I couldn't use all the
available memory:

# echo 2 > /proc/sys/vm/overcommit_memory

# echo 95 > /proc/sys/vm/overcommit_ratio
% ./test  /* malloc in loop as before */
malloc: Cannot allocate memory /* Great, no OOM, but: */

% free -m
          total       used       free     shared    buffers     cached
Mem:      3458        3429         29          0        102       1119
-/+ buffers/cache:    2207       1251

There's plenty of memory available. Shouldn't cache be automatically
dropped (this question was in my original mail, hence the subject)?

All this frustrated not only me, but a great number of users on our
local Croatian linux usenet newsgroup with some of them pointing that as
the reason they use solaris. And so on...

> Much better is to allow the user to decide at what point, regardless of 
> swap usage, their application is using much more memory than expected or 
> required.  They can do that right now pretty well with /proc/pid/oom_adj 
> without this outlandish claim that they should be expected to know the rss 
> of their applications at the time of oom to effectively tune oom_adj.

Believe me, barely a few developers use oom_adj for their applications,
and probably almost none of the end users. What should they do, every
time they start an application, go to console and set the oom_adj. You
cannot expect them to do that.

> What would you suggest?  A script that sits in a loop checking each task's 
> current rss from /proc/pid/stat or their current oom priority though 
> /proc/pid/oom_score and adjusting oom_adj preemptively just in case the 
> oom killer is invoked in the next second?

:)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
