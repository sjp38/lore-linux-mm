Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9F6A26B0078
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 01:26:51 -0500 (EST)
Received: by pwj7 with SMTP id 7so897482pwj.14
        for <linux-mm@kvack.org>; Tue, 16 Feb 2010 22:26:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1002161357170.23037@chino.kir.corp.google.com>
References: <1266335957.1709.67.camel@barrios-desktop>
	 <alpine.DEB.2.00.1002161357170.23037@chino.kir.corp.google.com>
Date: Wed, 17 Feb 2010 15:26:49 +0900
Message-ID: <28c262361002162226k7ec561cenf84f494618fa8c54@mail.gmail.com>
Subject: Re: [PATCH -mm] Kill existing current task quickly
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: multipart/mixed; boundary=0016e64ce58673d49b047fc5ef59
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--0016e64ce58673d49b047fc5ef59
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On Wed, Feb 17, 2010 at 7:03 AM, David Rientjes <rientjes@google.com> wrote=
:
> On Wed, 17 Feb 2010, Minchan Kim wrote:
>
>> If we found current task is existing but didn't set TIF_MEMDIE
>> during OOM victim selection, let's stop unnecessary looping for
>> getting high badness score task and go ahead for killing current.
>>
>> This patch would make side effect skip OOM_DISABLE test.
>> But It's okay since the task is existing and oom_kill_process
>> doesn't show any killing message since __oom_kill_task will
>> interrupt it in oom_kill_process.
>>
>> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
>> Cc: Nick Piggin <npiggin@suse.de>
>> ---
>> =C2=A0mm/oom_kill.c | =C2=A0 =C2=A01 +
>> =C2=A01 files changed, 1 insertions(+), 0 deletions(-)
>>
>> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
>> index 3618be3..5c21398 100644
>> --- a/mm/oom_kill.c
>> +++ b/mm/oom_kill.c
>> @@ -295,6 +295,7 @@ static struct task_struct
>> *select_bad_process(unsigned long *ppoints,
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 chosen =3D p;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 *ppoints =3D ULONG_MAX;
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
break;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (p->signal->oom_adj =
=3D=3D OOM_DISABLE)
>
> No, we don't want to break because there may be other candidate tasks tha=
t
> have TIF_MEMDIE set that will be detected if we keep scanning. =C2=A0Retu=
rning
> ERR_PTR(-1UL) from select_bad_process() has a special meaning: it means w=
e
> return to the page allocator without doing anything. =C2=A0We don't want =
more
> than one candidate task to ever have TIF_MEMDIE at a time, otherwise they
> can deplete all memory reserves and not make any forward progress. =C2=A0=
So we
> always have to iterate the entire tasklist unless we find an already oom
> killed task with access to memory reserves (to prevent needlessly killing
> additional tasks before the first had a chance to exit and free its
> memory) or a different candidate task is exiting so we'll be freeing
> memory shortly (or it will be invoking the oom killer itself as current
> and then get chosen as the victim).
>

Thanks you very much for the kind explanation, David.

How about this?

I can't use smtp port. so at a loss, I have to send patch by attachment
in webmail which would mangle my tab space.
Pz, forgive my wrong behavior.
If God help me, below inlined patch isn't mangled. :)

I think exit_mm's new test about TIF_MEMDIE isn't big overhead.
That's because is is on cache line due to exit_signal's pending check.
And expand task_lock in __oom_kill_task isn't big, I think. That's because
__oom_kill_task isn't called frequently.

-- CUT_HERE --

Date: Wed, 17 Feb 2010 23:59:40 +0900
Subject: [PATCH] [PATCH -mm] Kill existing current task quickly

If we found current task is existing but didn't set TIF_MEMDIE
during OOM victim selection, let's stop unnecessary
looping for getting high badness score task and go ahead
for killing current.

For forkbomb scenarion, there are many processes on system
so tasklist scanning time might be much big. Sometime we used to
use oom_kill_allocating_task to avoid expensive
task list scanning time.

For it, we have to make sure there are not TIF_MEMDIE's
another tasks. This patch introduces nr_memdie
for counting TIF_MEMDIE's tasks.

This patch would make side effect skip OOM_DISABLE test.
But It's okay since the task is existing and oom_kill_process
doesn't show any killing message since __oom_kill_task will
interrupt it in oom_kill_process.

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Nick Piggin <npiggin@suse.de>
---
 include/linux/oom.h |    2 ++
 kernel/exit.c       |    3 +++
 mm/oom_kill.c       |   12 +++++++++---
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 505aa9e..9babcce 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -48,5 +48,7 @@ extern int sysctl_panic_on_oom;
 extern int sysctl_oom_kill_allocating_task;
 extern int sysctl_oom_dump_tasks;

+extern unsigned int nr_memdie;
+
 #endif /* __KERNEL__*/
 #endif /* _INCLUDE_LINUX_OOM_H */
diff --git a/kernel/exit.c b/kernel/exit.c
index c5305fc..932c67b 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -50,6 +50,7 @@
 #include <linux/perf_event.h>
 #include <trace/events/sched.h>
 #include <linux/hw_breakpoint.h>
+#include <linux/oom.h>

 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -685,6 +686,8 @@ static void exit_mm(struct task_struct * tsk)
        /* more a memory barrier than a real lock */
        task_lock(tsk);
        tsk->mm =3D NULL;
+       if (test_thread_flag(TIF_MEMDIE))
+               nr_memdie--;
        up_read(&mm->mmap_sem);
        enter_lazy_tlb(mm, current);
        /* We don't want this task to be frozen prematurely */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3618be3..d5e3d70 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -32,6 +32,8 @@ int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
 int sysctl_oom_dump_tasks;
 static DEFINE_SPINLOCK(zone_scan_lock);
+
+unsigned int nr_memdie; /* count of TIF_MEMDIE processes */
 /* #define DEBUG */

 /*
@@ -295,6 +297,8 @@ static struct task_struct
*select_bad_process(unsigned long *ppoints,

                        chosen =3D p;
                        *ppoints =3D ULONG_MAX;
+                       if (nr_memdie =3D=3D 0)
+                               break;
                }

                if (p->signal->oom_adj =3D=3D OOM_DISABLE)
@@ -403,8 +407,6 @@ static void __oom_kill_task(struct task_struct *p,
int verbose)
                       K(p->mm->total_vm),
                       K(get_mm_counter(p->mm, MM_ANONPAGES)),
                       K(get_mm_counter(p->mm, MM_FILEPAGES)));
-       task_unlock(p);
-
        /*
         * We give our sacrificial lamb high priority and access to
         * all the memory it needs. That way it should be able to
@@ -412,7 +414,11 @@ static void __oom_kill_task(struct task_struct
*p, int verbose)
         */
        p->rt.time_slice =3D HZ;
        set_tsk_thread_flag(p, TIF_MEMDIE);
-
+       /*
+        * nr_memdie is protected by task_lock.
+        */
+       nr_memdie++;
+       task_unlock(p);
        force_sig(SIGKILL, p);
 }

--=20
1.6.0.4



--=20
Kind regards,
Minchan Kim

--0016e64ce58673d49b047fc5ef59
Content-Type: text/x-diff; charset=US-ASCII;
	name="0001-Kill-existing-current-task-quickly.patch"
Content-Disposition: attachment;
	filename="0001-Kill-existing-current-task-quickly.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g5rqfzz00

RGF0ZTogV2VkLCAxNyBGZWIgMjAxMCAyMzo1OTo0MCArMDkwMApTdWJqZWN0OiBbUEFUQ0hdIFtQ
QVRDSCAtbW1dIEtpbGwgZXhpc3RpbmcgY3VycmVudCB0YXNrIHF1aWNrbHkKCklmIHdlIGZvdW5k
IGN1cnJlbnQgdGFzayBpcyBleGlzdGluZyBidXQgZGlkbid0IHNldCBUSUZfTUVNRElFCmR1cmlu
ZyBPT00gdmljdGltIHNlbGVjdGlvbiwgbGV0J3Mgc3RvcCB1bm5lY2Vzc2FyeQpsb29waW5nIGZv
ciBnZXR0aW5nIGhpZ2ggYmFkbmVzcyBzY29yZSB0YXNrIGFuZCBnbyBhaGVhZApmb3Iga2lsbGlu
ZyBjdXJyZW50LgoKRm9yIGZvcmtib21iIHNjZW5hcmlvbiwgdGhlcmUgYXJlIG1hbnkgcHJvY2Vz
c2VzIG9uIHN5c3RlbQpzbyB0YXNrbGlzdCBzY2FubmluZyB0aW1lIG1pZ2h0IGJlIG11Y2ggYmln
LiBTb21ldGltZSB3ZSB1c2VkIHRvCnVzZSBvb21fa2lsbF9hbGxvY2F0aW5nX3Rhc2sgdG8gYXZv
aWQgZXhwZW5zaXZlCnRhc2sgbGlzdCBzY2FubmluZyB0aW1lLgoKRm9yIGl0LCB3ZSBoYXZlIHRv
IG1ha2Ugc3VyZSB0aGVyZSBhcmUgbm90IFRJRl9NRU1ESUUncwphbm90aGVyIHRhc2tzLiBUaGlz
IHBhdGNoIGludHJvZHVjZXMgbnJfbWVtZGllCmZvciBjb3VudGluZyBUSUZfTUVNRElFJ3MgdGFz
a3MuCgpUaGlzIHBhdGNoIHdvdWxkIG1ha2Ugc2lkZSBlZmZlY3Qgc2tpcCBPT01fRElTQUJMRSB0
ZXN0LgpCdXQgSXQncyBva2F5IHNpbmNlIHRoZSB0YXNrIGlzIGV4aXN0aW5nIGFuZCBvb21fa2ls
bF9wcm9jZXNzCmRvZXNuJ3Qgc2hvdyBhbnkga2lsbGluZyBtZXNzYWdlIHNpbmNlIF9fb29tX2tp
bGxfdGFzayB3aWxsCmludGVycnVwdCBpdCBpbiBvb21fa2lsbF9wcm9jZXNzLgoKU2lnbmVkLW9m
Zi1ieTogTWluY2hhbiBLaW0gPG1pbmNoYW4ua2ltQGdtYWlsLmNvbT4KQ2M6IERhdmlkIFJpZW50
amVzIDxyaWVudGplc0Bnb29nbGUuY29tPgpDYzogTmljayBQaWdnaW4gPG5waWdnaW5Ac3VzZS5k
ZT4KLS0tCiBpbmNsdWRlL2xpbnV4L29vbS5oIHwgICAgMiArKwoga2VybmVsL2V4aXQuYyAgICAg
ICB8ICAgIDMgKysrCiBtbS9vb21fa2lsbC5jICAgICAgIHwgICAxMiArKysrKysrKystLS0KIDMg
ZmlsZXMgY2hhbmdlZCwgMTQgaW5zZXJ0aW9ucygrKSwgMyBkZWxldGlvbnMoLSkKCmRpZmYgLS1n
aXQgYS9pbmNsdWRlL2xpbnV4L29vbS5oIGIvaW5jbHVkZS9saW51eC9vb20uaAppbmRleCA1MDVh
YTllLi45YmFiY2NlIDEwMDY0NAotLS0gYS9pbmNsdWRlL2xpbnV4L29vbS5oCisrKyBiL2luY2x1
ZGUvbGludXgvb29tLmgKQEAgLTQ4LDUgKzQ4LDcgQEAgZXh0ZXJuIGludCBzeXNjdGxfcGFuaWNf
b25fb29tOwogZXh0ZXJuIGludCBzeXNjdGxfb29tX2tpbGxfYWxsb2NhdGluZ190YXNrOwogZXh0
ZXJuIGludCBzeXNjdGxfb29tX2R1bXBfdGFza3M7CiAKK2V4dGVybiB1bnNpZ25lZCBpbnQgbnJf
bWVtZGllOworCiAjZW5kaWYgLyogX19LRVJORUxfXyovCiAjZW5kaWYgLyogX0lOQ0xVREVfTElO
VVhfT09NX0ggKi8KZGlmZiAtLWdpdCBhL2tlcm5lbC9leGl0LmMgYi9rZXJuZWwvZXhpdC5jCmlu
ZGV4IGM1MzA1ZmMuLjkzMmM2N2IgMTAwNjQ0Ci0tLSBhL2tlcm5lbC9leGl0LmMKKysrIGIva2Vy
bmVsL2V4aXQuYwpAQCAtNTAsNiArNTAsNyBAQAogI2luY2x1ZGUgPGxpbnV4L3BlcmZfZXZlbnQu
aD4KICNpbmNsdWRlIDx0cmFjZS9ldmVudHMvc2NoZWQuaD4KICNpbmNsdWRlIDxsaW51eC9od19i
cmVha3BvaW50Lmg+CisjaW5jbHVkZSA8bGludXgvb29tLmg+CiAKICNpbmNsdWRlIDxhc20vdWFj
Y2Vzcy5oPgogI2luY2x1ZGUgPGFzbS91bmlzdGQuaD4KQEAgLTY4NSw2ICs2ODYsOCBAQCBzdGF0
aWMgdm9pZCBleGl0X21tKHN0cnVjdCB0YXNrX3N0cnVjdCAqIHRzaykKIAkvKiBtb3JlIGEgbWVt
b3J5IGJhcnJpZXIgdGhhbiBhIHJlYWwgbG9jayAqLwogCXRhc2tfbG9jayh0c2spOwogCXRzay0+
bW0gPSBOVUxMOworCWlmICh0ZXN0X3RocmVhZF9mbGFnKFRJRl9NRU1ESUUpKQorCQlucl9tZW1k
aWUtLTsKIAl1cF9yZWFkKCZtbS0+bW1hcF9zZW0pOwogCWVudGVyX2xhenlfdGxiKG1tLCBjdXJy
ZW50KTsKIAkvKiBXZSBkb24ndCB3YW50IHRoaXMgdGFzayB0byBiZSBmcm96ZW4gcHJlbWF0dXJl
bHkgKi8KZGlmZiAtLWdpdCBhL21tL29vbV9raWxsLmMgYi9tbS9vb21fa2lsbC5jCmluZGV4IDM2
MThiZTMuLmQ1ZTNkNzAgMTAwNjQ0Ci0tLSBhL21tL29vbV9raWxsLmMKKysrIGIvbW0vb29tX2tp
bGwuYwpAQCAtMzIsNiArMzIsOCBAQCBpbnQgc3lzY3RsX3BhbmljX29uX29vbTsKIGludCBzeXNj
dGxfb29tX2tpbGxfYWxsb2NhdGluZ190YXNrOwogaW50IHN5c2N0bF9vb21fZHVtcF90YXNrczsK
IHN0YXRpYyBERUZJTkVfU1BJTkxPQ0soem9uZV9zY2FuX2xvY2spOworCit1bnNpZ25lZCBpbnQg
bnJfbWVtZGllOyAvKiBjb3VudCBvZiBUSUZfTUVNRElFIHByb2Nlc3NlcyAqLwogLyogI2RlZmlu
ZSBERUJVRyAqLwogCiAvKgpAQCAtMjk1LDYgKzI5Nyw4IEBAIHN0YXRpYyBzdHJ1Y3QgdGFza19z
dHJ1Y3QgKnNlbGVjdF9iYWRfcHJvY2Vzcyh1bnNpZ25lZCBsb25nICpwcG9pbnRzLAogCiAJCQlj
aG9zZW4gPSBwOwogCQkJKnBwb2ludHMgPSBVTE9OR19NQVg7CisJCQlpZiAobnJfbWVtZGllID09
IDApCisJCQkJYnJlYWs7CiAJCX0KIAogCQlpZiAocC0+c2lnbmFsLT5vb21fYWRqID09IE9PTV9E
SVNBQkxFKQpAQCAtNDAzLDggKzQwNyw2IEBAIHN0YXRpYyB2b2lkIF9fb29tX2tpbGxfdGFzayhz
dHJ1Y3QgdGFza19zdHJ1Y3QgKnAsIGludCB2ZXJib3NlKQogCQkgICAgICAgSyhwLT5tbS0+dG90
YWxfdm0pLAogCQkgICAgICAgSyhnZXRfbW1fY291bnRlcihwLT5tbSwgTU1fQU5PTlBBR0VTKSks
CiAJCSAgICAgICBLKGdldF9tbV9jb3VudGVyKHAtPm1tLCBNTV9GSUxFUEFHRVMpKSk7Ci0JdGFz
a191bmxvY2socCk7Ci0KIAkvKgogCSAqIFdlIGdpdmUgb3VyIHNhY3JpZmljaWFsIGxhbWIgaGln
aCBwcmlvcml0eSBhbmQgYWNjZXNzIHRvCiAJICogYWxsIHRoZSBtZW1vcnkgaXQgbmVlZHMuIFRo
YXQgd2F5IGl0IHNob3VsZCBiZSBhYmxlIHRvCkBAIC00MTIsNyArNDE0LDExIEBAIHN0YXRpYyB2
b2lkIF9fb29tX2tpbGxfdGFzayhzdHJ1Y3QgdGFza19zdHJ1Y3QgKnAsIGludCB2ZXJib3NlKQog
CSAqLwogCXAtPnJ0LnRpbWVfc2xpY2UgPSBIWjsKIAlzZXRfdHNrX3RocmVhZF9mbGFnKHAsIFRJ
Rl9NRU1ESUUpOwotCisJLyoKKwkgKiBucl9tZW1kaWUgaXMgcHJvdGVjdGVkIGJ5IHRhc2tfbG9j
ay4KKwkgKi8KKwlucl9tZW1kaWUrKzsKKwl0YXNrX3VubG9jayhwKTsKIAlmb3JjZV9zaWcoU0lH
S0lMTCwgcCk7CiB9CiAKLS0gCjEuNi4wLjQKCg==
--0016e64ce58673d49b047fc5ef59--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
