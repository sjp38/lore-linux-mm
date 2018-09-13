Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id C344A8E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 02:26:36 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id s5-v6so3301898iop.3
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 23:26:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h25-v6si1899709iog.252.2018.09.12.23.26.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 23:26:35 -0700 (PDT)
Subject: Re: [PATCH] selinux: Add __GFP_NOWARN to allocation at str_read()
References: <000000000000038dab0575476b73@google.com>
 <f3bcebc6-47a7-518e-70f7-c7e167621841@I-love.SAKURA.ne.jp>
 <CAHC9VhT-Thu6KppC-MWzqkB7R1CaQA9DWXOQnG0b2uS9+rvzoA@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <ea29a8bf-95b2-91d2-043b-ed73c9023166@i-love.sakura.ne.jp>
Date: Thu, 13 Sep 2018 15:26:19 +0900
MIME-Version: 1.0
In-Reply-To: <CAHC9VhT-Thu6KppC-MWzqkB7R1CaQA9DWXOQnG0b2uS9+rvzoA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Moore <paul@paul-moore.com>
Cc: selinux@tycho.nsa.gov, syzbot+ac488b9811036cea7ea0@syzkaller.appspotmail.com, Eric Paris <eparis@parisplace.org>, linux-kernel@vger.kernel.org, peter.enderborg@sony.com, Stephen Smalley <sds@tycho.nsa.gov>, syzkaller-bugs@googlegroups.com, linux-mm <linux-mm@kvack.org>

On 2018/09/13 12:02, Paul Moore wrote:
> On Fri, Sep 7, 2018 at 12:43 PM Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> syzbot is hitting warning at str_read() [1] because len parameter can
>> become larger than KMALLOC_MAX_SIZE. We don't need to emit warning for
>> this case.
>>
>> [1] https://syzkaller.appspot.com/bug?id=7f2f5aad79ea8663c296a2eedb81978401a908f0
>>
>> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Reported-by: syzbot <syzbot+ac488b9811036cea7ea0@syzkaller.appspotmail.com>
>> ---
>>  security/selinux/ss/policydb.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/security/selinux/ss/policydb.c b/security/selinux/ss/policydb.c
>> index e9394e7..f4eadd3 100644
>> --- a/security/selinux/ss/policydb.c
>> +++ b/security/selinux/ss/policydb.c
>> @@ -1101,7 +1101,7 @@ static int str_read(char **strp, gfp_t flags, void *fp, u32 len)
>>         if ((len == 0) || (len == (u32)-1))
>>                 return -EINVAL;
>>
>> -       str = kmalloc(len + 1, flags);
>> +       str = kmalloc(len + 1, flags | __GFP_NOWARN);
>>         if (!str)
>>                 return -ENOMEM;
> 
> Thanks for the patch.
> 
> My eyes are starting to glaze over a bit chasing down all of the
> different kmalloc() code paths trying to ensure that this always does
> the right thing based on size of the allocation and the different slab
> allocators ... are we sure that this will always return NULL when (len
> + 1) is greater than KMALLOC_MAX_SIZE for the different slab allocator
> configurations?
> 

Yes, for (len + 1) cannot become 0 (which causes kmalloc() to return
ZERO_SIZE_PTR) due to (len == (u32)-1) check above.

The only concern would be whether you want allocation failure messages.
I assumed you don't need it because we are returning -ENOMEM to the caller.
