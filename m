Message-Id: <l03130300b72b8fd29b5b@[192.168.239.105]>
In-Reply-To: 
        <Pine.LNX.4.21.0105182315430.5531-100000@imladris.rielhome.conectiva>
References: <l03130302b72ad6e553b5@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Sat, 19 May 2001 03:56:14 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: on load control / process swapping
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Matt Dillon <dillon@earth.backplane.com>, Terry Lambert <tlambert2@mindspring.com>, Charles Randall <crandall@matchlogic.com>, Roger Larsson <roger.larsson@norran.net>, arch@FreeBSD.ORG, linux-mm@kvack.org, sfkaplan@cs.amherst.edu
List-ID: <linux-mm.kvack.org>

>> FWIW, I've been running with a 2-line hack in my kernel for some weeks
>> now, which essentially forces the RSS of each process not to be forced
>> below some arbitrary "fair share" of the physical memory available.
>> It's not a very clean hack, but it improves performance by a very
>> large margin under a thrashing load.  The only problem I'm seeing is a
>> deadlock when I run out of VM completely, but I think that's a
>> separate issue that others are already working on.
>
>I'm pretty sure I know what you're running into.
>
>Say you guarantee a minimum of 3% of memory for each process;
>now when you have 30 processes running your memory is full and
>you cannot reclaim any pages when one of the processes runs
>into a page fault.

Actually I already thought of that one, and made it a "fair share" of the
system rather than a fixed amount.  IOW, the guaranteed amount is something
like (total_memory / nr_processes).  I think I was even sane enough to
lower this value slightly to allow for some buffer/cache memory, but I
didn't allow for locked pages (including the kernel itself).

The deadlock happened when the swap ran out, not the physical RAM, and is
independent of this particular hack - remember I'm running with some
out_of_memory() fixes and some other hackery I did a month or so ago
(remember that massive "OOM killer" thread?).  I should try to figure those
out and present cleaned-up versions for further perusal...

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)
big-mail: chromatix@penguinpowered.com
uni-mail: j.d.morton@lancaster.ac.uk

The key to knowledge is not to rely on people to teach you it.

Get VNC Server for Macintosh from http://www.chromatix.uklinux.net/vnc/

-----BEGIN GEEK CODE BLOCK-----
Version 3.12
GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)
-----END GEEK CODE BLOCK-----


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
