Received: from chorus.teradyne.com (chorus.teradyne.com [131.101.1.195])
	by rent.teradyne.com (8.8.8+Sun/8.8.8) with ESMTP id CAA21791
	for <linux-mm@kvack.org>; Wed, 12 Mar 2003 02:33:37 -0500 (EST)
Received: from laforge.ttd.teradyne.com (laforge.ttd.teradyne.com [131.101.20.119]) by chorus.teradyne.com (8.8.8+Sun/8.7.1) with ESMTP id CAA04411 for <linux-mm@kvack.org>; Wed, 12 Mar 2003 02:33:36 -0500 (EST)
Received: from heismanttd (heisman-ttd.ttd.teradyne.com [131.101.20.76]) by laforge.ttd.teradyne.com (8.8.8+Sun/8.7.1) with SMTP id BAA14486 for <linux-mm@kvack.org>; Wed, 12 Mar 2003 01:33:35 -0600 (CST)
Message-ID: <008601c2e869$b1364850$4c146583@heismanttd>
From: "Jake Dawley-Carr" <jake@dawley-carr.org>
Subject: HowTo: Profile Memory in a Linux System
Date: Wed, 12 Mar 2003 01:33:35 -0600
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I have written a mini-HOWTO on profiling memory usage under Linux.

If you have the time and the interest, please review this short
document. I will take your corrections and submit this document to the
Linux Documentation Project as a reference for others. 

If this is not an appropriate mailing list, would you please redirect
me to a relevant list?

Thanks,


Jake


HOWTO: Profile Memory in a Linux System

1.  Introduction

    It's important to determine how your system utilizes it's
    resources. If your systems performance is unacceptable, it is
    necessary to determine which resource is slowing the system
    down. This document attempts to identify the following:

    a.  What is the system memory usage per unit time?
    b.  How much swap is being used per unit time?
    c.  What does each process' memory use look like over time?
    d.  What processes are using the most memory?

    I used a RedHat-7.3 machine (kernel-2.4.18) for my experiments,
    but any modern Linux distribution with the commands "ps" and
    "free" would work.

2.  Definitions

    RAM (Random Access Memory) - Location where programs reside when
    they are running. Other names for this are system memory or
    physical memory. The purpose of this document is to determine if
    you have enough of this.

    Memory Buffers - A page cache for the virtual memory system. The
    kernel keeps track of frequently accessed memory and stores the
    pages here.

    Memory Cached - Any modern operating system will cache files
    frequently accessed. You can see the effects of this with the
    following commands:

        for i in 1 2 ; do
            free -o
            time grep -r foo /usr/bin >/dev/null 2>/dev/null
        done

    Memory Used - Amount of RAM in use by the computer. The kernel
    will attempt to use as much of this as possible through buffers
    and caching.

    Swap - It is possible to extend the memory space of the computer
    by using the hard drive as memory. This is called swap. Hard
    drives are typically several orders of magnitude slower than RAM
    so swap is only used when no RAM is available.

    Swap Used - Amount of swap space used by the computer.

    PID (Process IDentifier) - Each process (or instance of a running
    program) has a unique number. This number is called a PID.

    PPID (Parent Process IDentifier) - A process (or running program)
    can create new processes. The new process created is called a
    child process. The original process is called the parent
    process. The child process has a PPID equal to the PID of the
    parent process. There are two exceptions to this rule. The first
    is a program called "init". This process always has a PID of 1 and
    a PPID of 0. The second exception is when a parent process exit
    all of the child processes are adopted by the "init" process and
    have a PPID of 1. 

    VSIZE (Virtual memory SIZE) - The amount of memory the process is
    currently using. This includes the amount in RAM and the amount in
    swap.

    RSS (Resident Set Size) - The portion of a process that exists in
    physical memory (RAM). The rest of the program exists in swap. If
    the computer has not used swap, this number will be equal to
    VSIZE.

3.  What consumes System Memory?

    The kernel - The kernel will consume a couple of MB of memory. The
    memory that the kernel consumes can not be swapped out to
    disk. This memory is not reported by commands such as "free" or
    "ps".

    Running programs - Programs that have been executed will consume
    memory while they run.

    Memory Buffers - The amount of memory used is managed by the
    kernel. You can get the amount with "free".

    Memory Cached - The amount of memory used is managed by the
    kernel. You can get the amount with "free".

4.  Determining System Memory Usage

    The inputs to this section were obtained with the command:

        free -o

    The command "free" is a c program that reads the "/proc"
    filesystem.

    There are three elements that are useful when determining the
    system memory usage. They are:

    a.  Memory Used
    b.  Memory Used - Memory Buffers - Memory Cached
    c.  Swap Used

    A graph of "Memory Used" per unit time will show the "Memory Used"
    asymptotically approach the total amount of memory in the system
    under heavy use. This is normal, as RAM unused is RAM wasted.

    A graph of "Memory Used - Memory Buffered - Memory Cached" per
    unit time will give a good sense of the memory use of your
    applications minus the effects of your operating system. As you
    start new applications, this value should go up. As you quit
    applications, this value should go down. If an application has a
    severe memory leak, this line will have a positive slope.

    A graph of "Swap Used" per unit time will display the swap
    usage. When the system is low on RAM, a program called kswapd will
    swap parts of process if they haven't been used for some time. If
    the amount of swap continues to climb at a steady rate, you may
    have a memory leak or you might need more RAM.

5.  Per Process Memory Usage

    The inputs to this section were obtained with the command:

        ps -eo pid,ppid,rss,vsize,pcpu,pmem,cmd -ww --sort=pid

    The command "ps" is a c program that reads the "/proc"
    filesystem.

    There are two elements that are useful when determining the per
    process memory usage. They are:

    a.  RSS
    b.  VSIZE

    A graph of RSS per unit time will show how much RAM the process is
    using over time.

    A graph of VSIZE per unit time will show how large the process is
    over time.

6.  Collecting Data

    a.  Reboot the system. This will reset your systems memory use

    b.  Run the following commands every ten seconds and redirect the
        results to a file.

        free -o
        ps -eo pid,ppid,rss,vsize,pcpu,pmem,cmd -ww --sort=pid

    c.  Do whatever you normally do on your system

    d.  Stop logging your data

7.  Generate a Graph

    a.  System Memory Use

        For the output of "free", place the following on one graph

        1.  X-axis is "MB Used"

        2.  Y-axis is unit time

        3.  Memory Used per unit time

        4.  Memory Used - Memory Buffered - Memory Cached per unit time

        5.  Swap Used per unit time

    b.  Per Process Memory Use

        For the output of "ps", place the following on one graph

        1.  X-axis is "MB Used"

        2.  Y-axis is unit time

        3.  For each process with %MEM > 10.0

            a.  RSS per unit time

            b.  VSIZE per unit time

8. Understand the Graphs

    a.  System Memory Use

        "Memory Used" will approach "Memory Total"

        If "Memory Used - Memory Buffered - Memory Cached" is 75% of
        "Memory Used", you either have a memory leak or you need to
        purchase more memory. 

    b.  Per Process Memory Use

        This graph will tell you what processes are hogging the
        memory. 

        If the VSIZE of any of these programs has a constant, positive
        slope, it may have a memory leak.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
