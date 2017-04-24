Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 98B576B033C
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 13:52:40 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 39so42273912qts.5
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 10:52:40 -0700 (PDT)
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com. [209.85.220.182])
        by mx.google.com with ESMTPS id n187si18779517qkc.126.2017.04.24.10.52.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 10:52:39 -0700 (PDT)
Received: by mail-qk0-f182.google.com with SMTP id f76so44348771qke.2
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 10:52:39 -0700 (PDT)
Message-ID: <1493056356.2895.19.camel@redhat.com>
Subject: Re: [PATCH v3 20/20] gfs2: clean up some filemap_* calls
From: Jeff Layton <jlayton@redhat.com>
Date: Mon, 24 Apr 2017 13:52:36 -0400
In-Reply-To: <2092108386.509535.1493055674293.JavaMail.zimbra@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
	 <20170424132259.8680-21-jlayton@redhat.com>
	 <2139341349.405174.1493043175630.JavaMail.zimbra@redhat.com>
	 <1493053143.2895.15.camel@redhat.com>
	 <2092108386.509535.1493055674293.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Peterson <rpeterso@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross zwisler <ross.zwisler@linux.intel.com>, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

On Mon, 2017-04-24 at 13:41 -0400, Bob Peterson wrote:
> Hi,
> 
> ----- Original Message -----
> > On Mon, 2017-04-24 at 10:12 -0400, Bob Peterson wrote:
> > > > +	filemap_write_and_wait_range(mapping, gl->gl_vm.start, gl->gl_vm.end);
> > > 
> > > This should probably have "error = ", no?
> > > 
> > 
> > This error is discarded in the current code after resetting the error in
> > the mapping. With the earlier patches in this set we don't need to reset
> > the error like this anymore.
> > 
> > Now, if this code should doing something else with those errors, then
> > that's a separate problem.
> 
> Okay, I see. My bad.
>  
> > > >  	gfs2_ail_empty_gl(gl);
> > > >  
> > > >  	spin_lock(&gl->gl_lockref.lock);
> > > > @@ -225,12 +223,10 @@ static void inode_go_sync(struct gfs2_glock *gl)
> > > >  	filemap_fdatawrite(metamapping);
> > > >  	if (ip) {
> > > >  		struct address_space *mapping = ip->i_inode.i_mapping;
> > > > -		filemap_fdatawrite(mapping);
> > > > -		error = filemap_fdatawait(mapping);
> > > > -		mapping_set_error(mapping, error);
> > > > +		filemap_write_and_wait(mapping);
> > > > +	} else {
> > > > +		filemap_fdatawait(metamapping);
> > > >  	}
> > > > -	error = filemap_fdatawait(metamapping);
> > > > -	mapping_set_error(metamapping, error);
> > > 
> > > This part doesn't look right at all. There's a big difference in gfs2
> > > between
> > > mapping and metamapping. We need to wait for metamapping regardless.
> > > 
> > 
> > ...and this should wait. Basically, filemap_write_and_wait does
> > filemap_fdatawrite and then filemap_fdatawait. This is mostly just
> > replacing the existing code with a more concise helper.
> 
> But this isn't a simple replacement with a helper. This is two different
> address spaces (mapping and metamapping) and you added an else in there.
> 
> So with this patch metamapping gets written, and if there's an ip,
> mapping gets written but it doesn't wait for metamapping. Unless
> I'm missing something.
> 
> You could replace both filemap_fdatawrites with the helper instead.
> Today's code is structured as:
> 
> (a) write metamapping
> if (ip)
>     (b) write mapping
>     (c) wait for mapping
> (d) wait for metamapping
> 
> If you use the helper for both, it becomes, (a & d)(b & c) which is probably
> acceptable. (I think we just tried to optimize what the elevator was doing).
> 
> But the way you've got it coded here still looks wrong. It looks like:
> (a)
> if (ip)
>    (b & c)
> ELSE -
>    (d)
> 
> So (d) (metamapping) isn't guaranteed to be synced at the end of the function.
> Of course, you know the modified helper functions better than I do.
> What am I missing?
> 
> 

<facepalm>
You're right of course. I'll fix that up in my tree.

Thanks!
-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
