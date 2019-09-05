Return-Path: <SRS0=ftCo=XA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CD8FC43140
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 14:43:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48249206BA
	for <linux-mm@archiver.kernel.org>; Thu,  5 Sep 2019 14:43:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48249206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65D366B0269; Thu,  5 Sep 2019 10:43:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E7116B026B; Thu,  5 Sep 2019 10:43:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D51C6B026C; Thu,  5 Sep 2019 10:43:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0122.hostedemail.com [216.40.44.122])
	by kanga.kvack.org (Postfix) with ESMTP id 2686A6B0269
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 10:43:14 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C9D624853
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:43:13 +0000 (UTC)
X-FDA: 75901134666.28.bomb34_565aa1fd6d633
X-HE-Tag: bomb34_565aa1fd6d633
X-Filterd-Recvd-Size: 2781
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu,  5 Sep 2019 14:43:13 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ABAC9B0BA;
	Thu,  5 Sep 2019 14:43:11 +0000 (UTC)
Date: Thu, 5 Sep 2019 16:43:10 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Joel Fernandes <joel@joelfernandes.org>,
	Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, Tim Murray <timmurray@google.com>,
	carmenjackson@google.com, mayankgupta@google.com, dancol@google.com,
	rostedt@goodmis.org, minchan@kernel.org, akpm@linux-foundation.org,
	kernel-team@android.com,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org,
	Matthew Wilcox <willy@infradead.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH v2] mm: emit tracepoint when RSS changes by threshold
Message-ID: <20190905144310.GA14491@dhcp22.suse.cz>
References: <20190903200905.198642-1-joel@joelfernandes.org>
 <20190904084508.GL3838@dhcp22.suse.cz>
 <20190904153258.GH240514@google.com>
 <20190904153759.GC3838@dhcp22.suse.cz>
 <20190904162808.GO240514@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190904162808.GO240514@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Add Steven]

On Wed 04-09-19 12:28:08, Joel Fernandes wrote:
> On Wed, Sep 4, 2019 at 11:38 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Wed 04-09-19 11:32:58, Joel Fernandes wrote:
[...]
> > > but also for reducing
> > > tracing noise. Flooding the traces makes it less useful for long traces and
> > > post-processing of traces. IOW, the overhead reduction is a bonus.
> >
> > This is not really anything special for this tracepoint though.
> > Basically any tracepoint in a hot path is in the same situation and I do
> > not see a point why each of them should really invent its own way to
> > throttle. Maybe there is some way to do that in the tracing subsystem
> > directly.
> 
> I am not sure if there is a way to do this easily. Add to that, the fact that
> you still have to call into trace events. Why call into it at all, if you can
> filter in advance and have a sane filtering default?
> 
> The bigger improvement with the threshold is the number of trace records are
> almost halved by using a threshold. The number of records went from 4.6K to
> 2.6K.

Steven, would it be feasible to add a generic tracepoint throttling?
-- 
Michal Hocko
SUSE Labs

