Message-ID: <47B94D8C.8040605@bull.net>
Date: Mon, 18 Feb 2008 10:19:08 +0100
From: Nadia Derbey <Nadia.Derbey@bull.net>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] Scaling msgmni to the amount of lowmem
References: <20080211141646.948191000@bull.net>	<20080211141813.354484000@bull.net> <20080215215916.8566d337.akpm@linux-foundation.org>
In-Reply-To: <20080215215916.8566d337.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, linux-mm@kvack.org, containers@lists.linux-foundation.org, matthltc@us.ibm.com, cmm@us.ibm.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Mon, 11 Feb 2008 15:16:47 +0100 Nadia.Derbey@bull.net wrote:
> 
> 
>>[PATCH 01/08]
>>
>>This patch computes msg_ctlmni to make it scale with the amount of lowmem.
>>msg_ctlmni is now set to make the message queues occupy 1/32 of the available
>>lowmem.
>>
>>Some cleaning has also been done for the MSGPOOL constant: the msgctl man page
>>says it's not used, but it also defines it as a size in bytes (the code
>>expresses it in Kbytes).
>>
> 
> 
> Something's wrong here.  Running LTP's msgctl08 (specifically:
> ltp-full-20070228) cripples the machine.  It's a 4-way 4GB x86_64.
> 
> http://userweb.kernel.org/~akpm/config-x.txt
> http://userweb.kernel.org/~akpm/dmesg-x.txt
> 
> Normally msgctl08 will complete in a second or two.  With this patch I
> don't know how long it will take to complete, and the machine is horridly
> bogged down.  It does recover if you manage to kill msgctl08.  Feels like
> a terrible memory shortage, but there's plenty of memory free and it isn't
> swapping.
> 
> 
> 

Before the patchset, msgctl08 used to be run with the old msgmni value: 
16. Now it is run with a much higher msgmni value (1746 in my case), 
since it scales to the memory size.
When I call "msgctl08 100000 16" it completes fast.

Doing the follwing on the ref kernel:
echo 1746 > /proc/sys/kernel/msgmni
msgctl08 100000 1746

makes th test block too :-(

Will check to see where the problem comes from.

Rgards,
Nadia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
