Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 999178D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:27:11 -0400 (EDT)
Received: by yib2 with SMTP id 2so179580yib.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 12:27:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110324192247.GA5477@elte.hu>
References: <alpine.DEB.2.00.1103221635400.4521@tiger>
	<20110324142146.GA11682@elte.hu>
	<alpine.DEB.2.00.1103240940570.32226@router.home>
	<AANLkTikb8rtSX5hQG6MQF4quymFUuh5Tw97TcpB0YfwS@mail.gmail.com>
	<20110324172653.GA28507@elte.hu>
	<20110324185258.GA28370@elte.hu>
	<alpine.LFD.2.00.1103242005530.31464@localhost6.localdomain6>
	<20110324192247.GA5477@elte.hu>
Date: Thu, 24 Mar 2011 21:27:09 +0200
Message-ID: <AANLkTinBwM9egao496WnaNLAPUxhMyJmkusmxt+ARtnV@mail.gmail.com>
Subject: Re: [boot crash #2] Re: [GIT PULL] SLAB changes for v2.6.39-rc1
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Thomas Gleixner <tglx@linutronix.de>, Christoph Lameter <cl@linux.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 24, 2011 at 9:22 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Thomas Gleixner <tglx@linutronix.de> wrote:
>
>> On Thu, 24 Mar 2011, Ingo Molnar wrote:
>> > RIP: 0010:[<ffffffff810570a9>] =A0[<ffffffff810570a9>] get_next_timer_=
interrupt+0x119/0x260
>>
>> That's a typical timer crash, but you were unable to debug it with
>> debugobjects because commit d3f661d6 broke those.
>>
>> Christoph, debugobjects do not need to run with interupts
>> disabled. And just because they were in that section to keep all the
>> debug stuff together does not make an excuse for not looking at the
>> code and just slopping it into some totally unrelated ifdef along with
>> a completely bogus comment.
>>
>> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
>> ---
>> =A0mm/slub.c | =A0 =A04 ++--
>> =A01 file changed, 2 insertions(+), 2 deletions(-)
>>
>> Index: linux-2.6/mm/slub.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- linux-2.6.orig/mm/slub.c
>> +++ linux-2.6/mm/slub.c
>> @@ -849,11 +849,11 @@ static inline void slab_free_hook(struct
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_save(flags);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 kmemcheck_slab_free(s, x, s->objsize);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 debug_check_no_locks_freed(x, s->objsize);
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (!(s->flags & SLAB_DEBUG_OBJECTS))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 debug_check_no_obj_freed(x, s-=
>objsize);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_restore(flags);
>> =A0 =A0 =A0 }
>> =A0#endif
>> + =A0 =A0 if (!(s->flags & SLAB_DEBUG_OBJECTS))
>> + =A0 =A0 =A0 =A0 =A0 =A0 debug_check_no_obj_freed(x, s->objsize);
>
> Thanks, this did the trick!
>
> Tested-by: Ingo Molnar <mingo@elte.hu>
>
> With this fix i got the warning below - pinpointing a net/bluetooth/hci_c=
ore.c
> timer bug.

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
