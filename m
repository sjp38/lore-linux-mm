Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 7FE2B6B0033
	for <linux-mm@kvack.org>; Sat, 15 Jun 2013 02:41:10 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id 10so1209897pdi.25
        for <linux-mm@kvack.org>; Fri, 14 Jun 2013 23:41:09 -0700 (PDT)
Date: Sat, 15 Jun 2013 15:41:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Change soft-dirty interface?
Message-ID: <20130615064102.GA7470@gmail.com>
References: <20130613015329.GA3894@bbox>
 <51B98C9A.8020602@parallels.com>
 <20130614003213.GD4533@bbox>
 <20130614004133.GE4533@bbox>
 <20130614050738.GA21852@bbox>
 <51BAE9F3.5030301@parallels.com>
 <20130614112222.GB306@gmail.com>
 <51BB0065.7090408@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51BB0065.7090408@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org


Hi Pavel,

Sorry for the delaying.
Maybe our timezone difference and my boys's interrupt.

On Fri, Jun 14, 2013 at 03:37:09PM +0400, Pavel Emelyanov wrote:
> On 06/14/2013 03:22 PM, Minchan Kim wrote:
> > Hello Pavel,
> > 
> > On Fri, Jun 14, 2013 at 02:01:23PM +0400, Pavel Emelyanov wrote:
> >>>>>>> If it's not allowed, another approach should be new system call.
> >>>>>>>
> >>>>>>>         int sys_softdirty(pid_t pid, void *addr, size_t len);
> >>>>>>
> >>>>>> This looks like existing sys_madvise() one.
> >>>>>
> >>>>> Except pid part. It is added by your purpose, which external task
> >>>>> can control any process.
> >>
> >> In CRIU we can work with pid-less syscalls just fine :) So extending regular
> >> madvise would work.
> > 
> > I didn't know that.
> > Just out of curiosity. How can CRIU control other tasks without pid?
> 
> We use the parasite-injection technique [1]. Briefly -- we put a code into
> other task's address space using ptrace() and /proc/PID/map_files/ and make
> this code run and do what we need. Thus we can call madvise() "on" another
> task.

Interesting.

> 
> [1] http://lwn.net/Articles/454304/


> 
> >>
> >>>>>>
> >>>>>>> If we approach new system call, we don't need to maintain current
> >>>>>>> proc interface and it would be very handy to get a information
> >>>>>>> without pagemap (open/read/close) so we can add a parameter to
> >>>>>>> get a dirty information easily.
> >>>>>>>
> >>>>>>>         int sys_softdirty(pid_t pid, void *addr, size_t len, unsigned char *vec)
> >>>>>>>
> >>>>>>> What do you think about it?
> >>>>>>>
> >>>>>>
> >>>>>> This is OK for me, though there's another issue with this API I'd like
> >>>>>> to mention -- consider your app is doing these tricks with soft-dirty
> >>>>>> and at the same time CRIU tools live-migrate it using the soft-dirty bits
> >>>>>> to optimize the freeze time.
> >>>>>>
> >>>>>> In that case soft-dirty bits would be in wrong state for both -- you app
> >>>>>> and CRIU, but with the proc API we could compare the ctime-s of the 
> >>>>>> clear_refs file and find out, that someone spoiled the soft-dirty state
> >>>>>> from last time we messed with it and handle it somehow (copy all the memory
> >>>>>> in the worst case). Can we somehow handle this with your proposal?
> >>>>>
> >>>>> Good point I didn't think over that.
> >>>>> A simple idea popped from my mind is we can use read/write lock
> >>>>> so if pid is equal to calling process's one or pid is NULL,
> >>>>> we use read side lock, which can allow marking soft-dirty 
> >>>>> several vmas with parallel. And pid is not equal to calling
> >>>>> process's one, the API should try to hold write-side lock
> >>>>> then, if it's fail, the API should return EAGAIN so that CRIU
> >>>>> can progress other processes and retry it after a while.
> >>>>> Of course, it would make live-lock so that sys_softdirty might
> >>>>> need another argument like "int block".
> >>>>
> >>>> And we need a flag to show SELF_SOFT_DIRTY or EXTERNAL_SOFT_DIRTY
> >>>> and the flag will be protected by above lock. It could prevent mixed
> >>>> case by self and external.
> >>>
> >>> I realized it's not enough. Another idea is here.
> >>> The intenion is followin as,
> >>>
> >>> self softdirty VS self softdirty -> NOT exclusive
> >>> self softdirty VS external softdirty -> exclusive
> >>> external softdirty VS external softdirty-> excluisve
> >>
> >> I think it might work for us. However, I have two comments to the
> >> implementation, please see below.
> >>
> >>> struct softdirty token {
> >>>         u64 external;
> >>>         u64 internal;
> >>> };
> >>>
> >>>        int sys_set_softdirty(pid_t pid, unsigned long start, size_t len,
> >>>                                 struct softdirty *token); 
> > 
> > I should have mentioned that start and len are ignored if pid is not eqaul
> > to caller's pid.
> 
> OK
> 
> >>>        int sys_get_softdirty(pid_t pid, unsigned long start, size_t len, 
> >>>                                 struct softdirty token, char *vec);
> >>
> >> Can you please show an example how to use these two, I don't quite get how
> >> can I do external soft-dirty tracking in atomic manner.
> > 
> > Hmm, I don't know how CRIU works but ...
> > 
> > 	while(1) {
> > 
> > 		struct softdirty token;
> > 		
> > 		sys_set_softdirty(tracked_pid, 0, 0, &token);
> > 		...
> > 		...
> > 		...
> > 		if (!sys_get_softdirty(tacked_pid, 0, 0, token, NULL))
> > 			break;
> > 	}
> > 
> > Maybe do you have a concern about live-lock?
> 
> No, I worry about potential races with which we or application can skip
> dirty page. Let me describe how CRIU uses existing soft-dirty implementation.
> 
> 1. stop the task we want to work on
> 2. read the /proc/pid/pagemap file to find out which pages to
>    read. Those with soft-dirty _cleared_ should be _skipped_
> 3. read task's memory at calculated bitmap
> 4. reset soft dirty bits on task
> 5. resume task execution

Let me try to parse as my term.

1. admin does "echo 4 > /proc/<target>/clear_refs"
2. admin stop the target
3. admin reads the /proc/<target>/pagemap and make bitmap
   with only soft-dirty marked pages so we can avoid unnecessary
   migration
4. admin reads target's dirtied pages via bitmap from 3
5. admin does "echo 4 > /proc/<target>/clear_refs" again to find
   future diry pages of the target.
6. admin resumes the target

Right?
If so, my interface is following as

1. admin does set_softdirty(target, 0, 0, &token);
   (set_softdirty clears all soft-dirty bit from target process's
   page table.
2. admin stop the target
3. admin reads the /proc/target/pagemap and make bitmap
   with only soft-dirty marked pages so we can avoid unnecessary
   migration. 
4. admins does get_softdirty(target, 0, 0, token) to confirm
   someone else spoiled since 1
4-1. If it is reports error, then admins discard the bitmap got
     from 3 and have to read all memory.
5. admin does set_softdirty(target, 0, 0, &token) again to find
   future dirty pages of the target  
5. admin resumes the target.

> 
> With the interface you propose the sequence presumably should look like
> 
> 1. stop the task we want to work on
> 2. call set_softdirty + get_softdirty to get the soft-dirty bitmap and
>    reset one. If it reports error, then the soft-dirty we did before is
>    spoiled and all memory should be read (iow -- bitmap should be filled
>    with 1-s)
> 3. read task's memory at calculated bitmap
> 4. resume task execution

> 
> Am I right with this? If yes, why do we need two calls, wouldn't it be better

I failed to parse your terms so I wrote scnario as my understanding
so please see my above sequence and if you have a comment, please ask
again.

> to merge them into one?

It's not hard part but I wanted to show my intention clearly.
If we all agree on, let's think over interface again.

Thanks!

> 
> Thanks,
> Pavel

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
