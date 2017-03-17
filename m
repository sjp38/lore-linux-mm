Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 90AD86B038B
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 16:00:39 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b140so5203727wme.3
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 13:00:39 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id v188si3410717wme.122.2017.03.17.13.00.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 13:00:38 -0700 (PDT)
Date: Fri, 17 Mar 2017 16:00:23 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v4] mm/vmscan: more restrictive condition for retry in
 do_try_to_free_pages
Message-ID: <20170317200023.GA16939@cmpxchg.org>
References: <1489577808-19228-1-git-send-email-xieyisheng1@huawei.com>
 <20170317183928.GA12281@cmpxchg.org>
 <20170317184527.GC23957@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170317184527.GC23957@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, riel@redhat.com, shakeelb@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, qiuxishi@huawei.com

On Fri, Mar 17, 2017 at 07:45:27PM +0100, Michal Hocko wrote:
> On Fri 17-03-17 14:39:28, Johannes Weiner wrote:
> > On Wed, Mar 15, 2017 at 07:36:48PM +0800, Yisheng Xie wrote:
> > > @@ -2808,7 +2813,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
> > >  		return 1;
> > >  
> > >  	/* Untapped cgroup reserves?  Don't OOM, retry. */
> > > -	if (!sc->may_thrash) {
> > > +	if (sc->memcg_low_protection && !sc->may_thrash) {
> > 
> > 	if (sc->memcg_low_skipped) {
> > 		[...]
> > 		sc->memcg_low_reclaim = 1;
> 
> you need to set memcg_low_skipped = 0 here, right? Otherwise we do not
> have break out of the loop. Or am I missing something?

Oops, you're right of course. That needs to be reset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
