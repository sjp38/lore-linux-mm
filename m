Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E84D36B0005
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 10:43:12 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g15-v6so1404970pfh.10
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 07:43:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d65-v6si3104651pfg.142.2018.06.13.07.43.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Jun 2018 07:43:11 -0700 (PDT)
Date: Wed, 13 Jun 2018 07:42:53 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V6 00/30] block: support multipage bvec
Message-ID: <20180613144253.GA4693@infradead.org>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180611164806.GA7452@infradead.org>
 <20180612034242.GC26412@ming.t460p>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180612034242.GC26412@ming.t460p>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Tue, Jun 12, 2018 at 11:42:49AM +0800, Ming Lei wrote:
> On Mon, Jun 11, 2018 at 09:48:06AM -0700, Christoph Hellwig wrote:
> > D? think the new naming scheme in this series is a nightmare.  It
> > confuses the heck out of me, and that is despite knowing many bits of
> > the block layer inside out, and reviewing previous series.
> 
> In V5, there isn't such issue, since bio_for_each_segment* is renamed
> into bio_for_each_page* first before doing the change.

But now we are at V6 where that isn't the case..

> Seems Jens isn't fine with the big renaming, then I follow the suggestion
> of taking 'chunk' for representing multipage bvec in V6.

Please don't use chunk.  We are iterating over bio_vec structures, while
we have the concept of a chunk size for something else in the block layer,
so this just creates confusion.  Nevermind names like
bio_for_each_chunk_segment_all which just double the confusion.

So assuming that bio_for_each_segment is set to stay as-is for now,
here is a proposal for sanity by using the vec name.

OLD:	    bio_for_each_segment
NEW(page):  bio_for_each_segment, to be renamed bio_for_each_page later
NEW(bvec):  bio_for_each_bvec

OLD:	    __bio_for_each_segment
NEW(page):  __bio_for_each_segment, to be renamed __bio_for_each_page later
NEW(bvec):  (no bvec version needed)

OLD:	    bio_for_each_segment_all
NEW(page):  bio_for_each_page_all (needs updated prototype anyway)
NEW(bvec):  (no bvec version needed once bcache is fixed up)	
