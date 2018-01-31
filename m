Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 607556B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 13:14:01 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id e23so9221126oii.9
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 10:14:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d26si1108945otd.105.2018.01.31.10.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 10:14:00 -0800 (PST)
Date: Wed, 31 Jan 2018 13:13:56 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] Killing reliance on struct page->mapping
Message-ID: <20180131181356.GG2912@redhat.com>
References: <20180130004347.GD4526@redhat.com>
 <20180131165646.GI29051@ZenIV.linux.org.uk>
 <20180131174245.GE2912@redhat.com>
 <20180131175558.GA30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180131175558.GA30522@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org

On Wed, Jan 31, 2018 at 05:55:58PM +0000, Al Viro wrote:
> On Wed, Jan 31, 2018 at 12:42:45PM -0500, Jerome Glisse wrote:
> 
> > For block devices the idea is to use struct page and buffer_head (first one of
> > a page) as a key to find mapping (struct address_space) back.
> 
> Details, please...

Note that i am not talking about block device page (i am excluding
those from that). So just regular filesystem page (ext*,xfs,btrfs,
...).

So in block device context AFAIK only time when you need mapping is
if they are some I/O error. Given than i am doing this with intent to
write protect the page one can argue that i can wait for all writeback
to complete before proceeding. At that time, it does not matter to block
device if page->mapping is no longer an address_space because the block
device code is done with the page and has forget about it.

That's one solution, another one is to have struct bio_vec store
buffer_head pointer and not page pointer, from buffer_head you can
find struct page and using buffer_head and struct page pointer you
can walk the KSM rmap_item chain to find back the mapping. This
would be needed on I/O error for pending writeback of a newly write
protected page, so one can argue that the overhead of the chain lookup
to find back the mapping against which to report IO error, is an
acceptable cost.

Another solution is to override the writeback end callback with
special one capable of finding the mapping from struct page and bio
pointer. This would not need any change to block device code. It
would have the same overhead thought as solution 2 above.


My intention was to stick to first solution (wait for writeback and
make no modification to block device struct or function). Then latter
if it make sense to add support to write protect a page before write
back is done.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
