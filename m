Message-ID: <39D87F3A.7D21E18@mountain.net>
Date: Mon, 02 Oct 2000 08:27:38 -0400
From: Tom Leete <tleete@mountain.net>
MIME-Version: 1.0
Subject: Re: [PATCH] fix for VM  test9-pre7
References: <Pine.LNX.4.21.0010020038090.30717-100000@duckman.distro.conectiva>
Content-Type: multipart/mixed;
 boundary="------------96615B0CFDE1A7CCE0AD6CE6"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------96615B0CFDE1A7CCE0AD6CE6
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Rik van Riel wrote:
> 
> Hi,
> 
> The attached patch seems to fix all the reported deadlock
> problems with the new VM. Basically they could be grouped
> into 2 categories:
> 
> 1) __GFP_IO related locking issues
> 2) something sleeps on a free/clean/inactive page goal
>    that isn't worked towards
> 
> The patch has survived some heavy stresstesting on both
> SMP and UP machines. I hope nobody will be able to find
> a way to still crash this one ;)
> 
> A second change is a more dynamic free memory target
> (now freepages.high + inactive_target / 3), this seems
> to help a little bit in some loads.
> 

Hi,

I ran lmbench on test9-pre7 with and without the patch.

Test machine was a slow medium memory UP box:
Cx586@120Mhz, no optimizations, 56M

I still experience instability on this machine with both the
patched and vanilla kernel. It usually takes the form of
sudden total lockups, but on occasion I have seen oops +
panic at boot.

This summary doesn't show any performance advantage to the
patch, but the detailed plots show that memory access
latency degrades more gracefully wrt array size.

For bandwidth, I'm only including the summary. Vanilla is
listed first in each entry. Full lmbench report files on
request.

Tom
--------------96615B0CFDE1A7CCE0AD6CE6
Content-Type: text/plain; charset=us-ascii;
 name="vanilla-vs-riel"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vanilla-vs-riel"


                 L M B E N C H  1 . 9   S U M M A R Y
                 ------------------------------------
		 (Alpha software, do not distribute)

Processor, Processes - times in microseconds - smaller is better
----------------------------------------------------------------
Host                 OS  Mhz null null      open selct sig  sig  fork exec sh  
                             call  I/O stat clos       inst hndl proc proc proc
--------- ------------- ---- ---- ---- ---- ---- ----- ---- ---- ---- ---- ----
i486-linu Linux 2.4.0-t  119  1.8  4.0   51   62 0.33K  9.2   19 4.3K  16K  54K
i486-linu Linux 2.4.0-p  119  1.8  4.1   51   64 0.35K  9.2   19 4.5K  16K  55K

Context switching - times in microseconds - smaller is better
-------------------------------------------------------------
Host                 OS 2p/0K 2p/16K 2p/64K 8p/16K 8p/64K 16p/16K 16p/64K
                        ctxsw  ctxsw  ctxsw ctxsw  ctxsw   ctxsw   ctxsw
--------- ------------- ----- ------ ------ ------ ------ ------- -------
i486-linu Linux 2.4.0-t    2    388   1054   296   1733     439    1854
i486-linu Linux 2.4.0-p    5    308   1062   268   1650     416    1822

*Local* Communication latencies in microseconds - smaller is better
-------------------------------------------------------------------
Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
                        ctxsw       UNIX         UDP         TCP conn
--------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
i486-linu Linux 2.4.0-t     2    44  131   352         628       2267
i486-linu Linux 2.4.0-p     5    47  109   401         649       2186

File & VM system latencies in microseconds - smaller is better
--------------------------------------------------------------
Host                 OS   0K File      10K File      Mmap    Prot    Page	
                        Create Delete Create Delete  Latency Fault   Fault 
--------- ------------- ------ ------ ------ ------  ------- -----   ----- 
i486-linu Linux 2.4.0-t    110     18    337     39     2702     5    0.0K
i486-linu Linux 2.4.0-p    111     20    340     42     2829     4    0.0K

*Local* Communication bandwidths in MB/s - bigger is better
-----------------------------------------------------------
Host                OS  Pipe AF    TCP  File   Mmap  Bcopy  Bcopy  Mem   Mem
                             UNIX      reread reread (libc) (hand) read write
--------- ------------- ---- ---- ---- ------ ------ ------ ------ ---- -----
i486-linu Linux 2.4.0-t   15    6    6      9     32     14     14   32    39
i486-linu Linux 2.4.0-p   14    7    6     10     32     14     14   32    39

Memory latencies in nanoseconds - smaller is better
    (WARNING - may not be correct, check graphs)
---------------------------------------------------
Host                 OS   Mhz  L1 $   L2 $    Main mem    Guesses
--------- -------------   ---  ----   ----    --------    -------
i486-linu Linux 2.4.0-t   119    25    419         452    No L2 cache?
i486-linu Linux 2.4.0-p   119    25    365         459

--------------96615B0CFDE1A7CCE0AD6CE6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
