Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BD0756B0205
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:53:41 -0400 (EDT)
Message-ID: <4BA1090E.9090502@redhat.com>
Date: Wed, 17 Mar 2010 18:53:34 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
References: <20100315072214.GA18054@balbir.in.ibm.com> <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com> <4B9DEF81.6020802@redhat.com> <20100315202353.GJ3840@arachsys.com> <4B9F4CBD.3020805@redhat.com> <20100317152452.GZ31148@arachsys.com> <4BA101C5.9040406@redhat.com> <4BA105FE.2000607@redhat.com> <20100317164752.GA31884@arachsys.com>
In-Reply-To: <20100317164752.GA31884@arachsys.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Webb <chris@arachsys.com>
Cc: balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>, Kevin Wolf <kwolf@redhat.com>
List-ID: <linux-mm.kvack.org>

On 03/17/2010 06:47 PM, Chris Webb wrote:
> Avi Kivity<avi@redhat.com>  writes:
>
>    
>> Chris, can you carry out an experiment?  Write a program that
>> pwrite()s a byte to a file at the same location repeatedly, with the
>> file opened using O_SYNC.  Measure the write rate, and run blktrace
>> on the host to see what the disk (/dev/sda, not the volume) sees.
>> Should be a (write, flush, write, flush) per pwrite pattern or
>> similar (for writing the data and a journal block, perhaps even
>> three writes will be needed).
>>
>> Then scale this across multiple guests, measure and trace again.  If
>> we're lucky, the flushes will be coalesced, if not, we need to work
>> on it.
>>      
> Sure, sounds like an excellent plan. I don't have a test machine at the
> moment as the last host I was using for this has gone into production, but
> I'm due to get another one to install later today or first thing tomorrow
> which would be ideal for doing this. I'll follow up with the results once I
> have them.
>    

Meanwhile I looked at the code, and it looks bad.  There is an 
IO_CMD_FDSYNC, but it isn't tagged, so we have to drain the queue before 
issuing it.  In any case, qemu doesn't use it as far as I could tell, 
and even if it did, device-matter doesn't implement the needed 
->aio_fsync() operation.

So, there's a lot of plubming needed before we can get cache flushes 
merged into each other.  Given cache=writeback does allow merging, I 
think we explained part of the problem at least.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
