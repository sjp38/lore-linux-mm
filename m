Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 2D8956B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 16:19:26 -0400 (EDT)
Date: Thu, 25 Oct 2012 07:19:21 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
Message-ID: <20121024201921.GX4291@dastard>
References: <1350996411-5425-1-git-send-email-casualfisher@gmail.com>
 <20121023224706.GR4291@dastard>
 <CAA9v8mGjdi9Kj7p-yeLJx-nr8C+u4M=QcP5+WcA+5iDs6-thGw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9v8mGjdi9Kj7p-yeLJx-nr8C+u4M=QcP5+WcA+5iDs6-thGw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YingHang Zhu <casualfisher@gmail.com>
Cc: akpm@linux-foundation.org, Fengguang Wu <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Oct 24, 2012 at 07:53:59AM +0800, YingHang Zhu wrote:
> Hi Dave,
> On Wed, Oct 24, 2012 at 6:47 AM, Dave Chinner <david@fromorbit.com> wrote:
> > On Tue, Oct 23, 2012 at 08:46:51PM +0800, Ying Zhu wrote:
> >> Hi,
> >>   Recently we ran into the bug that an opened file's ra_pages does not
> >> synchronize with it's backing device's when the latter is changed
> >> with blockdev --setra, the application needs to reopen the file
> >> to know the change,
> >
> > or simply call fadvise(fd, POSIX_FADV_NORMAL) to reset the readhead
> > window to the (new) bdi default.
> >
> >> which is inappropriate under our circumstances.
> >
> > Which are? We don't know your circumstances, so you need to tell us
> > why you need this and why existing methods of handling such changes
> > are insufficient...
> >
> > Optimal readahead windows tend to be a physical property of the
> > storage and that does not tend to change dynamically. Hence block
> > device readahead should only need to be set up once, and generally
> > that can be done before the filesystem is mounted and files are
> > opened (e.g. via udev rules). Hence you need to explain why you need
> > to change the default block device readahead on the fly, and why
> > fadvise(POSIX_FADV_NORMAL) is "inappropriate" to set readahead
> > windows to the new defaults.
> Our system is a fuse-based file system, fuse creates a
> pseudo backing device for the user space file systems, the default readahead
> size is 128KB and it can't fully utilize the backing storage's read ability,
> so we should tune it.

Sure, but that doesn't tell me anything about why you can't do this
at mount time before the application opens any files. i.e.  you've
simply stated the reason why readahead is tunable, not why you need
to be fully dynamic.....

> The above third-party application using our file system maintains
> some long-opened files, we does not have any chances
> to force them to call fadvise(POSIX_FADV_NORMAL). :(

So raise a bug/feature request with the third party.  Modifying
kernel code because you can't directly modify the application isn't
the best solution for anyone. This really is an application problem
- the kernel already provides the mechanisms to solve this
problem...  :/

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
