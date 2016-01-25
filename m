Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 616E06B0254
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:40:26 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id r129so66791796wmr.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 06:40:26 -0800 (PST)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id ee2si28811524wjd.88.2016.01.25.06.40.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 06:40:25 -0800 (PST)
Received: by mail-wm0-f41.google.com with SMTP id u188so68504091wmu.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 06:40:25 -0800 (PST)
Date: Mon, 25 Jan 2016 15:40:23 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] proposals for topics
Message-ID: <20160125144023.GF23934@dhcp22.suse.cz>
References: <20160125133357.GC23939@dhcp22.suse.cz>
 <20160125142139.GF24938@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160125142139.GF24938@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon 25-01-16 15:21:39, Jan Kara wrote:
> Hi!
> 
> On Mon 25-01-16 14:33:57, Michal Hocko wrote:
[...
> >   Another issue is that GFP_NOFS is quite often used without any obvious
> >   reason. It is not clear which lock is held and could be taken from
> >   the reclaim path. Wouldn't it be much better if the no-recursion
> >   behavior was bound to the lock scope rather than particular allocation
> >   request? We already have something like this for PM
> >   pm_res{trict,tore}_gfp_mask resp. memalloc_noio_{save,restore}. It
> >   would be great if we could unify this and use the context based NOFS
> >   in the FS.
> 
> I like the idea that we'd protect lock scopes from reclaim recursion but the
> effort to do so would be IMHO rather big. E.g. there are ~75 instances of
> GFP_NOFS allocation in ext4/jbd2 codebase and making sure all are properly
> covered will take quite some auditing... I'm not saying we shouldn't do
> something like this, just you will have to be good in selling the benefits
> :).

My idea was that the first step would be using the helpers to mark
scopes and other usage of the ~__GFP_FS inside such a scope could be
identified much easier (e.g. a debugging WARN_ON or something like
that). That can be done in a longer term. Then I would hope for reducing
GFP_NOFS usage from mapping_gfp_mask.

I realize this is a lot of work but I believe this will pay of long
term. And especially the first step shouldn't be that hard because locks
used from the reclaim path shouldn't be that hard to identify.

GFP_NOFS is a mess these days and it is far from trivial to tell wether
it should be used or not from some paths.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
