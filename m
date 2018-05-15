Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 97BA06B0285
	for <linux-mm@kvack.org>; Tue, 15 May 2018 08:31:29 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v26-v6so2749692pgc.14
        for <linux-mm@kvack.org>; Tue, 15 May 2018 05:31:29 -0700 (PDT)
Received: from mx142.netapp.com (mx142.netapp.com. [2620:10a:4005:8000:2306::b])
        by mx.google.com with ESMTPS id p2-v6si8286388pgq.478.2018.05.15.05.31.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 05:31:28 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
 <20180515111159.GA31599@bombadil.infradead.org>
 <6999e635-e804-99d0-12fc-c13ff3e9ca58@netapp.com>
 <20180515120939.GA12217@hirez.programming.kicks-ass.net>
From: Boaz Harrosh <boazh@netapp.com>
Message-ID: <de0384c7-23a0-fb92-3672-d89b364c5597@netapp.com>
Date: Tue, 15 May 2018 15:31:02 +0300
MIME-Version: 1.0
In-Reply-To: <20180515120939.GA12217@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Matthew Wilcox <willy@infradead.org>, Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 15/05/18 15:09, Peter Zijlstra wrote:
> On Tue, May 15, 2018 at 02:41:41PM +0300, Boaz Harrosh wrote:
>> On 15/05/18 14:11, Matthew Wilcox wrote:
> 
>>> You're still thinking about this from the wrong perspective.  If you
>>> were writing a program to attack this facility, how would you do it?
>>> It's not exactly hard to leak one pointer's worth of information.
>>>
>>
>> That would be very hard. Because that program would:
>> - need to be root
>> - need to start and pretend it is zus Server with the all mount
>>   thread thing, register new filesystem, grab some pmem devices.
>> - Mount the said filesystem on said pmem. Create core-pinned ZT threads
>>   for all CPUs, start accepting IO.
>> - And only then it can start leaking the pointer and do bad things.
>>   The bad things it can do to the application, not to the Kernel.
> 
> No I think you can do bad things to the kernel at that point. Consider
> it populating the TLBs on the 'wrong' CPU by 'inadvertenly' touching
> 'random' memory.
> 
> Then cause an invalidation and get the page re-used for kernel bits.
> 
> Then access that page through the 'stale' TLB entry we still have on the
> 'wrong' CPU and corrupt kernel data.
> 

Yes a BAD filesystem Server can do bad things I agree. But a filesystem can
do very bad things in any case. through the front door, No? and we trust
it with our data. So there is some trust we already put in a filesystem i think.

I will try to look at this deeper, see if I can actually enforce this policy.
Do you have any ideas? can I force page_faults on the other cores?

Thank you for looking
Boaz
