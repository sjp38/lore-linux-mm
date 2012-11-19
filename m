Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 1340A6B0071
	for <linux-mm@kvack.org>; Mon, 19 Nov 2012 06:29:38 -0500 (EST)
Received: by mail-ie0-f169.google.com with SMTP id 10so8185382ied.14
        for <linux-mm@kvack.org>; Mon, 19 Nov 2012 03:29:37 -0800 (PST)
Message-ID: <50AA1813.80408@gmail.com>
Date: Mon, 19 Nov 2012 19:29:23 +0800
From: Jaegeuk Hanse <jaegeuk.hanse@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 10/12] thp: implement refcounting for huge zero page
References: <1353007622-18393-1-git-send-email-kirill.shutemov@linux.intel.com> <1353007622-18393-11-git-send-email-kirill.shutemov@linux.intel.com> <50A87EF0.3060706@gmail.com> <20121119095615.GA23869@otc-wbsnb-06> <50AA07D1.7030906@gmail.com> <20121119102318.GA24187@shutemov.name> <50AA11BE.6070205@gmail.com> <20121119110935.GA24372@shutemov.name>
In-Reply-To: <20121119110935.GA24372@shutemov.name>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>

On 11/19/2012 07:09 PM, Kirill A. Shutemov wrote:
> On Mon, Nov 19, 2012 at 07:02:22PM +0800, Jaegeuk Hanse wrote:
>> On 11/19/2012 06:23 PM, Kirill A. Shutemov wrote:
>>> On Mon, Nov 19, 2012 at 06:20:01PM +0800, Jaegeuk Hanse wrote:
>>>> On 11/19/2012 05:56 PM, Kirill A. Shutemov wrote:
>>>>> On Sun, Nov 18, 2012 at 02:23:44PM +0800, Jaegeuk Hanse wrote:
>>>>>> On 11/16/2012 03:27 AM, Kirill A. Shutemov wrote:
>>>>>>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>>>>>>
>>>>>>> H. Peter Anvin doesn't like huge zero page which sticks in memory forever
>>>>>>> after the first allocation. Here's implementation of lockless refcounting
>>>>>>> for huge zero page.
>>>>>>>
>>>>>>> We have two basic primitives: {get,put}_huge_zero_page(). They
>>>>>>> manipulate reference counter.
>>>>>>>
>>>>>>> If counter is 0, get_huge_zero_page() allocates a new huge page and
>>>>>>> takes two references: one for caller and one for shrinker. We free the
>>>>>>> page only in shrinker callback if counter is 1 (only shrinker has the
>>>>>>> reference).
>>>>>>>
>>>>>>> put_huge_zero_page() only decrements counter. Counter is never zero
>>>>>>> in put_huge_zero_page() since shrinker holds on reference.
>>>>>>>
>>>>>>> Freeing huge zero page in shrinker callback helps to avoid frequent
>>>>>>> allocate-free.
>>>>>>>
>>>>>>> Refcounting has cost. On 4 socket machine I observe ~1% slowdown on
>>>>>>> parallel (40 processes) read page faulting comparing to lazy huge page
>>>>>>> allocation.  I think it's pretty reasonable for synthetic benchmark.
>>>>>> Hi Kirill,
>>>>>>
>>>>>> I see your and Andew's hot discussion in v4 resend thread.
>>>>>>
>>>>>> "I also tried another scenario: usemem -n16 100M -r 1000. It creates
>>>>>> real memory pressure - no easy reclaimable memory. This time
>>>>>> callback called with nr_to_scan > 0 and we freed hzp. "
>>>>>>
>>>>>> What's "usemem"? Is it a tool and how to get it?
>>>>> http://www.spinics.net/lists/linux-mm/attachments/gtarazbJaHPaAT.gtar
>>>> Thanks for your response.  But how to use it, I even can't compile
>>>> the files.
>>>>
>>>> # ./case-lru-file-mmap-read
>>>> ./case-lru-file-mmap-read: line 3: hw_vars: No such file or directory
>>>> ./case-lru-file-mmap-read: line 7: 10 * mem / nr_cpu: division by 0
>>>> (error token is "nr_cpu")
>>>>
>>>> # gcc usemem.c -o usemem
>>> -lpthread
>>>
>>>> /tmp/ccFkIDWk.o: In function `do_task':
>>>> usemem.c:(.text+0x9f2): undefined reference to `pthread_create'
>>>> usemem.c:(.text+0xa44): undefined reference to `pthread_join'
>>>> collect2: ld returned 1 exit status
>>>>
>>>>>> It's hard for me to
>>>>>> find nr_to_scan > 0 in every callset, how can nr_to_scan > 0 in your
>>>>>> scenario?
>>>>> shrink_slab() calls the callback with nr_to_scan > 0 if system is under
>>>>> pressure -- look for do_shrinker_shrink().
>>>> Why Andrew's example(dd if=/fast-disk/large-file) doesn't call this
>>>> path? I think it also can add memory pressure, where I miss?
>>> dd if=large-file only fills pagecache -- easy reclaimable memory.
>>> Pagecache will be dropped first, before shrinking slabs.
>> How could I confirm page reclaim working hard and slabs are
>> reclaimed at this time?
> The only what I see is slabs_scanned in vmstat.

Oh, I see. Thanks! :-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
