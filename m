Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5AD738E0001
	for <linux-mm@kvack.org>; Sat, 15 Dec 2018 22:16:39 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b7so4565593eda.10
        for <linux-mm@kvack.org>; Sat, 15 Dec 2018 19:16:39 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p32si2581552edd.191.2018.12.15.19.16.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Dec 2018 19:16:37 -0800 (PST)
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] fork,memcg: fix crash in free_thread_stack on memcg
 charge fail
Date: Sun, 16 Dec 2018 03:16:06 +0000
Message-ID: <20181216031558.GA8627@castle.DHCP.thefacebook.com>
References: <20181214231726.7ee4843c@imladris.surriel.com>
In-Reply-To: <20181214231726.7ee4843c@imladris.surriel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <30CF8041DF09AB4988F50E631CABA187@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Andrew Morton  <akpm@linux-foundation.org>, Shakeel Butt" <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On Fri, Dec 14, 2018 at 11:17:26PM -0500, Rik van Riel wrote:
> Changeset 9b6f7e163cd0 ("mm: rework memcg kernel stack accounting")
> will result in fork failing if allocating a kernel stack for a task
> in dup_task_struct exceeds the kernel memory allowance for that cgroup.
>=20
> Unfortunately, it also results in a crash.
>=20
> This is due to the code jumping to free_stack and calling free_thread_sta=
ck
> when the memcg kernel stack charge fails, but without tsk->stack pointing
> at the freshly allocated stack.
>=20
> This in turn results in the vfree_atomic in free_thread_stack oopsing
> with a backtrace like this:
>=20
> #5 [ffffc900244efc88] die at ffffffff8101f0ab
>  #6 [ffffc900244efcb8] do_general_protection at ffffffff8101cb86
>  #7 [ffffc900244efce0] general_protection at ffffffff818ff082
>     [exception RIP: llist_add_batch+7]
>     RIP: ffffffff8150d487  RSP: ffffc900244efd98  RFLAGS: 00010282
>     RAX: 0000000000000000  RBX: ffff88085ef55980  RCX: 0000000000000000
>     RDX: ffff88085ef55980  RSI: 343834343531203a  RDI: 343834343531203a
>     RBP: ffffc900244efd98   R8: 0000000000000001   R9: ffff8808578c3600
>     R10: 0000000000000000  R11: 0000000000000001  R12: ffff88029f6c21c0
>     R13: 0000000000000286  R14: ffff880147759b00  R15: 0000000000000000
>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
>  #8 [ffffc900244efda0] vfree_atomic at ffffffff811df2c7
>  #9 [ffffc900244efdb8] copy_process at ffffffff81086e37
> #10 [ffffc900244efe98] _do_fork at ffffffff810884e0
> #11 [ffffc900244eff10] sys_vfork at ffffffff810887ff
> #12 [ffffc900244eff20] do_syscall_64 at ffffffff81002a43
>     RIP: 000000000049b948  RSP: 00007ffcdb307830  RFLAGS: 00000246
>     RAX: ffffffffffffffda  RBX: 0000000000896030  RCX: 000000000049b948
>     RDX: 0000000000000000  RSI: 00007ffcdb307790  RDI: 00000000005d7421
>     RBP: 000000000067370f   R8: 00007ffcdb3077b0   R9: 000000000001ed00
>     R10: 0000000000000008  R11: 0000000000000246  R12: 0000000000000040
>     R13: 000000000000000f  R14: 0000000000000000  R15: 000000000088d018
>     ORIG_RAX: 000000000000003a  CS: 0033  SS: 002b
>=20
> The simplest fix is to assign tsk->stack right where it is allocated.

Good catch!

Acked-by: Roman Gushchin <guro@fb.com>

Thanks!
