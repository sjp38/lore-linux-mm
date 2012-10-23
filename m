Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 8EBF16B0070
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 18:47:10 -0400 (EDT)
Date: Wed, 24 Oct 2012 09:47:06 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
Message-ID: <20121023224706.GR4291@dastard>
References: <1350996411-5425-1-git-send-email-casualfisher@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1350996411-5425-1-git-send-email-casualfisher@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Zhu <casualfisher@gmail.com>
Cc: akpm@linux-foundation.org, fengguang.wu@intel.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Oct 23, 2012 at 08:46:51PM +0800, Ying Zhu wrote:
> Hi,
>   Recently we ran into the bug that an opened file's ra_pages does not
> synchronize with it's backing device's when the latter is changed
> with blockdev --setra, the application needs to reopen the file
> to know the change,

or simply call fadvise(fd, POSIX_FADV_NORMAL) to reset the readhead
window to the (new) bdi default.

> which is inappropriate under our circumstances.

Which are? We don't know your circumstances, so you need to tell us
why you need this and why existing methods of handling such changes
are insufficient...

Optimal readahead windows tend to be a physical property of the
storage and that does not tend to change dynamically. Hence block
device readahead should only need to be set up once, and generally
that can be done before the filesystem is mounted and files are
opened (e.g. via udev rules). Hence you need to explain why you need
to change the default block device readahead on the fly, and why
fadvise(POSIX_FADV_NORMAL) is "inappropriate" to set readahead
windows to the new defaults.

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
