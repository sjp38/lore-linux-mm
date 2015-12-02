Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id AEE5D6B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 04:04:20 -0500 (EST)
Received: by wmww144 with SMTP id w144so205633750wmw.1
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 01:04:20 -0800 (PST)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTPS id t82si976371wmg.38.2015.12.02.01.04.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Dec 2015 01:04:19 -0800 (PST)
Message-ID: <565EB409.3090202@arm.com>
Date: Wed, 02 Dec 2015 09:04:09 +0000
From: Vladimir Murzin <vladimir.murzin@arm.com>
MIME-Version: 1.0
Subject: Re: [BISECTED] rcu_sched self-detected stall since 3.17
References: <564F3DCA.1080907@arm.com> <20151201130404.GL3816@twins.programming.kicks-ass.net>
In-Reply-To: <20151201130404.GL3816@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, neilb@suse.de, oleg@redhat.com, mark.rutland@arm.com, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On 01/12/15 13:04, Peter Zijlstra wrote:
> Sorry for the delay and thanks for the reminder!
>=20
> On Fri, Nov 20, 2015 at 03:35:38PM +0000, Vladimir Murzin wrote:
>> commit 743162013d40ca612b4cb53d3a200dff2d9ab26e
>> Author: NeilBrown <neilb@suse.de>
>> Date:   Mon Jul 7 15:16:04 2014 +1000
>>
>>     sched: Remove proliferation of wait_on_bit() action functions
>>
>> The only change I noticed is from (mm/filemap.c)
>>
>> =09io_schedule();
>> =09fatal_signal_pending(current)
>>
>> to (kernel/sched/wait.c)
>>
>> =09signal_pending_state(current->state, current)
>> =09io_schedule();
>>
>> and if I apply following diff I don't see stalls anymore.
>>
>> diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
>> index a104879..2d68cdb 100644
>> --- a/kernel/sched/wait.c
>> +++ b/kernel/sched/wait.c
>> @@ -514,9 +514,10 @@ EXPORT_SYMBOL(bit_wait);
>>
>>  __sched int bit_wait_io(void *word)
>>  {
>> +       io_schedule();
>> +
>>         if (signal_pending_state(current->state, current))
>>                 return 1;
>> -       io_schedule();
>>         return 0;
>>  }
>>  EXPORT_SYMBOL(bit_wait_io);
>>
>> Any ideas why it might happen and why diff above helps?
>=20
> Yes, the code as presented is simply wrong. And in fact most of the code
> it replaced was of the right form (with a few exceptions which would
> indeed have been subject to the same problem you've observed.
>=20
> Note how the late:
>=20
>   - cifs_sb_tcon_pending_wait
>   - fscache_wait_bit_interruptible
>   - sleep_on_page_killable
>   - wait_inquiry
>   - key_wait_bit_intr
>=20
> All check the signal state _after_ calling schedule().
>=20
> As opposed to:
>=20
>   - gfs2_journalid_wait
>=20
> which follows the broken pattern.
>=20
> Further notice that most expect a return of -EINTR, which also seems
> correct given that this is a signal, those that do not return -EINTR
> only check for a !0 return value so would work equally well with -EINTR.
>=20
> The reason this is broken is that schedule() will no-op when there is a
> pending signal, while raising a signal will also issue a wakeup.
>=20

Glad to hear confirmation on a problem. Thanks for detailed answer!

> Thus the right thing to do is check for the signal state after, that way
> you handle both cases:
>=20
>  - calling schedule() with a signal pending
>  - receiving a signal while sleeping
>=20
> As such, I would propose the below patch. Oleg, do you concur?
>=20
> ---
> Subject: sched,wait: Fix signal handling in bit wait helpers
>=20
> Vladimir reported getting RCU stall warnings and bisected it back to
> commit 743162013d40. That commit inadvertently reversed the calls to
> schedule() and signal_pending(), thereby not handling the case where the
> signal receives while we sleep.
>=20
> Fixes: 743162013d40 ("sched: Remove proliferation of wait_on_bit() action=
 functions")
> Fixes: cbbce8220949 ("SCHED: add some "wait..on_bit...timeout()" interfac=
es.")
> Reported-by: Vladimir Murzin <vladimir.murzin@arm.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  kernel/sched/wait.c | 16 ++++++++--------
>  1 file changed, 8 insertions(+), 8 deletions(-)
>=20
> diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
> index 052e02672d12..f10bd873e684 100644
> --- a/kernel/sched/wait.c
> +++ b/kernel/sched/wait.c
> @@ -583,18 +583,18 @@ EXPORT_SYMBOL(wake_up_atomic_t);
> =20
>  __sched int bit_wait(struct wait_bit_key *word)
>  {
> -=09if (signal_pending_state(current->state, current))
> -=09=09return 1;
>  =09schedule();
> +=09if (signal_pending(current))
> +=09=09return -EINTR;
>  =09return 0;
>  }
>  EXPORT_SYMBOL(bit_wait);
> =20
>  __sched int bit_wait_io(struct wait_bit_key *word)
>  {
> -=09if (signal_pending_state(current->state, current))
> -=09=09return 1;
>  =09io_schedule();
> +=09if (signal_pending(current))
> +=09=09return -EINTR;
>  =09return 0;
>  }
>  EXPORT_SYMBOL(bit_wait_io);
> @@ -602,11 +602,11 @@ EXPORT_SYMBOL(bit_wait_io);
>  __sched int bit_wait_timeout(struct wait_bit_key *word)
>  {
>  =09unsigned long now =3D READ_ONCE(jiffies);
> -=09if (signal_pending_state(current->state, current))
> -=09=09return 1;
>  =09if (time_after_eq(now, word->timeout))
>  =09=09return -EAGAIN;
>  =09schedule_timeout(word->timeout - now);
> +=09if (signal_pending(current))
> +=09=09return -EINTR;
>  =09return 0;
>  }
>  EXPORT_SYMBOL_GPL(bit_wait_timeout);
> @@ -614,11 +614,11 @@ EXPORT_SYMBOL_GPL(bit_wait_timeout);
>  __sched int bit_wait_io_timeout(struct wait_bit_key *word)
>  {
>  =09unsigned long now =3D READ_ONCE(jiffies);
> -=09if (signal_pending_state(current->state, current))
> -=09=09return 1;
>  =09if (time_after_eq(now, word->timeout))
>  =09=09return -EAGAIN;
>  =09io_schedule_timeout(word->timeout - now);
> +=09if (signal_pending(current))
> +=09=09return -EINTR;
>  =09return 0;
>  }
>  EXPORT_SYMBOL_GPL(bit_wait_io_timeout);
>=20

I run it overnight on top of 4.3 and didn't see stalls. So in case it helps

Tested-by: Vladimir Murzin <vladimir.murzin@arm.com>

Cheers
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
