Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 508AC6B0005
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 12:03:46 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so530034637pfx.0
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:03:46 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id i29si21087134pfa.172.2016.08.05.09.03.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Aug 2016 09:03:45 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id hh10so19573075pac.1
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 09:03:45 -0700 (PDT)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Subject: Re: [PATCH 1/2] mm: page_alloc.c: Add tracepoints for slowpath
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
In-Reply-To: <20160804111946.6cbbd30b@gandalf.local.home>
Date: Fri, 5 Aug 2016 21:33:25 +0530
Content-Transfer-Encoding: quoted-printable
Message-Id: <9D639468-2A70-4620-8BF5-C8B2FBB38A99@gmail.com>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com> <6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com> <20160727112303.11409a4e@gandalf.local.home> <0AF03F78-AA34-4531-899A-EA1076B6B3A1@gmail.com> <20160804111946.6cbbd30b@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com


> On Aug 4, 2016, at 8:49 PM, Steven Rostedt <rostedt@goodmis.org> =
wrote:
>=20
> On Fri, 29 Jul 2016 01:41:20 +0530
> Janani Ravichandran <janani.rvchndrn@gmail.com> wrote:
>=20
> Sorry for the late reply, I've been swamped with other things since
> coming back from my vacation.
>=20

No problem!
>=20
> Hmm, looking at the code, it appears setting tracing_thresh should
> work. Could you show me exactly what you did?
>=20

Sure. I wanted to observe how long it took to allocate pages and also =
how
long functions in the direct reclaim path took.

So I did:

echo function_graph > current_tracer
echo __alloc_pages_nodemask > set_graph_function
echo __alloc_pages_nodemask >> set_ftrace_filter
echo do_try_to_free_pages >> set_ftrace_filter
echo shrink_zone >> set_ftrace_filter
echo mem_cgroup_softlimit_reclaim >> set_ftrace_filter
echo shrink_zone_memcg >> set_ftrace_filter
echo shrink_slab >> set_ftrace_filter
echo shrink_list >> set_ftrace_filter
echo shrink_active_list >> set_ftrace_filter
echo shrink_inactive_list >> set_ftrace_filter

echo 20 > tracing_thresh

echo 1 > events/vmscan/mm_shrink_slab_start/enable
echo 1 > events/vmscan/mm_shrink_slab_end/enable
echo 1 > events/vmscan/mm_vmscan_direct_reclaim_begin/enable
echo 1 > events/vmscan/mm_vmscan_direct_reclaim_end/enable

Rik had suggested that it=E2=80=99d be good to write only the tracepoint =
info related to
high latencies to disk. Because otherwise, there=E2=80=99s a lot of =
information from
the tracepoints. Filtering them out would greatly reduce disk I/O.

What I first tried with begin/end tracepoints was simply use their =
timestamps
to calculate duration and write the tracepoint info to disk only if it =
exceeded a
certain number.

The function graph output is great when

a, no thresholds or tracepoints are set (with those aforementioned =
functions
used as filters).

Here is a sample output.
=
https://github.com/Jananiravichandran/Analyzing-tracepoints/blob/master/no=
_tp_no_threshold.txt

Lines 372 to 474 clearly show durations of functions and the output is =
helpful=20
to observe how long each function took.

b, no thresholds are set and the tracepoints are enabled to get some
additional information.

=
https://github.com/Jananiravichandran/Analyzing-tracepoints/blob/master/se=
t_tp_no_threshold.txt

Lines 785 to 916 here clearly show which tracepoints were invoked within =
which
function calls as the beginning and end of functions are clearly marked.

c, A threshold (20 in this case) is set but no tracepoints are enabled.

=
https://github.com/Jananiravichandran/Analyzing-tracepoints/blob/master/no=
_tp_set_threshold.txt

Lines 230 to 345 only show functions which exceeded the threshold.

But there=E2=80=99s a problem when a threshold is set and the =
tracepoints are enabled. It
is difficult to know the subset of the total tracepoint info printed =
that was actually
part of the functions that took longer than the threshold to execute (as =
there is no
info indicating the beginning of functions unlike case b, mentioned =
above).

For example,
between lines 59 and 75 here:

=
https://github.com/Jananiravichandran/Analyzing-tracepoints/blob/master/se=
t_tp_set_threshold.txt

we can see that there was a call to shrink_zone() which took 54.141 us
(greater than 20, the threshold). We also see a lot of tracepoint =
information
printed between lines 59 and 74. But it is not possible for us to filter =
out
only the tracepoint info that belongs to the shrink_zone() call that =
took 54.141
us as it is possible that some of the information was printed as part of
other shrink_zone() calls which took less than the threshold and =
therefore
did not make it to the output file.

So, it=E2=80=99s the filtering of anomalous data from tracepoints that I =
find difficult while
using function_graphs.=20

> Either way, adding your own function graph hook may be a good exercise
> in seeing how all this works.

Thank you for your suggestions regarding the function graph hook! I will =
try
it and see if there=E2=80=99s anything I can come up with!

Janani.

>=20
> -- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
