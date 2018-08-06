Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 67C616B0010
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 06:39:32 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id z3-v6so8295251plb.16
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 03:39:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x187-v6sor3065855pgb.174.2018.08.06.03.39.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 03:39:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180806094827.GH19540@dhcp22.suse.cz>
References: <0000000000005e979605729c1564@google.com> <20180806091552.GE19540@dhcp22.suse.cz>
 <CACT4Y+Ystnwv4M6Uh+HBKbdADAnJ6otfR0GoA20crzqV+b2onQ@mail.gmail.com> <20180806094827.GH19540@dhcp22.suse.cz>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 6 Aug 2018 12:39:09 +0200
Message-ID: <CACT4Y+ZEAoPWxEJ2yAf6b5cSjAm+MPx1yrk70BWHRrnDYdyb_A@mail.gmail.com>
Subject: Re: WARNING in try_charge
Content-Type: multipart/mixed; boundary="0000000000007a019c0572c1e4c7"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

--0000000000007a019c0572c1e4c7
Content-Type: text/plain; charset="UTF-8"

On Mon, Aug 6, 2018 at 11:48 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 06-08-18 11:30:37, Dmitry Vyukov wrote:
>> On Mon, Aug 6, 2018 at 11:15 AM, Michal Hocko <mhocko@kernel.org> wrote:
> [...]
>> > More interesting stuff is higher in the kernel log
>> > : [  366.435015] oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),cpuset=/,mems_allowed=0,oom_memcg=/ile0,task_memcg=/ile0,task=syz-executor3,pid=23766,uid=0
>> > : [  366.449416] memory: usage 112kB, limit 0kB, failcnt 1605
>> >
>> > Are you sure you want to have hard limit set to 0?
>>
>> syzkaller really does not mind to have it.
>
> So what do you use it for? What do you actually test by this setting?
>
> [...]
>> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> > index 4603ad75c9a9..852cd3dbdcd9 100644
>> > --- a/mm/memcontrol.c
>> > +++ b/mm/memcontrol.c
>> > @@ -1388,6 +1388,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>> >         bool ret;
>> >
>> >         mutex_lock(&oom_lock);
>> > +       pr_info("task=%s pid=%d invoked memcg oom killer. oom_victim=%d\n",
>> > +                       current->comm, current->pid, tsk_is_oom_victim(current));
>> >         ret = out_of_memory(&oc);
>> >         mutex_unlock(&oom_lock);
>> >         return ret;
>> >
>> > Anyway your memcg setup is indeed misconfigured. Memcg with 0 hard limit
>> > and basically no memory charged by existing tasks is not going to fly
>> > and the warning is exactly to call that out.
>>
>>
>> Please-please-please do not mix kernel bugs and notices to user into
>> the same bucket:
>
> Well, WARN_ON used to be a standard way to make user aware of a
> misbehavior. In this case it warns about a pottential runaway when memcg
> is misconfigured. I do not insist on using WARN_ON here of course. If
> there is a general agreement that such a condition is better handled by
> pr_err then I am fine with it. Users tend to be more sensitive on
> WARN_ONs though.
>
> Btw. running with the above diff on top might help us to ideantify
> whether this is a pre-mature warning or a valid one. Still useful to
> find out.

The bug report has a reproducer, so you can run it with the patch. Or
ask syzbot to test your patch:
https://github.com/google/syzkaller/blob/master/docs/syzbot.md#testing-patches
Which basically boils down to saying:

#syz test: git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
master

Note that a text patch without a base tree/commit can be useless, I
used torvalds/linux.git but I don't know if it will apply there or
not. Let's see.

--0000000000007a019c0572c1e4c7
Content-Type: text/x-patch; charset="US-ASCII"; name="cgroup.patch"
Content-Disposition: attachment; filename="cgroup.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_jki54m7q0

ZGlmZiAtLWdpdCBhL21tL21lbWNvbnRyb2wuYyBiL21tL21lbWNvbnRyb2wuYwppbmRleCA0NjAz
YWQ3NWM5YTkuLjg1MmNkM2RiZGNkOSAxMDA2NDQKLS0tIGEvbW0vbWVtY29udHJvbC5jCisrKyBi
L21tL21lbWNvbnRyb2wuYwpAQCAtMTM4OCw2ICsxMzg4LDggQEAgc3RhdGljIGJvb2wgbWVtX2Nn
cm91cF9vdXRfb2ZfbWVtb3J5KHN0cnVjdCBtZW1fY2dyb3VwICptZW1jZywgZ2ZwX3QgZ2ZwX21h
c2ssCiAJYm9vbCByZXQ7CiAKIAltdXRleF9sb2NrKCZvb21fbG9jayk7CisJcHJfaW5mbygidGFz
az0lcyBwaWQ9JWQgaW52b2tlZCBtZW1jZyBvb20ga2lsbGVyLiBvb21fdmljdGltPSVkXG4iLAor
CQkJY3VycmVudC0+Y29tbSwgY3VycmVudC0+cGlkLCB0c2tfaXNfb29tX3ZpY3RpbShjdXJyZW50
KSk7CiAJcmV0ID0gb3V0X29mX21lbW9yeSgmb2MpOwogCW11dGV4X3VubG9jaygmb29tX2xvY2sp
OwogCXJldHVybiByZXQ7Cgo=
--0000000000007a019c0572c1e4c7--
