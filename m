Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 579DC6B026B
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 13:04:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t78-v6so16527756pfa.8
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 10:04:58 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id d4-v6si19818274pla.81.2018.07.11.10.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 10:04:57 -0700 (PDT)
Subject: Re: [RFC v4 0/3] mm: zap pages with read mmap_sem in munmap for large
 mapping
References: <1531265649-93433-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180711111052.hbyukcwetmjjpij2@kshutemo-mobl1>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <3d4c69c9-dd2b-30d2-5bf2-d5b108a76758@linux.alibaba.com>
Date: Wed, 11 Jul 2018 10:04:48 -0700
MIME-Version: 1.0
In-Reply-To: <20180711111052.hbyukcwetmjjpij2@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 7/11/18 4:10 AM, Kirill A. Shutemov wrote:
> On Wed, Jul 11, 2018 at 07:34:06AM +0800, Yang Shi wrote:
>> Background:
>> Recently, when we ran some vm scalability tests on machines with large memory,
>> we ran into a couple of mmap_sem scalability issues when unmapping large memory
>> space, please refer to https://lkml.org/lkml/2017/12/14/733 and
>> https://lkml.org/lkml/2018/2/20/576.
>>
>>
>> History:
>> Then akpm suggested to unmap large mapping section by section and drop mmap_sem
>> at a time to mitigate it (see https://lkml.org/lkml/2018/3/6/784).
>>
>> V1 patch series was submitted to the mailing list per Andrew's suggestion
>> (see https://lkml.org/lkml/2018/3/20/786). Then I received a lot great feedback
>> and suggestions.
>>
>> Then this topic was discussed on LSFMM summit 2018. In the summit, Michal Hocko
>> suggested (also in the v1 patches review) to try "two phases" approach. Zapping
>> pages with read mmap_sem, then doing via cleanup with write mmap_sem (for
>> discussion detail, see https://lwn.net/Articles/753269/)
>>
>>
>> Approach:
>> Zapping pages is the most time consuming part, according to the suggestion from
>> Michal Hocko [1], zapping pages can be done with holding read mmap_sem, like
>> what MADV_DONTNEED does. Then re-acquire write mmap_sem to cleanup vmas.
>>
>> But, we can't call MADV_DONTNEED directly, since there are two major drawbacks:
>>    * The unexpected state from PF if it wins the race in the middle of munmap.
>>      It may return zero page, instead of the content or SIGSEGV.
>>    * Cana??t handle VM_LOCKED | VM_HUGETLB | VM_PFNMAP and uprobe mappings, which
>>      is a showstopper from akpm
>>
>> And, some part may need write mmap_sem, for example, vma splitting. So, the
>> design is as follows:
>>          acquire write mmap_sem
>>          lookup vmas (find and split vmas)
>>          set VM_DEAD flags
>>          deal with special mappings
>>          downgrade_write
>>
>>          zap pages
>>          release mmap_sem
>>
>>          retake mmap_sem exclusively
>>          cleanup vmas
>>          release mmap_sem
>>
>> Define large mapping size thresh as PUD size, just zap pages with read mmap_sem
>> for mappings which are >= PUD_SIZE. So, unmapping less than PUD_SIZE area still
>> goes with the regular path.
>>
>> All vmas which will be zapped soon will have VM_DEAD flag set. Since PF may race
>> with munmap, may just return the right content or SIGSEGV before the optimization,
>> but with the optimization, it may return a zero page. Here use this flag to mark
>> PF to this area is unstable, will trigger SIGSEGV, in order to prevent from the
>> unexpected 3rd state.
>>
>> If the vma has VM_LOCKED | VM_HUGETLB | VM_PFNMAP or uprobe, they are considered
>> as special mappings. They will be dealt with before zapping pages with write
>> mmap_sem held. Basically, just update vm_flags. The actual unmapping is still
>> done with read mmap_sem.
>>
>> And, since they are also manipulated by unmap_single_vma() which is called by
>> zap_page_range() with read mmap_sem held in this case, to prevent from updating
>> vm_flags in read critical section and considering the complexity of coding, just
>> check if VM_DEAD is set, then skip any VM_DEAD area since they should be handled
>> before.
>>
>> When cleaning up vmas, just call do_munmap() without carrying vmas from the above
>> to avoid race condition, since the address space might be already changed under
>> our feet after retaking exclusive lock.
>>
>> For the time being, just do this in munmap syscall path. Other vm_munmap() or
>> do_munmap() call sites (i.e mmap, mremap, etc) remain intact for stability reason.
>> And, make this 64 bit only explicitly per akpm's suggestion.
> I still see VM_DEAD as unnecessary complication. We should be fine without it.
> But looks like I'm in the minority :/
>
> It's okay. I have another suggestion that also doesn't require VM_DEAD
> trick too :)
>
> 1. Take mmap_sem for write;
> 2. Adjust VMA layout (split/remove). After the step all memory we try to
>     unmap is outside any VMA.
> 3. Downgrade mmap_sem to read.
> 4. Zap the page range.
> 5. Drop mmap_sem.
>
> I believe it should be safe.


Yes, it looks so. But, a further question is all the vmas have been 
removed, how zap_page_range could do its job? It depends on the vmas.

One approach is to save all the vmas on a separate list, then 
zap_page_range does unmap with this list.

Yang

>
> The pages in the range cannot be re-faulted after step 3 as find_vma()
> will not see the corresponding VMA and deliver SIGSEGV.
>
> New VMAs cannot be created in the range before step 5 since we hold the
> semaphore at least for read the whole time.
>
> Do you see problem in this approach?
>
