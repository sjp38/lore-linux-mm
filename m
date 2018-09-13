Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id C86308E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 08:55:14 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id l14-v6so1022171lja.20
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 05:55:14 -0700 (PDT)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id x22-v6si4081464ljc.163.2018.09.13.05.55.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Sep 2018 05:55:12 -0700 (PDT)
Subject: Re: [PATCH] selinux: Add __GFP_NOWARN to allocation at str_read()
References: <000000000000038dab0575476b73@google.com>
 <f3bcebc6-47a7-518e-70f7-c7e167621841@I-love.SAKURA.ne.jp>
 <CAHC9VhT-Thu6KppC-MWzqkB7R1CaQA9DWXOQnG0b2uS9+rvzoA@mail.gmail.com>
 <ea29a8bf-95b2-91d2-043b-ed73c9023166@i-love.sakura.ne.jp>
 <9d685700-bc5c-9c2f-7795-56f488d2ea38@sony.com>
 <20180913111135.GA21006@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sony.com>
Message-ID: <ec6547f4-6240-d901-b2d2-b5103a10493f@sony.com>
Date: Thu, 13 Sep 2018 14:55:11 +0200
MIME-Version: 1.0
In-Reply-To: <20180913111135.GA21006@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Paul Moore <paul@paul-moore.com>, selinux@tycho.nsa.gov, syzbot+ac488b9811036cea7ea0@syzkaller.appspotmail.com, Eric Paris <eparis@parisplace.org>, linux-kernel@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>, syzkaller-bugs@googlegroups.com, linux-mm <linux-mm@kvack.org>

On 09/13/2018 01:11 PM, Michal Hocko wrote:
> On Thu 13-09-18 09:12:04, peter enderborg wrote:
>> On 09/13/2018 08:26 AM, Tetsuo Handa wrote:
>>> On 2018/09/13 12:02, Paul Moore wrote:
>>>> On Fri, Sep 7, 2018 at 12:43 PM Tetsuo Handa
>>>> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>>>>> syzbot is hitting warning at str_read() [1] because len parameter c=
an
>>>>> become larger than KMALLOC_MAX_SIZE. We don't need to emit warning =
for
>>>>> this case.
>>>>>
>>>>> [1] https://syzkaller.appspot.com/bug?id=3D7f2f5aad79ea8663c296a2ee=
db81978401a908f0
>>>>>
>>>>> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>>>>> Reported-by: syzbot <syzbot+ac488b9811036cea7ea0@syzkaller.appspotm=
ail.com>
>>>>> ---
>>>>>  security/selinux/ss/policydb.c | 2 +-
>>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>>
>>>>> diff --git a/security/selinux/ss/policydb.c b/security/selinux/ss/p=
olicydb.c
>>>>> index e9394e7..f4eadd3 100644
>>>>> --- a/security/selinux/ss/policydb.c
>>>>> +++ b/security/selinux/ss/policydb.c
>>>>> @@ -1101,7 +1101,7 @@ static int str_read(char **strp, gfp_t flags,=
=20void *fp, u32 len)
>>>>>         if ((len =3D=3D 0) || (len =3D=3D (u32)-1))
>>>>>                 return -EINVAL;
>>>>>
>>>>> -       str =3D kmalloc(len + 1, flags);
>>>>> +       str =3D kmalloc(len + 1, flags | __GFP_NOWARN);
>>>>>         if (!str)
>>>>>                 return -ENOMEM;
>>>> Thanks for the patch.
>>>>
>>>> My eyes are starting to glaze over a bit chasing down all of the
>>>> different kmalloc() code paths trying to ensure that this always doe=
s
>>>> the right thing based on size of the allocation and the different sl=
ab
>>>> allocators ... are we sure that this will always return NULL when (l=
en
>>>> + 1) is greater than KMALLOC_MAX_SIZE for the different slab allocat=
or
>>>> configurations?
>>>>
>>> Yes, for (len + 1) cannot become 0 (which causes kmalloc() to return
>>> ZERO_SIZE_PTR) due to (len =3D=3D (u32)-1) check above.
>>>
>>> The only concern would be whether you want allocation failure message=
s.
>>> I assumed you don't need it because we are returning -ENOMEM to the c=
aller.
>>>
>> Would it not be better with
>>
>> =C2=A0=C2=A0=C2=A0 char *str;
>>
>> =C2=A0=C2=A0=C2=A0 if ((len =3D=3D 0) || (len =3D=3D (u32)-1) || (len =
>=3D KMALLOC_MAX_SIZE))
>> =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 return -EINVAL;
>>
>> =C2=A0=C2=A0=C2=A0 str =3D kmalloc(len + 1, flags);
>> =C2=A0=C2=A0=C2=A0 if (!str)
>> =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 return -ENOMEM;
> I strongly suspect that you want kvmalloc rather than kmalloc here. The=

> larger the request the more likely is the allocation to fail.
>
> I am not familiar with the code but I assume this is a root only
> interface so we don't have to worry about nasty users scenario.
>
I don't think we get any big data there at all. Usually less than 32 byte=
s. However this data can be in fast path so a vmalloc is not an option.

And some of the calls are GFP_ATOMC.
