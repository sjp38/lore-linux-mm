Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id EBF8D6B006C
	for <linux-mm@kvack.org>; Sun, 28 Oct 2012 21:16:36 -0400 (EDT)
Date: Mon, 29 Oct 2012 12:16:32 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/3] ext4: introduce ext4_error_remove_page
Message-ID: <20121029011632.GN29378@dastard>
References: <1351177969-893-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1351177969-893-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20121026061206.GA31139@thunk.org>
 <3908561D78D1C84285E8C5FCA982C28F19D5A13B@ORSMSX108.amr.corp.intel.com>
 <20121026184649.GA8614@thunk.org>
 <3908561D78D1C84285E8C5FCA982C28F19D5A388@ORSMSX108.amr.corp.intel.com>
 <20121027221626.GA9161@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121027221626.GA9161@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, "Luck, Tony" <tony.luck@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Akira Fujita <a-fujita@rs.jp.nec.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>

On Sat, Oct 27, 2012 at 06:16:26PM -0400, Theodore Ts'o wrote:
> On Fri, Oct 26, 2012 at 10:24:23PM +0000, Luck, Tony wrote:
> > > Well, we could set a new attribute bit on the file which indicates
> > > that the file has been corrupted, and this could cause any attempts to
> > > open the file to return some error until the bit has been cleared.
> > 
> > That sounds a lot better than renaming/moving the file.
> 
> What I would recommend is adding a 
> 
> #define FS_CORRUPTED_FL		0x01000000 /* File is corrupted */
> 
> ... and which could be accessed and cleared via the lsattr and chattr
> programs.

Except that there are filesystems that cannot implement such flags,
or require on-disk format changes to add more of those flags. This
is most definitely not a filesystem specific behaviour, so any sort
of VFS level per-file state needs to be kept in xattrs, not special
flags. Filesystems are welcome to optimise the storage of such
special xattrs (e.g. down to a single boolean flag in an inode), but
using a flag for something that dould, in fact, storage the exactly
offset and length of the corruption is far better than just storing
a "something is corrupted in this file" bit....

> > > Application programs could also get very confused when any attempt to
> > > open or read from a file suddenly returned some new error code (EIO,
> > > or should we designate a new errno code for this purpose, so there is
> > > a better indication of what the heck was going on?)
> > 
> > EIO sounds wrong ... but it is perhaps the best of the existing codes. Adding
> > a new one is also challenging too.
> 
> I think we really need a different error code from EIO; it's already
> horribly overloaded already, and if this is new behavior when the
> customers get confused and call up the distribution help desk, they
> won't thank us if we further overload EIO.  This is abusing one of the
> System V stream errno's, but no one else is using it:
> 
> #define EADV		 68  /* Advertise error */
> 
> I note that we've already added a new error code:
> 
> #define EHWPOISON 133	  /* Memory page has hardware error */
> 
> ... although the glibc shipping with Debian testing hasn't been taught
> what it is, so strerror(EHWPOISON) returns "Unknown error 133".  We
> could simply allow open(2) and stat(2) return this error, although I
> wonder if we're just better off defining a new error code.

If we are going to add special new "file corrupted" errors, we
should add EFSCORRUPTED (i.e. "filesystem corrupted") at the same
time....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
