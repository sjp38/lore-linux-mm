Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1CDD36B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 13:11:38 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id bk3so13380737wjc.4
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 10:11:38 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id h70si8451118wme.114.2016.12.14.10.11.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 10:11:36 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id he10so6183365wjc.2
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 10:11:36 -0800 (PST)
Date: Wed, 14 Dec 2016 19:11:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 3/3] oom, trace: add compaction retry tracepoint
Message-ID: <20161214181133.GB16763@dhcp22.suse.cz>
References: <20161214145324.26261-1-mhocko@kernel.org>
 <20161214145324.26261-4-mhocko@kernel.org>
 <60cfb7ca-fb95-7a34-bae2-9b7c49119573@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <60cfb7ca-fb95-7a34-bae2-9b7c49119573@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 14-12-16 18:28:38, Vlastimil Babka wrote:
> On 12/14/2016 03:53 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Higher order requests oom debugging is currently quite hard. We do have
> > some compaction points which can tell us how the compaction is operating
> > but there is no trace point to tell us about compaction retry logic.
> > This patch adds a one which will have the following format
> > 
> >             bash-3126  [001] ....  1498.220001: compact_retry: order=9 priority=COMPACT_PRIO_SYNC_LIGHT compaction_result=withdrawn retries=0 max_retries=16 should_retry=0
> > 
> > we can see that the order 9 request is not retried even though we are in
> > the highest compaction priority mode becase the last compaction attempt
> > was withdrawn. This means that compaction_zonelist_suitable must have
> > returned false and there is no suitable zone to compact for this request
> > and so no need to retry further.
> > 
> > another example would be
> >            <...>-3137  [001] ....    81.501689: compact_retry: order=9 priority=COMPACT_PRIO_SYNC_LIGHT compaction_result=failed retries=0 max_retries=16 should_retry=0
> > 
> > in this case the order-9 compaction failed to find any suitable
> > block. We do not retry anymore because this is a costly request
> > and those do not go below COMPACT_PRIO_SYNC_LIGHT priority.
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > ---
> >  include/trace/events/mmflags.h | 26 ++++++++++++++++++++++++++
> >  include/trace/events/oom.h     | 39 +++++++++++++++++++++++++++++++++++++++
> >  mm/page_alloc.c                | 22 ++++++++++++++++------
> >  3 files changed, 81 insertions(+), 6 deletions(-)
> > 
> > diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
> > index 7e4cfede873c..aa4caa6914a9 100644
> > --- a/include/trace/events/mmflags.h
> > +++ b/include/trace/events/mmflags.h
> > @@ -187,8 +187,32 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
> >  	EM( COMPACT_NO_SUITABLE_PAGE,	"no_suitable_page")	\
> >  	EM( COMPACT_NOT_SUITABLE_ZONE,	"not_suitable_zone")	\
> >  	EMe(COMPACT_CONTENDED,		"contended")
> > +
> > +/* High-level compaction status feedback */
> > +#define COMPACTION_FAILED	1
> > +#define COMPACTION_WITHDRAWN	2
> > +#define COMPACTION_PROGRESS	3
> > +
> > +#define compact_result_to_feedback(result)	\
> > +({						\
> > + 	enum compact_result __result = result;	\
> > +	(compaction_failed(__result)) ? COMPACTION_FAILED : \
> > +		(compaction_withdrawn(__result)) ? COMPACTION_WITHDRAWN : COMPACTION_PROGRESS; \
> > +})
> 
> It seems you forgot to actually use this "function" (sorry, didn't notice
> earlier) so currently it's translating enum compact_result directly into the
> failed/withdrawn/progress strings, which is wrong.

You are right. I've screwed while integrating the enum translation part.

> The correct place for the result->feedback conversion should be
> TP_fast_assign, so __entry->result should become __entry->feedback. It's too
> late in TP_printk, as userspace tools (e.g. trace-cmd) won't know the
> functions that compact_result_to_feedback() uses.

Thanks. The follow up fix should be
---
