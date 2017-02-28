Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id A034D6B0390
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 06:32:44 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id n127so14671564qkf.3
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 03:32:44 -0800 (PST)
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com. [209.85.220.172])
        by mx.google.com with ESMTPS id g5si1226048qkf.141.2017.02.28.03.32.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 03:32:43 -0800 (PST)
Received: by mail-qk0-f172.google.com with SMTP id u188so13504994qkc.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 03:32:43 -0800 (PST)
Message-ID: <1488281559.2874.1.camel@redhat.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] do we really need PG_error at all?
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 28 Feb 2017 06:32:39 -0500
In-Reply-To: <0bea2b1c-ddb1-f2bf-8ef7-b83d6a6404fc@gmail.com>
References: <1488120164.2948.4.camel@redhat.com>
	 <1488129033.4157.8.camel@HansenPartnership.com>
	 <877f4cr7ew.fsf@notabene.neil.brown.name>
	 <1488151856.4157.50.camel@HansenPartnership.com>
	 <874lzgqy06.fsf@notabene.neil.brown.name>
	 <1488208047.2876.6.camel@redhat.com>
	 <DC27F5BA-BCCA-41FF-8D41-7BB99AA4DB26@dilger.ca>
	 <87varvp5v1.fsf@notabene.neil.brown.name>
	 <1488244308.7627.5.camel@redhat.com>
	 <0bea2b1c-ddb1-f2bf-8ef7-b83d6a6404fc@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>, NeilBrown <neilb@suse.com>, Andreas Dilger <adilger@dilger.ca>
Cc: linux-block@vger.kernel.org, linux-scsi <linux-scsi@vger.kernel.org>, lsf-pc <lsf-pc@lists.linuxfoundation.org>, Neil Brown <neilb@suse.de>, LKML <linux-kernel@vger.kernel.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, 2017-02-28 at 12:12 +0200, Boaz Harrosh wrote:
> On 02/28/2017 03:11 AM, Jeff Layton wrote:
> <>
> > 
> > I'll probably have questions about the read side as well, but for now it
> > looks like it's mostly used in an ad-hoc way to communicate errors
> > across subsystems (block to fs layer, for instance).
> 
> If memory does not fail me it used to be checked long time ago in the
> read-ahead case. On the buffered read case, the first page is read synchronous
> and any error is returned to the caller, but then a read-ahead chunk is
> read async all the while the original thread returned to the application.
> So any errors are only recorded on the page-bit, since otherwise the uptodate
> is off and the IO will be retransmitted. Then the move to read_iter changed
> all that I think.
> But again this is like 5-6 years ago, and maybe I didn't even understand
> very well.
> 

Yep, that's what I meant about using it to communicate errors between
layers. e.g. end_buffer_async_read will check PageError and only
SetPageUptodate if it's not set. That has morphed a lot in the last few
years though and it looks like it may rely on PG_error less than it used
to.

> 
> I would like a Documentation of all this as well please. Where are the
> tests for this?
> 

Documentation is certainly doable (and I'd like to write some once we
have this all straightened out). In particular, I think we need clear
guidelines for fs authors on how to handle pagecache read and write
errors. Tests are a little tougher -- this is all kernel-internal stuff
and not easily visible to userland.

The one thing I have noticed is that even if you set AS_ENOSPC in the
mapping, you'll still get back -EIO on the first fsync if any PG_error
bits are set. I think we ought to fix that by not doing the
TestClearPageError call in __filemap_fdatawait_range, and just rely on
the mapping error there.

We could maybe roll a test for that, but it's rather hard to test ENOSPC
conditions in a fs-agnostic way. I'm open to suggestions here though.

-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
