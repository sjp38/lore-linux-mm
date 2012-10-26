Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E91256B0075
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 14:46:56 -0400 (EDT)
Date: Fri, 26 Oct 2012 14:46:49 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 2/3] ext4: introduce ext4_error_remove_page
Message-ID: <20121026184649.GA8614@thunk.org>
References: <1351177969-893-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1351177969-893-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20121026061206.GA31139@thunk.org>
 <3908561D78D1C84285E8C5FCA982C28F19D5A13B@ORSMSX108.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F19D5A13B@ORSMSX108.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Akira Fujita <a-fujita@rs.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On Fri, Oct 26, 2012 at 04:55:01PM +0000, Luck, Tony wrote:
> 
> I think that we know that the file *is* corrupted, not just "potentially".
> We probably know the location of the corruption to cache-line granularity.
> Perhaps better on systems where we have access to ecc syndrome bits,
> perhaps worse ... we do have some errors where the low bits of the address
> are not known.

Well, it's at least *possible* that it was only the ECC bits that got
flipped.  :-) Not likely, I'll grant!  (Or does the motherboard zero
out the entire cache-line on a hard ECC failure?)

> I'm in total agreement that forcing a reboot or fsck is unhelpful here.
> 
> But what should we do?  We don't want to let the error be propagated. That
> could cause a cascade of more failures as applications make bad decisions
> based on the corrupted data.
> 
> Perhaps we could ask the filesystem to move the file to a top-level
> "corrupted" directory (analogous to "lost+found") with some attached
> metadata to help recovery tools know where the file came from, and the
> range of corrupted bytes in the file? We'd also need to invalidate existing
> open file descriptors (or less damaging - flag them to avoid the corrupted
> area??). Whatever we do, it needs to be persistent across a reboot ... the
> lost bits are not going to magically heal themselves.

Well, we could set a new attribute bit on the file which indicates
that the file has been corrupted, and this could cause any attempts to
open the file to return some error until the bit has been cleared.
This would persist across reboots.  The only problem is that system
administrators might get very confused (at least at first, when they
first run a kernel or a distribution which has this feature enabled).
Application programs could also get very confused when any attempt to
open or read from a file suddenly returned some new error code (EIO,
or should we designate a new errno code for this purpose, so there is
a better indication of what the heck was going on?)

Also, if we just log the message in dmesg, if the system administrator
doesn't find the "this file is corrupted" bit right away, they might
not be able to determine which part of the file was corrupted.  How
important is this?  If the file system supports extended attributes,
should we attempt to attach a new extended attribute with information
about the ECC failure?

I'm not sure it's worth it to go to these extents, but I could imagine
some customers wanting to have this sort of information.  Do we know
what their "nice to have" / "must have" requirements might be?

     	       	       	       	    	 - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
