Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4FCC16B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 15:54:00 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id n9TJrua6029270
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 19:53:56 GMT
Received: from gv-out-0910.google.com (gvdc6.prod.google.com [10.16.130.6])
	by wpaz21.hot.corp.google.com with ESMTP id n9TJrraN006954
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 12:53:53 -0700
Received: by gv-out-0910.google.com with SMTP id c6so378801gvd.6
        for <linux-mm@kvack.org>; Thu, 29 Oct 2009 12:53:53 -0700 (PDT)
Date: Thu, 29 Oct 2009 12:53:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <4AE97861.1070902@gmail.com>
Message-ID: <alpine.DEB.2.00.0910291248480.2276@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org> <20091014135119.e1baa07f.kamezawa.hiroyu@jp.fujitsu.com> <4ADE3121.6090407@gmail.com> <20091026105509.f08eb6a3.kamezawa.hiroyu@jp.fujitsu.com> <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com> <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com>
 <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com> <20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com> <20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910290136000.11476@chino.kir.corp.google.com> <4AE97861.1070902@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: vedran.furac@gmail.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Oct 2009, Vedran Furac wrote:

> But then you should rename OOM killer to TRIPK:
> Totally Random Innocent Process Killer
> 

The randomness here is the order of the child list when the oom killer 
selects a task, based on the badness score, and then tries to kill a child 
with a different mm before the parent.

The problem you identified in http://pastebin.com/f3f9674a0, however, is a 
forkbomb issue where the badness score should never have been so high for 
kdeinit4 compared to "test".  That's directly proportional to adding the 
scores of all disjoint child total_vm values into the badness score for 
the parent and then killing the children instead.

That's the problem, not using total_vm as a baseline.  Replacing that with 
rss is not going to solve the issue and reducing the user's ability to 
specify a rough oom priority from userspace is simply not an option.

> If you have OOM situation and Xorg is the first, that means it's leaking
> memory badly and the system is probably already frozen/FUBAR. Killing
> krunner in that situation wouldn't do any good. From a user perspective,
> nothing changes, system is still FUBAR and (s)he would probably reboot
> cursing linux in the process.
> 

It depends on what you're running, we need to be able to have the option 
of protecting very large tasks on production servers.  Imagine if "test" 
here is actually a critical application that we need to protect, its 
not solely mlocked anonymous memory, but still kill if it is leaking 
memory beyond your approximate 2.5GB.  How do you do that when using rss 
as the baseline?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
