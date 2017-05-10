Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EC0352808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 07:34:33 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g12so7799316wrg.15
        for <linux-mm@kvack.org>; Wed, 10 May 2017 04:34:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 61si2990277wrp.328.2017.05.10.04.34.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 10 May 2017 04:34:32 -0700 (PDT)
Date: Wed, 10 May 2017 13:34:30 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v4 13/27] lib: add errseq_t type and infrastructure for
 handling it
Message-ID: <20170510113430.GE25137@quack2.suse.cz>
References: <20170509154930.29524-1-jlayton@redhat.com>
 <20170509154930.29524-14-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170509154930.29524-14-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

On Tue 09-05-17 11:49:16, Jeff Layton wrote:
> An errseq_t is a way of recording errors in one place, and allowing any
> number of "subscribers" to tell whether an error has been set again
> since a previous time.
> 
> It's implemented as an unsigned 32-bit value that is managed with atomic
> operations. The low order bits are designated to hold an error code
> (max size of MAX_ERRNO). The upper bits are used as a counter.
> 
> The API works with consumers sampling an errseq_t value at a particular
> point in time. Later, that value can be used to tell whether new errors
> have been set since that time.
> 
> Note that there is a 1 in 512k risk of collisions here if new errors
> are being recorded frequently, since we have so few bits to use as a
> counter. To mitigate this, one bit is used as a flag to tell whether the
> value has been sampled since a new value was recorded. That allows
> us to avoid bumping the counter if no one has sampled it since it
> was last bumped.
> 
> Later patches will build on this infrastructure to change how writeback
> errors are tracked in the kernel.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

The patch looks good to me. Feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

Just two nits below:
...
> +int errseq_check_and_advance(errseq_t *eseq, errseq_t *since)
> +{
> +	int err = 0;
> +	errseq_t old, new;
> +
> +	/*
> +	 * Most callers will want to use the inline wrapper to check this,
> +	 * so that the common case of no error is handled without needing
> +	 * to lock.
> +	 */

I'm not sure which locking you are speaking about here. Is the comment
stale?

> +	old = READ_ONCE(*eseq);
> +	if (old != *since) {
> +		/*
> +		 * Set the flag and try to swap it into place if it has
> +		 * changed.
> +		 *
> +		 * We don't care about the outcome of the swap here. If the
> +		 * swap doesn't occur, then it has either been updated by a
> +		 * writer who is bumping the seq count anyway, or another

"bumping the seq count anyway" part is not quite true. Writer may see
ERRSEQ_SEEN not set and so just update the error code and leave seq count
as is. But since you compare full errseq_t for equality, this works out as
designed...

> +		 * reader who is just setting the "seen" flag. Either outcome
> +		 * is OK, and we can advance "since" and return an error based
> +		 * on what we have.
> +		 */
> +		new = old | ERRSEQ_SEEN;
> +		if (new != old)
> +			cmpxchg(eseq, old, new);
> +		*since = new;
> +		err = -(new & MAX_ERRNO);
> +	}
> +	return err;
> +}
> +EXPORT_SYMBOL(errseq_check_and_advance);

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
