Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E24956B0044
	for <linux-mm@kvack.org>; Thu, 18 Dec 2008 15:09:15 -0500 (EST)
Message-ID: <494AAE56.6010704@cs.columbia.edu>
Date: Thu, 18 Dec 2008 15:11:02 -0500
From: Oren Laadan <orenl@cs.columbia.edu>
MIME-Version: 1.0
Subject: Re: [RFC v11][PATCH 05/13] Dump memory address space
References: <1228498282-11804-1-git-send-email-orenl@cs.columbia.edu> <1228498282-11804-6-git-send-email-orenl@cs.columbia.edu> <4949B4ED.9060805@google.com> <494A2F94.2090800@cs.columbia.edu> <494A9350.1060309@google.com>
In-Reply-To: <494A9350.1060309@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mike Waychison <mikew@google.com>
Cc: jeremy@goop.org, arnd@arndb.de, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, Linux Torvalds <torvalds@osdl.org>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>



Mike Waychison wrote:
> Oren Laadan wrote:
>>
>> Mike Waychison wrote:
>>> Comments below.
>>
>> Thanks for the detailed review.
>>
>>> Oren Laadan wrote:
>>>> For each VMA, there is a 'struct cr_vma'; if the VMA is file-mapped,
>>>> it will be followed by the file name. Then comes the actual contents,
>>>> in one or more chunk: each chunk begins with a header that specifies
>>>> how many pages it holds, then the virtual addresses of all the dumped
>>>> pages in that chunk, followed by the actual contents of all dumped
>>>> pages. A header with zero number of pages marks the end of the
>>>> contents.
>>>> Then comes the next VMA and so on.
>>>>
>>
>> [...]
>>
>>>> +    mutex_lock(&mm->context.lock);
>>>> +
>>>> +    hh->ldt_entry_size = LDT_ENTRY_SIZE;
>>>> +    hh->nldt = mm->context.size;
>>>> +
>>>> +    cr_debug("nldt %d\n", hh->nldt);
>>>> +
>>>> +    ret = cr_write_obj(ctx, &h, hh);
>>>> +    cr_hbuf_put(ctx, sizeof(*hh));
>>>> +    if (ret < 0)
>>>> +        goto out;
>>>> +
>>>> +    ret = cr_kwrite(ctx, mm->context.ldt,
>>>> +            mm->context.size * LDT_ENTRY_SIZE);
>>> Do we really want to emit anything under lock?  I realize that this
>>> patch goes and does a ton of writes with mmap_sem held for read -- is
>>> this ok?
>>
>> Because all tasks in the container must be frozen during the checkpoint,
>> there is no performance penalty for keeping the locks. Although the
>> object
>> should not change in the interim anyways, the locks protects us from,
>> e.g.
>> the task unfreezing somehow, or being killed by the OOM killer, or any
>> other change incurred from the "outside world" (even future code).
>>
>> Put in other words - in the long run it is safer to assume that the
>> underlying object may otherwise change.
>>
>> (If we want to drop the lock here before cr_kwrite(), we need to copy the
>> data to a temporary buffer first. If we also want to drop mmap_sem(), we
>> need to be more careful with following the vma's.)
>>
>> Do you see a reason to not keeping the locks ?
>>
> 
> I just thought it was a bit ugly, but I can't think of a case
> specifically where it's going to cause us harm.  If tasks are frozen,
> are they still subject to the oom killer?   Even that should be
> reasonably ok considering that the exit-path requires a
> down_read(mmap_sem) (at least, it used to..  I haven't gone over that
> path in a while..).

Excatly: this is safe because we keep the lock. It all boils down to
two points: holding the locks doesn't impair performance or functionality,
and it protects us against existing (if any) and future undesired
interactions with other code.

[...]

Oren.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
