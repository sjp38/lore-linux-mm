Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id C6FAC6B0078
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 20:59:55 -0500 (EST)
Received: by mail-vb0-f50.google.com with SMTP id fr13so5851529vbb.9
        for <linux-mm@kvack.org>; Fri, 21 Dec 2012 17:59:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrU7u7P67QCwmj4qTMHti1=MXyjy3V9FejWbbrMVi01mDw@mail.gmail.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
	<CALCETrUi4JJSahrDKBARrwGsGE=1RbH8WL4tk1YgDmEowzXtSQ@mail.gmail.com>
	<CANN689H+yOeA3pvBMGu52q7brfoDwtkh0pA==c8VVoCkapkx6g@mail.gmail.com>
	<CALCETrU7u7P67QCwmj4qTMHti1=MXyjy3V9FejWbbrMVi01mDw@mail.gmail.com>
Date: Fri, 21 Dec 2012 17:59:54 -0800
Message-ID: <CANN689GBCsZWKkAQuNGfF4OJwVOyZ5neUcJo=ajzMKNmFug+XQ@mail.gmail.com>
Subject: Re: [PATCH 0/9] Avoid populating unbounded num of ptes with mmap_sem held
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 21, 2012 at 5:09 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Fri, Dec 21, 2012 at 4:59 PM, Michel Lespinasse <walken@google.com> wrote:
>> On Fri, Dec 21, 2012 at 4:36 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>> Something's buggy here.  My evil test case is stuck with lots of
>>> threads spinning at 100% system time.
>>>
>>> The tasks in question use MCL_FUTURE but not MAP_POPULATE.  These
>>> tasks are immune to SIGKILL.
>>
>> Looking into it.
>>
>> There seems to be a problem with mlockall - the following program
>> fails in an unkillable way even before my changes:
>>
>> #include <sys/mman.h>
>> #include <stdio.h>
>> #include <stdint.h>
>>
>> int main(void) {
>>   void *p = mmap(NULL, 0x100000000000,
>>                  PROT_READ | PROT_WRITE,
>>                  MAP_PRIVATE | MAP_ANON | MAP_NORESERVE,
>>                  -1, 0);
>>   printf("p: %p\n", p);
>>   mlockall(MCL_CURRENT);
>>   return 0;
>> }
>>
>> I think my changes propagate this existing problem so it now shows up
>> in more places :/

So in my test case, the issue was caused by the mapping being 2^32
pages, which overflowed the integer 'nr_pages' argument to
__get_user_pages, which caused an infinite loop as __get_user_pages()
would return 0 so __mm_populate() would make no progress.

When dropping one zero from that humongous size in the test case, the
test case becomes at least killable.

> Hmm.  I'm using MCL_FUTURE with MAP_NORESERVE, but those mappings are
> not insanely large.  Should MAP_NORESERVE would negate MCL_FUTURE?
> I'm doing MAP_NORESERVE, PROT_NONE to prevent pages from being
> allocated in the future -- I have no intention of ever using them.

MAP_NORESERVE doesn't prevent page allocation, but PROT_NONE does
(precisely because people use it the same way as you do :)

> The other odd thing I do is use MAP_FIXED to replace MAP_NORESERVE pages.
Yes, I've seen people do that here too.

Could you share your test case so I can try reproducing the issue
you're seeing ?

Thanks,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
