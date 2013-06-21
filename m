Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 5417E6B0037
	for <linux-mm@kvack.org>; Thu, 20 Jun 2013 21:41:33 -0400 (EDT)
Date: Fri, 21 Jun 2013 10:41:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Change soft-dirty interface?
Message-ID: <20130621014145.GH11659@bbox>
References: <20130613015329.GA3894@bbox>
 <51B98C9A.8020602@parallels.com>
 <20130614003213.GD4533@bbox>
 <20130614004133.GE4533@bbox>
 <20130614050738.GA21852@bbox>
 <51BAE9F3.5030301@parallels.com>
 <20130614112222.GB306@gmail.com>
 <51BB0065.7090408@parallels.com>
 <20130615064102.GA7470@gmail.com>
 <51C17A70.9090508@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51C17A70.9090508@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Wed, Jun 19, 2013 at 01:31:28PM +0400, Pavel Emelyanov wrote:
> >>> Maybe do you have a concern about live-lock?
> >>
> >> No, I worry about potential races with which we or application can skip
> >> dirty page. Let me describe how CRIU uses existing soft-dirty implementation.
> >>
> >> 1. stop the task we want to work on
> >> 2. read the /proc/pid/pagemap file to find out which pages to
> >>    read. Those with soft-dirty _cleared_ should be _skipped_
> >> 3. read task's memory at calculated bitmap
> >> 4. reset soft dirty bits on task
> >> 5. resume task execution
> > 
> > Let me try to parse as my term.
> > 
> > 1. admin does "echo 4 > /proc/<target>/clear_refs"
> > 2. admin stop the target
> > 3. admin reads the /proc/<target>/pagemap and make bitmap
> >    with only soft-dirty marked pages so we can avoid unnecessary
> >    migration
> > 4. admin reads target's dirtied pages via bitmap from 3
> > 5. admin does "echo 4 > /proc/<target>/clear_refs" again to find
> >    future diry pages of the target.
> > 6. admin resumes the target
> > 
> > Right?
> 
> Almost, the step #1 looks excessive. We shouldn't clear the soft dirty
> _before_ stopping the target, otherwise we lose all the bits "collected"
> before it.
> 
> > If so, my interface is following as
> > 
> > 1. admin does set_softdirty(target, 0, 0, &token);
> >    (set_softdirty clears all soft-dirty bit from target process's
> >    page table.
> > 2. admin stop the target
> > 3. admin reads the /proc/target/pagemap and make bitmap
> >    with only soft-dirty marked pages so we can avoid unnecessary
> >    migration. 
> > 4. admins does get_softdirty(target, 0, 0, token) to confirm
> >    someone else spoiled since 1
> > 4-1. If it is reports error, then admins discard the bitmap got
> >      from 3 and have to read all memory.
> > 5. admin does set_softdirty(target, 0, 0, &token) again to find
> >    future dirty pages of the target  
> > 5. admin resumes the target.
> 
> Same here -- if we skip step #1, then we can merge steps 4 and 5 into
> one system call. Can we?
> 
> >>
> >> With the interface you propose the sequence presumably should look like
> >>
> >> 1. stop the task we want to work on
> >> 2. call set_softdirty + get_softdirty to get the soft-dirty bitmap and
> >>    reset one. If it reports error, then the soft-dirty we did before is
> >>    spoiled and all memory should be read (iow -- bitmap should be filled
> >>    with 1-s)
> >> 3. read task's memory at calculated bitmap
> >> 4. resume task execution
> > 
> >>
> >> Am I right with this? If yes, why do we need two calls, wouldn't it be better
> > 
> > I failed to parse your terms so I wrote scnario as my understanding
> > so please see my above sequence and if you have a comment, please ask
> > again.
> > 
> >> to merge them into one?
> > 
> > It's not hard part but I wanted to show my intention clearly.
> > If we all agree on, let's think over interface again.
> 
> For me the interface with a single syscall looks OK. If nobody else objects,
> I think you can go on with the kernel patches :) Presumably you can even
> use the criu project sources and tests to check how memory changes tracking
> works with the new interface.

Thanks for the good discussion!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
