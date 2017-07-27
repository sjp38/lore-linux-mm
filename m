Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 634136B025F
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:47:14 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id p135so16960095qke.0
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:47:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 28si15006437qts.227.2017.07.27.05.47.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 05:47:13 -0700 (PDT)
Date: Thu, 27 Jul 2017 08:47:08 -0400 (EDT)
From: Bob Peterson <rpeterso@redhat.com>
Message-ID: <932895023.34932662.1501159628674.JavaMail.zimbra@redhat.com>
In-Reply-To: <1501107773.15159.6.camel@redhat.com>
References: <20170726175538.13885-1-jlayton@kernel.org> <20170726175538.13885-5-jlayton@kernel.org> <20170726192105.GD15980@bombadil.infradead.org> <1501107773.15159.6.camel@redhat.com>
Subject: Re: [PATCH v2 4/4] gfs2: convert to errseq_t based writeback error
 reporting for fsync
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Jeff Layton <jlayton@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, "J . Bruce Fields" <bfields@fieldses.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com

----- Original Message -----
| On Wed, 2017-07-26 at 12:21 -0700, Matthew Wilcox wrote:
| > On Wed, Jul 26, 2017 at 01:55:38PM -0400, Jeff Layton wrote:
| > > @@ -668,12 +668,14 @@ static int gfs2_fsync(struct file *file, loff_t
| > > start, loff_t end,
| > >  		if (ret)
| > >  			return ret;
| > >  		if (gfs2_is_jdata(ip))
| > > -			filemap_write_and_wait(mapping);
| > > +			ret = file_write_and_wait(file);
| > > +		if (ret)
| > > +			return ret;
| > >  		gfs2_ail_flush(ip->i_gl, 1);
| > >  	}
| > 
| > Do we want to skip flushing the AIL if there was an error (possibly
| > previously encountered)?  I'd think we'd want to flush the AIL then report
| > the error, like this:
| > 
| 
| I wondered about that. Note that earlier in the function, we also bail
| out without flushing the AIL if sync_inode_metadata fails, so I assumed
| that we'd want to do the same here.
| 
| I could definitely be wrong and am fine with changing it if so.
| Discarding the error like we do today seems wrong though.
| 
| Bob, thoughts?

Hi Jeff, Matthew,

I'm not sure there's a right or wrong answer here. I don't know what's
best from a "correctness" point of view.

I guess I'm leaning toward Jeff's original solution where we don't
call gfs2_ail_flush() on error. The main purpose of ail_flush is to
go through buffer descriptors (bds) attached to the glock and generate
revokes for them in a new transaction. If there's an error condition,
trying to go through more hoops will probably just get us into more
trouble. If the error is -ENOMEM, we don't want to allocate new memory
for the new transaction. If the error is -EIO, we probably don't
want to encourage more writing either.

So on the one hand, it might be good to get rid of the buffer descriptors
so we don't leak memory, but that's probably also done elsewhere.
I have not chased down what happens in that case, but the same thing
would happen in the existing -EIO case a few lines above.

On the other hand, we probably don't want to start a new transaction
and start adding revokes to it, and such, due to the error.

Perhaps Steve Whitehouse can weigh in?

Regards,

Bob Peterson
Red Hat File Systems

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
