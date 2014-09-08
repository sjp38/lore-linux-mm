Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id B3D356B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 05:39:55 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id q5so2278864wiv.12
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 02:39:55 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id cv10si13096816wib.43.2014.09.08.02.39.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Sep 2014 02:39:54 -0700 (PDT)
Date: Mon, 8 Sep 2014 11:39:49 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v4 2/2] ksm: provide support to use deferrable timers for
 scanner thread
Message-ID: <20140908093949.GZ6758@twins.programming.kicks-ass.net>
References: <1408536628-29379-1-git-send-email-cpandya@codeaurora.org>
 <1408536628-29379-2-git-send-email-cpandya@codeaurora.org>
 <alpine.LSU.2.11.1408272258050.10518@eggly.anvils>
 <20140903095815.GK4783@worktop.ger.corp.intel.com>
 <alpine.LSU.2.11.1409080023100.1610@eggly.anvils>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="82wJsBn+m3vGehqm"
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1409080023100.1610@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Chintan Pandya <cpandya@codeaurora.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-arm-msm@vger.kernel.org, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, John Stultz <john.stultz@linaro.org>, Ingo Molnar <mingo@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>


--82wJsBn+m3vGehqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 08, 2014 at 01:25:36AM -0700, Hugh Dickins wrote:
> Well, yes, but... how do we know when there is no more work to do?

Yeah, I figured that out _after_ I send that email..

> Thomas has given reason why KSM might simply fail to do its job if we
> rely on the deferrable timer.  So I've tried another approach, patch
> below; but I do not expect you to jump for joy at the sight of it!

Indeed :/

> I've tried to minimize the offensive KSM hook in context_switch().
> Why place it there, rather than do something near profile_tick() or
> account_process_tick()?  Because KSM is aware of mms not tasks, and
> context_switch() should have the next mm cachelines hot (if not, a
> slight regrouping in mm_struct should do it); whereas I can find
> no reference whatever to mm_struct in kernel/time, so hooking to
> KSM from there would drag in another few cachelines every tick.
>=20
> (Another approach would be to set up KSM hint faulting, along the
> lines of NUMA hint faulting.  Not a path I'm keen to go down.)
>=20
> I'm not thrilled with this patch, I think it's somewhat defective
> in several ways.  But maybe in practice it will prove good enough,
> and if so then I'd rather not waste effort on complicating it.
>=20
> My own testing is not realistic, nor representative of real KSM users;
> and I have no idea what values of pages_to_scan and sleep_millisecs
> people really use (and those may make quite a difference to how
> well it works).
>=20
> Chintan, even if the scheduler guys turn out to hate it, please would
> you give the patch below a try, to see how well it works in your
> environment, whether it seems to go better or worse than your own patch.
>=20
> If it works well enough for you, maybe we can come up with ideas to
> make it more palatable.  I do think your issue is an important one
> to fix, one way or another.
>=20
> Thanks,
> Hugh
>=20
> [PATCH] ksm: avoid periodic wakeup while mergeable mms are quiet
>=20
> Description yet to be written!
>=20
> Reported-by: Chintan Pandya <cpandya@codeaurora.org>
> Not-Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>=20
>  include/linux/ksm.h   |   14 +++++++++++
>  include/linux/sched.h |    1=20
>  kernel/sched/core.c   |    9 ++++++-
>  mm/ksm.c              |   50 ++++++++++++++++++++++++++++------------
>  4 files changed, 58 insertions(+), 16 deletions(-)
>=20
> --- 3.17-rc4/include/linux/ksm.h	2014-03-30 20:40:15.000000000 -0700
> +++ linux/include/linux/ksm.h	2014-09-07 11:54:41.528003316 -0700

> @@ -87,6 +96,11 @@ static inline void ksm_exit(struct mm_st
>  {
>  }
> =20
> +static inline wait_queue_head_t *ksm_switch(struct mm_struct *mm)

s/ksm_switch/__&/

> +{
> +	return NULL;
> +}
> +
>  static inline int PageKsm(struct page *page)
>  {
>  	return 0;

> --- 3.17-rc4/kernel/sched/core.c	2014-08-16 16:00:54.062189063 -0700
> +++ linux/kernel/sched/core.c	2014-09-07 11:54:41.528003316 -0700

> @@ -2304,6 +2305,7 @@ context_switch(struct rq *rq, struct tas
>  	       struct task_struct *next)
>  {
>  	struct mm_struct *mm, *oldmm;
> +	wait_queue_head_t *wake_ksm =3D NULL;
> =20
>  	prepare_task_switch(rq, prev, next);
> =20
> @@ -2320,8 +2322,10 @@ context_switch(struct rq *rq, struct tas
>  		next->active_mm =3D oldmm;
>  		atomic_inc(&oldmm->mm_count);
>  		enter_lazy_tlb(oldmm, next);
> -	} else
> +	} else {
>  		switch_mm(oldmm, mm, next);
> +		wake_ksm =3D ksm_switch(mm);

Is this the right mm? We've just switched the stack, so we're looking at
next->mm when we switched away from current. That might not exist
anymore.

> +	}
> =20
>  	if (!prev->mm) {
>  		prev->active_mm =3D NULL;
> @@ -2348,6 +2352,9 @@ context_switch(struct rq *rq, struct tas
>  	 * frame will be invalid.
>  	 */
>  	finish_task_switch(this_rq(), prev);
> +
> +	if (wake_ksm)
> +		wake_up_interruptible(wake_ksm);
>  }

Quite horrible for sure. I really hate seeing KSM cruft all the way down
here. Can't we create a new (timer) infrastructure that does the right
thing? Surely this isn't the only such case.

I know both RCU and some NOHZ_FULL muck already track when the system is
completely idle. This is yet another case of that.

--82wJsBn+m3vGehqm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJUDXllAAoJEHZH4aRLwOS6XXgP/3S0AwWq3WaXgJAD4RwYaBh6
FFLgz+/Hl/QeBSDJXHPTt96D4ppMTeke4vWHx82dfagPcQS/8Tg7+dSQCkdRVaiG
iXWtGfuNS/oFJfIN3oOjAfhFhmlPvpgB+QswUm3xQ3ftZqsnlL+XoaDijrOyHsis
Qr7h4K95uU4iN/gvdfsjUmdoxifIZt8h/FHWX9F8NuZWYaWNlLQBsptaIqHLkIWg
so2gNxa3os2nJToMQtcMCNFkyZJvsMbf/kPBKzIJjX+eyNCuN2kVUObHFeSi7OLm
ACOgao/kTdWswz+tv+rOJ+gxLvAJ1ErPyKx4PuzDrDmXmWT/OI4ADPjW2oA3nbGX
PIryZuI5wXMRGFQDxyaGkEJqFKYiPDETiBCNDiDsja/m6uWeO/wcB2qNxgbQsaNx
McBftBKhUvpRUWdOIdadaat6Fx7xRnGJ78ZQ1dGqf3jk8Mr9iyxGuU6BcmNY3nEc
NyptRyCoQR/9H2EExMl1rukjsD3uTAOXgH++UJaLeLkqnWOMwU+r8NC0AUmOwOtg
sXRvTJDjoDp/w/nLYqRgCgRiAr7K/Yy+3SFdvdadHzt70/lxcOCtIp5NxjYRY6AR
0zPOwC5KlUO0LOIMaDlbdoKDhwzUISFCaNi9E08e4mwffw5LsuY4j3okJV6REW79
DZ72OzY8UTDchPWN6FUR
=A+t6
-----END PGP SIGNATURE-----

--82wJsBn+m3vGehqm--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
