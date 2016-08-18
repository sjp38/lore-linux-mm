Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 501CF830A2
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 14:49:46 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so3495170wmz.2
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 11:49:46 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id b185si1439989lfe.127.2016.08.18.11.49.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 11:49:44 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id 33so2139691lfw.3
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 11:49:44 -0700 (PDT)
From: Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>
Reply-To: arekm@maven.pl
Subject: Re: [PATCH] mm, oom: report compaction/migration stats for higher order requests
Date: Thu, 18 Aug 2016 20:49:42 +0200
References: <201608120901.41463.a.miskiewicz@gmail.com> <201608171034.54940.arekm@maven.pl> <20160817092909.GA20703@dhcp22.suse.cz>
In-Reply-To: <20160817092909.GA20703@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201608182049.42261.a.miskiewicz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-ext4@vger.kernel.org, linux-mm@kvack.org, Jan Kara <jack@suse.cz>

On Wednesday 17 of August 2016, Michal Hocko wrote:
> On Wed 17-08-16 10:34:54, Arkadiusz Mi=C5=9Bkiewicz wrote:
> [...]
>=20
> > With "[PATCH] mm, oom: report compaction/migration stats for higher ord=
er
> > requests" patch:
> > https://ixion.pld-linux.org/~arekm/p2/ext4/log-20160817.txt
> >=20
> > Didn't count much - all counters are 0
> > compaction_stall:0 compaction_fail:0 compact_migrate_scanned:0
> > compact_free_scanned:0 compact_isolated:0 pgmigrate_success:0
> > pgmigrate_fail:0
>=20
> Dohh, COMPACTION counters are events and those are different than other
> counters we have. They only have per-cpu representation and so we would
> have to do
> +       for_each_online_cpu(cpu) {
> +               struct vm_event_state *this =3D &per_cpu(vm_event_states,
> cpu); +               ret +=3D this->event[item];
> +       }
>=20
> which is really nasty because, strictly speaking, we would have to do
> {get,put}_online_cpus around that loop and that uses locking and we do
> not want to possibly block in this path just because something is in the
> middle of the hotplug. So let's scratch that patch for now and sorry I
> haven't realized that earlier.
>=20
> > two processes were killed by OOM (rm and cp), the rest of rm/cp didn't
> > finish
> >=20
> > and I'm interrupting it to try that next patch:
> > > Could you try to test with
> > > patch from
> > > http://lkml.kernel.org/r/20160816031222.GC16913@js1304-P5Q-DELUXE
> > > please? Ideally on top of linux-next. You can add both the compaction
> > > counters patch in the oom report and high order atomic reserves patch
> > > on top.
> >=20
> > Uhm, was going to use it on top of 4.7.[01] first.
>=20
> OK

So with  http://lkml.kernel.org/r/20160816031222.GC16913@js1304-P5Q-DELUXE
OOM no longer happens (all 10x rm/cp processes finished).

https://ixion.pld-linux.org/~arekm/p2/ext4/log-20160818.txt

On Wednesday 17 of August 2016, Jan Kara wrote:
> Just one more debug idea to add on top of what Michal said: Can you enable
> mm_shrink_slab_start and mm_shrink_slab_end tracepoints (via
> /sys/kernel/debug/tracing/events/vmscan/mm_shrink_slab_{start,end}/enable)
> and gather output from /sys/kernel/debug/tracing/trace_pipe while the copy
> is running?

Here it is:

https://ixion.pld-linux.org/~arekm/p2/ext4/log-trace_pipe-20160818.txt.gz

=2D-=20
Arkadiusz Mi=C5=9Bkiewicz, arekm / ( maven.pl | pld-linux.org )

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
