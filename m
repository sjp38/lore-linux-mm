Received: by ug-out-1314.google.com with SMTP id 34so1604889ugf.19
        for <linux-mm@kvack.org>; Thu, 27 Nov 2008 04:52:14 -0800 (PST)
Message-ID: <492E97FA.5000804@gmail.com>
Date: Thu, 27 Nov 2008 14:52:10 +0200
From: =?ISO-8859-1?Q?T=F6r=F6k_Edwin?= <edwintorok@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC v1][PATCH]page_fault retry with NOPAGE_RETRY
References: <604427e00811212247k1fe6b63u9efe8cfe37bddfb5@mail.gmail.com> <20081123091843.GK30453@elte.hu> <604427e00811251042t1eebded6k9916212b7c0c2ea0@mail.gmail.com> <20081126123246.GB23649@wotan.suse.de> <492DAA24.8040100@google.com> <20081127085554.GD28285@wotan.suse.de> <492E6849.6090205@google.com> <492E8708.4060601@gmail.com> <20081127120330.GM28285@wotan.suse.de> <492E90BC.1090208@gmail.com> <20081127123926.GN28285@wotan.suse.de>
In-Reply-To: <20081127123926.GN28285@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Mike Waychison <mikew@google.com>, Ying Han <yinghan@google.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rohit Seth <rohitseth@google.com>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On 2008-11-27 14:39, Nick Piggin wrote:
> On Thu, Nov 27, 2008 at 02:21:16PM +0200, Torok Edwin wrote:
>   
>> On 2008-11-27 14:03, Nick Piggin wrote:
>>     
>>>> Running my testcase shows no significant performance difference. What am
>>>> I doing wrong?
>>>>     
>>>>         
>>>  
>>> Software may just be doing a lot of mmap/munmap activity. threads +
>>> mmap is never going to be pretty because it is always going to involve
>>> broadcasting tlb flushes to other cores... Software writers shouldn't
>>> be scared of using processes (possibly with some shared memory).
>>>   
>>>       
>> It would be interesting to compare the performance of a threaded clamd,
>> and of a clamd that uses multiple processes.
>> Distributing tasks will be a bit more tricky, since it would need to use
>> IPC, instead of mutexes and condition variables.
>>     
>
> Yes, although you could use PTHREAD_PROCESS_SHARED pthread mutexes on
> the shared memory I believe (having never tried it myself).
>
>  
>   
>>> Actually, a lot of things get faster (like malloc, or file descriptor
>>> operations) because locks aren't needed.
>>>
>>> Despite common perception, processes are actually much *faster* than
>>> threads when doing common operations like these. They are slightly slower
>>> sometimes with things like creation and exit, or context switching, but
>>> if you're doing huge numbers of those operations, then it is unlikely
>>> to be a performance critical app... :)
>>>   
>>>       
>> How about distributing tasks to a set of worked threads, is the overhead
>> of using IPC instead of
>> mutexes/cond variables acceptable?
>>     
>
> It is really going to depend on a lot of things. What is involved in
> distributing tasks, how many cores and cache/TLB architecture of the
> system running on, etc.
>
> You want to distribute as much work as possible while touching as
> little memory as possible, in general.
>
> But if you're distributing threads over cores, and shared caches are
> physically tagged (which I think all x86 CPUs are), then you should
> be able to have multiple processes operate on shared memory just as
> efficiently as multiple threads I think.
>
> And then you also get the advantages of reduced contention on other
> shared locks and resources.
>   

Thanks for the tips, but lets get back to the original question:
why don't I see any performance improvement with the fault-retry patches?

My testcase only compares reads file with mmap, vs. reading files with
read, with different number of threads.
Leaving aside other reasons why mmap is slower, there should be some
speedup by running 4 threads vs 1 thread, but:

1 thread: read:27,18 28.76
1 thread: mmap: 25.45, 25.24
2 thread: read: 16.03, 15.66
2 thread: mmap: 22.20, 20.99
4 thread: read: 9.15, 9.12
4 thread: mmap: 20.38, 20.47

The speed of 4 threads is about the same as for 2 threads with mmap, yet
with read it scales nicely.
And the patch doesn't seem to improve scalability.
How can I find out if the patch works as expected? [i.e. verify that
faults are actually retried, and that they don't keep the semaphore locked]

> OK, I'll see if I can find them (am overseas at the moment, and I suspect
> they are stranded on some stationary rust back home, but I might be able
> to find them on the web).

Ok.

Best regards,
--Edwin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
