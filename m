From: Mark_H_Johnson@Raytheon.com
Subject: Re: Query on memory management
Message-ID: <OF1F3264FC.15A65DC1-ON862568BA.0069AFBB@hso.link.com>
Date: Fri, 7 Apr 2000 14:41:13 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@muc.de
List-ID: <linux-mm.kvack.org>

A short follow up to this response - I looked at the per process limits
[see Andi's answer to my (2) below] but it appears that they are not all
implemented. If you use bash to set the "max memory size" limit (which maps
into RLIMIT_RSS, defined in resource.h) - you can see that the value is
set, but apparently no code in Linux 2.2.14 uses this value. I grep'd the
source code & I could find it defined, but never used [except to set &
display].

To demonstrate, I can provide a sample program that maps a file into your
memory space & traverses it. You can set a small memory limit, run the
program, and see RSS grow well past the set limit (I set the limit to 8192
kbytes, file size was 30M, and saw >20M for RSS). If the file size is too
big, the code in /arch/i386/mm/fault.c will kill this process (as well as
others) if you run out of physical memory - even though you have plenty of
swap space left. You can disable that "kill code" in fault.c [what I
referred to in (3) below] and the program will run successfully to
completion in all cases, but the system is very sluggish. In addition, if
the mapped file is on an nfs volume, nfs will generate a lot of error
messages on the console.

Can someone comment on when the memory resource limits will be implemented
[or if help is needed to do so]?

If already implemented on the developmental kernel, where should I look for
patches for this specific change?

Thanks.
--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>
----- Forwarded by Mark H Johnson/RTS/Raytheon/US on 04/07/00 02:14 PM
-----
                                                                                                                    
                    Andi Kleen                                                                                      
                    <ak@muc.de>          To:     Mark H Johnson/RTS/Raytheon/US@RTS                                 
                                         cc:     linux-mm@kvack.org                                                 
                    04/06/00             Subject:     Re: Query on memory management                                
                    10:30 AM                                                                                        
                                                                                                                    
                                                                                                                    



On Thu, Apr 06, 2000 at 04:18:24PM +0200, Mark_H_Johnson@Raytheon.com
wrote:
[snip]
>
> (2) I've seen traffic related to "out of memory" problems. How close are
we
> to a permanent solution & do you need suggestions? For example, I can't
> seem to find any per-process limits to the "working set or virtual size"
> (could refer to either the number of physical or virtual pages a process
> can use). If that was implemented, some of the problems you have seen
with
> rogue processes could be prevented.

There are per process limits, settable using ulimit
When you set suitable process limits and limit the number of processes you
should never run out of swap.

>
> (3) Re: out of memory. I also saw code in 2.2.14 [arch/i386/mm/fault.c]

> prevents the init task (pid==1) from getting killed. Why can't that
> solution be applied to all tasks & let kswapd (or something else) keep
> moving pages to the swap file (or memory mapped files) & kill tasks if
and
> only if the backing store on disk is gone?

[snip]

-Andi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
