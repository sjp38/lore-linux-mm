Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D21446B0003
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 03:57:49 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id h77so365417pfj.11
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 00:57:49 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q127sor292420pga.280.2018.02.02.00.57.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Feb 2018 00:57:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180202062037.GH30522@ZenIV.linux.org.uk>
References: <001a113f6344393d89056430347d@google.com> <20180202045020.GF30522@ZenIV.linux.org.uk>
 <20180202053502.GB949@zzz.localdomain> <20180202054626.GG30522@ZenIV.linux.org.uk>
 <20180202062037.GH30522@ZenIV.linux.org.uk>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 2 Feb 2018 09:57:27 +0100
Message-ID: <CACT4Y+bDU00aQpJOUK8eB+Kv4HycNwKA=kShUe9kSd0FUqO+FQ@mail.gmail.com>
Subject: Re: possible deadlock in get_user_pages_unlocked
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Eric Biggers <ebiggers3@gmail.com>, syzbot <syzbot+bacbe5d8791f30c9cee5@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, James Morse <james.morse@arm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com

On Fri, Feb 2, 2018 at 7:20 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Fri, Feb 02, 2018 at 05:46:26AM +0000, Al Viro wrote:
>> On Thu, Feb 01, 2018 at 09:35:02PM -0800, Eric Biggers wrote:
>>
>> > Try starting up multiple instances of the program; that sometimes helps with
>> > these races that are hard to hit (since you may e.g. have a different number of
>> > CPUs than syzbot used).  If I start up 4 instances I see the lockdep splat after
>> > around 2-5 seconds.
>>
>> 5 instances in parallel, 10 minutes into the run...
>>
>> >  This is on latest Linus tree (4bf772b1467).  Also note the
>> > reproducer uses KVM, so if you're running it in a VM it will only work if you've
>> > enabled nested virtualization on the host (kvm_intel.nested=1).
>>
>> cat /sys/module/kvm_amd/parameters/nested
>> 1
>>
>> on host
>>
>> > Also it appears to go away if I revert ce53053ce378c21 ("kvm: switch
>> > get_user_page_nowait() to get_user_pages_unlocked()").
>>
>> That simply prevents this reproducer hitting get_user_pages_unlocked()
>> instead of grab mmap_sem/get_user_pages/drop mmap_sem.  I.e. does not
>> allow __get_user_pages_locked() to drop/regain ->mmap_sem.
>>
>> The bug may be in the way we call get_user_pages_unlocked() in that
>> commit, but it might easily be a bug in __get_user_pages_locked()
>> exposed by that reproducer somehow.
>
> I think I understand what's going on.  FOLL_NOWAIT handling is a serious
> mess ;-/  I'll probably have something to test tomorrow - I still can't
> reproduce it here, unfortunately.

Hi Al,

syzbot tests for up to 5 minutes. However, if there is a race involved
then you may need more time because the crash is probabilistic.
But from what I see most of the time, if one can't reproduce it
easily, it's usually due to some differences in setup that just don't
allow the crash to happen at all.
FWIW syzbot re-runs each reproducer on a freshly booted dedicated VM
and what it provided is the kernel output it got during run of the
provided program. So we have reasonably high assurance that this
reproducer worked in at least one setup.

Even if you can't reproduce it locally, you can use syzbot testing
service, see "syz test" here:
https://github.com/google/syzkaller/blob/master/docs/syzbot.md#communication-with-syzbot

We also try to collect known causes of non-working reproducers, so if
you get any hints as to why it does not reproduce for you, we can add
it here:
https://github.com/google/syzkaller/blob/master/docs/syzbot.md#crash-does-not-reproduce
Since kvm/ept are present in the stacks, I suspect that it may be due
to a different host CPU unfortunately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
