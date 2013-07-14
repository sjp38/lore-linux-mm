Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id BDC9A6B0033
	for <linux-mm@kvack.org>; Sat, 13 Jul 2013 23:13:04 -0400 (EDT)
Received: by mail-ie0-f175.google.com with SMTP id a11so15776132iee.6
        for <linux-mm@kvack.org>; Sat, 13 Jul 2013 20:13:04 -0700 (PDT)
Message-ID: <51E2173A.8080003@gmail.com>
Date: Sun, 14 Jul 2013 11:12:58 +0800
From: Sam Ben <sam.bennn@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] mm: madvise: MADV_POPULATE for quick pre-faulting
References: <20130627231605.8F9F12E6@viggo.jf.intel.com> <20130628054757.GA10429@gmail.com> <51CDB056.5090308@sr71.net> <51CE4451.4060708@gmail.com> <51D1AB6E.9030905@sr71.net> <20130702023748.GA10366@gmail.com>
In-Reply-To: <20130702023748.GA10366@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 07/02/2013 10:37 AM, Zheng Liu wrote:
> On Mon, Jul 01, 2013 at 09:16:46AM -0700, Dave Hansen wrote:
>> On 06/28/2013 07:20 PM, Zheng Liu wrote:
>>>>> IOW, a process needing to do a bunch of MAP_POPULATEs isn't
>>>>> parallelizable, but one using this mechanism would be.
>>> I look at the code, and it seems that we will handle MAP_POPULATE flag
>>> after we release mmap_sem locking in vm_mmap_pgoff():
>>>
>>>                  down_write(&mm->mmap_sem);
>>>                  ret = do_mmap_pgoff(file, addr, len, prot, flag, pgoff,
>>>                                      &populate);
>>>                  up_write(&mm->mmap_sem);
>>>                  if (populate)
>>>                          mm_populate(ret, populate);
>>>
>>> Am I missing something?
>> I went and did my same test using mmap(MAP_POPULATE)/munmap() pair
>> versus using MADV_POPULATE in 160 threads in parallel.
>>
>> MADV_POPULATE was about 10x faster in the threaded configuration.
>>
>> With MADV_POPULATE, the biggest cost is shipping the mmap_sem cacheline
>> around so that we can write the reader count update in to it.  With
>> mmap(), there is a lot of _contention_ on that lock which is much, much
>> more expensive than simply bouncing a cacheline around.
> Thanks for your explanation.
>
> FWIW, it would be great if we can let MAP_POPULATE flag support shared
> mappings because in our product system there has a lot of applications
> that uses mmap(2) and then pre-faults this mapping.  Currently these
> applications need to pre-fault the mapping manually.

How do you pre-fault the mapping manually in your product system? By 
walking through the file touching each page?

>
> Regards,
>                                                  - Zheng
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
