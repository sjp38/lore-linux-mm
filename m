Date: Wed, 25 Feb 1998 22:39:47 +0100
Message-Id: <199802252139.WAA27196@boole.fs100.suse.de>
From: "Dr. Werner Fink" <werner@suse.de>
In-reply-to: <199802252032.UAA01920@dax.dcs.ed.ac.uk> (sct@dcs.ed.ac.uk)
Subject: Re: Fairness in love and swapping
Sender: owner-linux-mm@kvack.org
To: sct@dcs.ed.ac.uk
Cc: torvalds@transmeta.com, blah@kvack.org, H.H.vanRiel@fys.ruu.nl, nahshon@actcom.co.il, alan@lxorguk.ukuu.org.uk, paubert@iram.es, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>
> I noticed something rather unfortunate when starting up two of these
> tests simultaneously, each test using a bit less than total physical
> memory.  The first test gobbled up the whole of ram as expected, but the
> second test did not.  What happened was that the contention for memory
> was keeping swap active all the time, but the processes which were
> already all in memory just kept running at full speed and so their pages
> all remained fresh in the page age table.  The newcomer processes were
> never able to keep a page in memory long enough for their age to compete
> with the old process' pages, and so I had a number of identical
> processes, half of which were fully swapped in and half of which were
> swapping madly.

Maybe my changes done for 2.0.3x in ipc/shm.c: shm_swap_in()

                shm_rss++;

                /* Give the physical reallocated page a bigger start */
                if (shm_rss < (MAP_NR(high_memory) >> 3))
                        mem_map[MAP_NR(page)].age = (PAGE_INITIAL_AGE + PAGE_ADVANCE);

and mm/page_alloc.c: swap_in()

                
        vma->vm_mm->rss++;
        tsk->maj_flt++;

        /* Give the physical reallocated page a bigger start */
        if (vma->vm_mm->rss < (MAP_NR(high_memory) >> 2))
                mem_map[MAP_NR(page)].age = (PAGE_INITIAL_AGE + PAGE_ADVANCE);


would help a bit.  With this few lines a recently swapin page gets a bigger
start by increasing the page age ... but only if the corresponding process to
not overtake the physical memory.  This change is not very smart (e.g. its not
a real comparsion by process swap count or priority) ... nevertheless it works
for 2.0.33.

> 
> Needless to say, this is highly unfair, but I'm not sure whether there
> is any easy way round it --- any clock algorithm will have the same
> problem, unless we start implementing dynamic resident set size limits.
> 


               Werner
