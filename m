Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 5611B6B026B
	for <linux-mm@kvack.org>; Sun, 15 Nov 2015 06:29:28 -0500 (EST)
Received: by lfdo63 with SMTP id o63so72978787lfd.2
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 03:29:27 -0800 (PST)
Received: from mail-lf0-x229.google.com (mail-lf0-x229.google.com. [2a00:1450:4010:c07::229])
        by mx.google.com with ESMTPS id dp2si21907113lbc.159.2015.11.15.03.29.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Nov 2015 03:29:26 -0800 (PST)
Received: by lfs39 with SMTP id 39so73139509lfs.3
        for <linux-mm@kvack.org>; Sun, 15 Nov 2015 03:29:26 -0800 (PST)
From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>
Subject: Re: memory reclaim problems on fs usage
Date: Sun, 15 Nov 2015 12:29:23 +0100
References: <201511102313.36685.arekm@maven.pl> <201511142140.38245.arekm@maven.pl> <201511151135.JGD81717.OFOOSMFJFQHVtL@I-love.SAKURA.ne.jp>
In-Reply-To: <201511151135.JGD81717.OFOOSMFJFQHVtL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201511151229.23312.arekm@maven.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: htejun@gmail.com, cl@linux.com, mhocko@suse.com, linux-mm@kvack.org, xfs@oss.sgi.com

On Sunday 15 of November 2015, Tetsuo Handa wrote:
> Arkadiusz Miskiewicz wrote:
> > > > vmstat_update() and submit_flushes() remained pending for about 110
> > > > seconds. If xlog_cil_push_work() were spinning inside GFP_NOFS
> > > > allocation, it should be reported as MemAlloc: traces, but no such
> > > > lines are recorded. I don't know why xlog_cil_push_work() did not
> > > > call schedule() for so long. Anyway, applying
> > > > http://lkml.kernel.org/r/20151111160336.GD1432@dhcp22.suse.cz should
> > > > solve vmstat_update() part.
> > >=20
> > > To apply that patch on top of 4.1.13 I also had to apply patches list=
ed
> > > below.
> > >=20
> > > So in summary appllied:
> > > http://sprunge.us/GYBb
> > > http://sprunge.us/XWUX
> > > http://sprunge.us/jZjV
> >=20
> > I've tried more to trigger "page allocation failure" with usual actions
> > that triggered it previously but couldn't reproduce. With these patches
> > applied it doesn't happen.
> >=20
> > Logs from my tests:
> >=20
> > http://ixion.pld-linux.org/~arekm/log-mm-3.txt.gz
> > http://ixion.pld-linux.org/~arekm/log-mm-4.txt.gz (with swap added)
>=20
> Good.
>=20
> vmstat_update() and submit_flushes() are no longer pending for long.
>=20
> log-mm-4.txt:Nov 14 16:40:08 srv kernel: [167753.393960]     pending:
> vmstat_shepherd, vmpressure_work_fn log-mm-4.txt:Nov 14 16:40:08 srv
> kernel: [167753.393984]     pending: submit_flushes [md_mod]
> log-mm-4.txt:Nov 14 16:41:08 srv kernel: [167813.439405]     pending:
> submit_flushes [md_mod] log-mm-4.txt:Nov 14 17:17:19 srv kernel:
> [169985.104806]     pending: vmstat_shepherd
>=20
> I think that the vmstat statistics now have correct values.
>=20
> > But are these patches solving the problem or just hiding it?
>=20
> Excuse me but I can't judge.
>
> If you are interested in monitoring how vmstat statistics are changing
> under stalled condition, you can try below patch.


Here is log with this and all previous patches applied:
http://ixion.pld-linux.org/~arekm/log-mm-5.txt.gz


>=20
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 35a46b4..3de3a14 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2794,8 +2794,7 @@ static int kmallocwd(void *unused)
>  	rcu_read_unlock();
>  	preempt_enable();
>  	show_workqueue_state();
> -	if (dump_target_pid <=3D 0)
> -		dump_target_pid =3D -pid;
> +	show_mem(0);
>  	/* Wait until next timeout duration. */
>  	schedule_timeout_interruptible(kmallocwd_timeout);
>  	if (memalloc_counter[index])


=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
