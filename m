Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 649626B004D
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 05:30:00 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.1/8.13.1) with ESMTP id n9C9TvVV020880
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 09:29:57 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9C9Tpqu3420362
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 11:29:57 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n9C9TpZB002451
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 11:29:51 +0200
Message-ID: <4AD2F70C.4010506@linux.vnet.ibm.com>
Date: Mon, 12 Oct 2009 11:29:48 +0200
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: make VM_MAX_READAHEAD configurable
References: <1255087175-21200-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <1255090830.8802.60.camel@laptop> <20091009122952.GI9228@kernel.dk> <20091009154950.43f01784@mschwide.boeblingen.de.ibm.com> <20091011011006.GA20205@localhost> <4AD2C43D.1080804@linux.vnet.ibm.com> <20091012062317.GA10719@localhost>
In-Reply-To: <20091012062317.GA10719@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> [SNIP]
>>> May I ask for more details about your performance regression and why
>>> it is related to readahead size? (we didn't change VM_MAX_READAHEAD..)
>>>   
>>>       
>> Sure, the performance regression appeared when comparing Novell SLES10 
>> vs. SLES11.
>> While you are right Wu that the upstream default never changed so far, 
>> SLES10 had a
>> patch applied that set 512.
>>     
>
> I see. I'm curious why SLES11 removed that patch. Did it experienced
> some regressions with the larger readahead size?
>
>   

Only the obvious expected one with very low free/cacheable
memory and a lot of parallel processes that do sequential I/O.
The RA size scales up for all of them but 64xMaxRA then
doesn't fit.

For example iozone with 64 threads (each on one disk for its own),
sequential access pattern read with I guess 10 M free for cache
suffered by ~15% due to trashing.

But that is a acceptable regression because it is no relevant
customer scenario, while the benefits apply to customer scenarios.

[...]
>> And as Andrew mentioned the diversity of devices cause any default to be 
>> wrong for one
>> or another installation. To solve that the udev approach can also differ 
>> between different
>> device types (might be easier on s390 than on other architectures 
>> because I need to take
>> care of two disk types atm - and both shold get 512).
>>     
>
> I guess it's not a general solution for all. There are so many
> devices in the world, and we have not yet considered the
> memory/workload combinations.
>   
I completely agree, let me fix "my" issue per udev for now.
And if some day the readahead mechanism evolves and
doesn't need any max RA at all we can all be happy.

[...]

-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, Open Virtualization 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
