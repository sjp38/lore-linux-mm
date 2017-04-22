Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1B26B0038
	for <linux-mm@kvack.org>; Sat, 22 Apr 2017 08:09:09 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g67so6870462wrd.0
        for <linux-mm@kvack.org>; Sat, 22 Apr 2017 05:09:09 -0700 (PDT)
Received: from dggrg01-dlp.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id 31si18697380wre.175.2017.04.22.05.08.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 22 Apr 2017 05:09:07 -0700 (PDT)
Message-ID: <58FB479B.6000902@huawei.com>
Date: Sat, 22 Apr 2017 20:07:55 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: A small window for a race condition in mm/rmap.c:page_lock_anon_vma_read
References: <23B7B563BA4E9446B962B142C86EF24ADBD62C@CNMAILEX03.lenovo.com> <20161221144343.GD593@dhcp22.suse.cz> <20161222135106.GY3124@twins.programming.kicks-ass.net> <alpine.LSU.2.11.1612221351340.1744@eggly.anvils> <23B7B563BA4E9446B962B142C86EF24ADBF34D@CNMAILEX03.lenovo.com>
In-Reply-To: <23B7B563BA4E9446B962B142C86EF24ADBF34D@CNMAILEX03.lenovo.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dashi DS1 Cao <caods1@lenovo.com>
Cc: Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi,  Dashi
The same issue I had occured every other week.  Do you have solve it .
 I want to know how it is fixed.  The patch exist in the mainline.

Thanks
zhongjiang
On 2016/12/23 10:38, Dashi DS1 Cao wrote:
> I'd expected that one or more tasks doing the free were the current task of other cpu cores, but only one of the four dumps has two swapd task that are concurrently at execution on different cpu.
> This is the task leading to the crash:
> PID: 247    TASK: ffff881fcfad8000  CPU: 14  COMMAND: "kswapd1"
>  #0 [ffff881fcfad7978] machine_kexec at ffffffff81051e9b
>  #1 [ffff881fcfad79d8] crash_kexec at ffffffff810f27e2
>  #2 [ffff881fcfad7aa8] oops_end at ffffffff8163f448
>  #3 [ffff881fcfad7ad0] die at ffffffff8101859b
>  #4 [ffff881fcfad7b00] do_general_protection at ffffffff8163ed3e
>  #5 [ffff881fcfad7b30] general_protection at ffffffff8163e5e8
>     [exception RIP: down_read_trylock+9]
>     RIP: ffffffff810aa9f9  RSP: ffff881fcfad7be0  RFLAGS: 00010286
>     RAX: 0000000000000000  RBX: ffff882b47ddadc0  RCX: 0000000000000000
>     RDX: 0000000000000000  RSI: 0000000000000000  RDI: 91550b2b32f5a3e8
>     RBP: ffff881fcfad7be0   R8: ffffea00ecc28860   R9: ffff883fcffeae28
>     R10: ffffffff81a691a0  R11: 0000000000000001  R12: ffff882b47ddadc1
>     R13: ffffea00ecc28840  R14: 91550b2b32f5a3e8  R15: ffffea00ecc28840
>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
>  #6 [ffff881fcfad7be8] page_lock_anon_vma_read at ffffffff811a3365
>  #7 [ffff881fcfad7c18] page_referenced at ffffffff811a35e7
>  #8 [ffff881fcfad7c90] shrink_active_list at ffffffff8117e8cc
>  #9 [ffff881fcfad7d48] balance_pgdat at ffffffff81180288
> #10 [ffff881fcfad7e20] kswapd at ffffffff81180813
> #11 [ffff881fcfad7ec8] kthread at ffffffff810a5b8f
> #12 [ffff881fcfad7f50] ret_from_fork at ffffffff81646a98
>
> And this is the one at the same time:
> PID: 246    TASK: ffff881fd27af300  CPU: 20  COMMAND: "kswapd0"
>  #0 [ffff881fffd05e70] crash_nmi_callback at ffffffff81045982
>  #1 [ffff881fffd05e80] nmi_handle at ffffffff8163f5d9
>  #2 [ffff881fffd05ec8] do_nmi at ffffffff8163f6f0
>  #3 [ffff881fffd05ef0] end_repeat_nmi at ffffffff8163ea13
>     [exception RIP: free_pcppages_bulk+529]
>     RIP: ffffffff81171ae1  RSP: ffff881fcfad38f0  RFLAGS: 00000087
>     RAX: 002fffff0000002c  RBX: ffffea007606ae40  RCX: 0000000000000000
>     RDX: ffffea007606ae00  RSI: 00000000000002b9  RDI: 0000000000000000
>     RBP: ffff881fcfad3978   R8: 0000000000000000   R9: 0000000000000001
>     R10: ffff88207ffda000  R11: 0000000000000002  R12: ffffea007606ae40
>     R13: 0000000000000002  R14: ffff88207ffda000  R15: 00000000000002b8
>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
> --- <NMI exception stack> ---
>  #4 [ffff881fcfad38f0] free_pcppages_bulk at ffffffff81171ae1
>  #5 [ffff881fcfad3980] free_hot_cold_page at ffffffff81171f08
>  #6 [ffff881fcfad39b8] free_hot_cold_page_list at ffffffff81171f76
>  #7 [ffff881fcfad39f0] shrink_page_list at ffffffff8117d71e
>  #8 [ffff881fcfad3b28] shrink_inactive_list at ffffffff8117e37a
>  #9 [ffff881fcfad3bf0] shrink_lruvec at ffffffff8117ee45
> #10 [ffff881fcfad3cf0] shrink_zone at ffffffff8117f2a6
> #11 [ffff881fcfad3d48] balance_pgdat at ffffffff8118054c
> #12 [ffff881fcfad3e20] kswapd at ffffffff81180813
> #13 [ffff881fcfad3ec8] kthread at ffffffff810a5b8f
> #14 [ffff881fcfad3f50] ret_from_fork at ffffffff81646a98
>
> I hope the information would be useful.
> Dashi Cao
>
> -----Original Message-----
> From: Hugh Dickins [mailto:hughd@google.com] 
> Sent: Friday, December 23, 2016 6:27 AM
> To: Peter Zijlstra <peterz@infradead.org>
> Cc: Michal Hocko <mhocko@kernel.org>; Dashi DS1 Cao <caods1@lenovo.com>; linux-mm@kvack.org; linux-kernel@vger.kernel.org; Hugh Dickins <hughd@google.com>
> Subject: Re: A small window for a race condition in mm/rmap.c:page_lock_anon_vma_read
>
> On Thu, 22 Dec 2016, Peter Zijlstra wrote:
>> On Wed, Dec 21, 2016 at 03:43:43PM +0100, Michal Hocko wrote:
>>> anon_vma locking is clever^Wsubtle as hell. CC Peter...
>>>
>>> On Tue 20-12-16 09:32:27, Dashi DS1 Cao wrote:
>>>> I've collected four crash dumps with similar backtrace. 
>>>>
>>>> PID: 247    TASK: ffff881fcfad8000  CPU: 14  COMMAND: "kswapd1"
>>>>  #0 [ffff881fcfad7978] machine_kexec at ffffffff81051e9b
>>>>  #1 [ffff881fcfad79d8] crash_kexec at ffffffff810f27e2
>>>>  #2 [ffff881fcfad7aa8] oops_end at ffffffff8163f448
>>>>  #3 [ffff881fcfad7ad0] die at ffffffff8101859b
>>>>  #4 [ffff881fcfad7b00] do_general_protection at ffffffff8163ed3e
>>>>  #5 [ffff881fcfad7b30] general_protection at ffffffff8163e5e8
>>>>     [exception RIP: down_read_trylock+9]
>>>>     RIP: ffffffff810aa9f9  RSP: ffff881fcfad7be0  RFLAGS: 00010286
>>>>     RAX: 0000000000000000  RBX: ffff882b47ddadc0  RCX: 0000000000000000
>>>>     RDX: 0000000000000000  RSI: 0000000000000000  RDI: 
>>>> 91550b2b32f5a3e8
>>> rdi is obviously a mess - smells like a string. So either sombody 
>>> has overwritten root_anon_vma or this is really a use after free...
>> e8 - ???
>> a3 - ???
>> f5 - ???
>> 32 - 2
>> 2b - +
>>  b -
>>
>> 55 - U
>> 91 - ???
>>
>> Not a string..
>>
>>>>     RBP: ffff881fcfad7be0   R8: ffffea00ecc28860   R9: ffff883fcffeae28
>>>>     R10: ffffffff81a691a0  R11: 0000000000000001  R12: ffff882b47ddadc1
>>>>     R13: ffffea00ecc28840  R14: 91550b2b32f5a3e8  R15: ffffea00ecc28840
>>>>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
>>>>  #6 [ffff881fcfad7be8] page_lock_anon_vma_read at ffffffff811a3365
>>>>  #7 [ffff881fcfad7c18] page_referenced at ffffffff811a35e7
>>>>  #8 [ffff881fcfad7c90] shrink_active_list at ffffffff8117e8cc
>>>>  #9 [ffff881fcfad7d48] balance_pgdat at ffffffff81180288
>>>> #10 [ffff881fcfad7e20] kswapd at ffffffff81180813
>>>> #11 [ffff881fcfad7ec8] kthread at ffffffff810a5b8f
>>>> #12 [ffff881fcfad7f50] ret_from_fork at ffffffff81646a98
>>>>
>>>> I suspect my customer hits into a small window of a race condition in mm/rmap.c: page_lock_anon_vma_read.
>>>> struct anon_vma *page_lock_anon_vma_read(struct page *page) {
>>>>         struct anon_vma *anon_vma = NULL;
>>>>         struct anon_vma *root_anon_vma;
>>>>         unsigned long anon_mapping;
>>>>
>>>>         rcu_read_lock();
>>>>         anon_mapping = (unsigned long)READ_ONCE(page->mapping);
>>>>         if ((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON)
>>>>                 goto out;
>>>>         if (!page_mapped(page))
>>>>                 goto out;
>>>>
>>>>         anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
>>>>         root_anon_vma = READ_ONCE(anon_vma->root);
>>> Could you dump the anon_vma and struct page as well?
>>>
>>>>         if (down_read_trylock(&root_anon_vma->rwsem)) {
>>>>                 /*
>>>>                  * If the page is still mapped, then this anon_vma is still
>>>>                  * its anon_vma, and holding the mutex ensures that it will
>>>>                  * not go away, see anon_vma_free().
>>>>                  */
>>>>                 if (!page_mapped(page)) {
>>>>                         up_read(&root_anon_vma->rwsem);
>>>>                         anon_vma = NULL;
>>>>                 }
>>>>                 goto out;
>>>>         }
>>>> ...
>>>> }
>>>>
>>>> Between the time the two "page_mapped(page)" are checked, the 
>>>> address (anon_mapping - PAGE_MAPPING_ANON) is unmapped! However it 
>>>> seems that anon_vma->root could still be read in but the value is 
>>>> wild. So the kernel crashes in down_read_trylock. But it's weird 
>>>> that all the "struct page" has its member "_mapcount" still with 
>>>> value 0, not -1, in the four crashes.
>> So the point is that while we hold rcu_read_lock() the actual memory 
>> backing the anon_vmas cannot be freed. It can be reused, but only for 
>> another anon_vma.
>>
>> Now, anon_vma_alloc() sets ->root to self, while anon_vma_free() 
>> leaves
>> ->root set to whatever. And any other ->root assignment is to a valid
>> anon_vma.
>>
>> Therefore, the same rules that ensure anon_vma stays valid, should 
>> also ensure anon_vma->root stays valid.
>>
>> Now, one thing that might go wobbly is that ->root assignments are not 
>> done using WRITE_ONCE(), this means a naughty compiler can miscompile 
>> those stores and introduce store-tearing, if our READ_ONCE() would 
>> observe such a tear, we'd be up some creek without a paddle.
> We would indeed.  And this being the season of goodwill, I'm biting my tongue not to say what I think of the prospect of store tearing.
> But that zeroed anon_vma implies tearing not the problem here anyway.
>
>> Now, its been a long time since I looked at any of this code, and I 
>> see that Hugh has fixed at least two wobblies in my original code.
> Nothing much, and this (admittedly subtle) technique has been working well for years, so I'm sceptical about "a small window for a race condition".
>
> But Dashi's right to point out that the struct page has _mapcount 0 (not -1 for logical 0) in these cases: it looks as if something is freeing (or corrupting) the anon_vma despite it still having pages mapped, or something is misaccounting (or corrupting) the _mapcount.
>
> But I've no idea what, and we have not heard such reports elsewhere.
> We don't even know what kernel this is - something special, perhaps?
>
> Hugh
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>
>
> .
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
