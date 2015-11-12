Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id E15CC6B0253
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 16:28:32 -0500 (EST)
Received: by lbbkw15 with SMTP id kw15so43114999lbb.0
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 13:28:32 -0800 (PST)
Received: from mail-lf0-x22a.google.com (mail-lf0-x22a.google.com. [2a00:1450:4010:c07::22a])
        by mx.google.com with ESMTPS id jb6si11406140lbc.123.2015.11.12.13.28.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Nov 2015 13:28:29 -0800 (PST)
Received: by lfdo63 with SMTP id o63so41853319lfd.2
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 13:28:28 -0800 (PST)
From: Arkadiusz =?utf-8?q?Mi=C5=9Bkiewicz?= <arekm@maven.pl>
Subject: Re: memory reclaim problems on fs usage
Date: Thu, 12 Nov 2015 22:28:26 +0100
References: <201511102313.36685.arekm@maven.pl> <201511120706.10739.arekm@maven.pl> <56449E44.7020407@I-love.SAKURA.ne.jp>
In-Reply-To: <56449E44.7020407@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201511122228.26399.arekm@maven.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org, xfs@oss.sgi.com

On Thursday 12 of November 2015, Tetsuo Handa wrote:
> On 2015/11/12 15:06, Arkadiusz Mi=C5=9Bkiewicz wrote:
> > On Wednesday 11 of November 2015, Tetsuo Handa wrote:
> >> Arkadiusz Mi?kiewicz wrote:
> >>> This patch is against which tree? (tried 4.1, 4.2 and 4.3)
> >>=20
> >> Oops. Whitespace-damaged. This patch is for vanilla 4.1.2.
> >> Reposting with one condition corrected.
> >=20
> > Here is log:
> >=20
> > http://ixion.pld-linux.org/~arekm/log-mm-1.txt.gz
> >=20
> > Uncompresses is 1.4MB, so not posting here.
>=20
> Thank you for the log. The result is unexpected for me.

[...]

>=20
> vmstat_update() and submit_flushes() remained pending for about 110
> seconds. If xlog_cil_push_work() were spinning inside GFP_NOFS allocation,
> it should be reported as MemAlloc: traces, but no such lines are recorded.
> I don't know why xlog_cil_push_work() did not call schedule() for so long.
> Anyway, applying
> http://lkml.kernel.org/r/20151111160336.GD1432@dhcp22.suse.cz should solve
> vmstat_update() part.

To apply that patch on top of 4.1.13 I also had to apply patches listed bel=
ow.=20

So in summary appllied:
http://sprunge.us/GYBb
http://sprunge.us/XWUX
http://sprunge.us/jZjV

(Could try http://lkml.kernel.org/r/20151111160336.GD1432@dhcp22.suse.cz on=
ly=20
if there is version for 4.1 tree somewhere)

commit 0aaa29a56e4fb0fc9e24edb649e2733a672ca099
Author: Mel Gorman <mgorman@techsingularity.net>
Date:   Fri Nov 6 16:28:37 2015 -0800

    mm, page_alloc: reserve pageblocks for high-order atomic allocations on=
=20
demand

commit 974a786e63c96a2401a78ddba926f34c128474f1
Author: Mel Gorman <mgorman@techsingularity.net>
Date:   Fri Nov 6 16:28:34 2015 -0800

    mm, page_alloc: remove MIGRATE_RESERVE

commit c2d42c16ad83006a706d83e51a7268db04af733a
Author: Andrew Morton <akpm@linux-foundation.org>
Date:   Thu Nov 5 18:48:43 2015 -0800

    mm/vmstat.c: uninline node_page_state()

commit 176bed1de5bf977938cad26551969eca8f0883b1
Author: Linus Torvalds <torvalds@linux-foundation.org>
Date:   Thu Oct 15 13:01:50 2015 -0700

    vmstat: explicitly schedule per-cpu work on the CPU we need it to run on


[...]

>=20
> Well, what steps should we try next for isolating the problem?
>=20
> Swap is not used at all. Turning off swap might help.

Disabled swap.

>=20
> [ 8633.753574] Free swap  =3D 117220800kB
> [ 8633.753576] Total swap =3D 117220820kB
>=20
> Turning off perf might also help.
>=20
> [ 5001.394085] perf interrupt took too long (2505 > 2495), lowering
> kernel.perf_event_max_sample_rate to 50100

Didn't find a way to disable perf. kernel .config option gets autoenabled b=
y=20
some dependency. So left this untouched.


With mentioned patches I wasn't able to reproduce memory allocation problem=
=20
(still trying though).=20

Current debug log: http://ixion.pld-linux.org/~arekm/log-mm-2.txt.gz

=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
