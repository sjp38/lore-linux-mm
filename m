Message-ID: <40CE66EE.8090903@yahoo.com.au>
Date: Tue, 15 Jun 2004 13:03:10 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Keeping mmap'ed files in core regression in 2.6.7-rc
References: <20040608142918.GA7311@traveler.cistron.net> <40CAA904.8080305@yahoo.com.au> <20040614140642.GE13422@traveler.cistron.net>
In-Reply-To: <20040614140642.GE13422@traveler.cistron.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miquel van Smoorenburg <miquels@cistron.nl>, Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Miquel van Smoorenburg wrote:
> On 2004.06.12 08:56, Nick Piggin wrote:
> 
>>Miquel van Smoorenburg wrote:
>>
>>
>>>Now I tried 2.6.7-rc2 and -rc3 (well rc2-bk-latest-before-rc3) and
>>>with those kernels, performance goes to hell because no matter
>>>how much I tune, the kernel will throw out the mmap'ed pages first.
>>>RSS of the innd process hovers around 200-250 MB instead of 600.
>>>
>>>Ideas ?
>>>
>>
>>Can you try the following patch please?
> 
> 
> The patch below indeed fixes this problem. Now most of the mmap'ed files
> are actually kept in memory and RSS is around 600 MB again:
> 

OK good. Cc'ing Andrew.

> $ uname -a
> Linux quantum 2.6.7-rc3 #1 SMP Mon Jun 14 12:48:34 CEST 2004 i686 GNU/Linux
> $ free
>              total       used       free     shared    buffers     cached
> Mem:       1037240     897668     139572          0     159320     501688
> -/+ buffers/cache:     236660     800580
> Swap:       996020      16160     979860
> $ ps u -C innd
> USER       PID %CPU %MEM   VSZ  RSS TTY      STAT START   TIME COMMAND
> news       277 31.8 56.2 857124 583896 ?     D    13:02  57:01 /usr/local/news/b
> 
> Hmm, weird that 'free' says that 139 MB is unused.. the box is doing
> lots of I/O. 'free' hovers between 30 - 250 MB over time.
> 
> Look, 1 minute later:
> 
> $ free
>              total       used       free     shared    buffers     cached
> Mem:       1037240     788368     248872          0      29260     497600
> -/+ buffers/cache:     261508     775732
> Swap:       996020      16260     979760
> 
> Ah wait, that appears to be an outgoing feed process that keeps on allocating
> and freeing memory at a fast rate, so that makes sense I guess. At least

That would be right.

> the RSS of the main innd process remains steady at around ~600 MB and that
> is what is important for this application.
> 

Absolute performance is the thing that matters at the end of the day.
Is it as good as 2.6.6 now?

Thanks
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
