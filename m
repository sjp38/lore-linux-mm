Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id D80116B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 04:39:25 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id a22so550899qcs.12
        for <linux-mm@kvack.org>; Mon, 15 Apr 2013 01:39:24 -0700 (PDT)
Message-ID: <516BBCB5.7050303@gmail.com>
Date: Mon, 15 Apr 2013 16:39:17 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] Hardware initiated paging of user process pages,
 hardware access to the CPU page tables of user processes
References: <5114DF05.7070702@mellanox.com> <CANN689Ff6vSu4ZvHek4J4EMzFG7EjF-Ej48hJKV_4SrLoj+mCA@mail.gmail.com> <CAH3drwaACy5KFv_2ozEe35u1Jpxs0f6msKoW=3_0nrWZpJnO4w@mail.gmail.com>
In-Reply-To: <CAH3drwaACy5KFv_2ozEe35u1Jpxs0f6msKoW=3_0nrWZpJnO4w@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Michel Lespinasse <walken@google.com>, Shachar Raindel <raindel@mellanox.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Roland Dreier <roland@purestorage.com>, Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Liran Liss <liranl@mellanox.com>

Hi Jerome,
On 02/10/2013 12:29 AM, Jerome Glisse wrote:
> On Sat, Feb 9, 2013 at 1:05 AM, Michel Lespinasse <walken@google.com> wrote:
>> On Fri, Feb 8, 2013 at 3:18 AM, Shachar Raindel <raindel@mellanox.com> wrote:
>>> Hi,
>>>
>>> We would like to present a reference implementation for safely sharing
>>> memory pages from user space with the hardware, without pinning.
>>>
>>> We will be happy to hear the community feedback on our prototype
>>> implementation, and suggestions for future improvements.
>>>
>>> We would also like to discuss adding features to the core MM subsystem to
>>> assist hardware access to user memory without pinning.
>> This sounds kinda scary TBH; however I do understand the need for such
>> technology.
>>
>> I think one issue is that many MM developers are insufficiently aware
>> of such developments; having a technology presentation would probably
>> help there; but traditionally LSF/MM sessions are more interactive
>> between developers who are already quite familiar with the technology.
>> I think it would help if you could send in advance a detailed
>> presentation of the problem and the proposed solutions (and then what
>> they require of the MM layer) so people can be better prepared.
>>
>> And first I'd like to ask, aren't IOMMUs supposed to already largely
>> solve this problem ? (probably a dumb question, but that just tells
>> you how much you need to explain :)
> For GPU the motivation is three fold. With the advance of GPU compute
> and also with newer graphic program we see a massive increase in GPU
> memory consumption. We easily can reach buffer that are bigger than
> 1gbytes. So the first motivation is to directly use the memory the
> user allocated through malloc in the GPU this avoid copying 1gbytes of
> data with the cpu to the gpu buffer. The second and mostly important

The pinned memory you mentioned is the memory user allocated or the 
memory of gpu buffer?

> to GPU compute is the use of GPU seamlessly with the CPU, in order to
> achieve this you want the programmer to have a single address space on
> the CPU and GPU. So that the same address point to the same object on
> GPU as on the CPU. This would also be a tremendous cleaner design from
> driver point of view toward memory management.
>
> And last, the most important, with such big buffer (>1gbytes) the
> memory pinning is becoming way to expensive and also drastically
> reduce the freedom of the mm to free page for other process. Most of
> the time a small window (every thing is relative the window can be >
> 100mbytes not so small :)) of the object will be in use by the
> hardware. The hardware pagefault support would avoid the necessity to
> pin memory and thus offer greater flexibility. At the same time the
> driver wants to avoid page fault as much as possible this is why i
> would like to be able to give hint to the mm about range of address it
> should avoid freeing page (swapping them out).
>
> The iommu was designed with other goals, which were first isolate
> device from one another and restrict device access to allowed memory.
> Second allow to remap address that are above device address space
> limit. Lot of device can only address 24bit or 32bit of memory and
> with computer with several gbytes of memory suddenly lot of the page
> become unreachable to the hardware. The iommu allow to work around
> this by remapping those high page into address that the hardware can
> reach.
>
> The hardware page fault support is a new feature of iommu designed to
> help the os and driver to reduce memory pinning and also share address
> space. Thought i am sure there are other motivations that i am not
> even aware off or would think off.
>
> Btw i won't be at LSF/MM so a free good beer (or other beverage) on me
> to whoever takes note on this subject in next conf we run into each
> others.
>
> Cheers,
> Jerome
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
