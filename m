Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 668E2C00306
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:35:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36638206BB
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 17:35:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36638206BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=goodmis.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B823C6B0275; Thu,  5 Sep 2019 13:35:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B32066B0276; Thu,  5 Sep 2019 13:35:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A20EC6B0277; Thu,  5 Sep 2019 13:35:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0046.hostedemail.com [216.40.44.46])
	by kanga.kvack.org (Postfix) with ESMTP id 804D96B0275
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 13:35:18 -0400 (EDT)
Received: from smtpin13.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1C602181AC9AE
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:35:18 +0000 (UTC)
X-FDA: 75901568316.13.sink97_8585e266c6f03
X-HE-Tag: sink97_8585e266c6f03
X-Filterd-Recvd-Size: 4319
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf20.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 17:35:17 +0000 (UTC)
Received: from oasis.local.home (bl11-233-114.dsl.telepac.pt [85.244.233.114])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9B2B3206A5;
	Thu,  5 Sep 2019 17:35:13 +0000 (UTC)
Date: Thu, 5 Sep 2019 13:35:07 -0400
From: Steven Rostedt <rostedt@goodmis.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Joel Fernandes
 <joel@joelfernandes.org>, LKML <linux-kernel@vger.kernel.org>, Tim Murray
 <timmurray@google.com>, Carmen Jackson <carmenjackson@google.com>, Mayank
 Gupta <mayankgupta@google.com>, Daniel Colascione <dancol@google.com>,
 Minchan Kim <minchan@kernel.org>, Andrew Morton
 <akpm@linux-foundation.org>, kernel-team <kernel-team@android.com>, "Aneesh
 Kumar K.V" <aneesh.kumar@linux.ibm.com>, Dan Williams
 <dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>, linux-mm
 <linux-mm@kvack.org>, Matthew Wilcox <willy@infradead.org>, Ralph Campbell
 <rcampbell@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>, Tom Zanussi
 <zanussi@kernel.org>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
Message-ID: <20190905133507.783c6c61@oasis.local.home>
In-Reply-To: <CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
References: <20190903200905.198642-1-joel@joelfernandes.org>
	<20190904084508.GL3838@dhcp22.suse.cz>
	<20190904153258.GH240514@google.com>
	<20190904153759.GC3838@dhcp22.suse.cz>
	<20190904162808.GO240514@google.com>
	<20190905144310.GA14491@dhcp22.suse.cz>
	<CAJuCfpFve2v7d0LX20btk4kAjEpgJ4zeYQQSpqYsSo__CY68xw@mail.gmail.com>
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



[ Added Tom ]

On Thu, 5 Sep 2019 09:03:01 -0700
Suren Baghdasaryan <surenb@google.com> wrote:

> On Thu, Sep 5, 2019 at 7:43 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > [Add Steven]
> >
> > On Wed 04-09-19 12:28:08, Joel Fernandes wrote:  
> > > On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@kernel.org> wrote:  
> > > >
> > > > On Wed 04-09-19 11:32:58, Joel Fernandes wrote:  
> > [...]  
> > > > > but also for reducing
> > > > > tracing noise. Flooding the traces makes it less useful for long traces and
> > > > > post-processing of traces. IOW, the overhead reduction is a bonus.  
> > > >
> > > > This is not really anything special for this tracepoint though.
> > > > Basically any tracepoint in a hot path is in the same situation and I do
> > > > not see a point why each of them should really invent its own way to
> > > > throttle. Maybe there is some way to do that in the tracing subsystem
> > > > directly.  
> > >
> > > I am not sure if there is a way to do this easily. Add to that, the fact that
> > > you still have to call into trace events. Why call into it at all, if you can
> > > filter in advance and have a sane filtering default?
> > >
> > > The bigger improvement with the threshold is the number of trace records are
> > > almost halved by using a threshold. The number of records went from 4.6K to
> > > 2.6K.  
> >
> > Steven, would it be feasible to add a generic tracepoint throttling?  
> 
> I might misunderstand this but is the issue here actually throttling
> of the sheer number of trace records or tracing large enough changes
> to RSS that user might care about? Small changes happen all the time
> but we are likely not interested in those. Surely we could postprocess
> the traces to extract changes large enough to be interesting but why
> capture uninteresting information in the first place? IOW the
> throttling here should be based not on the time between traces but on
> the amount of change of the traced signal. Maybe a generic facility
> like that would be a good idea?

You mean like add a trigger (or filter) that only traces if a field has
changed since the last time the trace was hit? Hmm, I think we could
possibly do that. Perhaps even now with histogram triggers?

-- Steve


