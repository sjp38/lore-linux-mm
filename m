Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE7656B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 03:38:38 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id q203so13428716wmb.0
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 00:38:38 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id v2si5232597wra.381.2017.10.16.00.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Oct 2017 00:38:37 -0700 (PDT)
Date: Mon, 16 Oct 2017 09:38:36 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v9 1/6] mm: introduce MAP_SHARED_VALIDATE, a mechanism
	to safely define new mmap flags
Message-ID: <20171016073836.GB28778@lst.de>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com> <150776923320.9144.6119113178052262946.stgit@dwillia2-desk3.amr.corp.intel.com> <20171012135127.GG29293@quack2.suse.cz> <CA+55aFyy-nz99c6erFh=aeyCOzsk0td5wHaVLpwBNA-sWNDZkA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyy-nz99c6erFh=aeyCOzsk0td5wHaVLpwBNA-sWNDZkA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Arnd Bergmann <arnd@arndb.de>, Linux API <linux-api@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Thu, Oct 12, 2017 at 09:32:17AM -0700, Linus Torvalds wrote:
> On Thu, Oct 12, 2017 at 6:51 AM, Jan Kara <jack@suse.cz> wrote:
> >
> > When thinking a bit more about this I've realized one problem: Currently
> > user can call mmap() with MAP_SHARED type and MAP_SYNC or MAP_DIRECT flags
> > and he will get the new semantics (if the kernel happens to support it).  I
> > think that is undesirable [..]
> 
> Why?
> 
> If you have a performance preference for MAP_DIRECT or something like
> that, but you don't want to *enforce* it, you'd use just plain
> MAP_SHARED with it.
> 
> Ie there may well be "I want this to work, possibly with downsides" issues.
> 
> So it seems to be a reasonable model, and disallowing it seems to
> limit people and not really help anything.

I don't think for MAP_DIRECT it matters (and I think we shouldn't have
MAP_DIRECT to start with, see the discussions later in the thread).

But for the main use case, MAP_SYNC you really want a hard error when you
don't get it.  And while we could tell people that they should only use
MAP_SYNC with MAP_SHARED_VALIDATE instead of MAP_SHARED chances that they
get it wrong are extremely high.  On the other hand if you really only
want a flag to optimize calling mmap twice is very little overhead, and
a very good documentation of you intent:

	addr = mmap(...., MAP_SHARED_VALIDATE | MAP_DIRECT, ...);
	if (!addr && errno = EOPNOTSUPP) {
		/* MAP_DIRECT didn't work, we'll just cope using blah, blah */
		addr = mmap(...., MAP_SHARED, ...);
	}
	if (!addr)
		goto handle_error;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
