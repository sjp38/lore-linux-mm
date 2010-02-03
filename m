Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5C90E6B004D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 14:52:38 -0500 (EST)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id o13JqVK6004652
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 11:52:31 -0800
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by wpaz5.hot.corp.google.com with ESMTP id o13JqU20004578
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 11:52:30 -0800
Received: by pzk27 with SMTP id 27so1819253pzk.33
        for <linux-mm@kvack.org>; Wed, 03 Feb 2010 11:52:29 -0800 (PST)
Date: Wed, 3 Feb 2010 11:52:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <201002032029.34145.elendil@planet.nl>
Message-ID: <alpine.DEB.2.00.1002031141350.27853@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <4B698CEE.5020806@redhat.com> <20100203170127.GH19641@balbir.in.ibm.com> <20100203170127.GH19641@balbir.in.ibm.com> <alpine.DEB.2.00.1002031021190.14088@chino.kir.corp.google.com>
 <201002032029.34145.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, l.lunak@suse.cz, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, jkosina@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, Frans Pop wrote:

> > * /proc/pid/oom_adj ranges from -1000 to +1000 to either
> > * completely disable oom killing or always prefer it.
> > */
> > points += p->signal->oom_adj;
> > 
> 
> Wouldn't that cause a rather huge compatibility issue given that the 
> current oom_adj works in a totally different way:
> 
> ! 3.1 /proc/<pid>/oom_adj - Adjust the oom-killer score
> ! ------------------------------------------------------
> ! This file can be used to adjust the score used to select which processes
> ! should be killed in an  out-of-memory  situation.  Giving it a high score
> ! will increase the likelihood of this process being killed by the
> ! oom-killer.  Valid values are in the range -16 to +15, plus the special
> ! value -17, which disables oom-killing altogether for this process.
> 
> ?
> 

I thought about whether we'd need an additional, complementary tunable 
such as /proc/pid/oom_bias that would effect this new memory-charging bias 
in the heuristic.  It could be implemented so that writing to oom_adj 
would clear oom_bias and vice versa.

Although that would certainly be possible, I didn't propose it for a 
couple of reasons:

 - it would clutter the space to have two seperate tunables when the 
   metrics that /proc/pid/oom_adj uses has become obsolete by the new
   baseline as a fraction of total RAM, and

 - we have always exported OOM_DISABLE, OOM_ADJUST_MIN, and OOM_ADJUST_MAX
   via include/oom.h so that userspace should use them sanely.  Setting
   a particular oom_adj value for anything other than OOM_DISABLE means 
   the score will be relative to other system tasks, so its a value that 
   is typically calibrated at runtime rather than static, hardcoded 
   values.

We could reuse /proc/pid/oom_adj for the new heuristic by severely 
reducing its granularity than it otherwise would by doing
(oom_adj * 1000 / OOM_ADJUST_MAX), but that will eventually become 
annoying and much more difficult to document.

Given your citation, I don't think we've ever described /proc/pid/oom_adj 
outside of the implementation as a bitshift, either.  So its use right now 
for anything other than OOM_DISABLE is probably based on scalar thinking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
