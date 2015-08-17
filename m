Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id CFFF06B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 07:58:47 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so72941697wic.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 04:58:47 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id d4si4717789wjn.153.2015.08.17.04.58.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=RC4-SHA bits=128/128);
        Mon, 17 Aug 2015 04:58:46 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 63F1998426
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 11:58:45 +0000 (UTC)
Date: Mon, 17 Aug 2015 12:58:17 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 04/10] mm, page_alloc: Remove unnecessary taking of a
 seqlock when cpusets are disabled
Message-ID: <20150817115817.GA9912@techsingularity.net>
References: <1439376335-17895-1-git-send-email-mgorman@techsingularity.net>
 <1439376335-17895-5-git-send-email-mgorman@techsingularity.net>
 <alpine.DEB.2.10.1508121714290.19264@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1508121714290.19264@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 12, 2015 at 05:16:50PM -0700, David Rientjes wrote:
> On Wed, 12 Aug 2015, Mel Gorman wrote:
> 
> > There is a seqcounter that protects against spurious allocation failures
> > when a task is changing the allowed nodes in a cpuset. There is no need
> > to check the seqcounter until a cpuset exists.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Acked-by: David Rientjes <rientjes@google.com>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > ---
> >  include/linux/cpuset.h | 6 ++++++
> >  1 file changed, 6 insertions(+)
> > 
> > diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> > index 1b357997cac5..6eb27cb480b7 100644
> > --- a/include/linux/cpuset.h
> > +++ b/include/linux/cpuset.h
> > @@ -104,6 +104,9 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
> >   */
> >  static inline unsigned int read_mems_allowed_begin(void)
> >  {
> > +	if (!cpusets_enabled())
> > +		return 0;
> > +
> >  	return read_seqcount_begin(&current->mems_allowed_seq);
> >  }
> >  
> > @@ -115,6 +118,9 @@ static inline unsigned int read_mems_allowed_begin(void)
> >   */
> >  static inline bool read_mems_allowed_retry(unsigned int seq)
> >  {
> > +	if (!cpusets_enabled())
> > +		return false;
> > +
> >  	return read_seqcount_retry(&current->mems_allowed_seq, seq);
> >  }
> >  
> 
> This patch is an obvious improvement, but I think it's also possible to 
> change this to be
> 
> 	if (nr_cpusets() <= 1)
> 		return false;
> 
> and likewise in the existing cpusets_enabled() check in 
> get_page_from_freelist().  A root cpuset may not exclude mems on the 
> system so, even if mounted, there's no need to check or be worried about 
> concurrent change when there is only one cpuset.

Good idea. I'll make this a separate patch on top and rename cpuset_enabled
to cpuset_mems_enabled to be clear about what it's checking.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
