Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 101CB6B0035
	for <linux-mm@kvack.org>; Tue, 23 Sep 2014 07:57:08 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id g10so5784984pdj.5
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 04:57:07 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id tw5si20299114pac.92.2014.09.23.04.57.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Sep 2014 04:57:07 -0700 (PDT)
Date: Tue, 23 Sep 2014 15:56:55 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [patch] mm: memcontrol: support transparent huge pages under
 pressure
Message-ID: <20140923115655.GJ18526@esperanza>
References: <1411132840-16025-1-git-send-email-hannes@cmpxchg.org>
 <xr934mvykgiv.fsf@gthelen.mtv.corp.google.com>
 <20140923082927.GG18526@esperanza>
 <20140923114827.GB13593@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20140923114827.GB13593@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Sep 23, 2014 at 07:48:27AM -0400, Johannes Weiner wrote:
> On Tue, Sep 23, 2014 at 12:29:27PM +0400, Vladimir Davydov wrote:
> > On Mon, Sep 22, 2014 at 10:52:50PM -0700, Greg Thelen wrote:
> > > In this condition, if res usage is at limit then there's no point in
> > > swapping because memsw.usage is already maximal.  Prior to this patch
> > > I think the kernel did the right thing, but not afterwards.
> > > 
> > > Before this patch:
> > >   if res.usage == res.limit, try_charge() indirectly calls
> > >   try_to_free_mem_cgroup_pages(noswap=true)
> > 
> > But this is wrong. If we fail to charge res, we should try to do swap
> > out along with page cache reclaim. Swap out won't affect memsw.usage,
> > but will diminish res.usage so that the allocation may succeed.
> 
> But we know that the memsw limit must be hit as well in that case, and
> swapping only makes progress in the sense that we are then succeeding
> the memory charge.  But we still fail to charge memsw.

Yeah, I admit I said nonsense. The problem Greg pointed out does exist.
I think your second patch (charging memsw before res) should fix it.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
