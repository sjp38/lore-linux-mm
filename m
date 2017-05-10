Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51B6A6B03E8
	for <linux-mm@kvack.org>; Wed, 10 May 2017 07:29:23 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m91so10071419qte.10
        for <linux-mm@kvack.org>; Wed, 10 May 2017 04:29:23 -0700 (PDT)
Received: from mail-qt0-f180.google.com (mail-qt0-f180.google.com. [209.85.216.180])
        by mx.google.com with ESMTPS id i46si2829460qta.64.2017.05.10.04.29.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 May 2017 04:29:22 -0700 (PDT)
Received: by mail-qt0-f180.google.com with SMTP id n4so24929168qte.2
        for <linux-mm@kvack.org>; Wed, 10 May 2017 04:29:22 -0700 (PDT)
Message-ID: <1494415759.2688.3.camel@redhat.com>
Subject: Re: [PATCH v4 13/27] lib: add errseq_t type and infrastructure for
 handling it
From: Jeff Layton <jlayton@redhat.com>
Date: Wed, 10 May 2017 07:29:19 -0400
In-Reply-To: <87inl9n0wu.fsf@notabene.neil.brown.name>
References: <20170509154930.29524-1-jlayton@redhat.com>
	 <20170509154930.29524-14-jlayton@redhat.com>
	 <87inl9n0wu.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neil@brown.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

On Wed, 2017-05-10 at 08:03 +1000, NeilBrown wrote:
> On Tue, May 09 2017, Jeff Layton wrote:
> 
> > An errseq_t is a way of recording errors in one place, and allowing any
> > number of "subscribers" to tell whether an error has been set again
> > since a previous time.
> > 
> > It's implemented as an unsigned 32-bit value that is managed with atomic
> > operations. The low order bits are designated to hold an error code
> > (max size of MAX_ERRNO). The upper bits are used as a counter.
> > 
> > The API works with consumers sampling an errseq_t value at a particular
> > point in time. Later, that value can be used to tell whether new errors
> > have been set since that time.
> > 
> > Note that there is a 1 in 512k risk of collisions here if new errors
> > are being recorded frequently, since we have so few bits to use as a
> > counter. To mitigate this, one bit is used as a flag to tell whether the
> > value has been sampled since a new value was recorded. That allows
> > us to avoid bumping the counter if no one has sampled it since it
> > was last bumped.
> > 
> > Later patches will build on this infrastructure to change how writeback
> > errors are tracked in the kernel.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> 
> I like that this is a separate lib/*.c - nicely structured too.
> 
> Reviewed-by: NeilBrown <neilb@suse.com>
> 
> 

Thanks, yeah...it occurred to me that this scheme is not really specific
to writeback errors. While I can't think of another use-case for
errseq_t's right offhand, I think this makes for cleaner layering and
should make it easy to use in other ways should they arise.

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
