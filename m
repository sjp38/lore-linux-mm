Message-ID: <41336B6F.6050806@pandora.be>
Date: Mon, 30 Aug 2004 20:01:19 +0200
From: Karl Vogel <karl.vogel@pandora.be>
MIME-Version: 1.0
Subject: Re: Kernel 2.6.8.1: swap storm of death - nr_requests > 1024 on swap
 partition
References: <20040828144303.0ae2bebe.akpm@osdl.org> <20040828215411.GY5492@holomorphy.com> <20040828151349.00f742f4.akpm@osdl.org> <20040828222816.GZ5492@holomorphy.com> <20040829033031.01c5f78c.akpm@osdl.org> <20040829141526.GC10955@suse.de> <20040829141718.GD10955@suse.de> <20040829131824.1b39f2e8.akpm@osdl.org> <20040829203011.GA11878@suse.de> <20040829135917.3e8ffed8.akpm@osdl.org> <20040830152025.GA2901@logos.cnet>
In-Reply-To: <20040830152025.GA2901@logos.cnet>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Andrew Morton <akpm@osdl.org>, Jens Axboe <axboe@suse.de>, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:

> What is the problem Karl is seeing again? There seem to be several, lets
> separate them
> 
> - OOM killer triggering (if there's swap space available and 
> "enough" anonymous memory to be swapped out this should not happen). 
> One of his complaint on the initial report (about the OOM killer).

Correct. On my 512Mb RAM system with 1Gb swap partition, running a 
calloc(1Gb) causes the process to get OOM killed when using CFQ.
The problem is not CFQ as such.. the problem is when nr_requests is too 
large (8192 being the default for CFQ).

The same will happen with the default nr_request of 128 which AS uses, 
if you use a low memory system. e.g. I booted with mem=128M and then a 
calloc(128Mb) can trigger the OOM.

> - Swap cache not freed after test app exists. Should not be a
> problem because such memory will be freed as soon as theres 
> pressure, I think.

After the OOM killer killed the calloc() task, the SwapCache still 
contains a large chunk of the original allocation. This get's cleared if 
there is alot of I/O (example: dd if=/dev/hdX of=/dev/null).

However, without the I/O's it doesn't seem to get freed.. this also 
causes a second run of calloc(1Gb) to fail as the SwapCache still 
accounts for used memory.

> How can you reproduce that?

It should be reproducable as follows:
- boot with mem=512M
- have a 1Gb swap partition / swapfile (the size doesn't really matter)
- use CFQ or set nr_requests to 8192 on the drive _hosting the swap_
- run  'expunge 1024'   (might work the 1st time, if so, run it again)


--- expunge.c program source ---
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
     char *p= calloc(1, atol(argv[1])*1024L*1024L);
     if (!p) {
         perror("calloc");
         exit(1);
     }
     return 0;
}
--- expunge.c program source ---



Another thing that you can try:
- boot with mem=128M
- have enough swap
- execute:  while true; do expunge 128; done

This will trigger an OOM even with AS (nr_requests = 128)



After the OOM, SwapCache still holds part of the allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
