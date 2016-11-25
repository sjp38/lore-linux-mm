Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4D65C6B0038
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 12:40:50 -0500 (EST)
Received: by mail-lf0-f71.google.com with SMTP id h201so28750467lfg.5
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 09:40:50 -0800 (PST)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id g84si21177903lji.87.2016.11.25.09.40.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 09:40:48 -0800 (PST)
Received: by mail-lf0-x22d.google.com with SMTP id c13so55185638lfg.0
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 09:40:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2a6c133d-a42e-34ca-108c-b1399b939d65@virtuozzo.com>
References: <cover.1478632698.git.andreyknvl@google.com> <9df5bd889e1b980d84aa41e7010e622005fd0665.1478632698.git.andreyknvl@google.com>
 <2a6c133d-a42e-34ca-108c-b1399b939d65@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 25 Nov 2016 18:40:27 +0100
Message-ID: <CACT4Y+YB1QBzzdBbPWrq6u2M3B7WuavHZn6KswJi0Qi2DhqDLA@mail.gmail.com>
Subject: Re: [PATCH 1/2] stacktrace: fix print_stack_trace printing timestamp twice
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrey Konovalov <andreyknvl@google.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@redhat.com>, Kostya Serebryany <kcc@google.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Nov 9, 2016 at 5:10 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> On 11/08/2016 10:37 PM, Andrey Konovalov wrote:
>> Right now print_stack_trace prints timestamp twice, the first time
>> it's done by printk when printing spaces, the second - by print_ip_sym.
>> As a result, stack traces in KASAN reports have double timestamps:
>> [   18.822232] Allocated by task 3838:
>> [   18.822232]  [   18.822232] [<ffffffff8107e236>] save_stack_trace+0x16/0x20
>> [   18.822232]  [   18.822232] [<ffffffff81509bd6>] save_stack+0x46/0xd0
>> [   18.822232]  [   18.822232] [<ffffffff81509e4b>] kasan_kmalloc+0xab/0xe0
>> ....
>>
>> Fix by calling printk only once.
>>
>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>
>
> Right, since commit 4bcc595ccd80 ("printk: reinstate KERN_CONT for printing continuation lines")
> printk requires KERN_CONT to continue log messages, and print_ip_sym() doesn't have it.
>
> After a small nit bellow fixed:
>         Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
>
>> ---
>>  kernel/stacktrace.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/kernel/stacktrace.c b/kernel/stacktrace.c
>> index b6e4c16..56f510f 100644
>> --- a/kernel/stacktrace.c
>> +++ b/kernel/stacktrace.c
>> @@ -14,13 +14,15 @@
>>  void print_stack_trace(struct stack_trace *trace, int spaces)
>>  {
>>       int i;
>> +     unsigned long ip;
>
> This can be inside for loop.
>>
>>       if (WARN_ON(!trace->entries))
>>               return;
>>
>>       for (i = 0; i < trace->nr_entries; i++) {
>> -             printk("%*c", 1 + spaces, ' ');
>> -             print_ip_sym(trace->entries[i]);
>> +             ip = trace->entries[i];
>> +             printk("%*c[<%p>] %pS\n", 1 + spaces, ' ',
>> +                             (void *) ip, (void *) ip);


There is another similar case in lockdep's print_lock:

print_lock_name(lock_classes + class_idx - 1);
printk(", at: ");
print_ip_sym(hlock->acquire_ip);

This used to be a single line, but now 3.

[  131.449807] swapper/2/0 is trying to acquire lock:
[  131.449859]  (&port_lock_key){-.-...}, at: [<c036a6dc>]
serial8250_console_write+0x108/0x134

vs:

[  337.270069] syz-executor/3125 is trying to acquire lock:
[  337.270069]  ([  337.270069] rtnl_mutex
){+.+.+.}[  337.270069] , at:
[  337.270069] [<ffffffff86b3d34c>] rtnl_lock+0x1c/0x20


printk(", at: "); requires KERN_CONT.
But should we add KERN_CONT to print_ip_sym instead of duplicating it
everywhere? Or add print_ip_sym_cont?



>>       }
>>  }
>>  EXPORT_SYMBOL_GPL(print_stack_trace);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
