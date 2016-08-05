Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id DBF1F6B0005
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 12:30:42 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s207so110353179oie.1
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:30:42 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0234.hostedemail.com. [216.40.44.234])
        by mx.google.com with ESMTPS id o96si19050387ioi.16.2016.08.05.09.30.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 09:30:40 -0700 (PDT)
Date: Fri, 5 Aug 2016 12:30:34 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] mm: page_alloc.c: Add tracepoints for slowpath
Message-ID: <20160805123034.75fae008@gandalf.local.home>
In-Reply-To: <9D639468-2A70-4620-8BF5-C8B2FBB38A99@gmail.com>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com>
	<6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com>
	<20160727112303.11409a4e@gandalf.local.home>
	<0AF03F78-AA34-4531-899A-EA1076B6B3A1@gmail.com>
	<20160804111946.6cbbd30b@gandalf.local.home>
	<9D639468-2A70-4620-8BF5-C8B2FBB38A99@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Fri, 5 Aug 2016 21:33:25 +0530
Janani Ravichandran <janani.rvchndrn@gmail.com> wrote:


> > Hmm, looking at the code, it appears setting tracing_thresh should
> > work. Could you show me exactly what you did?
> >  =20
>=20
> Sure. I wanted to observe how long it took to allocate pages and also how
> long functions in the direct reclaim path took.
>=20
> So I did:
>=20
> echo function_graph > current_tracer
> echo __alloc_pages_nodemask > set_graph_function

Eliminate the update to set_graph_function step. I'm not sure this is
the cause, but it's not needed. Adding to set_ftrace_filter should be
sufficient.

> echo __alloc_pages_nodemask >> set_ftrace_filter

Use '>' and not '>>' as I don't know what you had in there before, as
I'm guessing you want this to only contain what you listed here.

> echo do_try_to_free_pages >> set_ftrace_filter
> echo shrink_zone >> set_ftrace_filter
> echo mem_cgroup_softlimit_reclaim >> set_ftrace_filter
> echo shrink_zone_memcg >> set_ftrace_filter
> echo shrink_slab >> set_ftrace_filter
> echo shrink_list >> set_ftrace_filter
> echo shrink_active_list >> set_ftrace_filter
> echo shrink_inactive_list >> set_ftrace_filter
>=20
> echo 20 > tracing_thresh

You probably want to clear the trace here, or set function_graph here
first. Because the function graph starts writing to the buffer
immediately.

>=20
> echo 1 > events/vmscan/mm_shrink_slab_start/enable
> echo 1 > events/vmscan/mm_shrink_slab_end/enable
> echo 1 > events/vmscan/mm_vmscan_direct_reclaim_begin/enable
> echo 1 > events/vmscan/mm_vmscan_direct_reclaim_end/enable
>=20
> Rik had suggested that it=E2=80=99d be good to write only the tracepoint =
info related to
> high latencies to disk. Because otherwise, there=E2=80=99s a lot of infor=
mation from
> the tracepoints. Filtering them out would greatly reduce disk I/O.
>=20
> What I first tried with begin/end tracepoints was simply use their timest=
amps
> to calculate duration and write the tracepoint info to disk only if it ex=
ceeded a
> certain number.
>=20
> The function graph output is great when
>=20
> a, no thresholds or tracepoints are set (with those aforementioned functi=
ons
> used as filters).
>=20
> Here is a sample output.
> https://github.com/Jananiravichandran/Analyzing-tracepoints/blob/master/n=
o_tp_no_threshold.txt
>=20
> Lines 372 to 474 clearly show durations of functions and the output is he=
lpful=20
> to observe how long each function took.
>=20
> b, no thresholds are set and the tracepoints are enabled to get some
> additional information.
>=20
> https://github.com/Jananiravichandran/Analyzing-tracepoints/blob/master/s=
et_tp_no_threshold.txt
>=20
> Lines 785 to 916 here clearly show which tracepoints were invoked within =
which
> function calls as the beginning and end of functions are clearly marked.
>=20
> c, A threshold (20 in this case) is set but no tracepoints are enabled.
>=20
> https://github.com/Jananiravichandran/Analyzing-tracepoints/blob/master/n=
o_tp_set_threshold.txt
>=20
> Lines 230 to 345 only show functions which exceeded the threshold.
>=20
> But there=E2=80=99s a problem when a threshold is set and the tracepoints=
 are enabled. It
> is difficult to know the subset of the total tracepoint info printed that=
 was actually
> part of the functions that took longer than the threshold to execute (as =
there is no
> info indicating the beginning of functions unlike case b, mentioned above=
).
>=20
> For example,
> between lines 59 and 75 here:
>=20
> https://github.com/Jananiravichandran/Analyzing-tracepoints/blob/master/s=
et_tp_set_threshold.txt

When threshold is set, the entry is not recorded, because it is only
showing the exit and the time it took in that function:

0) kswapd0-52 | + 54.141 us | } /* shrink_zone */

shrink_zone() took 54.141us.

The reason it doesn't record the entry is because it would fill the
entire buffer, if the threshold is never hit. One can't predict the
time in a function when you first enter that function.

>=20
> we can see that there was a call to shrink_zone() which took 54.141 us
> (greater than 20, the threshold). We also see a lot of tracepoint informa=
tion
> printed between lines 59 and 74. But it is not possible for us to filter =
out
> only the tracepoint info that belongs to the shrink_zone() call that took=
 54.141
> us as it is possible that some of the information was printed as part of
> other shrink_zone() calls which took less than the threshold and therefore
> did not make it to the output file.

Exactly!

You need your own interpreter here. Perhaps a module that either reads
the tracepoints directly and registers a function graph tracer itself.
The trace events and function tracers are plugable. You don't need to
use the tracing system to use them. Just hook into them directly.

Things like the wakeup latency tracer does this. Look at
kernel/trace/trace_sched_wakeup.c for an example. It hooks into the
sched_wakeup and sched_switch tracepoints, and also has a way to use
function and function_graph tracing.



>=20
> So, it=E2=80=99s the filtering of anomalous data from tracepoints that I =
find difficult while
> using function_graphs.=20

Well, as I said, you can't filter on the entry tracepoint/function
because you don't know how long that function will take yet. You need
to have code that takes all information and only writes it out after
you hit the latency. That's going to require some custom coding.

>=20
> > Either way, adding your own function graph hook may be a good exercise
> > in seeing how all this works. =20
>=20
> Thank you for your suggestions regarding the function graph hook! I will =
try
> it and see if there=E2=80=99s anything I can come up with!

Great! And note, even if you add extra tracepoints, you can hook
directly into them too. Again, see the trace_sched_wakeup.c for
examples.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
