Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 23C656B0005
	for <linux-mm@kvack.org>; Wed,  2 May 2018 07:14:04 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id s8-v6so10030124pgf.0
        for <linux-mm@kvack.org>; Wed, 02 May 2018 04:14:04 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j4sor104399pfn.82.2018.05.02.04.14.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 May 2018 04:14:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+aOS+pOmXTGCRpyy+pzpDnz+q971hzZhEJp=xbZp8DoUA@mail.gmail.com>
References: <1525258689-3430-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <CACT4Y+aOS+pOmXTGCRpyy+pzpDnz+q971hzZhEJp=xbZp8DoUA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 2 May 2018 13:13:42 +0200
Message-ID: <CACT4Y+ZBdXW0JUc=ASYKdpZKTkEnL7ksG5r8Tx7FRxhR+wY6Gw@mail.gmail.com>
Subject: Re: [PATCH] kasan: record timestamp of memory allocation/free
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Serebryany <kcc@google.com>, Pekka Enberg <penberg@kernel.org>, Steven Rostedt <rostedt@goodmis.org>

drop dead email address

On Wed, May 2, 2018 at 1:12 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, May 2, 2018 at 12:58 PM, Tetsuo Handa
> <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> syzbot is reporting many refcount/use-after-free bugs along with flood of
>> memory allocation fault injection messages. Showing timestamp of memory
>> allocation/free would help narrowing down kernel messages to examine.
>>
>> Revive timestamp field which was removed by commit cd11016e5f5212c1
>> ("mm, kasan: stackdepot implementation. Enable stackdepot for SLAB").
>
> Hi Tetsuo,
>
> Header real estate is very expensive as it directly contributes to
> KASAN memory overhead. We dropped time on purpose to keep header 16
> bytes. This doubles it to 32 bytes per heap object. Before we start
> putting more stuff  in there, we need to move free-related meta data
> into object itself (as it's not used after free) as it was before.
>
> There is also this improvement that also has plans on any spare space in header:
> https://bugzilla.kernel.org/show_bug.cgi?id=198437
> I would say that rcu_call stack is more important as actual free stack
> is usually meaningless for async-freed objects.
>
>
>> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Cc: Alexander Potapenko <glider@google.com>
>> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Pekka Enberg <penberg@kernel.org>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Andrey Konovalov <adech.fo@gmail.com>
>> Cc: Dmitry Vyukov <dvyukov@google.com>
>> Cc: Steven Rostedt <rostedt@goodmis.org>
>> Cc: Konstantin Serebryany <kcc@google.com>
>> Cc: Dmitry Chernenkov <dmitryc@google.com>
>> ---
>>  mm/kasan/kasan.c  | 1 +
>>  mm/kasan/kasan.h  | 1 +
>>  mm/kasan/report.c | 3 ++-
>>  3 files changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
>> index 135ce28..a336834 100644
>> --- a/mm/kasan/kasan.c
>> +++ b/mm/kasan/kasan.c
>> @@ -457,6 +457,7 @@ static inline depot_stack_handle_t save_stack(gfp_t flags)
>>  static inline void set_track(struct kasan_track *track, gfp_t flags)
>>  {
>>         track->pid = current->pid;
>> +       track->when = jiffies;
>>         track->stack = save_stack(flags);
>>  }
>>
>> diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
>> index c12dcfd..0e4951b 100644
>> --- a/mm/kasan/kasan.h
>> +++ b/mm/kasan/kasan.h
>> @@ -77,6 +77,7 @@ struct kasan_global {
>>  struct kasan_track {
>>         u32 pid;
>>         depot_stack_handle_t stack;
>> +       unsigned long when;
>>  };
>>
>>  struct kasan_alloc_meta {
>> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
>> index 5c169aa..062c8ae 100644
>> --- a/mm/kasan/report.c
>> +++ b/mm/kasan/report.c
>> @@ -183,7 +183,8 @@ static void kasan_end_report(unsigned long *flags)
>>
>>  static void print_track(struct kasan_track *track, const char *prefix)
>>  {
>> -       pr_err("%s by task %u:\n", prefix, track->pid);
>> +       pr_err("%s by task %u (%lu jiffies ago):\n", prefix, track->pid,
>> +              jiffies - track->when);
>>         if (track->stack) {
>>                 struct stack_trace trace;
>>
>> --
>> 1.8.3.1
>>
