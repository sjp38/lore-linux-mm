Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 7D8086B0072
	for <linux-mm@kvack.org>; Sat, 27 Oct 2012 21:58:12 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/3] ext4: introduce ext4_error_remove_page
Date: Sat, 27 Oct 2012 21:57:38 -0400
Message-Id: <1351389458-5279-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20121027221626.GA9161@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Akira Fujita <a-fujita@rs.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Theodore Ts'o <tytso@mit.edu>"Luck, Tony" <tony.luck@intel.com>Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>"Kleen, Andi" <andi.kleen@intel.com>"Wu, Fengguang" <fengguang.wu@intel.com>Andrew Morton <akpm@linux-foundation.org>Jan Kara <jack@suse.cz>Jun'ichi Nomura <j-nomura@ce.jp.nec.com>

Hi Ted,

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

Thank you for the info. This could help my next work.

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

Whether we use EIO or EHWPOISON seems to be controversial. Andi likes
to use EIO because we can handle memory errors and legacy I/O errors in
the similar and integrated manner.
But personally, it's OK for me to use EHWPOISON. Obviously defining this
error code in glibc is a necessary step if we go in this direction.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
