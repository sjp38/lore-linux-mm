Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id B95436B00FD
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 19:34:41 -0500 (EST)
Message-ID: <4F443814.6050209@fb.com>
Date: Tue, 21 Feb 2012 16:34:28 -0800
From: Arun Sharma <asharma@fb.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Enable MAP_UNINITIALIZED for archs with mmu
References: <1326912662-18805-1-git-send-email-asharma@fb.com> <20120119114206.653b88bd.kamezawa.hiroyu@jp.fujitsu.com> <4F1E013E.9060009@fb.com> <20120124120704.3f09b206.kamezawa.hiroyu@jp.fujitsu.com> <4F1F5EB8.3000407@fb.com>
In-Reply-To: <4F1F5EB8.3000407@fb.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, akpm@linux-foundation.org

On 1/24/12 5:45 PM, Arun Sharma wrote:
> On 1/23/12 7:07 PM, KAMEZAWA Hiroyuki wrote:
>
>> You can see reduction of clear_page() cost by removing GFP_ZERO but
>> what's your application's total performance ? Is it good enough
>> considering
>> many risks ?
>
> I see 90k calls/sec to clear_page_c when running our application. I
> don't have data on the impact of GFP_ZERO alone, but an earlier
> experiment when we tuned malloc to not call madvise(MADV_DONTNEED)
> aggressively saved us 3% CPU. So I'm expecting this to be a 1-2% win.

I saw some additional measurement data today.

We were running at a lower-than-default value for the rate at which our 
malloc implementation releases unused faulted-in memory to the kernel 
via madvise(). This was done just to reduce the impact of clear_page() 
on application performance. But it cost us at least several hundred megs 
(if not more) in additional RSS.

We compared the impact of increasing the madvise rate to the default[1]. 
This used to cause a 3% CPU regression earlier. But with the patch, the 
regression was completely gone and we recovered a bunch of memory in 
terms of reduced RSS.

Hope this additional data is useful. Happy to clean up the patch and 
implement the opt-in flags.

  -Arun

[1] The default rate is 32:1, i.e. no more than 1/32th of the heap is 
unused and dirty (i.e. contributing to RSS).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
