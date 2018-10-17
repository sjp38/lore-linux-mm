Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF8E46B0006
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 12:40:59 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d7-v6so11501291pfj.6
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 09:40:59 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id p7-v6si19371319pll.42.2018.10.17.09.40.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 09:40:58 -0700 (PDT)
Date: Wed, 17 Oct 2018 09:40:39 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [PATCH 25/26] xfs: support returning partial reflink results
Message-ID: <20181017164039.GP28243@magnolia>
References: <153965939489.1256.7400115244528045860.stgit@magnolia>
 <153966005536.3607.787445581785795364.stgit@magnolia>
 <20181017084002.GI16896@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181017084002.GI16896@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Wed, Oct 17, 2018 at 01:40:02AM -0700, Christoph Hellwig wrote:
> > @@ -1415,11 +1419,17 @@ xfs_reflink_remap_range(
> >  
> >  	trace_xfs_reflink_remap_range(src, pos_in, len, dest, pos_out);
> >  
> > +	if (len == 0) {
> > +		ret = 0;
> > +		goto out_unlock;
> > +	}
> > +
> 
> As pointed out last time this check is superflous, right above we have
> this check:
> 
> 	if (ret < 0 || len == 0)
> 		return ret;

Oops, sorry I missed that, will fix now.

> >  	ret = xfs_reflink_remap_blocks(src, sfsbno, dest, dfsbno, fsblen,
> > -			pos_out + len);
> > +			&remappedfsb, pos_out + len);
> > +	remapped_bytes = min_t(loff_t, len, XFS_FSB_TO_B(mp, remappedfsb));
> 
> I still think returning the bytes from the function would be saner,
> but maybe that's just me.

Hmmm, this call site is getting messy; I'll tack on another patch to
clean that up too.

--D
