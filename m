Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_2 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7743BC00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:14:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CC2920825
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 21:14:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="vsNYqXux"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CC2920825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D26F86B0003; Thu,  5 Sep 2019 17:14:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAF966B0005; Thu,  5 Sep 2019 17:14:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B76866B0007; Thu,  5 Sep 2019 17:14:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0143.hostedemail.com [216.40.44.143])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1866B0003
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:14:41 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id F0A4D180AD7C3
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:14:40 +0000 (UTC)
X-FDA: 75902121120.09.chalk15_bb2d702d8d3a
X-HE-Tag: chalk15_bb2d702d8d3a
X-Filterd-Recvd-Size: 8881
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 21:14:40 +0000 (UTC)
Received: from tzanussi-mobl (c-98-220-238-81.hsd1.il.comcast.net [98.220.238.81])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3D899206CD;
	Thu,  5 Sep 2019 21:14:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1567718079;
	bh=KxDpEEjWoEP8fmB/aB/zVXytAr8wUD3CUGPH3t3toyw=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=vsNYqXuxiOFH2tLsrscxgKuasuBEoZ9puI3rmJJU/IIBVWBGmpec6Qne1mPrGDdOs
	 NtziBk+vJbE9Zt1XlRH4D3FG2vv5nfUqg8KK5YV6BsagdcYVjhpF5cYOPxUMoqaqiF
	 HnVWNZgtR5OWV3b5h/aetC5J9g8CNbwgxp0hO77I=
Message-ID: <1567718076.16718.39.camel@kernel.org>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
From: Tom Zanussi <zanussi@kernel.org>
To: Daniel Colascione <dancol@google.com>
Cc: Joel Fernandes <joel@joelfernandes.org>, Steven Rostedt
 <rostedt@goodmis.org>, Suren Baghdasaryan <surenb@google.com>, Michal Hocko
 <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Tim Murray
 <timmurray@google.com>, Carmen Jackson <carmenjackson@google.com>, Mayank
 Gupta <mayankgupta@google.com>, Minchan Kim <minchan@kernel.org>, Andrew
 Morton <akpm@linux-foundation.org>, kernel-team <kernel-team@android.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Dan Williams
 <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, linux-mm
 <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>, Ralph Campbell
 <rcampbell@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>
Date: Thu, 05 Sep 2019 16:14:36 -0500
In-Reply-To: <CAKOZuescyhpGWUrZT+WpOoQP-gQ-8YYTyzwzZzBTxaJiLhMHxw@mail.gmail.com>
References: <20190903200905.198642-1-joel@joelfernandes.org>
	 <20190904084508.GL3838@dhcp22.suse.cz> <20190904153258.GH240514@google.com>
	 <20190904153759.GC3838@dhcp22.suse.cz> <20190904162808.GO240514@google.com>
	 <20190905144310.GA14491@dhcp22.suse.cz>
	 <CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
	 <20190905133507.783c6c61@oasis.local.home>
	 <20190905174705.GA106117@google.com> <20190905175108.GB106117@google.com>
	 <1567713403.16718.25.camel@kernel.org>
	 <CAKOZuescyhpGWUrZT+WpOoQP-gQ-8YYTyzwzZzBTxaJiLhMHxw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1-1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-09-05 at 13:24 -0700, Daniel Colascione wrote:
> On Thu, Sep 5, 2019 at 12:56 PM Tom Zanussi <zanussi@kernel.org>
> wrote:
> > On Thu, 2019-09-05 at 13:51 -0400, Joel Fernandes wrote:
> > > On Thu, Sep 05, 2019 at 01:47:05PM -0400, Joel Fernandes wrote:
> > > > On Thu, Sep 05, 2019 at 01:35:07PM -0400, Steven Rostedt wrote:
> > > > > 
> > > > > 
> > > > > [ Added Tom ]
> > > > > 
> > > > > On Thu, 5 Sep 2019 09:03:01 -0700
> > > > > Suren Baghdasaryan <surenb@google.com> wrote:
> > > > > 
> > > > > > On Thu, Sep 5, 2019 at 7:43 AM Michal Hocko <mhocko@kernel.
> > > > > > org>
> > > > > > wrote:
> > > > > > > 
> > > > > > > [Add Steven]
> > > > > > > 
> > > > > > > On Wed 04-09-19 12:28:08, Joel Fernandes wrote:
> > > > > > > > On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@ke
> > > > > > > > rnel
> > > > > > > > .org> wrote:
> > > > > > > > > 
> > > > > > > > > On Wed 04-09-19 11:32:58, Joel Fernandes wrote:
> > > > > > > 
> > > > > > > [...]
> > > > > > > > > > but also for reducing
> > > > > > > > > > tracing noise. Flooding the traces makes it less
> > > > > > > > > > useful
> > > > > > > > > > for long traces and
> > > > > > > > > > post-processing of traces. IOW, the overhead
> > > > > > > > > > reduction
> > > > > > > > > > is a bonus.
> > > > > > > > > 
> > > > > > > > > This is not really anything special for this
> > > > > > > > > tracepoint
> > > > > > > > > though.
> > > > > > > > > Basically any tracepoint in a hot path is in the same
> > > > > > > > > situation and I do
> > > > > > > > > not see a point why each of them should really invent
> > > > > > > > > its
> > > > > > > > > own way to
> > > > > > > > > throttle. Maybe there is some way to do that in the
> > > > > > > > > tracing subsystem
> > > > > > > > > directly.
> > > > > > > > 
> > > > > > > > I am not sure if there is a way to do this easily. Add
> > > > > > > > to
> > > > > > > > that, the fact that
> > > > > > > > you still have to call into trace events. Why call into
> > > > > > > > it
> > > > > > > > at all, if you can
> > > > > > > > filter in advance and have a sane filtering default?
> > > > > > > > 
> > > > > > > > The bigger improvement with the threshold is the number
> > > > > > > > of
> > > > > > > > trace records are
> > > > > > > > almost halved by using a threshold. The number of
> > > > > > > > records
> > > > > > > > went from 4.6K to
> > > > > > > > 2.6K.
> > > > > > > 
> > > > > > > Steven, would it be feasible to add a generic tracepoint
> > > > > > > throttling?
> > > > > > 
> > > > > > I might misunderstand this but is the issue here actually
> > > > > > throttling
> > > > > > of the sheer number of trace records or tracing large
> > > > > > enough
> > > > > > changes
> > > > > > to RSS that user might care about? Small changes happen all
> > > > > > the
> > > > > > time
> > > > > > but we are likely not interested in those. Surely we could
> > > > > > postprocess
> > > > > > the traces to extract changes large enough to be
> > > > > > interesting
> > > > > > but why
> > > > > > capture uninteresting information in the first place? IOW
> > > > > > the
> > > > > > throttling here should be based not on the time between
> > > > > > traces
> > > > > > but on
> > > > > > the amount of change of the traced signal. Maybe a generic
> > > > > > facility
> > > > > > like that would be a good idea?
> > > > > 
> > > > > You mean like add a trigger (or filter) that only traces if a
> > > > > field has
> > > > > changed since the last time the trace was hit? Hmm, I think
> > > > > we
> > > > > could
> > > > > possibly do that. Perhaps even now with histogram triggers?
> > > > 
> > > > 
> > > > Hey Steve,
> > > > 
> > > > Something like an analog to digitial coversion function where
> > > > you
> > > > lose the
> > > > granularity of the signal depending on how much trace data:
> > > > https://www.globalspec.com/ImageRepository/LearnMore/20142/9ee3
> > > > 8d1a
> > > > 85d37fa23f86a14d3a9776ff67b0ec0f3b.gif
> > > 
> > > s/how much trace data/what the resolution is/
> > > 
> > > > so like, if you had a counter incrementing with values after
> > > > the
> > > > increments
> > > > as:  1,3,4,8,12,14,30 and say 5 is the threshold at which to
> > > > emit a
> > > > trace,
> > > > then you would get 1,8,12,30.
> > > > 
> > > > So I guess what is need is a way to reduce the quantiy of trace
> > > > data this
> > > > way. For this usecase, the user mostly cares about spikes in
> > > > the
> > > > counter
> > > > changing that accurate values of the different points.
> > > 
> > > s/that accurate/than accurate/
> > > 
> > > I think Tim, Suren, Dan and Michal are all saying the same thing
> > > as
> > > well.
> > > 
> > 
> > There's not a way to do this using existing triggers (histogram
> > triggers have an onchange() that fires on any change, but that
> > doesn't
> > help here), and I wouldn't expect there to be - these sound like
> > very
> > specific cases that would never have support in the simple trigger
> > 'language'.
> 
> I don't see the filtering under discussion as some "very specific"
> esoteric need. You need this general kind of mechanism any time you
> want to monitor at low frequency a thing that changes at high
> frequency. The general pattern isn't specific to RSS or even memory
> in
> general. One might imagine, say, wanting to trace large changes in
> TCP
> window sizes. Any time something in the kernel has a "level" and that
> level changes at high frequency and we want to learn about big swings
> in that level, the mechanism we're talking about becomes useful. I
> don't think it should be out of bounds for the histogram mechanism,
> which is *almost* there right now. We already have the ability to
> accumulate values derived from ftrace events into tables keyed on
> various fields in these events and things like onmax().
> 

OK, so with the histograms we already have onchange(), which triggers
on any change.

Would it be sufficient to just add a 'threshold' param to that i.e.
onchange(x) means trigger whenever the difference between the new value
and the previous value is >= x?

Tom


