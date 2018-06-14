Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0D5C6B000C
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 21:19:20 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id k83-v6so3652042qkl.15
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 18:19:20 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id h20-v6si2472016qtm.314.2018.06.13.18.19.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jun 2018 18:19:19 -0700 (PDT)
Date: Thu, 14 Jun 2018 09:18:58 +0800
From: Ming Lei <ming.lei@redhat.com>
Subject: Re: [PATCH V6 00/30] block: support multipage bvec
Message-ID: <20180614011852.GA19828@ming.t460p>
References: <20180609123014.8861-1-ming.lei@redhat.com>
 <20180611164806.GA7452@infradead.org>
 <20180612034242.GC26412@ming.t460p>
 <20180613144253.GA4693@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180613144253.GA4693@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jens Axboe <axboe@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>, David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Randy Dunlap <rdunlap@infradead.org>

On Wed, Jun 13, 2018 at 07:42:53AM -0700, Christoph Hellwig wrote:
> On Tue, Jun 12, 2018 at 11:42:49AM +0800, Ming Lei wrote:
> > On Mon, Jun 11, 2018 at 09:48:06AM -0700, Christoph Hellwig wrote:
> > > D? think the new naming scheme in this series is a nightmare.  It
> > > confuses the heck out of me, and that is despite knowing many bits of
> > > the block layer inside out, and reviewing previous series.
> > 
> > In V5, there isn't such issue, since bio_for_each_segment* is renamed
> > into bio_for_each_page* first before doing the change.
> 
> But now we are at V6 where that isn't the case..
> 
> > Seems Jens isn't fine with the big renaming, then I follow the suggestion
> > of taking 'chunk' for representing multipage bvec in V6.
> 
> Please don't use chunk.  We are iterating over bio_vec structures, while
> we have the concept of a chunk size for something else in the block layer,
> so this just creates confusion.  Nevermind names like
> bio_for_each_chunk_segment_all which just double the confusion.

We may keep the name of bio_for_each_segment_all(), and just change
the prototype in one single big patch.

> 
> So assuming that bio_for_each_segment is set to stay as-is for now,
> here is a proposal for sanity by using the vec name.
> 
> OLD:	    bio_for_each_segment
> NEW(page):  bio_for_each_segment, to be renamed bio_for_each_page later
> NEW(bvec):  bio_for_each_bvec
> 
> OLD:	    __bio_for_each_segment
> NEW(page):  __bio_for_each_segment, to be renamed __bio_for_each_page later
> NEW(bvec):  (no bvec version needed)

For the above two, basically similar with V6, just V6 takes chunk, :-)

> 
> OLD:	    bio_for_each_segment_all
> NEW(page):  bio_for_each_page_all (needs updated prototype anyway)
> NEW(bvec):  (no bvec version needed once bcache is fixed up)	

This one may cause confusing, since we iterate over pages via
bio_for_each_segment(), but the _all version takes another name
of page, still iterate over pages.

So could we change it in the following way?

 OLD:	    bio_for_each_segment_all
 NEW(page): bio_for_each_segment_all (update prototype in one tree-wide &
 			big patch, to be renamed bio_for_each_page_all)
 NEW(bvec):  (no bvec version needed once bcache is fixed up)	


Thanks,
Ming
