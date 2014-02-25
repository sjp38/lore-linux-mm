Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 125B36B00A0
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 18:16:33 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id cc10so1446674wib.17
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:16:33 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si9234034wix.2.2014.02.25.15.16.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 15:16:32 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH] ksm: Expose configuration via sysctl
From: Alexander Graf <agraf@suse.de>
In-Reply-To: <20140225171940.GS6835@laptop.programming.kicks-ass.net>
Date: Wed, 26 Feb 2014 07:16:17 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <5E6DB7F9-41E0-4DCC-A14B-49E2F4134A1C@suse.de>
References: <1393284484-27637-1-git-send-email-agraf@suse.de> <20140225171528.GJ4407@cmpxchg.org> <20140225171940.GS6835@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Hugh Dickins <hughd@google.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Andrea Arcangeli <aarcange@redhat.com>, "kay@vrfy.org" <kay@vrfy.org>



>> Am 26.02.2014 um 01:19 schrieb Peter Zijlstra <peterz@infradead.org>:
>>=20
>>> On Tue, Feb 25, 2014 at 12:15:28PM -0500, Johannes Weiner wrote:
>>> On Tue, Feb 25, 2014 at 12:28:04AM +0100, Alexander Graf wrote:
>>> Configuration of tunables and Linux virtual memory settings has traditio=
nally
>>> happened via sysctl. Thanks to that there are well established ways to m=
ake
>>> sysctl configuration bits persistent (sysctl.conf).
>>>=20
>>> KSM introduced a sysfs based configuration path which is not covered by u=
ser
>>> space persistent configuration frameworks.
>>>=20
>>> In order to make life easy for sysadmins, this patch adds all access to a=
ll
>>> KSM tunables via sysctl as well. That way sysctl.conf works for KSM as w=
ell,
>>> giving us a streamlined way to make KSM configuration persistent.
>>>=20
>>> Reported-by: Sasche Peilicke <speilicke@suse.com>
>>> Signed-off-by: Alexander Graf <agraf@suse.de>
>>> ---
>>> kernel/sysctl.c |   10 +++++++
>>> mm/ksm.c        |   78 +++++++++++++++++++++++++++++++++++++++++++++++++=
++++++
>>> 2 files changed, 88 insertions(+), 0 deletions(-)
>>>=20
>>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>>> index 332cefc..2169a00 100644
>>> --- a/kernel/sysctl.c
>>> +++ b/kernel/sysctl.c
>>> @@ -217,6 +217,9 @@ extern struct ctl_table random_table[];
>>> #ifdef CONFIG_EPOLL
>>> extern struct ctl_table epoll_table[];
>>> #endif
>>> +#ifdef CONFIG_KSM
>>> +extern struct ctl_table ksm_table[];
>>> +#endif
>>>=20
>>> #ifdef HAVE_ARCH_PICK_MMAP_LAYOUT
>>> int sysctl_legacy_va_layout;
>>> @@ -1279,6 +1282,13 @@ static struct ctl_table vm_table[] =3D {
>>>   },
>>>=20
>>> #endif /* CONFIG_COMPACTION */
>>> +#ifdef CONFIG_KSM
>>> +    {
>>> +        .procname    =3D "ksm",
>>> +        .mode        =3D 0555,
>>> +        .child        =3D ksm_table,
>>> +    },
>>> +#endif
>>=20
>> ksm can be a module, so this won't work.
>>=20
>> Can we make those controls proper module parameters instead?
>=20
> You can do dynamic sysctl registration and removal. Its its own little
> filesystem of sorts.

Hm. Doesn't this open another big can of worms? If we have ksm as a module a=
nd our sysctl helpers try to enable ksm on boot, they may not be able to bec=
ause the module hasn't been loaded yet.

So in that case, we want to always register the sysctl and dynamically load t=
he ksm module when the sysctl gets accessed - similar to how we can do stub d=
evices that load modiles, no?

Alex=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
