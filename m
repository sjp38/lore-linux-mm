Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 9B359828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 09:34:20 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id l124so31387907wmf.1
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 06:34:20 -0700 (PDT)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id gk3si16152391wjd.195.2016.03.18.06.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Mar 2016 06:34:19 -0700 (PDT)
Received: by mail-wm0-f52.google.com with SMTP id l68so37592531wml.1
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 06:34:19 -0700 (PDT)
Date: Fri, 18 Mar 2016 14:34:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,writeback: Don't use memory reserves for
 wb_start_writeback
Message-ID: <20160318133417.GB30225@dhcp22.suse.cz>
References: <1457847155-19394-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201603132322.BEA57780.QMVOHFOSFJLOtF@I-love.SAKURA.ne.jp>
 <20160314160900.GC11400@dhcp22.suse.cz>
 <20160316204617.GH21104@mtj.duckdns.org>
 <20160318131136.GE7152@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160318131136.GE7152@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.com>

On Fri 18-03-16 14:11:36, Jan Kara wrote:
> On Wed 16-03-16 13:46:17, Tejun Heo wrote:
> > Hello,
> > 
> > (cc'ing Jan)
> > 
> > On Mon, Mar 14, 2016 at 05:09:00PM +0100, Michal Hocko wrote:
> > > On Sun 13-03-16 23:22:23, Tetsuo Handa wrote:
> > > [...]
> > > 
> > > I am not familiar with the writeback code so I might be missing
> > > something essential here but why are we even queueing more and more
> > > work without checking there has been enough already scheduled or in
> > > progress.
> > >
> > > Something as simple as:
> > > diff --git a/fs/fs-writeback.c b/fs/fs-writeback.c
> > > index 6915c950e6e8..aa52e23ac280 100644
> > > --- a/fs/fs-writeback.c
> > > +++ b/fs/fs-writeback.c
> > > @@ -887,7 +887,7 @@ void wb_start_writeback(struct bdi_writeback *wb, long nr_pages,
> > >  {
> > >  	struct wb_writeback_work *work;
> > >  
> > > -	if (!wb_has_dirty_io(wb))
> > > +	if (!wb_has_dirty_io(wb) || writeback_in_progress(wb))
> > >  		return;
> > 
> > I'm not sure this would be safe.  It shouldn't harm correctness as
> > wb_start_writeback() isn't used in sync case but this might change
> > flush behavior in various ways.  Dropping GFP_ATOMIC as suggested by
> > Tetsuo is likely better.
> 
> Yes, there can be different requests for different numbers of pages to be
> written and you don't want to discard a request to clean 4000 pages just
> because a writeback of 10 pages is just running. As Tejun says, this is not
> a hard requirement but in general it would be unexpected for the users of
> the api...

Thanks for the clarification. Then the proper fix indeed is to add
__GFP_NOMEMALLOC. 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
