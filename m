Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D923E6B004D
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 01:53:09 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id n9C5r6NT004943
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 05:53:06 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9C5r6Ti753724
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 07:53:06 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n9C5r5vQ014380
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 07:53:06 +0200
Message-ID: <4AD2C43D.1080804@linux.vnet.ibm.com>
Date: Mon, 12 Oct 2009 07:53:01 +0200
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: make VM_MAX_READAHEAD configurable
References: <1255087175-21200-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <1255090830.8802.60.camel@laptop> <20091009122952.GI9228@kernel.dk> <20091009154950.43f01784@mschwide.boeblingen.de.ibm.com> <20091011011006.GA20205@localhost>
In-Reply-To: <20091011011006.GA20205@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> Hi Martin,
>
> On Fri, Oct 09, 2009 at 09:49:50PM +0800, Martin Schwidefsky wrote:
>   
>> On Fri, 9 Oct 2009 14:29:52 +0200
>> Jens Axboe <jens.axboe@oracle.com> wrote:
>>
>>     
>>> On Fri, Oct 09 2009, Peter Zijlstra wrote:
>>>       
>>>> On Fri, 2009-10-09 at 13:19 +0200, Ehrhardt Christian wrote:
>>>>         
>>>>> From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
>>>>>
>>>>> On one hand the define VM_MAX_READAHEAD in include/linux/mm.h is just a default
>>>>> and can be configured per block device queue.
>>>>> On the other hand a lot of admins do not use it, therefore it is reasonable to
>>>>> set a wise default.
>>>>>
>>>>> This path allows to configure the value via Kconfig mechanisms and therefore
>>>>> allow the assignment of different defaults dependent on other Kconfig symbols.
>>>>>
>>>>> Using this, the patch increases the default max readahead for s390 improving
>>>>> sequential throughput in a lot of scenarios with almost no drawbacks (only
>>>>> theoretical workloads with a lot concurrent sequential read patterns on a very
>>>>> low memory system suffer due to page cache trashing as expected).
>>>>>           
> [snip]
>   
>> The patch from Christian fixes a performance regression in the latest
>> distributions for s390. So we would opt for a larger value, 512KB seems
>> to be a good one. I have no idea what that will do to the embedded
>> space which is why Christian choose to make it configurable. Clearly
>> the better solution would be some sort of system control that can be
>> modified at runtime. 
>>     
>
> May I ask for more details about your performance regression and why
> it is related to readahead size? (we didn't change VM_MAX_READAHEAD..)
>   
Sure, the performance regression appeared when comparing Novell SLES10 
vs. SLES11.
While you are right Wu that the upstream default never changed so far, 
SLES10 had a
patch applied that set 512.

As mentioned before I didn't expect to get a generic 128->512 patch 
accepted,therefore
the configurable solution. But after Peter and Jens replied so quickly 
stating that
changing the default in kernel would be the wrong way to go I already 
looked out for
userspace alternatives. At least for my issues I could fix it with 
device specific udev rules
too.

And as Andrew mentioned the diversity of devices cause any default to be 
wrong for one
or another installation. To solve that the udev approach can also differ 
between different
device types (might be easier on s390 than on other architectures 
because I need to take
care of two disk types atm - and both shold get 512).

The testcase for anyone who wants to experiment with it is almost too 
easy, the biggest
impact can be seen with single thread iozone - I get ~40% better 
throughput when
increasing the readahead size to 512 (even bigger RA sizes don't help 
much in my
environment, probably due to fast devices).

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, Open Virtualization 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
