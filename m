Subject: Re: Question about pte_alloc()
Message-ID: <OF9A0A3560.2E2B9BC3-ON86256998.0052EDF0@hou.us.ray.com>
From: Mark_H_Johnson@Raytheon.com
Date: Wed, 15 Nov 2000 09:20:52 -0600
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux MM <linux-mm@kvack.org>, owner-linux-mm@kvack.org, Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>
List-ID: <linux-mm.kvack.org>

Could you please clarify what is meant by...
  "You cannot safely play pte games at interrupt time.  You _must_
do this in the foreground."
We are concerned because it may block adoption of Linux for one of our
current applications.

We are looking at rehosting a computer emulation to Linux. Our current bare
machine solution uses protection settings in the page table to trap
operations we are interested in. The sequence of steps we currently use is
something like...
 [0] pages protected & an auxiliary table indicates which routine to call
when each page is accessed
 [1] application is started and runs normally
 [2] the application accesses a protected page - trap generated
 [3] trap handler captures the address being manipulated
 [4] trap handler modifies context so the instruction can succeed
 [5] the instruction is single stepped
 [6] the designated routine is called w/ the address being manipulated
 [7] it does its simulation (perhaps of an interface card) and returns
 [8] the context is restored & execution resumes with the next instruction
This sequence allows our emulation to capture all reads and writes to the
simulated devices. We simulate the operation of those devices (functional,
timing, etc.). We also have a restriction that we can't change the binary
code of the software that is running [it allows patches & performs checksum
for consistency]. We need some method to do this (or something similar).
 - Can we do this kind of manipulation with the page tables if we modified
the Linux trap handlers?
 - Are there "better" ways of doing this?

Thanks.

--Mark H Johnson
  <mailto:Mark_H_Johnson@raytheon.com>


                                                                                                                     
                    "Stephen C.                                                                                      
                    Tweedie"              To:     Shuvabrata Ganguly <sganguly@cse.iitkgp.ernet.in>                  
                    <sct@redhat.co        cc:     linux MM <linux-mm@kvack.org>                                      
                    m>                    Subject:     Re: Question about pte_alloc()                                
                    Sent by:                                                                                         
                    owner-linux-mm                                                                                   
                    @kvack.org                                                                                       
                                                                                                                     
                                                                                                                     
                    11/15/00 04:56                                                                                   
                    AM                                                                                               
                                                                                                                     
                                                                                                                     



Hi,

On Wed, Nov 15, 2000 at 02:07:38AM -0500, Shuvabrata Ganguly wrote:
>
> it appears from the code that pte_alloc() might block since it allocates
> a page table with GFP_KERNEL if the page table doesnt already exist. i
> need to call pte_alloc() at interrupt time.

You cannot safely play pte games at interrupt time.  You _must_ do
this in the foreground.

 >Basically i want to map some
> kernel memory into user space as soon as the device gives me data.

Why can't you just let the application know that the event has
occurred and then let it mmap the data itself?

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
