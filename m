Subject: Re: 2.6.0-test9-mm3 - AIO test results
From: Daniel McNeil <daniel@osdl.org>
In-Reply-To: <20031112233002.436f5d0c.akpm@osdl.org>
References: <20031112233002.436f5d0c.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1068761038.1805.35.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Date: 13 Nov 2003 14:03:58 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "linux-aio@kvack.org" <linux-aio@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew,

I'm testing test9-mm3 on a 2-proc Xeon with a ext3 file system.
I tested using the test programs aiocp and aiodio_sparse.
(see http://developer.osdl.org/daniel/AIO/)

Using aiocp with i/o sizes from 1k to 512k to copy files worked
without any errors or kernel debug messages.

With 64k i/o, the aiodio_sparse program complete without any errors.
There are no kernel error messages, so that is good.

There are still problems with non power of 2 i/o sizes using AIO and
O_DIRECT.  It hangs with aio's that do not seem to complete.  The test
does exit when hitting ^c and there are no kernel messages.  Test output
below:

$ ./aiodio_sparse

$ ./aiodio_sparse -dd -s 1751k -r 18k -w 11k
child 1843, read loop count 0
io_submit() return 16
aiodio_sparse: 16 i/o in flight
aiodio_sparse: offset 180224 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 191488 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 202752 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 214016 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 225280 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 236544 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 247808 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 259072 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 270336 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 281600 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 292864 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 304128 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
child 1843, read loop count 10
io_submit() return 1
aiodio_sparse: offset 315392 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 326656 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 337920 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 349184 filesize 1793024 inflight 16
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 11264 res2 0
io_submit() return 1
aiodio_sparse: offset 360448 filesize 1793024 inflight 16
child 1843, read loop count 20
child 1843, read loop count 30
child 1843, read loop count 40
child 1843, read loop count 50
child 1843, read loop count 60
child 1843, read loop count 70

$ ./aiodio_sparse -i 9 -d -s 180k -r 18k -w 18k  
io_submit() return 9
aiodio_sparse: 9 i/o in flight
aiodio_sparse: offset 165888 filesize 184320 inflight 9
aiodio_sparse: io_getevent() returned 1
aiodio_sparse: io_getevent() res 18432 res2 0
io_submit() return 1
child 2060, read loop count 0
child 2060, read loop count 10
child 2060, read loop count 20

Daniel

On Wed, 2003-11-12 at 23:30, Andrew Morton wrote:

> - Significant changes to the AIO and direct-io code.  This needs beating
>   on; hopefully we're now close to a solution to the fairly complex problems
>   in there.
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
