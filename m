Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 99DA56B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 11:22:32 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 4so173525113pfw.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 08:22:32 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.9])
        by mx.google.com with ESMTPS id h82si11565607pfd.43.2016.05.05.08.22.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 08:22:31 -0700 (PDT)
Date: Thu, 5 May 2016 08:22:30 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
Message-ID: <20160505152230.GA3994@infradead.org>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
 <1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
 <5727753F.6090104@plexistor.com>
 <20160505142433.GA4557@infradead.org>
 <CAPcyv4gdmo5m=Arf5sp5izJfNaaAkaaMbOzud8KRcBEC8RRu1Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4gdmo5m=Arf5sp5izJfNaaAkaaMbOzud8KRcBEC8RRu1Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Boaz Harrosh <boaz@plexistor.com>, linux-block@vger.kernel.org, linux-ext4 <linux-ext4@vger.kernel.org>, Jan Kara <jack@suse.cz>, Matthew Wilcox <matthew@wil.cx>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>, Jens Axboe <axboe@fb.com>, Linux MM <linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, May 05, 2016 at 08:15:32AM -0700, Dan Williams wrote:
> > Agreed - makig O_DIRECT less direct than not having it is plain stupid,
> > and I somehow missed this initially.
> 
> Of course I disagree because like Dave argues in the msync case we
> should do the correct thing first and make it fast later, but also
> like Dave this arguing in circles is getting tiresome.

We should do the right thing first, and make it fast later.  But this
proposal is not getting it right - it still does not handle errors
for the fast path, but magically makes it work for direct I/O by
in general using a less optional path for O_DIRECT.  It's getting the
worst of all choices.

As far as I can tell the only sensible option is to:

 - always try dax-like I/O first
 - have a custom get_user_pages + rw_bytes fallback handles bad blocks
   when hitting EIO

And then we need to sort out the concurrent write synchronization.
Again there I think we absolutely have to obey Posix for the !O_DIRECT
case and can avoid it for O_DIRECT, similar to the existing non-DAX
semantics.  If we want any special additional semantics we _will_ need
a special O_DAX flag.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
