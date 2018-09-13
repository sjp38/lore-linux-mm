Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 363AD8E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 09:04:19 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id a10-v6so8286680itc.9
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 06:04:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c65-v6sor2733677itc.93.2018.09.13.06.04.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Sep 2018 06:04:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <ec6547f4-6240-d901-b2d2-b5103a10493f@sony.com>
References: <000000000000038dab0575476b73@google.com> <f3bcebc6-47a7-518e-70f7-c7e167621841@I-love.SAKURA.ne.jp>
 <CAHC9VhT-Thu6KppC-MWzqkB7R1CaQA9DWXOQnG0b2uS9+rvzoA@mail.gmail.com>
 <ea29a8bf-95b2-91d2-043b-ed73c9023166@i-love.sakura.ne.jp>
 <9d685700-bc5c-9c2f-7795-56f488d2ea38@sony.com> <20180913111135.GA21006@dhcp22.suse.cz>
 <ec6547f4-6240-d901-b2d2-b5103a10493f@sony.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 13 Sep 2018 15:03:56 +0200
Message-ID: <CACT4Y+aBefAOPmvd1RF_Vy8TBFUJM9ves2atyFfmBnZnH7Kxsw@mail.gmail.com>
Subject: Re: [PATCH] selinux: Add __GFP_NOWARN to allocation at str_read()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sony.com>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Paul Moore <paul@paul-moore.com>, SELinux <selinux@tycho.nsa.gov>, syzbot+ac488b9811036cea7ea0@syzkaller.appspotmail.com, Eric Paris <eparis@parisplace.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Smalley <sds@tycho.nsa.gov>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, linux-mm <linux-mm@kvack.org>

On Thu, Sep 13, 2018 at 2:55 PM, peter enderborg
<peter.enderborg@sony.com> wrote:
>>>>>> syzbot is hitting warning at str_read() [1] because len parameter can
>>>>>> become larger than KMALLOC_MAX_SIZE. We don't need to emit warning for
>>>>>> this case.
>>>>>>
>>>>>> [1] https://syzkaller.appspot.com/bug?id=7f2f5aad79ea8663c296a2eedb81978401a908f0
>>>>>>
>>>>>> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>>>>>> Reported-by: syzbot <syzbot+ac488b9811036cea7ea0@syzkaller.appspotmail.com>
>>>>>> ---
>>>>>>  security/selinux/ss/policydb.c | 2 +-
>>>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>>>
>>>>>> diff --git a/security/selinux/ss/policydb.c b/security/selinux/ss/policydb.c
>>>>>> index e9394e7..f4eadd3 100644
>>>>>> --- a/security/selinux/ss/policydb.c
>>>>>> +++ b/security/selinux/ss/policydb.c
>>>>>> @@ -1101,7 +1101,7 @@ static int str_read(char **strp, gfp_t flags, void *fp, u32 len)
>>>>>>         if ((len == 0) || (len == (u32)-1))
>>>>>>                 return -EINVAL;
>>>>>>
>>>>>> -       str = kmalloc(len + 1, flags);
>>>>>> +       str = kmalloc(len + 1, flags | __GFP_NOWARN);
>>>>>>         if (!str)
>>>>>>                 return -ENOMEM;
>>>>> Thanks for the patch.
>>>>>
>>>>> My eyes are starting to glaze over a bit chasing down all of the
>>>>> different kmalloc() code paths trying to ensure that this always does
>>>>> the right thing based on size of the allocation and the different slab
>>>>> allocators ... are we sure that this will always return NULL when (len
>>>>> + 1) is greater than KMALLOC_MAX_SIZE for the different slab allocator
>>>>> configurations?
>>>>>
>>>> Yes, for (len + 1) cannot become 0 (which causes kmalloc() to return
>>>> ZERO_SIZE_PTR) due to (len == (u32)-1) check above.
>>>>
>>>> The only concern would be whether you want allocation failure messages.
>>>> I assumed you don't need it because we are returning -ENOMEM to the caller.
>>>>
>>> Would it not be better with
>>>
>>>     char *str;
>>>
>>>     if ((len == 0) || (len == (u32)-1) || (len >= KMALLOC_MAX_SIZE))
>>>         return -EINVAL;
>>>
>>>     str = kmalloc(len + 1, flags);
>>>     if (!str)
>>>         return -ENOMEM;
>> I strongly suspect that you want kvmalloc rather than kmalloc here. The
>> larger the request the more likely is the allocation to fail.
>>
>> I am not familiar with the code but I assume this is a root only
>> interface so we don't have to worry about nasty users scenario.
>>
> I don't think we get any big data there at all. Usually less than 32 bytes. However this data can be in fast path so a vmalloc is not an option.
>
> And some of the calls are GFP_ATOMC.

Then another option is to introduce reasonable application-specific
limit and not rely on kmalloc-anything at all. We did this for some
instances of this warning too. One advantage of it is that it prevents
users from doing silly things (or maybe will discover bugs in
user-space code better, why are they asking for megs here?). Another
advantage is that what works on one version of kernel will continue to
work on another version of kernel. Today it's possible that a policy
works on one kernel with 4MB kmalloc limit, but breaks on another with
2MB limit. Ideally exact value of KMALLOC_MAX_SIZE does not affect
anything in user-space.
