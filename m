Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_2 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 544BAC00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 19:56:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 774E920825
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 19:56:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="T60UeUo5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 774E920825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 809FF6B0003; Thu,  5 Sep 2019 15:56:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 794B26B0005; Thu,  5 Sep 2019 15:56:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6836E6B0007; Thu,  5 Sep 2019 15:56:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0230.hostedemail.com [216.40.44.230])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6AC6B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 15:56:48 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id D74741263
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 19:56:47 +0000 (UTC)
X-FDA: 75901924854.07.whip78_3b42237f90e27
X-HE-Tag: whip78_3b42237f90e27
X-Filterd-Recvd-Size: 17609
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 19:56:47 +0000 (UTC)
Received: from tzanussi-mobl (c-98-220-238-81.hsd1.il.comcast.net [98.220.238.81])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8F8F5206BB;
	Thu,  5 Sep 2019 19:56:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567713406;
	bh=TsKYvK/ZUtCoAhSRR/M30Y8URCRv6GIPc2PRZ5VnJqk=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=T60UeUo5lJ33cBmrQtIsEslZvkcvcIzVAu3LKKoGRBM7ldxQ2wbTuO/5182KLHqkJ
	 KxzLWb/f2mmXWA7qx0fXvf3w7ypjq1yndyBiiUhbMdD4iCwrcWh3bvs2pwd2ovP6PL
	 xMW+WV/TU/zVhNT9oCjj27wPyt7cDcTe7HhZiCQc=
Message-ID: <1567713403.16718.25.camel@kernel.org>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
From: Tom Zanussi <zanussi@kernel.org>
To: Joel Fernandes <joel@joelfernandes.org>, Steven Rostedt
	 <rostedt@goodmis.org>
Cc: Suren Baghdasaryan <surenb@google.com>, Michal Hocko
 <mhocko@kernel.org>,  LKML <linux-kernel@vger.kernel.org>, Tim Murray
 <timmurray@google.com>, Carmen Jackson <carmenjackson@google.com>, Mayank
 Gupta <mayankgupta@google.com>, Daniel Colascione <dancol@google.com>,
 Minchan Kim <minchan@kernel.org>, Andrew Morton
 <akpm@linux-foundation.org>, kernel-team <kernel-team@android.com>, "Aneesh
 Kumar K.V" <aneesh.kumar@linux.ibm.com>, Dan Williams
 <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, linux-mm
 <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>, Ralph Campbell
 <rcampbell@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 05 Sep 2019 14:56:43 -0500
In-Reply-To: <20190905175108.GB106117@google.com>
References: <20190903200905.198642-1-joel@joelfernandes.org>
	 <20190904084508.GL3838@dhcp22.suse.cz> <20190904153258.GH240514@google.com>
	 <20190904153759.GC3838@dhcp22.suse.cz> <20190904162808.GO240514@google.com>
	 <20190905144310.GA14491@dhcp22.suse.cz>
	 <CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
	 <20190905133507.783c6c61@oasis.local.home>
	 <20190905174705.GA106117@google.com> <20190905175108.GB106117@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1-1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 2019-09-05 at 13:51 -0400, Joel Fernandes wrote:
> On Thu, Sep 05, 2019 at 01:47:05PM -0400, Joel Fernandes wrote:
> > On Thu, Sep 05, 2019 at 01:35:07PM -0400, Steven Rostedt wrote:
> > > 
> > > 
> > > [ Added Tom ]
> > > 
> > > On Thu, 5 Sep 2019 09:03:01 -0700
> > > Suren Baghdasaryan <surenb@google.com> wrote:
> > > 
> > > > On Thu, Sep 5, 2019 at 7:43 AM Michal Hocko <mhocko@kernel.org>
> > > > wrote:
> > > > > 
> > > > > [Add Steven]
> > > > > 
> > > > > On Wed 04-09-19 12:28:08, Joel Fernandes wrote:  
> > > > > > On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@kernel
> > > > > > .org> wrote:  
> > > > > > > 
> > > > > > > On Wed 04-09-19 11:32:58, Joel Fernandes wrote:  
> > > > > 
> > > > > [...]  
> > > > > > > > but also for reducing
> > > > > > > > tracing noise. Flooding the traces makes it less useful
> > > > > > > > for long traces and
> > > > > > > > post-processing of traces. IOW, the overhead reduction
> > > > > > > > is a bonus.  
> > > > > > > 
> > > > > > > This is not really anything special for this tracepoint
> > > > > > > though.
> > > > > > > Basically any tracepoint in a hot path is in the same
> > > > > > > situation and I do
> > > > > > > not see a point why each of them should really invent its
> > > > > > > own way to
> > > > > > > throttle. Maybe there is some way to do that in the
> > > > > > > tracing subsystem
> > > > > > > directly.  
> > > > > > 
> > > > > > I am not sure if there is a way to do this easily. Add to
> > > > > > that, the fact that
> > > > > > you still have to call into trace events. Why call into it
> > > > > > at all, if you can
> > > > > > filter in advance and have a sane filtering default?
> > > > > > 
> > > > > > The bigger improvement with the threshold is the number of
> > > > > > trace records are
> > > > > > almost halved by using a threshold. The number of records
> > > > > > went from 4.6K to
> > > > > > 2.6K.  
> > > > > 
> > > > > Steven, would it be feasible to add a generic tracepoint
> > > > > throttling?  
> > > > 
> > > > I might misunderstand this but is the issue here actually
> > > > throttling
> > > > of the sheer number of trace records or tracing large enough
> > > > changes
> > > > to RSS that user might care about? Small changes happen all the
> > > > time
> > > > but we are likely not interested in those. Surely we could
> > > > postprocess
> > > > the traces to extract changes large enough to be interesting
> > > > but why
> > > > capture uninteresting information in the first place? IOW the
> > > > throttling here should be based not on the time between traces
> > > > but on
> > > > the amount of change of the traced signal. Maybe a generic
> > > > facility
> > > > like that would be a good idea?
> > > 
> > > You mean like add a trigger (or filter) that only traces if a
> > > field has
> > > changed since the last time the trace was hit? Hmm, I think we
> > > could
> > > possibly do that. Perhaps even now with histogram triggers?
> > 
> > 
> > Hey Steve,
> > 
> > Something like an analog to digitial coversion function where you
> > lose the
> > granularity of the signal depending on how much trace data:
> > https://www.globalspec.com/ImageRepository/LearnMore/20142/9ee38d1a
> > 85d37fa23f86a14d3a9776ff67b0ec0f3b.gif
> 
> s/how much trace data/what the resolution is/
> 
> > so like, if you had a counter incrementing with values after the
> > increments
> > as:  1,3,4,8,12,14,30 and say 5 is the threshold at which to emit a
> > trace,
> > then you would get 1,8,12,30.
> > 
> > So I guess what is need is a way to reduce the quantiy of trace
> > data this
> > way. For this usecase, the user mostly cares about spikes in the
> > counter
> > changing that accurate values of the different points.
> 
> s/that accurate/than accurate/
> 
> I think Tim, Suren, Dan and Michal are all saying the same thing as
> well.
> 

There's not a way to do this using existing triggers (histogram
triggers have an onchange() that fires on any change, but that doesn't
help here), and I wouldn't expect there to be - these sound like very
specific cases that would never have support in the simple trigger
'language'.

On the other hand, I have been working on something that should give
you the ability to do something like this, by writing a module that
hooks into arbitrary trace events, accessing their fields, building up
any needed state across events, and then generating synthetic events as
needed:

https://git.kernel.org/pub/scm/linux/kernel/git/zanussi/linux-trace.git/log/?h=ftrace/in-kernel-events-v0

The documentation is in the top commit, and I'll include it below, but
the basic idea is that you can set up a 'live handler' for any event,
and when that event is hit, you look at the data and save it however
you need, or modify some state machine, etc, and the event is then
discarded since it's in soft enable mode and doesn't end up in the
trace stream unless you enable it.  At any point you can decide to
generate a synthetic event of your own design which will end up in the
trace output.

I don't know much about the RSS threshold case, but it seems you could
just set up a live handler for the RSS tracepoint and monitor it in the
module.  Then whenever it hits your granularity threshold or so, just
generate a new 'RSS threshold' synthetic event at that point, which
would then be the only thing in the trace buffer.  Well, I'm probably
oversimplifying the problem, but hopefully close enough.

If this code looks like it might be useful in general, let me know and
I'll clean it up - at this point it's only prototype-quality and needs
plenty of work.

Thanks,

Tom

[PATCH] trace: Documentation for in-kernel trace event API

Add Documentation for creating and generating synthetic events from
modules, along with instructions for creating custom event handlers
for existing events.

Signed-off-by: Tom Zanussi <zanussi@kernel.org>
---
 Documentation/trace/events.rst | 200 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 200 insertions(+)

diff --git a/Documentation/trace/events.rst b/Documentation/trace/events.rst
index f7e1fcc0953c..b7d69b894ec0 100644
--- a/Documentation/trace/events.rst
+++ b/Documentation/trace/events.rst
@@ -525,3 +525,203 @@ The following commands are supported:
   event counts (hitcount).
 
   See Documentation/trace/histogram.rst for details and examples.
+
+6.3 In-kernel trace event API
+-----------------------------
+
+In most cases, the command-line interface to trace events is more than
+sufficient.  Sometimes, however, applications might find the need for
+more complex relationships than can be expressed through a simple
+series of linked command-line expressions, or putting together sets of
+commands may be simply too cumbersome.  An example might be an
+application that needs to 'listen' to the trace stream in order to
+maintain an in-kernel state machine detecting, for instance, when an
+illegal kernel state occurs in the scheduler.
+
+The trace event subsystem provides an in-kernel API allowing modules
+or other kernel code to access the trace stream in real-time, and
+simultaneously generate user-defined 'synthetic' events at will, which
+can be used to either augment the existing trace stream and/or signal
+that a particular important state has occured.
+
+The API provided for these purposes is describe below and allows the
+following:
+
+  - creating and defining custom handlers for existing trace events
+  - dynamically creating synthetic event definitions
+  - generating synthetic events from custom handlers
+
+6.3.1 Creating and defining custom handlers for existing trace events
+---------------------------------------------------------------------
+
+To create a live event handler for an existing event in a kernel
+module, the create_live_handler() function should be used.  The name
+of the event and its subsystem should be specified, along with an
+event_trigger_ops object.  The event_trigger_ops object specifies the
+name of the callback function that will be called on every hit of the
+named event.  For example, to have the 'sched_switch_event_trigger()'
+callback called on every sched_switch event, the following code could
+be used:
+
+  static struct event_trigger_ops event_live_trigger_ops = {
+      .func			= sched_switch_event_trigger,
+      .print			= event_live_trigger_print,
+      .init			= event_live_trigger_init,
+      .free			= event_live_trigger_free,
+  };
+
+  data = create_live_handler("sched", "sched_switch", &event_live_trigger_ops);
+
+In order to access the event's trace data on an event hit, field
+accessors can be used.  When the callback function is invoked, an
+array of live_field 'accessors' is passed in as the private_data of
+the event_trigger_data passed to the handler.  A given event field's
+data can be accessed via the live_field struct pointer corresponding
+to that field, specifically by calling the live_field->fn() member,
+which will return the field data as a u64 that can be cast into the
+actual field type (is_string_field() can be used to determine and deal
+with string field types).
+
+For example, the following code will print out each field value for
+various types:
+
+  for (i = 0; i < MAX_ACCESSORS; i++) {
+      field = live_accessors->accessors[i];
+      if (!field)
+          break;
+
+      val = field->fn(field->field, rbe, rec);
+
+      if (is_string_field(field->field))
+          printk("\tval=%s (%s)\n", (char *)(long)val, field->field->name);
+      else
+          printk("\tval=%llu (%s)\n", val, field->field->name);
+  }
+
+  val = prev_comm_field->fn(prev_comm_field->field, rbe, rec);
+  printk("prev_comm: %s\n", (char *)val);
+  val = prev_pid_field->fn(prev_pid_field->field, rbe, rec);
+  printk("prev_pid: %d\n", (pid_t)val);
+
+  print_timestamp(live_accessors->timestamp_accessor, rec, rbe);
+
+In order for this to work, a set of field accessors needs to be
+created before the event is registered.  This is best done in the
+event_trigger_ops.init() callback, which is called from the
+create_live_handler() code.
+
+create_live_field_accessors() automatically creates and add a live
+field accessor for each field in a trace event.
+
+Each field will have an accessor created for it and added to the
+live_accessors array for the event.  This includes the common event
+fields, but doesn't include the common_timestamp (which can be added
+manually using add_live_field_accessor() if needed).
+
+If you don't need or want accessors for every field, you can add them
+individually using add_live_field_accessor() for each one.
+
+A given field's accessor, for use in the handler, can be retrieved
+using find_live_field_accessor() with the field's name.
+
+For example, this call would create a set of live field accessors, one
+for each field of the sched_switch event:
+
+  live_accessors = create_live_field_accessors("sched", "sched_switch");
+
+To access a couple specific sched_switch fields (the same fields we
+used above in the handler):
+
+  prev_pid_field = find_live_field_accessor(live_accessors, "prev_pid");
+  prev_comm_field = find_live_field_accessor(live_accessors, "prev_comm");
+
+To add a common_timestamp accessor, use this call:
+
+  ret = add_live_field_accessor(live_accessors, "common_timestamp");
+
+Note that the common_timestamp accessor is special and unlike all
+other accessors, can be accessed using the dedicated
+live_accessors->timestamp_accessor member.
+
+6.3.2 Dyamically creating synthetic event definitions
+-----------------------------------------------------
+
+To create a new synthetic event from a kernel module, an empty
+synthetic event should first be created using
+create_empty_synthetic_event().  The name of the event should be
+supplied to this function.  For example, to create a new "livetest"
+synthetic event:
+
+  struct synth_event *se = create_empty_synth_event("livetest");
+
+Once a synthetic event object has been created, it can then be
+populated with fields.  Fields are added one by one using
+add_synth_field(), supplying the new synthetic event object, a field
+type, and a field name.  For example, to add a new int field named
+"intfield", the following call should be made:
+
+  ret = add_synth_field(se, "int", "intfield");
+
+See synth_field_size() for available types. If field_name contains [n]
+the field is considered to be an array.
+
+Once all the fields have been added, the event should be finalized and
+registered by calling the finalize_synth_event() function:
+
+  ret = finalize_synth_event(se);
+
+At this point, the event object is ready to be used for generating new
+events.
+
+6.3.3 Generating synthetic events from custom handlers
+------------------------------------------------------
+
+To generate a synthetic event, the generate_synth_event() function is
+used.  It's passed the trace_event_file representing the synthetic
+event (which can be retrieved using find_event_file() using the
+synthetic event name and "synthetic" as the system name, along with
+top_trace_array() as the trace array), along with an array of u64, one
+for each synthetic event field.
+
+The 'vals' array is just an array of u64, the number of which must
+match the number of field in the synthetic event, and which must be in
+the same order as the synthetic event fields.
+
+All vals should be cast to u64, and string vals are just pointers to
+strings, cast to u64.  Strings will be copied into space reserved in
+the event for the string, using these pointers.
+
+So for a synthetic event that was created using the following:
+
+  se = create_empty_synth_event("schedtest");
+  add_synth_field(se, "pid_t", "next_pid_field");
+  add_synth_field(se, "char[16]", "next_comm_field");
+  add_synth_field(se, "u64", "ts_ns");
+  add_synth_field(se, "u64", "ts_ms");
+  add_synth_field(se, "unsigned int", "cpu");
+  add_synth_field(se, "char[64]", "my_string_field");
+  add_synth_field(se, "int", "my_int_field");
+  finalize_synth_event(se);
+
+  schedtest_event_file = find_event_file(top_trace_array(),
+                                         "synthetic", "schedtest");
+
+Code to generate a synthetic event might then look like this:
+
+  u64 vals[7];
+
+  ts_ns = get_timestamp(live_accessors->timestamp_accessor, rec, rbe, true);
+  ts_ms = get_timestamp(live_accessors->timestamp_accessor, rec, rbe, false);
+  cpu = smp_processor_id();
+  next_comm_val = next_comm_field->fn(next_comm_field->field, rbe, rec);
+  next_pid_val = next_pid_field->fn(next_pid_field->field, rbe, rec);
+
+  vals[0] = next_pid_val;
+  vals[1] = next_comm_val;
+  vals[2] = ts_ns;
+  vals[3] = ts_ms;
+  vals[4] = cpu;
+  vals[5] = (u64)"thneed";
+  vals[6] = 398;
+
+  generate_synth_event(schedtest_event_file, vals, sizeof(vals));
-- 
2.14.1


