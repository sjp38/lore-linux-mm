Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id AC2CC6B0005
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 11:06:51 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id u110so99540080qge.3
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 08:06:51 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id p40si17447048qge.42.2016.03.07.08.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 08:06:50 -0800 (PST)
Subject: Re: [PATCH v2] sparc64: Add support for Application Data Integrity
 (ADI)
References: <1456951177-23579-1-git-send-email-khalid.aziz@oracle.com>
 <20160305.230702.1325379875282120281.davem@davemloft.net>
 <56DD9949.1000106@oracle.com> <56DD9E94.70201@oracle.com>
 <CALCETrXey2_xEXhzjgHtZmf-dLp-9pec===d-8chLxrp8wgRXg@mail.gmail.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <56DDA6FD.4040404@oracle.com>
Date: Mon, 7 Mar 2016 09:06:21 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrXey2_xEXhzjgHtZmf-dLp-9pec===d-8chLxrp8wgRXg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Rob Gardner <rob.gardner@oracle.com>
Cc: David Miller <davem@davemloft.net>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, dingel@linux.vnet.ibm.com, zhenzhang.zhang@huawei.com, bob.picco@oracle.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Arnd Bergmann <arnd@arndb.de>, sparclinux@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, chris.hyser@oracle.com, Richard Weinberger <richard@nod.at>, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Greg Thelen <gthelen@google.com>, Jan Kara <jack@suse.cz>, xiexiuqi@huawei.com, Vineet.Gupta1@synopsys.com, Andrew Lutomirski <luto@kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, bsegall@google.com, Geert Uytterhoeven <geert@linux-m68k.org>, Davidlohr Bueso <dave@stgolabs.net>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>

On 03/07/2016 08:43 AM, Andy Lutomirski wrote:
> On Mon, Mar 7, 2016 at 7:30 AM, Rob Gardner <rob.gardner@oracle.com> wrote:
>> On 03/07/2016 07:07 AM, Khalid Aziz wrote:
>>>
>>> On 03/05/2016 09:07 PM, David Miller wrote:
>>>>
>>>> From: Khalid Aziz <khalid.aziz@oracle.com>
>>>> Date: Wed,  2 Mar 2016 13:39:37 -0700
>>>>
>>>>>      In this
>>>>>      first implementation I am enabling ADI for hugepages only
>>>>>      since these pages are locked in memory and hence avoid the
>>>>>      issue of saving and restoring tags.
>>>>
>>>>
>>>> This makes the feature almost entire useless.
>>>>
>>>> Non-hugepages must be in the initial implementation.
>>>
>>>
>>> Hi David,
>>>
>>> Thanks for the feedback. I will get this working for non-hugepages as
>>> well. ADI state of each VMA region is already stored in the VMA itself in my
>>> first implementation, so I do not lose it when the page is swapped out. The
>>> trouble is ADI version tags for each VMA region have to be stored on the
>>> swapped out pages since the ADI version tags are flushed when TLB entry for
>>> a page is flushed.
>>
>>
>>
>> Khalid,
>>
>> Are you sure about that last statement? My understanding is that the tags
>> are stored in physical memory, and remain there until explicitly changed or
>> removed, and so flushing a TLB entry has no effect on the ADI tags. If it
>> worked the way you think, then somebody would have to potentially reload a
>> long list of ADI tags on every TLB miss.
>>
>
> I'll bite, since this was sent to linux-api:
>
> Can someone explain what this feature does for the benefit of people
> who haven't read the manual (and who don't even know where to find the
> manual)?
>
> Are the top few bits of a sparc64 virtual address currently
> must-be-zero?  Does this feature change the semantics so that those
> bits are ignored for address resolution and instead must match
> whatever the ADI tag is determined to be during address resolution?
>
> Is this enforced for both user and kernel accesses?
>
> Is the actual ADI tag associated with a "page" associated with the
> page of physical memory or is it associated with a mapping?  That is,
> if there are two virtual aliases of the same physical page (in the
> same process or otherwise), does the hardware require them to have the
> same ADI tag?  If the answer is no, then IMO this is definitely
> something that should use mprotect and you should seriously consider
> using something like mprotect_key (new syscall, not in Linus' tree
> yet) for it.  In fact, you might consider a possible extra parameter
> to that syscall for this purpose.
>
> Cc: Dave Hansen.  It seems to be the zeitgeist to throw tag bits at
> PTEs these days.
>

Hi Andy,

The primary purpose of this feature is to prevent rogue accesses to 
memory regions. If a database were to allocate memory pages to cache 
database, it can enable ADI on those pages and set version tags. Version 
tag for a memory address is encoded in bits 63-60 in the virtual 
address. When accessing an ADI enabled memory region, top 4 bits of the 
virtual address presented to the MMU must match the version tag set 
earlier. When these bits do not match a tag, an MCD (Memory Corruption 
Detected) exception is raised. Kernel sends a SIGBUS to the offending 
process in response. There is some more info on ADI at 
<https://swisdev.oracle.com/_files/What-Is-ADI.html>.

Top 4-bits of sparc64 virtual address are used for version tag only when 
a process has its PSTATE.mcde bit set and it is accessing a memory 
region that has ADI enabled on it (TTE.mcd set) and a version tag was 
set on the virtual address being accessed. These 4-bits retain their 
original semantics in all other cases.

ADI version tags are checked for data fetches only. My implementation 
enforces this for userspace addresses only. Expanding this to include 
kernel data addresses as well will be a good thing to do to protect 
kernel data but I want to try to do this incrementally - (1) ADI for 
userspace addresses only for mlock'd pages, (2) expand support to 
swappable pages, (3) ADI for kernel data pages, (4)......whatever else 
makes sense...

ADI version tag applies to virtual addresses only. If two processes have 
virtual addresses mapping to the same physical page, they must use the 
same tag. Hardware will send MCD exception if the tags do not match. 
This was done to ensure a hack does not bypass ADI protection by simply 
inserting another VA-to-PA mapping. I do like the idea of mprotect() as 
David suggested and it can be done with existing mprotect() call. I will 
have to add a new key PROT_ADI to support this.

Thanks,
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
