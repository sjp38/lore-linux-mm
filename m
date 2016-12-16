Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2B66B027C
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:35:05 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id s68so60823590ywg.7
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:35:05 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id w4si4090518wmg.1.2016.12.16.07.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 07:35:04 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id he10so15146776wjc.2
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 07:35:04 -0800 (PST)
Date: Fri, 16 Dec 2016 16:35:02 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/9 v2] scope GFP_NOFS api
Message-ID: <20161216153502.GP13940@dhcp22.suse.cz>
References: <20161215140715.12732-1-mhocko@kernel.org>
 <1481900758.31172.20.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1481900758.31172.20.camel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <umgwanakikbuti@gmail.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, "Peter Zijlstra (Intel)" <peterz@infradead.org>

On Fri 16-12-16 16:05:58, Mike Galbraith wrote:
> On Thu, 2016-12-15 at 15:07 +0100, Michal Hocko wrote:
> > Hi,
> > I have posted the previous version here [1]. Since then I have added a
> > support to suppress reclaim lockdep warnings (__GFP_NOLOCKDEP) to allow
> > removing GFP_NOFS usage motivated by the lockdep false positives. On top
> > of that I've tried to convert few KM_NOFS usages to use the new flag in
> > the xfs code base. This would need a review from somebody familiar with
> > xfs of course.
> 
> The wild ass guess below prevents the xfs explosion below when running
> ltp zram tests.

Yes this looks correct. Thanks for noticing. I will fold it to the
patch2. Thanks for testing Mike!
> 
> ---
>  fs/xfs/kmem.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- a/fs/xfs/kmem.h
> +++ b/fs/xfs/kmem.h
> @@ -45,7 +45,7 @@ kmem_flags_convert(xfs_km_flags_t flags)
>  {
>  	gfp_t	lflags;
>  
> -	BUG_ON(flags & ~(KM_SLEEP|KM_NOSLEEP|KM_NOFS|KM_MAYFAIL|KM_ZERO));
> +	BUG_ON(flags & ~(KM_SLEEP|KM_NOSLEEP|KM_NOFS|KM_MAYFAIL|KM_ZERO|KM_NOLOCKDEP));
>  
>  	if (flags & KM_NOSLEEP) {
>  		lflags = GFP_ATOMIC | __GFP_NOWARN;
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
