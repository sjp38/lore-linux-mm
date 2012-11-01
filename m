Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id B43F36B0078
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 19:06:34 -0400 (EDT)
Received: by mail-qc0-f169.google.com with SMTP id t2so1142885qcq.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2012 16:06:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121101154306.c0871efb.akpm@linux-foundation.org>
References: <alpine.DEB.2.00.1210222257580.22198@chino.kir.corp.google.com>
	<CAA25o9ScWUsRr2ziqiEt9U9UvuMuYim+tNpPCyN88Qr53uGhVQ@mail.gmail.com>
	<alpine.DEB.2.00.1210291158510.10845@chino.kir.corp.google.com>
	<CAA25o9Rk_C=jaHJwWQ8TJL0NF5_Xv2umwxirtdugF6w3rHruXg@mail.gmail.com>
	<20121030001809.GL15767@bbox>
	<CAA25o9R0zgW74NRGyZZHy4cFbfuVEmHWVC=4O7SuUjywN+Uvpw@mail.gmail.com>
	<alpine.DEB.2.00.1210292239290.13203@chino.kir.corp.google.com>
	<CAA25o9Tp5J6-9JzwEfcZJ4dHQCEKV9_GYO0ZQ05Ttc3QWP=5_Q@mail.gmail.com>
	<20121031005738.GM15767@bbox>
	<alpine.DEB.2.00.1210311151341.8809@chino.kir.corp.google.com>
	<20121101024316.GB24883@bbox>
	<alpine.DEB.2.00.1210312140090.17607@chino.kir.corp.google.com>
	<CAA25o9SdQ7e5w8=W0faz82nZ7_3N7xbbExKQe0-HsU87hs2MPA@mail.gmail.com>
	<alpine.DEB.2.00.1211011448490.19373@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1211011451480.19373@chino.kir.corp.google.com>
	<20121101154306.c0871efb.akpm@linux-foundation.org>
Date: Thu, 1 Nov 2012 16:06:33 -0700
Message-ID: <CAA25o9S2=Si-Rg=nU5KzdUCqdWMpoefNL=YXAVQb=ZZxYCBB5w@mail.gmail.com>
Subject: Re: [patch] mm, oom: allow exiting threads to have access to memory reserves
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Dan Magenheimer <dan.magenheimer@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Sonny Rao <sonnyrao@google.com>

On Thu, Nov 1, 2012 at 3:43 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Thu, 1 Nov 2012 14:58:18 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
>
>> Exiting threads, those with PF_EXITING set, can pagefault and require
>> memory before they can make forward progress.  This happens, for instance,
>> when a process must fault task->robust_list, a userspace structure, before
>> detaching its memory.
>>
>> These threads also aren't guaranteed to get access to memory reserves
>> unless oom killed or killed from userspace.  The oom killer won't grant
>> memory reserves if other threads are also exiting other than current and
>> stalling at the same point.  This prevents needlessly killing processes
>> when others are already exiting.
>>
>> Instead of special casing all the possible sitations between PF_EXITING
>> getting set and a thread detaching its mm where it may allocate memory,
>> which probably wouldn't get updated when a change is made to the exit
>> path, the solution is to give all exiting threads access to memory
>> reserves if they call the oom killer.  This allows them to quickly
>> allocate, detach its mm, and free the memory it represents.
>
> Seems very sensible.
>
>> Acked-by: Minchan Kim <minchan@kernel.org>
>> Tested-by: Luigi Semenzato <semenzato@google.com>
>
> What did Luigi actually test?  Was there some reproducible bad behavior
> which this patch fixes?

Yes.  I have a load that reliably reproduces the problem (in 3.4), and
it goes away with this change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
