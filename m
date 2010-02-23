Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4F5916001DA
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 03:26:09 -0500 (EST)
Message-ID: <4B839103.2060901@cn.fujitsu.com>
Date: Tue, 23 Feb 2010 16:25:39 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time (58568d2)
References: <20100218134921.GF9738@laptop> <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com> <20100219033126.GI9738@laptop> <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com> <20100222121222.GV9738@laptop> <alpine.DEB.2.00.1002221400060.23881@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002221400060.23881@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

on 2010-2-23 6:00, David Rientjes wrote:
> On Mon, 22 Feb 2010, Nick Piggin wrote:
> 
>> If you have a concurrent reader without any synchronisation, then what
>> stops it from loading a word of the mask before stores to add the new
>> nodes and then loading another word of the mask after the stores to
>> remove the old nodes? (which can give an empty mask).
>>
> 
> Currently nothing, so we'll need a variant for configurations where the 
> size of nodemask_t is larger than we can atomically store.
> 

Sorry, Could you explain what you advised?
I think it is hard to fix this problem by adding a variant, because it is
hard to avoid loading a word of the mask before

	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);

and then loading another word of the mask after

	tsk->mems_allowed = *newmems;

unless we use lock.

Maybe we need a rw-lock to protect task->mems_allowed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
