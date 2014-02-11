Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f170.google.com (mail-ea0-f170.google.com [209.85.215.170])
	by kanga.kvack.org (Postfix) with ESMTP id DC8E76B0037
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:48:50 -0500 (EST)
Received: by mail-ea0-f170.google.com with SMTP id g15so2122806eak.1
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 10:48:50 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id 43si33862406eeh.31.2014.02.11.10.48.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 10:48:48 -0800 (PST)
Date: Tue, 11 Feb 2014 13:48:43 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 3/8] memcg: update comment about charge reparenting on
 cgroup exit
Message-ID: <20140211184843.GL6963@cmpxchg.org>
References: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
 <1391792665-21678-4-git-send-email-hannes@cmpxchg.org>
 <20140210142344.GI7117@dhcp22.suse.cz>
 <alpine.LSU.2.11.1402101208290.1516@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1402101208290.1516@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 10, 2014 at 12:12:42PM -0800, Hugh Dickins wrote:
> On Mon, 10 Feb 2014, Michal Hocko wrote:
> > On Fri 07-02-14 12:04:20, Johannes Weiner wrote:
> > > Reparenting memory charges in the css_free() callback was meant as a
> > > temporary fix for charges that race with offlining, but after some
> > > follow-up discussion, it turns out that this is really the right place
> > > to reparent charges because it guarantees none are in-flight.
> 
> Perhaps: I'm not as gung-ho for this new orthodoxy as you are.
>
> > > Make clear that the reparenting in css_offline() is an optimistic
> > > sweep of established charges because swapout records might hold up
> > > css_free() indefinitely, but that in fact the css_free() reparenting
> > > is the properly synchronized one.
> 
> It worries me that you keep referring to the memsw usage, but
> forget the kmem usage, which also delays css_free() indefinitely.
>
> Or am I out-of-date?  Seems not, mem_cgroup_reparent_chages() still
> waits for memcg->res - memcg->kmem to reach 0, knowing there's not
> much certainty that kmem will reach 0 any time soon.
>
> I think you need a plan for what to do with the kmem pinning,
> before going much further in reworking the memsw pinning.
> 
> Or at the least, please mention it in this patch's comment.

It think the discussion from the other thread bled over into this one
a little bit, this patch was merely about clarifying that .css_free()
reparenting is not the crude hack it was described as.

Yes, I forgot about kmem and it should be mentioned in this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
