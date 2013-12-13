Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id D3B2A6B00B0
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 10:27:29 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id x13so2033161wgg.7
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 07:27:29 -0800 (PST)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id wg1si949289wjb.115.2013.12.13.07.27.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 13 Dec 2013 07:27:29 -0800 (PST)
Received: by mail-wi0-f169.google.com with SMTP id hn6so2395272wib.4
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 07:27:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAFftDdq-qS2nMC07bVReZk6ksg0-Nkp7GkNSQ47Z_TsDEbZcfw@mail.gmail.com>
References: <1386018639-18916-1-git-send-email-wroberts@tresys.com>
	<1386018639-18916-2-git-send-email-wroberts@tresys.com>
	<52AB15C0.7090701@tycho.nsa.gov>
	<CAFftDdquPe9dE_4x_mr0BT2jziUAEtdyjk4DqXvt2-nnBf73zg@mail.gmail.com>
	<52AB21F1.6030003@tycho.nsa.gov>
	<CAFftDdq-qS2nMC07bVReZk6ksg0-Nkp7GkNSQ47Z_TsDEbZcfw@mail.gmail.com>
Date: Fri, 13 Dec 2013 10:27:28 -0500
Message-ID: <CAFftDdr1fd-fdjb1A9=CNjhd+cf51u1EwonU-Jth84Cdnt+t8A@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: Create utility functions for accessing a tasks
 commandline value
From: William Roberts <bill.c.roberts@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Smalley <sds@tycho.nsa.gov>
Cc: "linux-audit@redhat.com" <linux-audit@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Richard Guy Briggs <rgb@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, William Roberts <wroberts@tresys.com>

On Fri, Dec 13, 2013 at 10:26 AM, William Roberts
<bill.c.roberts@gmail.com> wrote:
> On Fri, Dec 13, 2013 at 10:04 AM, Stephen Smalley <sds@tycho.nsa.gov> wrote:
>> On 12/13/2013 09:51 AM, William Roberts wrote:
>>> On Fri, Dec 13, 2013 at 9:12 AM, Stephen Smalley <sds@tycho.nsa.gov> wrote:
>>>> Also, why not just get_task_mm(task) within the function rather than
>>>> pass it in by the caller?
>>>>
>>>
>>> Yes I was debating whether or not to drop the pointer checks... np
>>>
>>> WRT the locking and moving it into the function. You need to take the lock
>>> to determine the size of the cmdline area. The idea on the interface is you
>>> would take the locks, acquire the size via the inline func, alloc memory and
>>> then call the copy function. In some cases, like proc/pid/cmdline, they just
>>> alloc a page and truncate on that boundary. However, one may with to truncate
>>> on an arbitrary boundry, especially when cacheing the values, as you don't want
>>> to allocate too much. So inbetween functions calls that get the length and copy,
>>> one can make a decision based on their allocation scheme. Moving the locks
>>> to the functions would require multiple locks and unlocks in the common case.
>>
>> I don't think it is a good idea to split it up, as what happens if the
>> range changes between the time you compute the length and the time you
>> copy?  And your current callers appear to always get_task_mm(), compute
>> len, call the helper, and mmput.  So just take it all to the helper (at
>> which point the helper essentially becomes proc_pid_cmdline).
>>
>
> That's why I keep the semaphore over the whole operation. The issue arises with
> the amount to allocate by the caller, which is a bit of a shot in the
> dark. The caller
> may not wish to over allocate a buffer. This same issue could arise in
> the current
> code, but they hold the sem.
>
>>>> Unsigned int buflen passed as int len argument without a range check?
>>>> Note that in the proc_pid_cmdline() code, they first cap it at PAGE_SIZE
>>>> before passing it.
>>>>
>>>
>>> buflen is passed by the caller. So if you look in the following patch
>>> introducing its
>>> use in proc/fs/base.c, their is a check.
>>>         /*The caller of this allocates a page */
>>>         if (len > PAGE_SIZE)
>>>                 len = PAGE_SIZE;
>>>
>>>         res = copy_cmdline(task, mm, buffer, len);
>>
>> I understand that, but you are making correct operation of the helper
>> dependent on the caller already having applied such a cap to the length.
>>  Which is unsafe practice and may not hold true for future callers.
>>
>
> Again, what if the caller wished to cap it as 32, 64, 128, or 2 * PAGE_SIZE?
> They can just pass the value on which to cap, which is their buffer that they
> allocated. Thus they know the size. Again, all of this boils down to
> the allocation
> scheme which you comment on below. With that said, this becomes a whole lot
> simpler.
>
>>>>> +     if (res <= 0)
>>>>> +             return 0;
>>>>> +
>>>>> +     if (res > buflen)
>>>>> +             res = buflen;
>>>>
>>>> Is this a possible condition?  Under what circumstances?
>>>
>>> for  (res <= 0), in that case, the underlying call
>>> to __access_remote_vm() returns an int. Most of the mm functions look
>>> like they are using
>>> ints for probably some historical reason I am not aware of. I tried to
>>> pick the strongest invariant,
>>> however, I don't think < 0 is possible.
>>>
>>> For the res > buflen check, that might might be an artifact from the
>>> PAGE_SIZE cap from the original
>>> code. It would only be possible if a process was able to write to
>>> their mm when the semaphores are held.
>>> I am assuming the case of:
>>> kernel gets size
>>> kernel allocs buffer
>>> kernel copys but size has differed. I guess if I broke the locking out
>>> it could happen, you need size and copy
>>> to be autonomous.
>>
>> Sorry, you misunderstood.  The <=0 case is clearly possible; I was only
>> asking about the res > buflen check, which seems impossible as you
>> provided buflen as the max for the access_process_vm() call.  That one
>> does not make sense to me and has no equivalent in the original
>> proc_pid_cmdline() code.
>>
>>>> I think you are better off just copying proc_pid_cmdline() exactly as is
>>>> into a common helper function and then reusing it for audit.  Far less
>>>> work, and far less potential for mistakes.
>>>
>>> I don't like caching a whole page in that audit context. So most of
>>> the complexity relates to
>>> determining the size of the cache. Steve Grub was in favor of limiting
>>> the cmdline value to
>>> PATH_MAX. So if that is an acceptable cache size, we can take the
>>> existing code from
>>> procfs/base.c and just add an argument indicating the size of the
>>> buffer. procfs will be
>>> PAGE_SIZE and audit will be PATH_MAX. Thoughts?
>>
>> Yes, that seems reasonable to me.
>>
>>
>
> SGTM, Ill go that route with these... much simpler and avoids
> the caller having to know how to lock the memory region properly.
>

FYI, i am away from my dev machine. ill get these out in a couple of weeks.

-- 
Respectfully,

William C Roberts

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
