Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 303726B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 15:42:19 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id fz5so117205230obc.0
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 12:42:19 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id y198si13196972oie.130.2016.03.07.12.42.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 12:42:18 -0800 (PST)
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
 <20160305.230702.1325379875282120281.davem@davemloft.net>
 <56DD9949.1000106@oracle.com>
 <20160307.115626.807716799249471744.davem@davemloft.net>
 <56DDC2B6.6020009@oracle.com>
 <CALCETrXN43nT4zq2MpO90VrgK3k+DKHjOHWf7iOhS7TSBmdCPQ@mail.gmail.com>
 <56DDC6E0.4000907@oracle.com>
 <CALCETrU5NCzh3b7We8903G0_Tm-oycgP3+gS9fG+vC_rdgTddw@mail.gmail.com>
 <56DDDA31.9090105@oracle.com>
 <CALCETrXXU0fs2ezq+Wn_kr4dZTO=0RJmt6b=XBSA-wM7W_9j9A@mail.gmail.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <56DDE783.8090009@oracle.com>
Date: Mon, 7 Mar 2016 13:41:39 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrXXU0fs2ezq+Wn_kr4dZTO=0RJmt6b=XBSA-wM7W_9j9A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: David Miller <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, dingel@linux.vnet.ibm.com, bob.picco@oracle.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Arnd Bergmann <arnd@arndb.de>, sparclinux@vger.kernel.org, Rob Gardner <rob.gardner@oracle.com>, Michal Hocko <mhocko@suse.cz>, chris.hyser@oracle.com, Richard Weinberger <richard@nod.at>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, Andrew Lutomirski <luto@kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Benjamin Segall <bsegall@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Davidlohr Bueso <dave@stgolabs.net>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On 03/07/2016 12:54 PM, Andy Lutomirski wrote:
> On Mon, Mar 7, 2016 at 11:44 AM, Khalid Aziz <khalid.aziz@oracle.com> wrote:
>>
>> Consider this scenario:
>>
>> 1. Process A creates a shm and attaches to it.
>> 2. Process A fills shm with data it wants to share with only known
>> processes. It enables ADI and sets tags on the shm.
>> 3. Hacker triggers something like stack overflow on process A, exec's a new
>> rogue binary and manages to attach to this shm. MMU knows tags were set on
>> the virtual address mapping to the physical pages hosting the shm. If MMU
>> does not require the rogue process to set the exact same tags on its mapping
>> of the same shm, rogue process has defeated the ADI protection easily.
>>
>> Does this make sense?
>
> This makes sense, but I still think the design is poor.  If the hacker
> gets code execution, then they can trivially brute force the ADI bits.

True, with only 16 possible tag values (actually only 14 since 0 and 15 
are reserved values), it is entirely possible to brute force the ADI 
tag. ADI is just another tool one can use to mitigate attacks. A process 
that accesses an ADI enabled memory with invalid tag gets a SIGBUS and 
is terminated. This can trigger alerts on the system and system policies 
could block the next attack. If a daemon is compromised and is forced to 
hand out data from memory it should not be reading (similar to 
heartbleed bug). the daemon itself is terminated with SIGBUS which 
should be enough to alert system admins. A rotating set of tags would 
reduce the risk from brute force attacks. Tags are set on cacheline 
(which is 64 bytes on M7). A single regular sized page can have 128 sets 
of tags. Allowing for 14 possible values for each set, that is a lot of 
possible combinations of tags making it very hard to brute force tags 
for more than a cacheline at a time. There are probably other better 
ways to make the tags harder to crack.

>
> Also, if this is the use case in mind, shouldn't the ADI bits bet set
> on the file, not the mapping?  E.g. have an ioctl on the shmfs file
> that sets its ADI bits?

Shared data may not always be backed by a file. My understanding is one 
of the use cases is for in-memory databases. This shared space could 
also be used to hand off transactions in flight to other processes. 
These transactions in flight would not be backed by a file. Some of 
these use cases might not use shmfs even. Setting ADI bits at virtual 
address level catches all these cases since what backs the tagged 
virtual address can be anything - a mapped file, mmio space, just plain 
chunk of memory.

>
>> A process can not just write version tags and make the file inaccessible to
>> others. It takes three steps to enable ADI:
>>
>> 1. Set PSTATE.mcde for the process.
>> 2. Set TTE.mcd on all PTEs for the virtual addresses ADI is being enabled
>> on.
>> 3. Set version tags.
>>
>> Unless all three steps are taken, tag checking will not be done. stxa will
>> fail unless step 2 is completed. In your example, the step of setting
>> TTE.mcd will force sharing to stop for the process through
>> change_protection(), right?
>
> OK, that makes some sense.
>
> Can a shared page ever have TTE.mcd set?  How does one share a page,
> even deliberately, between two processes with cmd set?

For two processes to share a page, their VMAs have to be identical as I 
understand it. If one process has TTE.mcd set (which means vma->vm_flags 
is different) while the other does not, they do not share a page.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
