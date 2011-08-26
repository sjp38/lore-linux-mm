Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8723F900138
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 14:21:32 -0400 (EDT)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p7QILNdo001056
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 11:21:23 -0700
Received: from qwj8 (qwj8.prod.google.com [10.241.195.72])
	by wpaz29.hot.corp.google.com with ESMTP id p7QIKk3b022168
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 11:21:22 -0700
Received: by qwj8 with SMTP id 8so2854983qwj.32
        for <linux-mm@kvack.org>; Fri, 26 Aug 2011 11:21:22 -0700 (PDT)
Date: Fri, 26 Aug 2011 11:21:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: VM: add would_have_oomkilled sysctl
In-Reply-To: <20110826161422.GB30573@redhat.com>
Message-ID: <alpine.DEB.2.00.1108261117550.13943@chino.kir.corp.google.com>
References: <20110826161422.GB30573@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, 26 Aug 2011, Dave Jones wrote:

> At various times in the past, we've had reports where users have been
> convinced that the oomkiller was too heavy handed. I added this sysctl
> mostly as a knob for them to see that the kernel really doesn't do much better
> without killing something.
> 

The page allocator expects that the oom killer will kill something to free 
memory so it takes a temporary timeout and then retries the allocation 
indefinitely.  We never oom kill unless we are going to retry 
indefinitely, otherwise it wouldn't be worthwhile.

That said, the only time the oom killer doesn't actually do something is 
when it detects an exiting thread that will hopefully free memory soon or 
when it detects an eligible thread that has already been oom killed and 
we're waiting for it to exit.  So this patch will result in an endless 
series of unratelimited printk's.

Not sure that's very helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
