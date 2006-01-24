From: "Ray Bryant" <raybry@mpdtxmail.amd.com>
Subject: Re: [PATCH/RFC] Shared page tables
Date: Tue, 24 Jan 2006 17:43:28 -0600
References: <A6D73CCDC544257F3D97F143@[10.1.1.4]>
 <200601231758.08397.raybry@mpdtxmail.amd.com>
 <6BC41571790505903C7D3CD6@[10.1.1.4]>
In-Reply-To: <6BC41571790505903C7D3CD6@[10.1.1.4]>
MIME-Version: 1.0
Message-ID: <200601241743.28889.raybry@mpdtxmail.amd.com>
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Hugh Dickins <hugh@veritas.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Monday 23 January 2006 18:19, Dave McCracken wrote:

>
> My apologies.  I do have a small test program and intended to clean it up
> to send to Robin, but got sidetracked (it's fugly at the moment).  I'll see
> about getting it a bit more presentable.
>

I created a test case that mmaps() a 20 GB anonymous, shared region, then 
forks off 128 child processes that touch the 20 GB region.    The results are 
pretty dramatic:

                          2.6.15                            2.6.15-shpt
                         ---------                         ----------------
Total time:          182 s                                  12.2 s
Fork time:             30,2 s                               10.4 s
pte space:            5 GB                                 44 MB

Here total time is the amount of time for all 128 threads to fork and touch 
all 20 GB of data and fork time is the elapsed time for the parent to do all 
of the forks.    pte space is the amount of space reported in /proc/meminfo 
to hold the page tables required to run the test program.   This is on an 
8-core, 4 socket Opteron running at 2.2 GHZ with 32 GB of RAM.

Of course, it would be more dramatic with a real DB application, but that is 
going to take a bit longer to get running, perhaps a couple of months by the 
time all is said and done.

Now I am off to figure out how Andi's mmap() randomization patch interacts 
with all of this stuff.

-- 
Ray Bryant
AMD Performance Labs                   Austin, Tx
512-602-0038 (o)                 512-507-7807 (c)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
