Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id D380E6B0253
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 11:11:27 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id 191so129984841wmq.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 08:11:27 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id g5si30364290wmd.47.2016.03.31.08.11.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 08:11:26 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i204so22755265wmd.0
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 08:11:26 -0700 (PDT)
Date: Thu, 31 Mar 2016 17:11:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: move GFP_NOFS check to out_of_memory
Message-ID: <20160331151124.GG27831@dhcp22.suse.cz>
References: <1459258055-1173-1-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1603291510560.11705@chino.kir.corp.google.com>
 <20160330094750.GH30729@dhcp22.suse.cz>
 <201603302046.CBJ39064.LFVQOHOOJtFSMF@I-love.SAKURA.ne.jp>
 <20160330121141.GD4324@dhcp22.suse.cz>
 <201603312056.BJH95312.HOQFFSVMJOLtOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201603312056.BJH95312.HOQFFSVMJOLtOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, linux-mm@kvack.org, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Thu 31-03-16 20:56:23, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 30-03-16 20:46:48, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Tue 29-03-16 15:13:54, David Rientjes wrote:
> > > > > On Tue, 29 Mar 2016, Michal Hocko wrote:
> > > > > 
> > > > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > > > index 86349586eacb..1c2b7a82f0c4 100644
> > > > > > --- a/mm/oom_kill.c
> > > > > > +++ b/mm/oom_kill.c
> > > > > > @@ -876,6 +876,10 @@ bool out_of_memory(struct oom_control *oc)
> > > > > >  		return true;
> > > > > >  	}
> > > > > >  
> > > > > > +	/* The OOM killer does not compensate for IO-less reclaim. */
> > > > > > +	if (!(oc->gfp_mask & __GFP_FS))
> > > > > > +		return true;
> > > > > > +
> > > 
> > > This patch will disable pagefault_out_of_memory() because currently
> > > pagefault_out_of_memory() is passing oc->gfp_mask == 0.
> > > 
> > > Because of current behavior, calling oom notifiers from !__GFP_FS seems
> > > to be safe.
> > 
> > You are right! I have completely missed that and thought we were
> > providing GFP_KERNEL there. So we have two choices. Either we do
> > use GFP_KERNEL (same as we do for sysrq+f) or we special case
> > pagefault_out_of_memory in some way. The second option seems to be safer
> > because the gfp_mask has to contain at least ___GFP_DIRECT_RECLAIM to
> > trigger the OOM path.
> 
> Oops, I missed that this patch also disables out_of_memory() for !__GFP_FS &&
> __GFP_NOFAIL allocation requests.

True. The following should take care of that:

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 54aa4ec06889..32d8210b8773 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -882,7 +882,7 @@ bool out_of_memory(struct oom_control *oc)
 	 * make sure exclude 0 mask - all other users should have at least
 	 * ___GFP_DIRECT_RECLAIM to get here.
 	 */
-	if (oc->gfp_mask && !(oc->gfp_mask & __GFP_FS))
+	if (oc->gfp_mask && !(oc->gfp_mask & (__GFP_FS|__GFP_NOFAIL)))
 		return true;
 
 	/*

Thanks for spotting this!

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
