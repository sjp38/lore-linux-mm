Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E2E226B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 03:56:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y142so8388000wme.12
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 00:56:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 125si4960467wmk.237.2017.10.16.00.56.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Oct 2017 00:56:56 -0700 (PDT)
Date: Mon, 16 Oct 2017 09:56:55 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v9 1/6] mm: introduce MAP_SHARED_VALIDATE, a mechanism to
 safely define new mmap flags
Message-ID: <20171016075655.GE32738@quack2.suse.cz>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150776923320.9144.6119113178052262946.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171012135127.GG29293@quack2.suse.cz>
 <CA+55aFyy-nz99c6erFh=aeyCOzsk0td5wHaVLpwBNA-sWNDZkA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyy-nz99c6erFh=aeyCOzsk0td5wHaVLpwBNA-sWNDZkA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Arnd Bergmann <arnd@arndb.de>, Linux API <linux-api@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>

On Thu 12-10-17 09:32:17, Linus Torvalds wrote:
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

I have two concerns:

1) IMHO it supports sloppy programming from userspace - if application asks
e.g. for MAP_DIRECT and doesn't know whether it gets it or not, it would
have to be very careful not to assume anything about that in its code. And
frankly I think the most likely scenario is that a programmer will just use
MAP_SHARED | MAP_DIRECT, *assume* he will get the MAP_DIRECT semantics if
the call does not fail and then complain when his application breaks.

2) In theory there could be an application that inadvertedly sets some high
flag bits and now it would get confused by getting different mmap(2)
semantics. But I agree this is mostly theoretical.

Overall I think the benefit of being able to say "do MAP_DIRECT if you can"
does not outweight the risk of bugs in userspace applications. Especially
since userspace can easily implement the same semantics by retrying the
mmap(2) call without MAP_SHARED_VALIDATE | MAP_DIRECT.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
