Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 970476B0007
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 06:47:17 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g18-v6so8404653pfh.20
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 03:47:17 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 33-v6si9617771plu.283.2018.08.06.03.47.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 03:47:16 -0700 (PDT)
Subject: Re: WARNING in try_charge
References: <0000000000005e979605729c1564@google.com>
 <20180806091552.GE19540@dhcp22.suse.cz>
 <CACT4Y+Ystnwv4M6Uh+HBKbdADAnJ6otfR0GoA20crzqV+b2onQ@mail.gmail.com>
 <20180806094827.GH19540@dhcp22.suse.cz>
 <CACT4Y+ZEAoPWxEJ2yAf6b5cSjAm+MPx1yrk70BWHRrnDYdyb_A@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <884de816-671a-44d4-a6a1-2ad7eff53715@I-love.SAKURA.ne.jp>
Date: Mon, 6 Aug 2018 19:47:00 +0900
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZEAoPWxEJ2yAf6b5cSjAm+MPx1yrk70BWHRrnDYdyb_A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Michal Hocko <mhocko@kernel.org>
Cc: syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, Vladimir Davydov <vdavydov.dev@gmail.com>

On 2018/08/06 19:39, Dmitry Vyukov wrote:
> On Mon, Aug 6, 2018 at 11:48 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> Btw. running with the above diff on top might help us to ideantify
>> whether this is a pre-mature warning or a valid one. Still useful to
>> find out.

Since syzbot already found a syz reproducer, you can ask syzbot to test it.

> 
> The bug report has a reproducer, so you can run it with the patch. Or
> ask syzbot to test your patch:
> https://github.com/google/syzkaller/blob/master/docs/syzbot.md#testing-patches
> Which basically boils down to saying:
> 
> #syz test: git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> master

Excuse me, but this is linux-next only problem. Therefore,

#syz test: git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4603ad75c9a9..852cd3dbdcd9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1388,6 +1388,8 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	bool ret;
 
 	mutex_lock(&oom_lock);
+	pr_info("task=%s pid=%d invoked memcg oom killer. oom_victim=%d\n",
+			current->comm, current->pid, tsk_is_oom_victim(current));
 	ret = out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
 	return ret;

F.Y.I. Waiting until __mmput() completes (with timeout using OOM score feedback)
( https://syzkaller.appspot.com/x/patch.diff?x=101e449c400000 ) solves this race.
