Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 8E3786B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 10:08:11 -0500 (EST)
Received: by vbnl22 with SMTP id l22so503874vbn.14
        for <linux-mm@kvack.org>; Thu, 12 Jan 2012 07:08:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOtvUMfmSrotCGn-51SC3eiQU=xK4C_Trh+8FEfTGOJcGUgVag@mail.gmail.com>
References: <1326276668-19932-1-git-send-email-mgorman@suse.de>
	<1326276668-19932-3-git-send-email-mgorman@suse.de>
	<CAOtvUMfmSrotCGn-51SC3eiQU=xK4C_Trh+8FEfTGOJcGUgVag@mail.gmail.com>
Date: Thu, 12 Jan 2012 17:08:10 +0200
Message-ID: <CAOtvUMeL19942umZH22THGU-TQbnjRfxz-JLdY_wdWPN7ZNy5Q@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: page allocator: Do not drain per-cpu lists via
 IPI from page allocator context
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Miklos Szeredi <mszeredi@novell.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Greg KH <gregkh@suse.de>, Gong Chen <gong.chen@intel.com>

On Thu, Jan 12, 2012 at 4:51 PM, Gilad Ben-Yossef <gilad@benyossef.com> wro=
te:
> On Wed, Jan 11, 2012 at 12:11 PM, Mel Gorman <mgorman@suse.de> wrote:
> <SNIP>
>> Rather than making it safe to call get_online_cpus() from the page
>> allocator, this patch simply removes the page allocator call to
>> drain_all_pages(). To avoid impacting high-order allocation success
>> rates, it still drains the local per-cpu lists for high-order
>> allocations that failed. As a side effect, this reduces the number
>> of IPIs sent during low memory situations.
>>
>> Signed-off-by: Mel Gorman <mgorman@suse.de>
>> ---
>> =A0mm/page_alloc.c | =A0 16 ++++++++++++----
>> =A01 files changed, 12 insertions(+), 4 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 2b8ba3a..b6df6fc 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1119,7 +1119,9 @@ void drain_local_pages(void *arg)
>> =A0*/
>> =A0void drain_all_pages(void)
>> =A0{
>> + =A0 =A0 =A0 get_online_cpus();
>> =A0 =A0 =A0 =A0on_each_cpu(drain_local_pages, NULL, 1);
>> + =A0 =A0 =A0 put_online_cpus();
>> =A0}
>>
>> =A0#ifdef CONFIG_HIBERNATION
>> @@ -1982,11 +1984,17 @@ retry:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0migratetype);
>>
>> =A0 =A0 =A0 =A0/*
>> - =A0 =A0 =A0 =A0* If an allocation failed after direct reclaim, it coul=
d be because
>> - =A0 =A0 =A0 =A0* pages are pinned on the per-cpu lists. Drain them and=
 try again
>> + =A0 =A0 =A0 =A0* If a high-order allocation failed after direct reclai=
m, there is a
>> + =A0 =A0 =A0 =A0* possibility that it is because the necessary buddies =
have been
>> + =A0 =A0 =A0 =A0* freed to the per-cpu list. Drain the local list and t=
ry again.
>> + =A0 =A0 =A0 =A0* drain_all_pages is not used because it is unsafe to c=
all
>> + =A0 =A0 =A0 =A0* get_online_cpus from this context as it is possible t=
hat kthreadd
>> + =A0 =A0 =A0 =A0* would block during thread creation and the cost of se=
nding storms
>> + =A0 =A0 =A0 =A0* of IPIs in low memory conditions is quite high.
>> =A0 =A0 =A0 =A0 */
>> - =A0 =A0 =A0 if (!page && !drained) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_all_pages();
>> + =A0 =A0 =A0 if (!page && order && !drained) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_pages(get_cpu());
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_cpu();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0drained =3D true;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto retry;
>> =A0 =A0 =A0 =A0}
>> --
>> 1.7.3.4
>>
>
> I very much like the judo like quality of relying on the fact that in
> memory pressure conditions most
> of the cpus will end up in the direct reclaim path to drain them all
> without IPIs.
>
> What I can't figure out is why we don't need =A0get/put_online_cpus()
> pair around each and every call
> to on_each_cpu everywhere? and if we do, perhaps making it a part of
> on_each_cpu is the way to go?
>
> Something like:
>
> diff --git a/kernel/smp.c b/kernel/smp.c
> index f66a1b2..cfa3882 100644
> --- a/kernel/smp.c
> +++ b/kernel/smp.c
> @@ -691,11 +691,15 @@ void on_each_cpu(void (*func) (void *info), void
> *info, int wait)
> =A0{
> =A0 =A0 =A0 =A0unsigned long flags;
>
> + =A0 =A0 =A0 BUG_ON(in_atomic());
> +
> + =A0 =A0 =A0 get_online_cpus();
> =A0 =A0 =A0 =A0preempt_disable();
> =A0 =A0 =A0 =A0smp_call_function(func, info, wait);
> =A0 =A0 =A0 =A0local_irq_save(flags);
> =A0 =A0 =A0 =A0func(info);
> =A0 =A0 =A0 =A0local_irq_restore(flags);
> =A0 =A0 =A0 =A0preempt_enable();
> + =A0 =A0 =A0 put_online_cpus();
> =A0}
> =A0EXPORT_SYMBOL(on_each_cpu);
>
> Does that makes?

Well, it dies on boot (after adding the needed include file), so it's
obviously wrong, but I'm still guessing
other users of on_each_cpu will need an =A0get/put_online_cpus() wrapper to=
o.

Maybe -

on_each_cpu(...)
{
  get_online_cpus();
  __on_each_cpu(...);
  put_online_cpus();
}

We'll need to audit all callers.

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
