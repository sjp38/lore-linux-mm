Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 97A076B004D
	for <linux-mm@kvack.org>; Mon, 23 Jan 2012 19:54:23 -0500 (EST)
Message-ID: <4F1E013E.9060009@fb.com>
Date: Mon, 23 Jan 2012 16:54:22 -0800
From: Arun Sharma <asharma@fb.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Enable MAP_UNINITIALIZED for archs with mmu
References: <1326912662-18805-1-git-send-email-asharma@fb.com> <20120119114206.653b88bd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120119114206.653b88bd.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, akpm@linux-foundation.org

On 1/18/12 6:42 PM, KAMEZAWA Hiroyuki wrote:
>
> Hmm, then,
> 1. a new task jumped into this cgroup can see any uncleared data...
> 2. if a memcg pointer is reused, the information will be leaked.

You're suggesting mm_match_cgroup() is good enough for accounting 
purposes, but not usable for cases where its important to get the 
equality right?

> 3. If VM_UNINITALIZED is set, the process can see any data which
>     was freed by other process which doesn't know VM_UNINITALIZED at all.
>
> 4. The process will be able to see file cache data which the it has no
>     access right if it's accessed by memcg once.
>
> 3&  4 seems too danger.

Yes - these are the risks that I'm hoping we can document, so the 
cgroups admin can avoid opting-in if not everything running in the 
cgroup is trusted.

>
> Isn't it better to have this as per-task rather than per-memcg ?
> And just allow to reuse pages the page has freed ?
>

I'm worrying that the additional complexity of maintaining a per-task 
page list would be a problem. It might slow down workloads that 
alloc/free a lot because of the added code. It'll probably touch the 
kswapd as well (for reclaiming pages from the per-task free lists under 
low mem conditions).

Did you have some implementation ideas which would not have the problems 
above?

  -Arun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
