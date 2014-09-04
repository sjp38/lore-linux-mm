Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8D2936B0035
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 11:09:04 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id w7so11529221lbi.25
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 08:09:03 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id df2si7871443lac.21.2014.09.04.08.09.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 08:09:02 -0700 (PDT)
Date: Thu, 4 Sep 2014 11:08:46 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
Message-ID: <20140904150846.GA10794@cmpxchg.org>
References: <54061505.8020500@sr71.net>
 <20140902221814.GA18069@cmpxchg.org>
 <5406466D.1020000@sr71.net>
 <20140903001009.GA25970@cmpxchg.org>
 <5406612E.8040802@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5406612E.8040802@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, Linus Torvalds <torvalds@linuxfoundation.org>, Andrew Morton <akpm@linuxfoundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Sep 02, 2014 at 05:30:38PM -0700, Dave Hansen wrote:
> On 09/02/2014 05:10 PM, Johannes Weiner wrote:
> > On Tue, Sep 02, 2014 at 03:36:29PM -0700, Dave Hansen wrote:
> >> On 09/02/2014 03:18 PM, Johannes Weiner wrote:
> >>> Accounting new pages is buffered through per-cpu caches, but taking
> >>> them off the counters on free is not, so I'm guessing that above a
> >>> certain allocation rate the cost of locking and changing the counters
> >>> takes over.  Is there a chance you could profile this to see if locks
> >>> and res_counter-related operations show up?
> >>
> >> It looks pretty much the same, although it might have equalized the
> >> charge and uncharge sides a bit.  Full 'perf top' output attached.
> > 
> > That looks like a partial profile, where did the page allocator, page
> > zeroing etc. go?  Because the distribution among these listed symbols
> > doesn't seem all that crazy:
> 
> Perf was only outputting the top 20 functions.  Believe it or not, page
> zeroing and the rest of the allocator path wasn't even in the path of
> the top 20 functions because there is so much lock contention.
> 
> Here's a longer run of 'perf top' along with the top 100 functions:
> 
> 	http://www.sr71.net/~dave/intel/perf-top-1409702817.txt.gz
> 
> you can at least see copy_page_rep in there.

Thanks for the clarification, that is truly horrible.  Does the
following revert restore performance in your case?

---
