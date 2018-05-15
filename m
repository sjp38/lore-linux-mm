Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4989F6B0297
	for <linux-mm@kvack.org>; Tue, 15 May 2018 09:29:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e7-v6so69291pfi.8
        for <linux-mm@kvack.org>; Tue, 15 May 2018 06:29:46 -0700 (PDT)
Received: from mx144.netapp.com (mx144.netapp.com. [2620:10a:4005:8000:2306::d])
        by mx.google.com with ESMTPS id j17-v6si38309pgv.395.2018.05.15.06.29.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 06:29:45 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
 <20180515111159.GA31599@bombadil.infradead.org>
 <6999e635-e804-99d0-12fc-c13ff3e9ca58@netapp.com>
 <20180515120355.GE31599@bombadil.infradead.org>
From: Boaz Harrosh <boazh@netapp.com>
Message-ID: <afe2c02f-3ecd-5f54-53ab-d45c11a5b4aa@netapp.com>
Date: Tue, 15 May 2018 16:29:22 +0300
MIME-Version: 1.0
In-Reply-To: <20180515120355.GE31599@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 15/05/18 15:03, Matthew Wilcox wrote:
> On Tue, May 15, 2018 at 02:41:41PM +0300, Boaz Harrosh wrote:
>> That would be very hard. Because that program would:
>> - need to be root
>> - need to start and pretend it is zus Server with the all mount
>>   thread thing, register new filesystem, grab some pmem devices.
>> - Mount the said filesystem on said pmem. Create core-pinned ZT threads
>>   for all CPUs, start accepting IO.
>> - And only then it can start leaking the pointer and do bad things.
> 
> All of these things you've done for me by writing zus Server.  All I
> have to do now is compromise zus Server.
> 
>>   The bad things it can do to the application, not to the Kernel.
>>   And as a full filesystem it can do those bad things to the application
>>   through the front door directly not needing the mismatch tlb at all.
> 
> That's not true.  When I have a TLB entry that points to a page of kernel
> ram, I can do almost anything, depending on what the kernel decides to
> do with that ram next.  Maybe it's page cache again, in which case I can
> affect whatever application happens to get it allocated.  Maybe it's a
> kmalloc page next, in which case I can affect any part of the kernel.
> Maybe it's a page table, then I can affect any process.
> 
>> That said. It brings up a very important point that I wanted to talk about.
>> In this design the zuf(Kernel) and the zus(um Server) are part of the distribution.
>> I would like to have the zus module be signed by the distro's Kernel's key and
>> checked on loadtime. I know there is an effort by Redhat guys to try and sign all
>> /sbin/* servers and have Kernel check these. So this is not the first time people
>> have thought about that.
> 
> You're getting dangerously close to admitting that the entire point
> of this exercise is so that you can link non-GPL NetApp code into the
> kernel in clear violation of the GPL.
> 

It is not that at all. What I'm trying to do is enable a zero-copy,
synchronous, low latency, low overhead. highly parallel - a new modern
interface with application servers.

You yourself had such a project that could easily be served out-of-the-box
with zufs, of a device that wanted to sit in user-mode.

Sometimes it is very convenient and needed for Servers to sit in
user-mode. And this interface allows that. And it is not always
a licensing thing. Though yes licensing is also an issue sometimes.
It is the reality we are living in.

But please indulge me I am curious how the point of signing /sbin/
servers, made you think about GPL licensing issues?

That said, is your point that as long as user-mode servers are sloooowwww
they are OK to be supported but if they are as fast as the kernel,
(as demonstrated a zufs based FS was faster then xfs-dax on same pmem)
Then it is a GPL violation?

Thanks
Boaz
