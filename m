Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id F211B6B005A
	for <linux-mm@kvack.org>; Sun,  8 Jan 2012 11:04:21 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so2712921vbb.14
        for <linux-mm@kvack.org>; Sun, 08 Jan 2012 08:04:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120103142624.faf46d77.akpm@linux-foundation.org>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
	<1325499859-2262-2-git-send-email-gilad@benyossef.com>
	<20120103142624.faf46d77.akpm@linux-foundation.org>
Date: Sun, 8 Jan 2012 18:04:19 +0200
Message-ID: <CAOtvUMcx0etVbYWz_z66ns9NbU=rvRChQqc1YYYYNJjYmOUsoQ@mail.gmail.com>
Subject: Re: [PATCH v5 1/8] smp: Introduce a generic on_each_cpu_mask function
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Wed, Jan 4, 2012 at 12:26 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, =A02 Jan 2012 12:24:12 +0200
> Gilad Ben-Yossef <gilad@benyossef.com> wrote:
>
>> on_each_cpu_mask calls a function on processors specified my cpumask,
>> which may include the local processor.
>>
>> All the limitation specified in smp_call_function_many apply.
>>
>> ...
>>
>> --- a/include/linux/smp.h
>> +++ b/include/linux/smp.h
>> @@ -102,6 +102,13 @@ static inline void call_function_init(void) { }
>> =A0int on_each_cpu(smp_call_func_t func, void *info, int wait);
>>
>> =A0/*
>> + * Call a function on processors specified by mask, which might include
>> + * the local one.
>> + */
>> +void on_each_cpu_mask(const struct cpumask *mask, void (*func)(void *),
>> + =A0 =A0 =A0 =A0 =A0 =A0 void *info, bool wait);
>> +
>> +/*
>> =A0 * Mark the boot cpu "online" so that it can call console drivers in
>> =A0 * printk() and can access its per-cpu storage.
>> =A0 */
>> @@ -132,6 +139,15 @@ static inline int up_smp_call_function(smp_call_fun=
c_t func, void *info)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_enable(); =A0 =A0 =A0 =A0 =A0 =A0 =
\
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 0; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0\
>> =A0 =A0 =A0 })
>> +#define on_each_cpu_mask(mask, func, info, wait) \
>> + =A0 =A0 do { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (cpumask_test_cpu(0, (mask))) { =A0 =A0 =A0=
\
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_disable(); =A0 =A0 =
=A0 =A0 =A0 =A0\
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (func)(info); =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_enable(); =A0 =A0 =
=A0 =A0 =A0 =A0 \
>> + =A0 =A0 =A0 =A0 =A0 =A0 } =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
>> + =A0 =A0 } while (0)
>
> Why is the cpumask_test_cpu() call there? =A0It's hard to think of a
> reason why "mask" would specify any CPU other than "0" in a
> uniprocessor kernel.

As Michal already answered, because the current CPU might be not
specified in the mask, even on UP.

> If this code remains as-is, please add a comment here explaining this,
> so others don't wonder the same thing.

Comment added and will be included in V6.

Thanks for the review.

Gilad



--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"Unfortunately, cache misses are an equal opportunity pain provider."
-- Mike Galbraith, LKML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
