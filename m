Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 3E86B6B004D
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 20:45:36 -0500 (EST)
Message-ID: <4F1F5EB8.3000407@fb.com>
Date: Tue, 24 Jan 2012 17:45:28 -0800
From: Arun Sharma <asharma@fb.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Enable MAP_UNINITIALIZED for archs with mmu
References: <1326912662-18805-1-git-send-email-asharma@fb.com> <20120119114206.653b88bd.kamezawa.hiroyu@jp.fujitsu.com> <4F1E013E.9060009@fb.com> <20120124120704.3f09b206.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120124120704.3f09b206.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Balbir Singh <bsingharora@gmail.com>, akpm@linux-foundation.org

On 1/23/12 7:07 PM, KAMEZAWA Hiroyuki wrote:

> You can see reduction of clear_page() cost by removing GFP_ZERO but
> what's your application's total performance ? Is it good enough considering
> many risks ?

I see 90k calls/sec to clear_page_c when running our application. I 
don't have data on the impact of GFP_ZERO alone, but an earlier 
experiment when we tuned malloc to not call madvise(MADV_DONTNEED) 
aggressively saved us 3% CPU. So I'm expecting this to be a 1-2% win.

But not calling madvise() increases our RSS and increases the risk of OOM.

Agree with your analysis that removing the cache misses at clear_page() 
is not always a win, since it moves the misses to the code where the app 
first touches the data.

  -Arun


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
