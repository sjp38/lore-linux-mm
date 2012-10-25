Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id F00B16B0071
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 21:50:18 -0400 (EDT)
Date: Thu, 25 Oct 2012 12:50:14 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
Message-ID: <20121025015014.GC29378@dastard>
References: <1350996411-5425-1-git-send-email-casualfisher@gmail.com>
 <20121023224706.GR4291@dastard>
 <CAA9v8mGjdi9Kj7p-yeLJx-nr8C+u4M=QcP5+WcA+5iDs6-thGw@mail.gmail.com>
 <20121024201921.GX4291@dastard>
 <CAA9v8mExDX1TYgCrRfYuh82SnNmNkqC4HjkmczSnz3Ca4zT_qw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA9v8mExDX1TYgCrRfYuh82SnNmNkqC4HjkmczSnz3Ca4zT_qw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: YingHang Zhu <casualfisher@gmail.com>
Cc: akpm@linux-foundation.org, Fengguang Wu <fengguang.wu@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 25, 2012 at 08:17:05AM +0800, YingHang Zhu wrote:
> On Thu, Oct 25, 2012 at 4:19 AM, Dave Chinner <david@fromorbit.com> wrote:
> > On Wed, Oct 24, 2012 at 07:53:59AM +0800, YingHang Zhu wrote:
> >> Hi Dave,
> >> On Wed, Oct 24, 2012 at 6:47 AM, Dave Chinner <david@fromorbit.com> wrote:
> >> > On Tue, Oct 23, 2012 at 08:46:51PM +0800, Ying Zhu wrote:
> >> >> Hi,
> >> >>   Recently we ran into the bug that an opened file's ra_pages does not
> >> >> synchronize with it's backing device's when the latter is changed
> >> >> with blockdev --setra, the application needs to reopen the file
> >> >> to know the change,
> >> >
> >> > or simply call fadvise(fd, POSIX_FADV_NORMAL) to reset the readhead
> >> > window to the (new) bdi default.
> >> >
> >> >> which is inappropriate under our circumstances.
> >> >
> >> > Which are? We don't know your circumstances, so you need to tell us
> >> > why you need this and why existing methods of handling such changes
> >> > are insufficient...
> >> >
> >> > Optimal readahead windows tend to be a physical property of the
> >> > storage and that does not tend to change dynamically. Hence block
> >> > device readahead should only need to be set up once, and generally
> >> > that can be done before the filesystem is mounted and files are
> >> > opened (e.g. via udev rules). Hence you need to explain why you need
> >> > to change the default block device readahead on the fly, and why
> >> > fadvise(POSIX_FADV_NORMAL) is "inappropriate" to set readahead
> >> > windows to the new defaults.
> >> Our system is a fuse-based file system, fuse creates a
> >> pseudo backing device for the user space file systems, the default readahead
> >> size is 128KB and it can't fully utilize the backing storage's read ability,
> >> so we should tune it.
> >
> > Sure, but that doesn't tell me anything about why you can't do this
> > at mount time before the application opens any files. i.e.  you've
> > simply stated the reason why readahead is tunable, not why you need
> > to be fully dynamic.....
> We store our file system's data on different disks so we need to change ra_pages
> dynamically according to where the data resides, it can't be fixed at mount time
> or when we open files.

That doesn't make a whole lot of sense to me. let me try to get this
straight.

There is data that resides on two devices (A + B), and a fuse
filesystem to access that data. There is a single file in the fuse
fs has data on both devices. An app has the file open, and when the
data it is accessing is on device A you need to set the readahead to
what is best for device A? And when the app tries to access data for
that file that is on device B, you need to set the readahead to what
is best for device B? And you are changing the fuse BDI readahead
settings according to where the data in the back end lies?

It seems to me that you should be setting the fuse readahead to the
maximum of the readahead windows the data devices have configured at
mount time and leaving it at that....

> The abstract bdi of fuse and btrfs provides some dynamically changing
> bdi.ra_pages
> based on the real backing device. IMHO this should not be ignored.

btrfs simply takes into account the number of disks it has for a
given storage pool when setting up the default bdi ra_pages during
mount.  This is basically doing what I suggested above.  Same with
the generic fuse code - it's simply setting a sensible default value
for the given fuse configuration.

Neither are dynamic in the sense you are talking about, though.

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
