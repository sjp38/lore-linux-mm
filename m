Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF936B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 09:21:28 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id n5so82298093wmn.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 06:21:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 201si24677939wml.102.2016.01.25.06.21.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 25 Jan 2016 06:21:27 -0800 (PST)
Date: Mon, 25 Jan 2016 15:21:39 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] proposals for topics
Message-ID: <20160125142139.GF24938@quack.suse.cz>
References: <20160125133357.GC23939@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160125133357.GC23939@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Hi!

On Mon 25-01-16 14:33:57, Michal Hocko wrote:
> - GFP_NOFS is another one which would be good to discuss. Its primary
>   use is to prevent from reclaim recursion back into FS. This makes
>   such an allocation context weaker and historically we haven't
>   triggered OOM killer and rather hopelessly retry the request and
>   rely on somebody else to make a progress for us. There are two issues
>   here.
>   First we shouldn't retry endlessly and rather fail the allocation and
>   allow the FS to handle the error. As per my experiments most FS cope
>   with that quite reasonably. Btrfs unfortunately handles many of those
>   failures by BUG_ON which is really unfortunate.
>   Another issue is that GFP_NOFS is quite often used without any obvious
>   reason. It is not clear which lock is held and could be taken from
>   the reclaim path. Wouldn't it be much better if the no-recursion
>   behavior was bound to the lock scope rather than particular allocation
>   request? We already have something like this for PM
>   pm_res{trict,tore}_gfp_mask resp. memalloc_noio_{save,restore}. It
>   would be great if we could unify this and use the context based NOFS
>   in the FS.

I like the idea that we'd protect lock scopes from reclaim recursion but the
effort to do so would be IMHO rather big. E.g. there are ~75 instances of
GFP_NOFS allocation in ext4/jbd2 codebase and making sure all are properly
covered will take quite some auditing... I'm not saying we shouldn't do
something like this, just you will have to be good in selling the benefits
:).

								Honza


-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
