Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id ADB776B005A
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 12:21:16 -0500 (EST)
Received: by qao25 with SMTP id 25so666047qao.14
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 09:21:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1112061734450.26844@chino.kir.corp.google.com>
References: <1322770029-10297-1-git-send-email-yinghan@google.com>
	<alpine.DEB.2.00.1112061734450.26844@chino.kir.corp.google.com>
Date: Wed, 7 Dec 2011 09:21:15 -0800
Message-ID: <CALWz4izNE6So17q0QqE34k1PoZD0hHJvm3L6V_yCaa19szzOrQ@mail.gmail.com>
Subject: Re: [PATCH V6] Eliminate task stack trace duplication
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, Dec 6, 2011 at 5:35 PM, David Rientjes <rientjes@google.com> wrote:
> On Thu, 1 Dec 2011, Ying Han wrote:
>
>> The problem with small dmesg ring buffer like 512k is that only limited =
number
>> of task traces will be logged. Sometimes we lose important information o=
nly
>> because of too many duplicated stack traces. This problem occurs when du=
mping
>> lots of stacks in a single operation, such as sysrq-T.
>>
>> This patch tries to reduce the duplication of task stack trace in the du=
mp
>> message by hashing the task stack. The hashtable is a 32k pre-allocated =
buffer
>> during bootup. Each time if we find the identical task trace in the task=
 stack,
>> we dump only the pid of the task which has the task trace dumped. So it =
is easy
>> to back track to the full stack with the pid.
>>
>> When we do the hashing, we eliminate garbage entries from stack traces. =
Those
>> entries are still being printed in the dump to provide more debugging
>> informations.
>>
>> [ =A0 58.469730] kworker/0:0 =A0 =A0 S 0000000000000000 =A0 =A0 0 =A0 =
=A0 4 =A0 =A0 =A02 0x00000000
>> [ =A0 58.469735] =A0ffff88082fcfde80 0000000000000046 ffff88082e9d8000 f=
fff88082fcfc010
>> [ =A0 58.469739] =A0ffff88082fce9860 0000000000011440 ffff88082fcfdfd8 f=
fff88082fcfdfd8
>> [ =A0 58.469743] =A00000000000011440 0000000000000000 ffff88082fcee180 f=
fff88082fce9860
>> [ =A0 58.469747] Call Trace:
>> [ =A0 58.469751] =A0[<ffffffff8108525a>] worker_thread+0x24b/0x250
>> [ =A0 58.469754] =A0[<ffffffff8108500f>] ? manage_workers+0x192/0x192
>> [ =A0 58.469757] =A0[<ffffffff810885bd>] kthread+0x82/0x8a
>> [ =A0 58.469760] =A0[<ffffffff8141aed4>] kernel_thread_helper+0x4/0x10
>> [ =A0 58.469763] =A0[<ffffffff8108853b>] ? kthread_worker_fn+0x112/0x112
>> [ =A0 58.469765] =A0[<ffffffff8141aed0>] ? gs_change+0xb/0xb
>> [ =A0 58.469768] kworker/u:0 =A0 =A0 S 0000000000000004 =A0 =A0 0 =A0 =
=A0 5 =A0 =A0 =A02 0x00000000
>> [ =A0 58.469773] =A0ffff88082fcffe80 0000000000000046 ffff880800000000 f=
fff88082fcfe010
>> [ =A0 58.469777] =A0ffff88082fcea080 0000000000011440 ffff88082fcfffd8 f=
fff88082fcfffd8
>> [ =A0 58.469781] =A00000000000011440 0000000000000000 ffff88082fd4e9a0 f=
fff88082fcea080
>> [ =A0 58.469785] Call Trace:
>> [ =A0 58.469786] <Same stack as pid 4>
>> [ =A0 58.470235] kworker/0:1 =A0 =A0 S 0000000000000000 =A0 =A0 0 =A0 =
=A013 =A0 =A0 =A02 0x00000000
>> [ =A0 58.470255] =A0ffff88082fd3fe80 0000000000000046 ffff880800000000 f=
fff88082fd3e010
>> [ =A0 58.470279] =A0ffff88082fcee180 0000000000011440 ffff88082fd3ffd8 f=
fff88082fd3ffd8
>> [ =A0 58.470301] =A00000000000011440 0000000000000000 ffffffff8180b020 f=
fff88082fcee180
>> [ =A0 58.470325] Call Trace:
>> [ =A0 58.470332] <Same stack as pid 4>
>>
>> changelog v6..v5:
>> 1. clear saved stack trace before printing a set of stacks. this ensures=
 the printed
>> stack traces are not omitted messages.
>> 2. add log level in printing duplicate stack.
>> 3. remove the show_stack() API change, and non-x86 arch won't need furth=
er change.
>> 4. add more inline documentations.
>>
>> changelog v5..v4:
>> 1. removed changes to Kconfig file
>> 2. changed hashtable to keep only hash value and length of stack
>> 3. simplified hashtable lookup
>>
>> changelog v4..v3:
>> 1. improve de-duplication by eliminating garbage entries from stack trac=
es.
>> with this change 793/825 stack traces were recognized as duplicates. in =
v3
>> only 482/839 were duplicates.
>>
>> changelog v3..v2:
>> 1. again better documentation on the patch description.
>> 2. make the stack_hash_table to be allocated at compile time.
>> 3. have better name of variable index
>> 4. move save_dup_stack_trace() in kernel/stacktrace.c
>>
>> changelog v2..v1:
>> 1. better documentation on the patch description
>> 2. move the spinlock inside the hash lockup, so reducing the holding tim=
e.
>>
>> Note:
>> 1. with pid namespace, we might have same pid number for different proce=
sses. i
>> wonder how the stack trace (w/o dedup) handles the case, it uses tsk->pi=
d as well
>> as far as I checked.
>> 2. the core functionality is in x86-specific code, this could be moved o=
ut to
>> support other architectures.
>> 3. Andrew made the suggestion of doing appending to stack_hash_table[].
>>
>> Signed-off-by: Ying Han <yinghan@google.com>
>> Signed-off-by: Greg Thelen <gthelen@google.com>
>> ---
>> =A0arch/x86/include/asm/stacktrace.h | =A0 11 +++-
>> =A0arch/x86/kernel/dumpstack.c =A0 =A0 =A0 | =A0 24 ++++++-
>> =A0arch/x86/kernel/dumpstack_32.c =A0 =A0| =A0 =A07 +-
>> =A0arch/x86/kernel/dumpstack_64.c =A0 =A0| =A0 =A07 +-
>> =A0arch/x86/kernel/stacktrace.c =A0 =A0 =A0| =A0123 ++++++++++++++++++++=
+++++++++++++++++
>> =A0include/linux/sched.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +
>> =A0include/linux/stacktrace.h =A0 =A0 =A0 =A0| =A0 =A04 +
>> =A0kernel/sched.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 32 ++++++=
+++-
>> =A0kernel/stacktrace.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 15 +++++
>> =A09 files changed, 211 insertions(+), 15 deletions(-)
>>
>
> Looks like something that would go through x86/debug? =A0Probably best to=
 cc
> Ingo, Peter, and Thomas.

Thank you David, I was about to add linux-kernel into the cc list
yesterday as well.

--Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
