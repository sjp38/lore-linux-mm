Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81EDE6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 18:22:56 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o124so68629114qke.9
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:22:56 -0700 (PDT)
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com. [209.85.220.171])
        by mx.google.com with ESMTPS id f92si3086915qtd.528.2017.07.26.15.22.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 15:22:55 -0700 (PDT)
Received: by mail-qk0-f171.google.com with SMTP id x191so27409176qka.5
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 15:22:55 -0700 (PDT)
Message-ID: <1501107773.15159.6.camel@redhat.com>
Subject: Re: [PATCH v2 4/4] gfs2: convert to errseq_t based writeback error
 reporting for fsync
From: Jeff Layton <jlayton@redhat.com>
Date: Wed, 26 Jul 2017 18:22:53 -0400
In-Reply-To: <20170726192105.GD15980@bombadil.infradead.org>
References: <20170726175538.13885-1-jlayton@kernel.org>
	 <20170726175538.13885-5-jlayton@kernel.org>
	 <20170726192105.GD15980@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Jeff Layton <jlayton@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, "J .
 Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

On Wed, 2017-07-26 at 12:21 -0700, Matthew Wilcox wrote:
> On Wed, Jul 26, 2017 at 01:55:38PM -0400, Jeff Layton wrote:
> > @@ -668,12 +668,14 @@ static int gfs2_fsync(struct file *file, loff_t start, loff_t end,
> >  		if (ret)
> >  			return ret;
> >  		if (gfs2_is_jdata(ip))
> > -			filemap_write_and_wait(mapping);
> > +			ret = file_write_and_wait(file);
> > +		if (ret)
> > +			return ret;
> >  		gfs2_ail_flush(ip->i_gl, 1);
> >  	}
> 
> Do we want to skip flushing the AIL if there was an error (possibly
> previously encountered)?  I'd think we'd want to flush the AIL then report
> the error, like this:
> 

I wondered about that. Note that earlier in the function, we also bail
out without flushing the AIL if sync_inode_metadata fails, so I assumed
that we'd want to do the same here. 

I could definitely be wrong and am fine with changing it if so.
Discarding the error like we do today seems wrong though.

Bob, thoughts?


>  		if (gfs2_is_jdata(ip))
> -			filemap_write_and_wait(mapping);
> +			ret = file_write_and_wait(file);
>  		gfs2_ail_flush(ip->i_gl, 1);
> +		if (ret)
> +			return ret;
>  	}
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
