Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03E736B0760
	for <linux-mm@kvack.org>; Sat, 10 Nov 2018 19:26:56 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id l7-v6so14324009qkd.5
        for <linux-mm@kvack.org>; Sat, 10 Nov 2018 16:26:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r47-v6si9530039qte.220.2018.11.10.16.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Nov 2018 16:26:55 -0800 (PST)
Subject: Re: [RFC PATCH 01/12] locking/lockdep: Rework
 lockdep_set_novalidate_class()
References: <1541709268-3766-1-git-send-email-longman@redhat.com>
 <1541709268-3766-2-git-send-email-longman@redhat.com>
 <20181110141458.GE3339@worktop.programming.kicks-ass.net>
From: Waiman Long <longman@redhat.com>
Message-ID: <bc8ef8ae-c673-f4ae-fab1-3fe1bc884087@redhat.com>
Date: Sat, 10 Nov 2018 19:26:51 -0500
MIME-Version: 1.0
In-Reply-To: <20181110141458.GE3339@worktop.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 11/10/2018 09:14 AM, Peter Zijlstra wrote:
> On Thu, Nov 08, 2018 at 03:34:17PM -0500, Waiman Long wrote:
>> The current lockdep_set_novalidate_class() implementation is like
>> a hack. It assigns a special class key for that lock and calls
>> lockdep_init_map() twice.
> Ideally it would go away.. it is not thing that should be used.

Yes, I agree. Right now, lockdep_set_novalidate_class() is used in

drivers/base/core.c:=C2=A0=C2=A0=C2=A0 lockdep_set_novalidate_class(&dev-=
>mutex);
drivers/md/bcache/btree.c:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 lockdep_set_nova=
lidate_class(&b->lock);
drivers/md/bcache/btree.c:=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0
lockdep_set_novalidate_class(&b->write_lock);

Do you know the history behind making them novalidate?

>
>> This patch changes the implementation to make it more general so that
>> it can be used by other special lock class types. A new "type" field
>> is added to both the lockdep_map and lock_class structures.
>>
>> The new field can now be used to designate a lock and a class object
>> as novalidate. The lockdep_set_novalidate_class() call, however, shoul=
d
>> be called before lock initialization which calls lockdep_init_map().
> I don't really feel like this is something that should be made easier o=
r
> better.

I am not saying that this patch make lockdep_set_novalidate_class()
easier to use. It is that terminal locks will share similar code path
and so I rework it so that they can checked together in one test instead
of 2 separate tests.

>> @@ -102,6 +100,8 @@ struct lock_class {
>>  	int				name_version;
>>  	const char			*name;
>> =20
>> +	unsigned int			flags;
>> +
>>  #ifdef CONFIG_LOCK_STAT
>>  	unsigned long			contention_point[LOCKSTAT_POINTS];
>>  	unsigned long			contending_point[LOCKSTAT_POINTS];
> Esp. not at the cost of growing the data structures.
>
>

I did reduce the size by 16 bytes for 64-bit architecture in my previous
lockdep patch. Now I claw back 8 bytes for this new functionality.

Cheers,
Longman
