Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 425316B0033
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 04:58:31 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id u48so2904887qtc.3
        for <linux-mm@kvack.org>; Thu, 14 Sep 2017 01:58:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 13si6908046qtr.283.2017.09.14.01.58.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Sep 2017 01:58:30 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8E8s6oV139754
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 04:58:29 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cyp6rsuq2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 14 Sep 2017 04:58:29 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 14 Sep 2017 09:58:27 +0100
Subject: Re: [PATCH v3 04/20] mm: VMA sequence count
References: <1504894024-2750-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1504894024-2750-5-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170913115354.GA7756@jagdpanzerIV.localdomain>
 <44849c10-bc67-b55e-5788-d3c6bb5e7ad1@linux.vnet.ibm.com>
 <20170914003116.GA599@jagdpanzerIV.localdomain>
 <441ff1c6-72a7-5d96-02c8-063578affb62@linux.vnet.ibm.com>
 <20170914081358.GG599@jagdpanzerIV.localdomain>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 14 Sep 2017 10:58:16 +0200
MIME-Version: 1.0
In-Reply-To: <20170914081358.GG599@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <26fa0b71-4053-5af7-baa0-e5fff9babf41@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 14/09/2017 10:13, Sergey Senozhatsky wrote:
> Hi,
> 
> On (09/14/17 09:55), Laurent Dufour wrote:
> [..]
>>> so if there are two CPUs, one doing write_seqcount() and the other one
>>> doing read_seqcount() then what can happen is something like this
>>>
>>> 	CPU0					CPU1
>>>
>>> 						fs_reclaim_acquire()
>>> 	write_seqcount_begin()
>>> 	fs_reclaim_acquire()			read_seqcount_begin()
>>> 	write_seqcount_end()
>>>
>>> CPU0 can't write_seqcount_end() because of fs_reclaim_acquire() from
>>> CPU1, CPU1 can't read_seqcount_begin() because CPU0 did write_seqcount_begin()
>>> and now waits for fs_reclaim_acquire(). makes sense?
>>
>> Yes, this makes sense.
>>
>> But in the case of this series, there is no call to
>> __read_seqcount_begin(), and the reader (the speculative page fault
>> handler), is just checking for (vm_seq & 1) and if this is true, simply
>> exit the speculative path without waiting.
>> So there is no deadlock possibility.
> 
> probably lockdep just knows that those locks interleave at some
> point.
> 
> 
> by the way, I think there is one path that can spin
> 
> find_vma_srcu()
>  read_seqbegin()
>   read_seqcount_begin()
>    raw_read_seqcount_begin()
>     __read_seqcount_begin()


That's right, but here this is the  sequence counter mm->mm_seq, not the
vm_seq one.

This one is held to protect walking the VMA list "locklessly"...

Cheers,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
