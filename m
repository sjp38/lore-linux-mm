Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 5734A6B0069
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 13:56:33 -0500 (EST)
Received: by mail-vb0-f53.google.com with SMTP id b23so15770823vbz.12
        for <linux-mm@kvack.org>; Thu, 03 Jan 2013 10:56:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANN689G-+Dns7BEJVG1SNO_CYA1vCEhiyf7F90sKYPvrNsXN9w@mail.gmail.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
 <CALCETrUi4JJSahrDKBARrwGsGE=1RbH8WL4tk1YgDmEowzXtSQ@mail.gmail.com>
 <CANN689H+yOeA3pvBMGu52q7brfoDwtkh0pA==c8VVoCkapkx6g@mail.gmail.com>
 <CALCETrU7u7P67QCwmj4qTMHti1=MXyjy3V9FejWbbrMVi01mDw@mail.gmail.com>
 <CANN689GBCsZWKkAQuNGfF4OJwVOyZ5neUcJo=ajzMKNmFug+XQ@mail.gmail.com>
 <CALCETrUOXjm6uoZ=TwyPr0_EQT-10ko5k448FwGP_dMwb=v=AA@mail.gmail.com> <CANN689G-+Dns7BEJVG1SNO_CYA1vCEhiyf7F90sKYPvrNsXN9w@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 3 Jan 2013 10:56:11 -0800
Message-ID: <CALCETrWBGVP9o0BO1vBSQU9Eh+OQ35SH-xNU4RUdUCYSo+XSLQ@mail.gmail.com>
Subject: Re: [PATCH 0/9] Avoid populating unbounded num of ptes with mmap_sem held
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Dec 22, 2012 at 1:37 AM, Michel Lespinasse <walken@google.com> wrote:
> On Fri, Dec 21, 2012 at 6:16 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> On Fri, Dec 21, 2012 at 5:59 PM, Michel Lespinasse <walken@google.com> wrote:
>>> Could you share your test case so I can try reproducing the issue
>>> you're seeing ?
>>
>> Not so easy.  My test case is a large chunk of a high-frequency
>> trading system :)
>
> Huh, its probably better if I don't see it then :)
>
>> I just tried it again.  Not I have a task stuck in
>> mlockall(MCL_CURRENT|MCL_FUTURE).  The stack is:
>>
>> [<0000000000000000>] flush_work+0x1c2/0x280
>> [<0000000000000000>] schedule_on_each_cpu+0xe3/0x130
>> [<0000000000000000>] lru_add_drain_all+0x15/0x20
>> [<0000000000000000>] sys_mlockall+0x125/0x1a0
>> [<0000000000000000>] tracesys+0xd0/0xd5
>> [<0000000000000000>] 0xffffffffffffffff
>>
>> The sequence of mmap and munmap calls, according to strace, is:
>>
> [...]
>> 6084  mmap(0x7f54fd02a000, 6776, PROT_READ|PROT_WRITE,
>> MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f54fd02a000
>
> So I noticed you use mmap with a size that is not a multiple of
> PAGE_SIZE. This is perfectly legal, but I hadn't tested that case, and
> lo and behold, it's something I got wrong. Patch to be sent as a reply
> to this. Without this patch, vm_populate() will show a debug message
> if you have CONFIG_DEBUG_VM set, and likely spin in an infinite loop
> if you don't.
>
>> 6084  mmap(NULL, 26258, PROT_READ, MAP_SHARED, 4, 0) = 0x7f5509f9d000
>> 6084  mmap(NULL, 4096, PROT_READ|PROT_WRITE,
>> MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f5509f9c000
>> 6084  munmap(0x7f5509f9c000, 4096)      = 0
>> 6084  mlockall(MCL_CURRENT|MCL_FUTURE
>>
>> This task is unkillable.  Two other tasks are stuck spinning.
>
> Now I'm confused, because:
>
> 1- your trace shows the hang occurs during mlockall(), and this code
> really wasn't touched much in my series (besides renaming
> do_mlock_pages into __mm_populate())
>
> 2- the backtrace above showed sys_mlockall() -> lru_add_drain_all(),
> which is the very beginning of mlockall(), before anything of
> importance happens (and in particular, before the MCL_FUTURE flag
> takes action). So, I'm going to assume that it's one of the other
> spinning threads that is breaking things. If one of the spinning
> threads got stuck within vm_populate(), this could even be explained
> by the bug I mentioned above.
>
> Could you check if the fix I'm going to send as a reply to this works
> for you, and if not, where the two spinning threads are being stuck ?
>

It works.  In case anyone cares, the whole series is

Tested-by: Andy Lutomirski <luto@amacapital.net>

I'll let you know if anything else breaks.  I'll be pounding on a
kernel with this patched in for the next couple of days, I expect.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
