Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id BB8D56B02D1
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 12:59:06 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id k1so41895437qtb.20
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:59:06 -0700 (PDT)
Received: from mail-qt0-f180.google.com (mail-qt0-f180.google.com. [209.85.216.180])
        by mx.google.com with ESMTPS id 30si18152377qtw.234.2017.04.24.09.59.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 09:59:06 -0700 (PDT)
Received: by mail-qt0-f180.google.com with SMTP id g60so119283863qtd.3
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:59:05 -0700 (PDT)
Message-ID: <1493053143.2895.15.camel@redhat.com>
Subject: Re: [PATCH v3 20/20] gfs2: clean up some filemap_* calls
From: Jeff Layton <jlayton@redhat.com>
Date: Mon, 24 Apr 2017 12:59:03 -0400
In-Reply-To: <2139341349.405174.1493043175630.JavaMail.zimbra@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
	 <20170424132259.8680-21-jlayton@redhat.com>
	 <2139341349.405174.1493043175630.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Peterson <rpeterso@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross zwisler <ross.zwisler@linux.intel.com>, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

On Mon, 2017-04-24 at 10:12 -0400, Bob Peterson wrote:
> ----- Original Message -----
> > In some places, it's trying to reset the mapping error after calling
> > filemap_fdatawait. That's no longer required. Also, turn several
> > filemap_fdatawrite+filemap_fdatawait calls into filemap_write_and_wait.
> > That will at least return writeback errors that occur during the write
> > phase.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/gfs2/glops.c | 12 ++++--------
> >  fs/gfs2/lops.c  |  4 +---
> >  fs/gfs2/super.c |  6 ++----
> >  3 files changed, 7 insertions(+), 15 deletions(-)
> > 
> > diff --git a/fs/gfs2/glops.c b/fs/gfs2/glops.c
> > index 5db59d444838..7362d19fdc4c 100644
> > --- a/fs/gfs2/glops.c
> > +++ b/fs/gfs2/glops.c
> > @@ -158,9 +158,7 @@ static void rgrp_go_sync(struct gfs2_glock *gl)
> >  	GLOCK_BUG_ON(gl, gl->gl_state != LM_ST_EXCLUSIVE);
> >  
> >  	gfs2_log_flush(sdp, gl, NORMAL_FLUSH);
> > -	filemap_fdatawrite_range(mapping, gl->gl_vm.start, gl->gl_vm.end);
> > -	error = filemap_fdatawait_range(mapping, gl->gl_vm.start, gl->gl_vm.end);
> > -	mapping_set_error(mapping, error);
> > +	filemap_write_and_wait_range(mapping, gl->gl_vm.start, gl->gl_vm.end);
> 
> This should probably have "error = ", no?
> 

This error is discarded in the current code after resetting the error in
the mapping. With the earlier patches in this set we don't need to reset
the error like this anymore.

Now, if this code should doing something else with those errors, then
that's a separate problem.

> >  	gfs2_ail_empty_gl(gl);
> >  
> >  	spin_lock(&gl->gl_lockref.lock);
> > @@ -225,12 +223,10 @@ static void inode_go_sync(struct gfs2_glock *gl)
> >  	filemap_fdatawrite(metamapping);
> >  	if (ip) {
> >  		struct address_space *mapping = ip->i_inode.i_mapping;
> > -		filemap_fdatawrite(mapping);
> > -		error = filemap_fdatawait(mapping);
> > -		mapping_set_error(mapping, error);
> > +		filemap_write_and_wait(mapping);
> > +	} else {
> > +		filemap_fdatawait(metamapping);
> >  	}
> > -	error = filemap_fdatawait(metamapping);
> > -	mapping_set_error(metamapping, error);
> 
> This part doesn't look right at all. There's a big difference in gfs2 between
> mapping and metamapping. We need to wait for metamapping regardless.
> 

...and this should wait. Basically, filemap_write_and_wait does
filemap_fdatawrite and then filemap_fdatawait. This is mostly just
replacing the existing code with a more concise helper.

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
