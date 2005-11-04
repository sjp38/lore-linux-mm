Received: from thermo.lanl.gov (thermo.lanl.gov [128.165.59.202])
	by mailwasher-b.lanl.gov (8.12.11/8.12.11/(ccn-5)) with SMTP id jA4EuWZr020482
	for <linux-mm@kvack.org>; Fri, 4 Nov 2005 07:56:33 -0700
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
In-Reply-To: <Pine.LNX.4.64.0511032105110.27915@g5.osdl.org>
Message-Id: <20051104145628.90DC71845CE@thermo.lanl.gov>
Date: Fri,  4 Nov 2005 07:56:28 -0700 (MST)
From: andy@thermo.lanl.gov (Andy Nelson)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: andy@thermo.lanl.gov, torvalds@osdl.org
Cc: akpm@osdl.org, arjan@infradead.org, arjanv@infradead.org, haveblue@us.ibm.com, kravetz@us.ibm.com, lhms-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@mbligh.org, mel@csn.ul.ie, mingo@elte.hu, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Linus,

Since my other affiliation is with X2, which also goes by 
the name Thermonuclear Applications, we have a deal. I'll
continue to help with the work on getting nuclear fusion 
to work, and you work on getting my big pages to work 
in linux. We both have lots of funding and resources behind 
us and are working with smart people. It should be easy.
Beyond that, I don't know much of anything about chemistry,
you'll have to find someone else to increase your battery 
efficiency that way.

Big pages don't work now, and zones do not help because the
load is too unpredictable. Sysadmins *always* turn them
off, for very good reasons. They cripple the machine.


I'll try in this post also to merge a couple of replies with 
other responses:

I think it was Martin Bligh who wrote that his customer gets
25% speedups with big pages. That is peanuts compared to my
factor 3.4 (search comp.arch for John Mashey's and my name
at the University of Edinburgh in Jan/Feb 2003 for a conversation
that includes detailed data about this), but proves the point that 
it is far more than just me that wants big pages. 

If your and other kernel developer's (<<0.01% of the universe) kernel
builds slow down by 5% and my and other people's simulations (perhaps 
0.01% of the universe) speed up by a factor up to 3 or 4, who wins? 
Answer right now: you do, since you are writing the kernel to 
respond to your own issues, which are no more representative of the
rest of the universe than my work is. Answer as I think it
ought to be: I do, since I'd bet that HPC takes far more net
cycles in the world than every one else's kernel builds put
together. I can't expect much of anyone else to notice either
way and neither can you, so that is a wash.


Ingo Molnar says that zones work for him. In response I
will now repeat my previous rant about why zones don't
work. I understand that my post was very long and people
probably didn't read it all. So I'll just repeat that
part:



2) The last paragraph above is important because of the way HPC
   works as an industry. We often don't just have a dedicated machine to
   run on, that gets booted once and one dedicated application runs on it
   till it dies or gets rebooted again. Many jobs run on the same machine.
   Some jobs run for weeks. Others run for a few hours over and over
   again. Some run massively parallel. Some run throughput.

   How is this situation handled? With a batch scheduler. You submit
   a job to run and ask for X cpus, Y memory and Z time. It goes and
   fits you in wherever it can. cpusets were helpful infrastructure
   in linux for this. 

   You may get some cpus on one side of the machine, some more
   on the other, and memory associated with still others. They
   do a pretty good job of allocating resources sanely, but there is
   only so much that it can do. 

   The important point here for page related discusssions is that
   someone, you don't know who, was running on those cpu's and memory
   before you. And doing Ghu Knows What with it. 

   This code could be running something that benefits from small pages, or
   it could be running with large pages. It could be dynamically
   allocating and freeing large or small blocks of memory or it could be
   allocating everything at the beginning and running statically
   thereafter. Different codes do different things. That means that the
   memory state could be totally fubar'ed before your job ever gets
   any time allocated to it.

>Nobody takes a random machine and says "ok, we'll now put our most 
>performance-critical database on this machine, and oh, btw, you can't 
>reboot it and tune for it beforehand". 

   Wanna bet?

   What I wrote above makes tuning the machine itself totally ineffective.
   What do you tune for? Tuning for one person's code makes someone else's
   slower. Tuning for the same code on one input makes another input run
   horribly. 
   
   You also can't be rebooting after every job. What about all the other
   ones that weren't done yet? You'd piss off everyone running there and
   it takes too long besides.

   What about a machine that is running multiple instances of some
   database, some bigger or smaller than others, or doing other kinds
   of work? Do you penalize the big ones or the small ones, this kind
   of work or that?


   You also can't establish zones that can't be changed on the fly
   as things on the system change. How do zones like that fit into
   numa? How do things work when suddenly you've got a job that wants
   the entire memory filled with large pages and you've only got 
   half your system set up for large pages? What if you tune the
   system that way and then let that job run. For some stupid reason user
   reason it dies 10 minutes after starting? Do you let the 30
   other jobs in the queue sit idle because they want a different
   page distribution?

   This way lies madness. Sysadmins just say no and set up the machine
   in as stably as they can, usually with something not too different
   that whatever manufacturer recommends as a default. For very good reasons.  

   I would bet the only kind of zone stuff that could even possibly
   work would be related to a cpu/memset zone arrangement. See below.


Andy Nelson



--
Andy Nelson                       Theoretical Astrophysics Division (T-6) 
andy dot nelson at lanl dot gov   Los Alamos National Laboratory
http://www.phys.lsu.edu/~andy     Los Alamos, NM 87545











--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
