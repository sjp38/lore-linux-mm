Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9708B6B01F3
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 03:04:49 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o2V74kkC004674
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 09:04:46 +0200
Received: from pwi10 (pwi10.prod.google.com [10.241.219.10])
	by wpaz29.hot.corp.google.com with ESMTP id o2V74h3n008093
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 00:04:44 -0700
Received: by pwi10 with SMTP id 10so8364542pwi.17
        for <linux-mm@kvack.org>; Wed, 31 Mar 2010 00:04:43 -0700 (PDT)
Date: Wed, 31 Mar 2010 00:04:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
In-Reply-To: <20100331153152.3004e41c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003302358500.7072@chino.kir.corp.google.com>
References: <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329140633.GA26464@desktop> <alpine.DEB.2.00.1003291259400.14859@chino.kir.corp.google.com>
 <20100330142923.GA10099@desktop> <alpine.DEB.2.00.1003301326490.5234@chino.kir.corp.google.com> <20100331095714.9137caab.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003302302420.22316@chino.kir.corp.google.com> <20100331151356.673c16c0.kamezawa.hiroyu@jp.fujitsu.com>
 <20100331063007.GN3308@balbir.in.ibm.com> <20100331153152.3004e41c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, anfei <anfei.zhou@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010, KAMEZAWA Hiroyuki wrote:

> "By hand" includes "automatically with daemon program", of course.
> 
> Hmm, in short, your opinion is "killing current is good for now" ?
> 
> I have no strong opinion, here. (Because I'll recommend all customers to
> disable oom kill if they don't want any task to be killed automatically.)
> 

I think there're a couple of options: either define threshold notifiers 
with memory.usage_in_bytes so userspace can proactively address low memory 
situations prior to oom, or use the oom notifier after setting 
echo 1 > /dev/cgroup/blah/memory.oom_control to address those issues 
in userspace as they happen.  If userspace wants to defer back to the 
kernel oom killer because it can't raise max_usage_in_bytes, then
echo 0 > /dev/cgroup/blah/memory.oom_control should take care of it 
instantly and I'd rather see a misconfigured memcg with tasks that are 
OOM_DISABLE but not memcg->oom_kill_disable to be starved of memory than 
panicking the entire system.

Those are good options for users having to deal with low memory 
situations, thanks for continuing to work on it!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
