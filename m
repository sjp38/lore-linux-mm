Date: Mon, 9 Oct 2000 20:25:34 -0400 (EDT)
From: Byron Stanoszek <gandalf@winds.org>
Subject: [RFC] New ideas for the OOM handler
In-Reply-To: <Pine.LNX.4.21.0010091829140.7807-100000@winds.org>
Message-ID: <Pine.LNX.4.21.0010091842240.7807-100000@winds.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerrit.Huizenga@us.ibm.com
Cc: Rik van Riel <riel@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Andi Kleen <ak@suse.de>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <andrea@suse.de>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

What I'd personally like to see in the OOM should cover the following
scenarios, theoretically:

 1. User does a malloc() bomb. This should be caught instantly and killed when
    there is no memory left to allocate. This covers tons of low-sized
    mallocs() as well as a timed delay infinite loop. Obviously, unless the
    sysadmin enabled vm_overcommit_memory (if that even still exists in 2.4),
    the person won't be able to malloc(2147483647) anyway. The reason is clear.

 2. We want to protect daemon-type system level processes more than anything.
    Therefore, any non-root process should be given higher priority for killing
    versus a superuser process. On production systems, root is less likely to
    hog a machine's memory than normal users. Furthermore, root's processes are
    effectively more important and should be handled specially.
    
    This does NOT mean that we should ignore mistakes such as #1 above (Higher
    priority does not mean exclusive priority). This also does not mean that
    superuser processes shouldn't be killed until all regular user processes
    are dead. Obviously, if root is tricked into running a malloc() bomb, the
    VM should kill that process first.

 3. We want to target processes that will give us the biggest memory gain in
    return. We should look more closely at parent nodes of parent-child
    processes that use shared memory or copy-on-write segments between the two
    from the use of a fork(). The 'originator' of that shared memory should be
    the one to target. (See #4 below for how this may be useful).

    Total VSZ should not be the primary basis for selection. It does not make
    sense to kill a child whose VSZ is 80,000kb when its parent is 70,000kb
    (and 65,000kb is shared between the two). In contrast, it does make sense
    to base the selection on the process who is the 'originator' of the shared
    memory segment (the one who creates the mmap, or who loads the DSO).
    
    The best way to describe the DSO case is with an example. Say the machine
    has 8 MB of ram. Root decides to run Apache, which happily loads several
    dynamically shared objects. Say there was enough memory to load the parent
    process and all shared objects, and then the process spawns an additional
    15 PIDs / threads with shared memory attached. The correct process to
    target here is the parent httpd and not the children individually. However,
    we do not want to leave the children lying around without the parent, as
    this does nothing, and no shared memory would be expunged (see #4 below).

    This concept becomes much harder to grasp when you want to subtract the
    size of shared libraries (e.g. libc, libm) from the VSZ. As long as another
    process has a shared object, then that size should be factored out. A
    program whose shared Libc is 1200k out of a total VSZ of 2600k should not
    get killed over a static program using 2200k.

    The same thing goes for fork()'d processes, since memory is copy-on-write.
    There is not much benefit to killing a child who just came out of a fork(),
    as the parent will most likely fork again.

 4. Arguably, children of a killed process in the same process/session group
    should also be killed. If netscape got killed, its child DNS helper should
    too. It's more likely that a [working] shell would not be killed,
    preventing several user programs from getting killed also. Programs like
    'screen' should always initialize a new process group or session for their
    children so that their children disassociate themselves from the parent
    process. Most (but not all) child processes of high-memory programs would
    be the 'worker bees' for that program.

    This is a lot to chew, and I even doubt this should go into practice
    because 90% of independent child processes are not initialized with a
    separate session/process group ID. But this satisfies the assumption that
    most memory eaters would usually be Leaf Nodes in the process table (e.g.
    large programs run off of a shell) rather than parent nodes, and a shell is
    not likely to be selected for killing. I'd like some comments on this.

 5. How about factoring stack size into the equation? I don't know how the
    stack figures into the VM, but processes with a 70,000 function backtrace
    log should be looked at with higher interest than a 'valid' program such as
    'netscape'. Chances are the kernel already sets stack size limits and kills
    with a SIGSEGV when that limit is hit, so we might not have to worry about
    this one.

 6. Kill programs with an abnormally large number of pages used in the page
    table first. This covers the usage of programs like Electric Fence that eat
    up memory extremely quickly, while most of those pages are not actually
    resident in Physical RAM.

Rules to enforce:

 1. Init should never be killed. Ever. Unless the machine is on crack.

 2. Processes with no virtual memory should not be touched -- Kernel threads.

Additional ideas:

I thought of some additional ways of determining which process gets killed
first, prioritized on the above criteria:

 1. Keep a count of the number of sbrk() memory regions in terms of size for
    each process. The count should not be a recent total or moving average kept
    for the past 5-10 minutes, but instead it should be a ratio relative to the
    size of sbrk() requests of other processes. This quickly determines which
    process is eating up memory the fastest. 99 out of 100 times this will be a
    runaway process, an evil malloc(), or an overly abusive user. At times like
    these, the user will 'expect' the program to crash with a SEGV anyway.

 2. Short of marking a process a "System Process", we want to keep programs
    like X or Svgalib from crashing. In this manner, I agree with the person
    who said programs that have I/O Ports or devices open should be one of the
    last to kill.
    
    Also, if such processes DO get killed, we want them to return the user into
    a usable state where they can interact with the computer. In all OOM
    killers 2.2 and up, killing X with sig 9 is a _bad_ idea. With all due
    respects, we should be killing these processes with SIGSEGV instead of
    SIGKILL to give programs a chance to cool down. However, when the OOM
    killer kicks in there might not be enough memory free for even a printk()
    let alone a core dump. It should be possible to reserve memory for handling
    OOM situations (for instance, kick in OOM when there is 64kb of memory free
    and no less). Chances are the program will just crash due to default signal
    handling. But if the program catches SEGV and does nothing about it, then
    when 0kb of memory becomes free, completely terminate the program.

    This, of course, should only happen when swap is something like 95% full
    and the program isn't almost entirely swapped out. We should also set a
    flag to Never dump core. We should leave enough space on the swap partition
    for memory to get swapped out to disk (and program memory swapped in) to
    let a signal handler do its job. I think using 100% swap is a bad idea.

These are all ideas and suggestions, and I expect most to be flamed out quick.
I wrote this to get people thinking about how we could improve our current OOM
killer and kill the 'right' programs instead of vital system daemons, without
leaving our machine idle for 5 minutes while the OOM killer tries to think of
what to kill next, either because the program is ignoring SIGTERM or there is
100% swap space used.

All in all, the OOM killer we have now is much better than the 2.2 version and
works very well for its intended purpose. These are the types of ideas I would
toss around if I were to implement the killer myself. Keeping it from being too
complicated is the hard part. So, having said the above, elaborate on these
ideas to see if we can _really_ improve our OOM and if it is worth the trouble
doing so.

I however suggest strongly that we implement the check for PID == 1 into the
current OOM and toss out checking for Nice status, which makes no real sense
(see my last post, and the posts for several others).

 -Byron

-- 
Byron Stanoszek                         Ph: (330) 644-3059
Systems Programmer                      Fax: (330) 644-8110
Commercial Timesharing Inc.             Email: bstanoszek@comtime.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
