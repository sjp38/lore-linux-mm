Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id BDA786B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 03:03:31 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id d42so78975qca.15
        for <linux-mm@kvack.org>; Tue, 16 Apr 2013 00:03:30 -0700 (PDT)
Message-ID: <516CF7BB.3050301@gmail.com>
Date: Tue, 16 Apr 2013 15:03:23 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] Hardware initiated paging of user process pages,
 hardware access to the CPU page tables of user processes
References: <5114DF05.7070702@mellanox.com> <CAH3drwbjQa2Xms30b8J_oEUw7Eikcno-7Xqf=7=da3LHWXvkKA@mail.gmail.com>
In-Reply-To: <CAH3drwbjQa2Xms30b8J_oEUw7Eikcno-7Xqf=7=da3LHWXvkKA@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Shachar Raindel <raindel@mellanox.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Roland Dreier <roland@purestorage.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Liran Liss <liranl@mellanox.com>

Hi Jerome,
On 02/08/2013 11:21 PM, Jerome Glisse wrote:
> On Fri, Feb 8, 2013 at 6:18 AM, Shachar Raindel <raindel@mellanox.com> wrote:
>> Hi,
>>
>> We would like to present a reference implementation for safely sharing
>> memory pages from user space with the hardware, without pinning.
>>
>> We will be happy to hear the community feedback on our prototype
>> implementation, and suggestions for future improvements.
>>
>> We would also like to discuss adding features to the core MM subsystem to
>> assist hardware access to user memory without pinning.
>>
>> Following is a longer motivation and explanation on the technology
>> presented:
>>
>> Many application developers would like to be able to be able to communicate
>> directly with the hardware from the userspace.
>>
>> Use cases for that includes high performance networking API such as
>> InfiniBand, RoCE and iWarp and interfacing with GPUs.
>>
>> Currently, if the user space application wants to share system memory with
>> the hardware device, the kernel component must pin the memory pages in RAM,
>> using get_user_pages.
>>
>> This is a hurdle, as it usually makes large portions the application memory
>> unmovable. This pinning also makes the user space development model very
>> complicated ? one needs to register memory before using it for communication
>> with the hardware.
>>
>> We use the mmu-notifiers [1] mechanism to inform the hardware when the
>> mapping of a page is changed. If the hardware tries to access a page which
>> is not yet mapped for the hardware, it requests a resolution for the page
>> address from the kernel.
>>
>> This mechanism allows the hardware to access the entire address space of the
>> user application, without pinning even a single page.
>>
>> We would like to use the LSF/MM forum opportunity to discuss open issues we
>> have for further development, such as:
>>
>> -Allowing the hardware to perform page table walk, similar to
>> get_user_pages_fast to resolve user pages that are already in RAM.

get_user_pages_fast just get page reference count instead of populate 
the pte to page table, correct? Then how can GPU driver use iommu to 
access the page?

>>
>> -Batching page eviction by various kernel subsystems (swapper, page-cache)
>> to reduce the amount of communication needed with the hardware in such
>> events
>>
>> -Hinting from the hardware to the MM regarding page fetches which are
>> speculative, similarly to prefetching done by the page-cache
>>
>> -Page-in notifications from the kernel to the driver, such that we can keep
>> our secondary TLB in sync with the kernel page table without incurring page
>> faults.
>>
>> -Allowed and banned actions while in an MMU notifier callback. We have
>> already done some work on making the MMU notifiers sleepable [2], but there
>> might be additional limitations, which we would like to discuss.
>>
>> -Hinting from the MMU notifiers as for the reason for the notification - for
>> example we would like to react differently if a page was moved by NUMA
>> migration vs. page being swapped out.
>>
>> [1] http://lwn.net/Articles/266320/
>>
>> [2] http://comments.gmane.org/gmane.linux.kernel.mm/85002
>>
>> Thanks,
>>
>> --Shachar
> As a GPU driver developer i can say that this is something we want to
> do in a very near future. Also i think we would like another
> capabilities :
>
> - hint to mm on memory range that are best not to evict (easier for
> driver to know what is hot and gonna see activities)
>
> Dunno how big the change to the page eviction path would need to be.
>
> Cheers,
> Jerome
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
