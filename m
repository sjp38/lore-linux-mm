Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id EE1628E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 03:12:07 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id f2-v6so1297818lff.12
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 00:12:07 -0700 (PDT)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id k81-v6si3777116lje.31.2018.09.13.00.12.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 00:12:06 -0700 (PDT)
Subject: Re: [PATCH] selinux: Add __GFP_NOWARN to allocation at str_read()
References: <000000000000038dab0575476b73@google.com>
 <f3bcebc6-47a7-518e-70f7-c7e167621841@I-love.SAKURA.ne.jp>
 <CAHC9VhT-Thu6KppC-MWzqkB7R1CaQA9DWXOQnG0b2uS9+rvzoA@mail.gmail.com>
 <ea29a8bf-95b2-91d2-043b-ed73c9023166@i-love.sakura.ne.jp>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <9d685700-bc5c-9c2f-7795-56f488d2ea38@sony.com>
Date: Thu, 13 Sep 2018 09:12:04 +0200
MIME-Version: 1.0
In-Reply-To: <ea29a8bf-95b2-91d2-043b-ed73c9023166@i-love.sakura.ne.jp>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Paul Moore <paul@paul-moore.com>
Cc: selinux@tycho.nsa.gov, syzbot+ac488b9811036cea7ea0@syzkaller.appspotmail.com, Eric Paris <eparis@parisplace.org>, linux-kernel@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>, syzkaller-bugs@googlegroups.com, linux-mm <linux-mm@kvack.org>

On 09/13/2018 08:26 AM, Tetsuo Handa wrote:
> On 2018/09/13 12:02, Paul Moore wrote:
>> On Fri, Sep 7, 2018 at 12:43 PM Tetsuo Handa
>> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>>> syzbot is hitting warning at str_read() [1] because len parameter can=

>>> become larger than KMALLOC_MAX_SIZE. We don't need to emit warning fo=
r
>>> this case.
>>>
>>> [1] https://syzkaller.appspot.com/bug?id=3D7f2f5aad79ea8663c296a2eedb=
81978401a908f0
>>>
>>> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>>> Reported-by: syzbot <syzbot+ac488b9811036cea7ea0@syzkaller.appspotmai=
l.com>
>>> ---
>>>  security/selinux/ss/policydb.c | 2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/security/selinux/ss/policydb.c b/security/selinux/ss/pol=
icydb.c
>>> index e9394e7..f4eadd3 100644
>>> --- a/security/selinux/ss/policydb.c
>>> +++ b/security/selinux/ss/policydb.c
>>> @@ -1101,7 +1101,7 @@ static int str_read(char **strp, gfp_t flags, v=
oid *fp, u32 len)
>>>         if ((len =3D=3D 0) || (len =3D=3D (u32)-1))
>>>                 return -EINVAL;
>>>
>>> -       str =3D kmalloc(len + 1, flags);
>>> +       str =3D kmalloc(len + 1, flags | __GFP_NOWARN);
>>>         if (!str)
>>>                 return -ENOMEM;
>> Thanks for the patch.
>>
>> My eyes are starting to glaze over a bit chasing down all of the
>> different kmalloc() code paths trying to ensure that this always does
>> the right thing based on size of the allocation and the different slab=

>> allocators ... are we sure that this will always return NULL when (len=

>> + 1) is greater than KMALLOC_MAX_SIZE for the different slab allocator=

>> configurations?
>>
> Yes, for (len + 1) cannot become 0 (which causes kmalloc() to return
> ZERO_SIZE_PTR) due to (len =3D=3D (u32)-1) check above.
>
> The only concern would be whether you want allocation failure messages.=

> I assumed you don't need it because we are returning -ENOMEM to the cal=
ler.
>
Would it not be better with

=C2=A0=C2=A0=C2=A0 char *str;

=C2=A0=C2=A0=C2=A0 if ((len =3D=3D 0) || (len =3D=3D (u32)-1) || (len >=3D=
=20KMALLOC_MAX_SIZE))
=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 return -EINVAL;

=C2=A0=C2=A0=C2=A0 str =3D kmalloc(len + 1, flags);
=C2=A0=C2=A0=C2=A0 if (!str)
=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 return -ENOMEM;
