Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A7C88E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 06:41:49 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t7so33580424edr.21
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 03:41:49 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cg5-v6si7798620ejb.288.2019.01.03.03.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 03:41:47 -0800 (PST)
Subject: Re: KMSAN: uninit-value in mpol_rebind_mm
References: <000000000000c06550057e4cac7c@google.com>
 <a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
 <CACT4Y+bRvwxkdnyRosOujpf5-hkBwd2g0knyCQHob7p=0hC=Dw@mail.gmail.com>
 <CAG_fn=Wmjqo8yWesAfF+E2QTT1pqoODaUMA56ufsrDOE_R4snQ@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d4f807d3-7b9a-e2c3-e846-a7158757a146@suse.cz>
Date: Thu, 3 Jan 2019 12:41:45 +0100
MIME-Version: 1.0
In-Reply-To: <CAG_fn=Wmjqo8yWesAfF+E2QTT1pqoODaUMA56ufsrDOE_R4snQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Yisheng Xie <xieyisheng1@huawei.com>, zhong jiang <zhongjiang@huawei.com>

On 1/3/19 12:14 PM, Alexander Potapenko wrote:
> On Thu, Jan 3, 2019 at 9:42 AM Dmitry Vyukov <dvyukov@google.com> wrote:
>>
>> On Thu, Jan 3, 2019 at 9:36 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>>>
>>>
>>> On 12/31/18 8:51 AM, syzbot wrote:
>>>> Hello,
>>>>
>>>> syzbot found the following crash on:
>>>>
>>>> HEAD commit:    79fc24ff6184 kmsan: highmem: use kmsan_clear_page() in cop..
>>>> git tree:       kmsan
>>>> console output: https://syzkaller.appspot.com/x/log.txt?x=13c48b67400000
>>>> kernel config:  https://syzkaller.appspot.com/x/.config?x=901dd030b2cc57e7
>>>> dashboard link: https://syzkaller.appspot.com/bug?extid=b19c2dc2c990ea657a71
>>>> compiler:       clang version 8.0.0 (trunk 349734)
>>>>
>>>> Unfortunately, I don't have any reproducer for this crash yet.
>>>>
>>>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>>>> Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com
>>>>
>>>> ==================================================================
>>>> BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [inline]
>>>> BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
>>>
>>> The report doesn't seem to indicate where the uninit value resides in
>>> the mempolicy object.
>>
>> Yes, it doesn't and it's not trivial to do. The tool reports uses of
>> unint _values_. Values don't necessary reside in memory. It can be a
>> register, that come from another register that was calculated as a sum
>> of two other values, which may come from a function argument, etc.
>>
>>> I'll have to guess. mm/mempolicy.c:353 contains:
>>>
>>>         if (!mpol_store_user_nodemask(pol) &&
>>>             nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
>>>
>>> "mpol_store_user_nodemask(pol)" is testing pol->flags, which I couldn't
>>> see being uninitialized after leaving mpol_new(). So I'll guess it's
>>> actually about accessing pol->w.cpuset_mems_allowed on line 354.
>>>
>>> For w.cpuset_mems_allowed to be not initialized and the nodes_equal()
>>> reachable for a mempolicy where mpol_set_nodemask() is called in
>>> do_mbind(), it seems the only possibility is a MPOL_PREFERRED policy
>>> with empty set of nodes, i.e. MPOL_LOCAL equivalent. Let's see if the
>>> patch below helps. This code is a maze to me. Note the uninit access
>>> should be benign, rebinding this kind of policy is always a no-op.
> If I'm reading mempolicy.c right, `pol->flags & MPOL_F_LOCAL` doesn't
> imply `pol->mode == MPOL_PREFERRED`, shouldn't we check for both here?

I think it does? Only preferred mempolicies set it, including
default_policy, and MPOL_LOCAL is converted to MPOL_PREFERRED
internally. Anyway we would need the opposite implication here to be
safe, and that's also true.

>>> ----8<----
>>> From ff0ca29da6bc2572d7b267daa77ced6083e3f02d Mon Sep 17 00:00:00 2001
>>> From: Vlastimil Babka <vbabka@suse.cz>
>>> Date: Thu, 3 Jan 2019 09:31:59 +0100
>>> Subject: [PATCH] mm, mempolicy: fix uninit memory access
>>>
>>> ---
>>>  mm/mempolicy.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
>>> index d4496d9d34f5..a0b7487b9112 100644
>>> --- a/mm/mempolicy.c
>>> +++ b/mm/mempolicy.c
>>> @@ -350,7 +350,7 @@ static void mpol_rebind_policy(struct mempolicy *pol, const nodemask_t *newmask)
>>>  {
>>>         if (!pol)
>>>                 return;
>>> -       if (!mpol_store_user_nodemask(pol) &&
>>> +       if (!mpol_store_user_nodemask(pol) && !(pol->flags & MPOL_F_LOCAL) &&
>>>             nodes_equal(pol->w.cpuset_mems_allowed, *newmask))
>>>                 return;
>>>
>>> --
>>> 2.19.2
>>>
>>> --
>>> You received this message because you are subscribed to the Google Groups "syzkaller-bugs" group.
>>> To unsubscribe from this group and stop receiving emails from it, send an email to syzkaller-bugs+unsubscribe@googlegroups.com.
>>> To view this discussion on the web visit https://groups.google.com/d/msgid/syzkaller-bugs/a71997c3-e8ae-a787-d5ce-3db05768b27c%40suse.cz.
>>> For more options, visit https://groups.google.com/d/optout.
> 
> 
> 
