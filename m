Message-Id: <3.0.6.32.20020114235555.007bfac0@boo.net>
Date: Mon, 14 Jan 2002 23:55:55 -0500
From: Jason Papadopoulos <jasonp@boo.net>
Subject: Re: [PATCH] page coloring for 2.4.17 kernel
In-Reply-To: <20020114224603.N5057@redhat.com>
References: <3.0.6.32.20020113204610.007c7a60@boo.net>
 <3.0.6.32.20020113204610.007c7a60@boo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At 10:46 PM 1/14/02 +0000, you wrote:

>> Hello. Please be patient with this, my first post to linux-mm.
>> The included patch modifies the free list in the 2.4.17 kernel
>> to support round-robin page coloring. It seems to work okay
>> on an Alpha and speeds up a lot of number-crunching code I
>> have lying around (lmbench reports some higher bandwidths too).
>> The patch is a port of the 2.2.20 version that I recently posted
>> to the linux kernelmailing list.
>
>Do you have numbers to show the sort of performance difference it
>makes?

It's a little difficult to tell with lmbench, since results can vary 
slightly from run to run. The following numbers seem to be fairly
repeatable (DS10 Alphaserver with 466MHz ev6 processor and 2MB L2 cache).
The 2.2.20 numbers are with the original page coloring patch, the first
2.4.17 numbers are for the unpatched kernel and the second set uses
page coloring.


*Local* Communication latencies in microseconds - smaller is better
-------------------------------------------------------------------
Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
                        ctxsw       UNIX         UDP         TCP conn
--------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
alpha-lin  Linux 2.2.20     1     6   15    22          39           
alpha-lin  Linux 2.4.17     1     8   20    38          64        212
alpha-lin  Linux 2.4.17     1    11   19    28          37        163

File & VM system latencies in microseconds - smaller is better
--------------------------------------------------------------
Host                 OS   0K File      10K File      Mmap    Prot    Page	
                        Create Delete Create Delete  Latency Fault   Fault 
--------- ------------- ------ ------ ------ ------  ------- -----   ----- 
alpha-lin  Linux 2.2.20      6      1     13      1     9699     1    0.7K
alpha-lin  Linux 2.4.17      3      0      9      2      619     0    0.0K
alpha-lin  Linux 2.4.17      3      0     10      2      624     0    0.0K

*Local* Communication bandwidths in MB/s - bigger is better
-----------------------------------------------------------
Host                OS  Pipe AF    TCP  File   Mmap  Bcopy  Bcopy  Mem   Mem
                             UNIX      reread reread (libc) (hand) read write
--------- ------------- ---- ---- ---- ------ ------ ------ ------ ---- -----
alpha-lin  Linux 2.2.20  261  255   -1    189    370    262    209  370   330
alpha-lin  Linux 2.4.17  373  327  137    203    370    268    208  371   335
alpha-lin  Linux 2.4.17  362  371  196    259    371    262    203  370   332

Memory latencies in nanoseconds - smaller is better
    (WARNING - may not be correct, check graphs)
---------------------------------------------------
Host                 OS   Mhz  L1 $   L2 $    Main mem    Guesses
--------- -------------   ---  ----   ----    --------    -------
alpha-lin  Linux 2.2.20   461     6     32         199
alpha-lin  Linux 2.4.17   462     6     75         199
alpha-lin  Linux 2.4.17   462     6     32         199


For computational workloads whose working set fit in L2 it makes a 
huge difference (I've seen 30% speedups in FFT benchmarks). Kernel
compiles also seem to go 1-2% faster. I also have a memory latency
tester written in assembly language for the ev6, and without the
patch it seems you can only get high bandwidth out of L2 for working
sets of about 256k in size. With page coloring turned on you get
constant high memory bandwidth all the way out to the full L2 cache
size.

It would be interesting to see how i386 machines benefit from page
coloring, since they have very fast but somewhat tiny L2 caches with
high associativity.

jasonp
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
