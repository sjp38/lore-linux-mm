Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id A37116B0071
	for <linux-mm@kvack.org>; Sun, 28 Oct 2012 22:40:34 -0400 (EDT)
Date: Sun, 28 Oct 2012 22:40:24 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH 2/3] ext4: introduce ext4_error_remove_page
Message-ID: <20121029024024.GC9365@thunk.org>
References: <1351177969-893-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1351177969-893-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20121026061206.GA31139@thunk.org>
 <3908561D78D1C84285E8C5FCA982C28F19D5A13B@ORSMSX108.amr.corp.intel.com>
 <20121026184649.GA8614@thunk.org>
 <3908561D78D1C84285E8C5FCA982C28F19D5A388@ORSMSX108.amr.corp.intel.com>
 <20121027221626.GA9161@thunk.org>
 <20121029011632.GN29378@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121029011632.GN29378@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Akira Fujita <a-fujita@rs.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On Mon, Oct 29, 2012 at 12:16:32PM +1100, Dave Chinner wrote:
> 
> Except that there are filesystems that cannot implement such flags,
> or require on-disk format changes to add more of those flags. This
> is most definitely not a filesystem specific behaviour, so any sort
> of VFS level per-file state needs to be kept in xattrs, not special
> flags. Filesystems are welcome to optimise the storage of such
> special xattrs (e.g. down to a single boolean flag in an inode), but
> using a flag for something that dould, in fact, storage the exactly
> offset and length of the corruption is far better than just storing
> a "something is corrupted in this file" bit....

Agreed, if we're going to add an xattr, then we might as well store
not just a boolean, but some indication of what part of the file was
corrupted.  The only complication is what if there are many memory
corruptions.  Do we store just the last ECC hard error that we
detected?  Or just the first?

It wasn't clear to me it was worth the extra complexity, but if there
are indeed for file systems that don't have or don't want to allocate
a spare bit in their inode structure, that might be a good enough
justification to add an xattr.  (Was this a hypothetical, or does this
constraint apply to XFS or some other file system that you're aware of?)

> > I note that we've already added a new error code:
> > 
> > #define EHWPOISON 133	  /* Memory page has hardware error */
> > 
> > ... although the glibc shipping with Debian testing hasn't been taught
> > what it is, so strerror(EHWPOISON) returns "Unknown error 133".  We
> > could simply allow open(2) and stat(2) return this error, although I
> > wonder if we're just better off defining a new error code.
> 
> If we are going to add special new "file corrupted" errors, we
> should add EFSCORRUPTED (i.e. "filesystem corrupted") at the same
> time....

I would dearly love it if we could allocate a new EFSCORRUPTED errno.
I was about to follow XFS's lead and change ext4 to return EUCLEAN
instead of EIO in the cases of fs corruption, but that really is ugly
and gross...

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
