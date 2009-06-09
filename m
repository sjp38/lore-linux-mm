Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 4F5256B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 15:13:55 -0400 (EDT)
Message-Id: <434B6A05-E82A-4AF4-94E2-E1F3DA9A5268@thehive.com>
From: Matthew Von Maszewski <matthew@thehive.com>
In-Reply-To: <D03E346D-8DDF-4134-84C9-07AB66493A58@thehive.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (Apple Message framework v935.3)
Subject: Re: huge mem mmap eats all CPU when multiple processes
Date: Tue, 9 Jun 2009 15:14:08 -0400
References: <8FDBF172-AAA8-4737-A6C6-50B468CA0CBF@thehive.com> <20090609094117.8226c0ca.kamezawa.hiroyu@jp.fujitsu.com> <D03E346D-8DDF-4134-84C9-07AB66493A58@thehive.com>
Sender: owner-linux-mm@kvack.org
To: Matthew Von Maszewski <matthew@thehive.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Re test program:

I am not yet able to create a simple test program that:

1.  matches the huge mem performance problem seen in "top" sample  
below, and
2.  has clean execution when switched to a non hugemem file/mmap.

Using process shared pthread_mutex_t objects inside tight loops  
creates something similar.  But the huge mem file and standard vm file  
both have the problem.  Maybe this slightly supports Kame's comment  
about activity being serialized on a system mutex for huge mem ? ... I  
am not qualified to judge.

Open to any suggestions for tests / measurements.

Matthew



On Jun 9, 2009, at 10:16 AM, Matthew Von Maszewski wrote:

> My apologies for lack of clarity in the original email.  I am  
> working on a test program to send out later today.   Here are my  
> responses to the questions asked:
>
>
> On Jun 8, 2009, at 8:41 PM, KAMEZAWA Hiroyuki wrote:
>
>> On Mon, 8 Jun 2009 10:27:49 -0400
>> Matthew Von Maszewski <matthew@thehive.com> wrote:
>>
>>> [note: not on kernel mailing list, please cc author]
>>>
>>> Symptom:  9 processes mmap same 2 Gig memory section for a shared C
>>> heap (lots of random access).  All process begin extreme CPU load in
>>> top.
>>>
>>> - Same code works well when only single process access huge mem.
>> Does this "huge mem" means HugeTLB(2M/4Mbytes) pages ?
>
> Yes.  My debian x86_64 kernel build uses 2m pages.  Test by one  
> process is really fast.  Test by multiple process against same  
> mmap() file are really slow
>
>>
>>
>>> - Code works well with standard vm based mmap file and 9 processes.
>>>
>>
>> What is sys/user ratio in top ? Almost all cpus are used by "sys" ?
>
>
> Tasks:  94 total,   3 running,  91 sleeping,   0 stopped,   0 zombie
> Cpu0  :  5.6%us, 86.4%sy,  0.0%ni,  1.3%id,  5.3%wa,  0.0%hi,   
> 1.3%si,  0.0%st
> Cpu1  :  1.0%us, 92.4%sy,  0.0%ni,  0.0%id,  5.6%wa,  0.0%hi,   
> 1.0%si,  0.0%st
> Cpu2  :  1.7%us, 90.4%sy,  0.0%ni,  0.0%id,  7.3%wa,  0.0%hi,   
> 0.7%si,  0.0%st
> Cpu3  :  0.0%us, 70.4%sy,  0.0%ni, 25.1%id,  4.0%wa,  0.0%hi,   
> 0.5%si,  0.0%st
> Mem:   6103960k total,  2650044k used,  3453916k free,     6068k  
> buffers
> Swap:  5871716k total,        0k used,  5871716k free,    84504k  
> cached
>
>  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
> 3681 proxy     20   0 2638m 1596 1312 S   43  0.0   0:07.87  
> tentacle.e.prof
> 3687 proxy     20   0 2656m 1592 1312 S   43  0.0   0:07.69  
> tentacle.e.prof
> 3689 proxy     20   0 2662m 1600 1312 S   42  0.0   0:07.82  
> tentacle.e.prof
> 3683 proxy     20   0 2652m 1596 1312 S   41  0.0   0:07.75  
> tentacle.e.prof
> 3684 proxy     20   0 2650m 1596 1312 S   41  0.0   0:07.89  
> tentacle.e.prof
> 3686 proxy     20   0 2644m 1596 1312 S   40  0.0   0:07.80  
> tentacle.e.prof
> 3685 proxy     20   0 2664m 1592 1312 S   40  0.0   0:07.82  
> tentacle.e.prof
> 3682 proxy     20   0 2646m 1616 1328 S   38  0.0   0:07.73  
> tentacle.e.prof
> 3664 proxy     20   0 2620m 1320  988 R   36  0.0   0:01.08 tentacle.e
> 3678 proxy     20   0 72352  35m 1684 R   11  0.6   0:01.79 squid
>
> tentacle.e and tentacle.e.prof are copies of the same executable  
> file, started with different command line options.  tentacle.e is  
> started by an init.d script.  tentacle.e.prof processes are started  
> by squid.
>
> I am creating a simplified program to duplicate the scenario.  Will  
> send it along later today.
>
>>
>>
>>> Environment:
>>>
>>> - Intel x86_64:  Dual core Xeon with hyperthreading (4 logical
>>> processors)
>>> - 6 Gig ram, 2.5G allocated to huge mem
>> by boot option ?
>
> huge mem initialization
>
> 1.  sysctl.conf allocates the desired number of 2M pages:
>
> system:/mnt$ tail -n 3 /etc/sysctl.conf
> #huge
> vm.nr_hugepages=1200
>
>
> 2. init.d script for tentacle.e mounts the file system and  
> preallocates space
>
> (from init.d file starting tentacle.e)
>
>    umount /mnt/hugefs
>    mount -t hugetlbfs -o uid=proxy,size=2300M none /mnt/hugefs
>
> system:/mnt df -kP
> Filesystem         1024-blocks      Used Available Capacity Mounted on
> /dev/sda1            135601864  32634960  96078636      26% /
> tmpfs                  3051980         0   3051980       0% /lib/ 
> init/rw
> udev                     10240        68     10172       1% /dev
> tmpfs                  3051980         0   3051980       0% /dev/shm
> none                   2355200   2117632    237568      90% /mnt/ 
> hugefs
>
>
>>
>>
>>> - tried with kernels 2.6.29.4 and 2.6.30-rc8
>>> - following mmap() call has base address as NULL on first process,
>>> then returned address passed to subsequent processes (not threads,
>>> processes)
>>>
>>>           m_MemSize=((m_MemSize/(2048*1024))+1)*2048*1024;
>>>            m_BaseAddr=mmap(m_File->GetFixedBase(), m_MemSize,
>>>                            (PROT_READ | PROT_WRITE),
>>>                            MAP_SHARED, m_File->GetFileId(),  
>>> m_Offset);
>>>
>>>
>>> I am not a kernel hacker so I have not attempted to debug.  Will be
>>> able to spend time on a sample program for sharing later today or
>>> tomorrow.  Sending this note now in case this is already known.
>>>
>>
>> IIUC, all page faults to hugetlb are serialized by system's mutex.  
>> Then, touching
>> in parallel doesn't do fast job..
>> Then, I wonder touching all necessary maps by one thread is good,  
>> in general.
>>
>>
>>
>>> Don't suppose this is as simple as a Copy-On-Write flag being set  
>>> wrong?
>>>
>> I don't think, so.
>>
>>> Please send notes as to things I need to capture to better describe
>>> this bug.  Happy to do the work.
>>>
>> Add cc to linux-mm.
>>
>> Thanks,
>> -Kame
>>
>>
>>> Thanks,
>>> Matthew
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux- 
>>> kernel" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
>>>
>>
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
