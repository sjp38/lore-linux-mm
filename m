Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7760D6B0032
	for <linux-mm@kvack.org>; Sun,  7 Dec 2014 10:21:41 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id n12so4408277wgh.36
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 07:21:40 -0800 (PST)
Received: from mail-wg0-x22d.google.com (mail-wg0-x22d.google.com. [2a00:1450:400c:c00::22d])
        by mx.google.com with ESMTPS id o6si44563547wjb.41.2014.12.07.07.21.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Dec 2014 07:21:40 -0800 (PST)
Received: by mail-wg0-f45.google.com with SMTP id b13so4467532wgh.18
        for <linux-mm@kvack.org>; Sun, 07 Dec 2014 07:21:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1412010138420.7580@eggly.anvils>
References: <1415912518-8508-1-git-send-email-nefelim4ag@gmail.com> <alpine.LSU.2.11.1412010138420.7580@eggly.anvils>
From: Timofey Titovets <nefelim4ag@gmail.com>
Date: Sun, 7 Dec 2014 18:20:59 +0300
Message-ID: <CAGqmi75EKYOY+POQRwzF=o1cdNesfmEVnUBc7ONrL-TGLteNGw@mail.gmail.com>
Subject: Re: [RESEND][PATCH V3 0/4] KSM: Mark new vma for deduplication
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

2014-12-01 13:35 GMT+03:00 Hugh Dickins <hughd@google.com>:
> On Fri, 14 Nov 2014, Timofey Titovets wrote:
>
>> Good time of day List,
>> this tiny series of patches implement feature for auto deduping all anonymous memory.
>> mark_new_vma - new ksm sysfs interface
>> Every time then new vma created and mark_new_vma set to 1, then will be vma marked as VM_MERGEABLE and added to ksm queue.
>> This can produce small overheads
>> (I have not catch any problems or slowdown)
>>
>> This is useful for:
>> Android (CM) devs which implement ksm support with patching system.
>> Users of tiny pc.
>> Servers what not use KVM but use something very releated, like containers.
>>
>> Can be pulled from:
>> https://github.com/Nefelim4ag/linux.git ksm_improvements
>>
>> For tests:
>> I have tested it and it working very good. For testing apply it and enable ksm:
>> echo 1 | sudo tee /sys/kernel/mm/ksm/run
>> This show how much memory saved:
>> echo $[$(cat /sys/kernel/mm/ksm/pages_shared)*$(getconf PAGE_SIZE)/1024 ]KB
>>
>> On my system i save ~1% of memory 26 Mb/2100 Mb (deduped)/(used)
>>
>> v2:
>>       Added Kconfig for control default value of mark_new_vma
>>       Added sysfs interface for control mark_new_vma
>>       Splitted in several patches
>>
>> v3:
>>       Documentation for ksm changed for clarify new cha
>>
>> Timofey Titovets (4):
>>   KSM: Add auto flag new VMA as VM_MERGEABLE
>>   KSM: Add to sysfs - mark_new_vma
>>   KSM: Add config to control mark_new_vma
>>   KSM: mark_new_vma added to Documentation.
>>
>>  Documentation/vm/ksm.txt |  7 +++++++
>>  include/linux/ksm.h      | 39 +++++++++++++++++++++++++++++++++++++++
>>  mm/Kconfig               |  7 +++++++
>>  mm/ksm.c                 | 39 ++++++++++++++++++++++++++++++++++++++-
>>  mm/mmap.c                | 17 +++++++++++++++++
>>  5 files changed, 108 insertions(+), 1 deletion(-)
>
> I welcome what you're trying to achieve with this,
> but have a lot of issues with how you have gone about it.
>
> (I have my own patch to mm/mmap.c to achieve a similar effect, for
> testing KSM: but looking through it again now, conclude that it's just
> too hacky for others' eyes: I'd be glad to have something in the tree
> that saves me from having to apply that hack in the future.)

Where i can see your code? =)

> Please reduce this to a single patch: I don't see anything gained,
> but both our time wasted, from having it split into four.

Sorry, fixed =-=

> Please run scripts/checkpatch.pl over the result: it has quite a
> few complaints; or you might prefer to do that afterwards...
>
> Please throw away all(?) of your changes to mm/mmap.c, and those
> inlines in include/linux/ksm.h.  KSM has a tradition of invading
> the rest of mm as little as possible, and I'd like to keep to that
> so far as we can (and others will want us to keep to that even more
> than I do).
>
>    Instead of trying to apply VM_MERGEABLE in assorted places
>    throughout mmap.c, you should instead be modifying ksm.c to
>    ignore VM_MERGEABLE and respect only its conditioning flags
>    when your option is set.  (Looking through those conditioning
>    flags, I think the only one that actually matters internally
>    is probably VM_HUGETLB - having an anon_vma is in practice the
>    important criterion - but better that you continue to respect
>    those flags for now, rather than experimenting without them.)
>
>    Then I think all you need is one hook somewhere to ensure that
>    every mm gets on KSM's mm_list (while your option is set),
>    instead of just those which call madvise(,,MADV_MERGEABLE).
>    Or does this approach not work for some reason?

First of all, I am a kernel newbie and i can miss something, sorry if
it happens.

Ksm can't scan memory by itself. I'm not only mark page as
VM_MERGEABLE, i call __ksm_enter for adding it to ksm mm_list.
I already think about case where ksm scan all mm find marked with
VM_MERGEABLE and add it to own mm_list:
First its can slow down entire system as i think. But at now it does not matter.
Second, really, i can't find global mm tree =_='' or something like it
for add one to ksm.
Can you specify where i can found it or may be i mistaking in somewhere?

i must fix issue above before try modify ksm for ignore VM_MERGEABLE =\

> Please find some better naming: I suggest "all_mergeable" for
> the tunable, and KSM_ALL_MERGEABLE for the config option (my hack
> has an "allksm" boot option, but I think we can do without that).
> Poor naming ("ksm_vma_add_new" was an mm operation) misled you into
> putting hooks into quite unnecessary places (how would splitting a
> vma require a change to the mm's MMF_MERGEABLE?).

Thanks for idea, i renamed it.

> Then we can look at the result of that; but be warned, as you can
> see from the "speed" of my reply, I have no time to spare at present,
> and few others are interested in KSM (perhaps that's an unfortunate
> side-effect of our success in keeping it isolated from the rest of mm).
>
> Thanks,
> Hugh

Not a problem Hugh, thanks for reply.

-- 
Have a nice day,
Timofey.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
