Message-ID: <440CE027.5090207@hp.com>
Date: Mon, 06 Mar 2006 17:21:43 -0800
From: Rick Jones <rick.jones2@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH] avoid atomic op on page free
References: <20060307001015.GG32565@linux.intel.com> <20060306165039.1c3b66d8.akpm@osdl.org>
In-Reply-To: <20060306165039.1c3b66d8.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: netdev@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Benjamin LaHaise <bcrl@linux.intel.com> wrote:
> 
>>Hello Andrew et al,
>>
>>The patch below adds a fast path that avoids the atomic dec and test 
>>operation and spinlock acquire/release on page free.  This is especially 
>>important to the network stack which uses put_page() to free user 
>>buffers.  Removing these atomic ops helps improve netperf on the P4 
>>from ~8126Mbit/s to ~8199Mbit/s (although that number fluctuates quite a 
>>bit with some runs getting 8243Mbit/s).  There are probably better 
>>workloads to see an improvement from this on, but removing 3 atomics and 
>>an irq save/restore is good.
>>
 > ...
> Because userspace has to do peculiar things to get its pages taken off the
> LRU.  What exactly was that application doing?
> 
> The patch adds slight overhead to the common case while providing
> improvement to what I suspect is a very uncommon case?

A netperf TCP_STREAM test sits in a tight loop calling send() on the 
side running netperf and recv() on the side running netserver.  By 
default it accepts the default socket buffer sizes, and uses what is 
returned by a getsockopt(SO_SNDBUF) _before_ connect() as its "send 
size"  (and SO_RCVBUF as the default recv size)

So, in that regard it will be akin to a unidirectional bulk transfer 
application - eg ftp.

Netperf TCP_STREAM will send from a "ring" of buffers allocated at one 
time via malloc that in number are one more than SO_SNDBUF/sendsize.

There is also the TCP_SENDFILE test that is similar to TCP_STREAM only 
the netperf side calls sendfile(); and a TCP_RR test that will by 
default exchange single-byte requests and responses - single 
"transaction" outstanding at a time.  The idea was to test path length 
without taxing link bandwidth.

There are commandline options to change all of that, and several other 
tests, some optional compilations:

http://www.netperf.org/svn/netperf2/trunk/doc/

will have most if not all the nitty gritty details.  Some of the more 
recent additions to netperf are only described in the netperf-talk 
mailing list:

http://www.netperf.org/pipermail/netperf-talk/

eg support for more than one transaction outstanding in an _RR test and 
other odds and ends.

rick jones

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
