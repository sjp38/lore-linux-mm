Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 744C62808A3
	for <linux-mm@kvack.org>; Wed, 10 May 2017 10:18:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b5so24525332pfe.0
        for <linux-mm@kvack.org>; Wed, 10 May 2017 07:18:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t61si2943352plb.258.2017.05.10.07.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 07:18:24 -0700 (PDT)
Date: Wed, 10 May 2017 07:18:21 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v4 13/27] lib: add errseq_t type and infrastructure for
 handling it
Message-ID: <20170510141821.GB1590@bombadil.infradead.org>
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

On Tue, May 09, 2017 at 11:49:16AM -0400, Jeff Layton wrote:
> +++ b/lib/errseq.c
> @@ -0,0 +1,199 @@
> +#include <linux/err.h>
> +#include <linux/bug.h>
> +#include <linux/atomic.h>
> +#include <linux/errseq.h>
> +
> +/*
> + * An errseq_t is a way of recording errors in one place, and allowing any
> + * number of "subscribers" to tell whether it has changed since an arbitrary
> + * time of their choosing.

You use the word "time" in several places in the documentation, but I think
it's clearer to say "sampling point" or "sample", since you're not using jiffies
or nanoseconds.  For example, I'd phrase this paragraph this way:

 * An errseq_t is a way of recording errors in one place, and allowing any
 * number of "subscribers" to tell whether it has changed since they last
 * sampled it.

> + * The general idea is for consumers to sample an errseq_t value at a
> + * particular point in time. Later, that value can be used to tell whether any
> + * new errors have occurred since that time.

 * The general idea is for consumers to sample an errseq_t value.  That
 * value can be used to tell whether any new errors have occurred since
 * the last time it was sampled.

> +/* The "ones" bit for the counter */

Maybe "The lowest bit of the counter"?

> +/**
> + * errseq_check - has an error occurred since a particular point in time?

"has an error occurred since the last time it was sampled"

> +/**
> + * errseq_check_and_advance - check an errseq_t and advance it to the current value
> + * @eseq: pointer to value being checked reported

"value being checked reported"?

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
> +	old = READ_ONCE(*eseq);
> +	if (old != *since) {
> +		/*
> +		 * Set the flag and try to swap it into place if it has
> +		 * changed.
> +		 *
> +		 * We don't care about the outcome of the swap here. If the
> +		 * swap doesn't occur, then it has either been updated by a
> +		 * writer who is bumping the seq count anyway, or another
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

I probably need to read through the patchset some more to understand this.
Naively, surely "since" should be updated to the current value of 'eseq'
if we failed the cmpxchg()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
