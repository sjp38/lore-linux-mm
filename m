Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id E5A7A6B0068
	for <linux-mm@kvack.org>; Wed, 29 Aug 2012 02:03:11 -0400 (EDT)
Message-ID: <503DA954.80009@ce.jp.nec.com>
Date: Wed, 29 Aug 2012 14:32:04 +0900
From: "Jun'ichi Nomura" <j-nomura@ce.jp.nec.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] HWPOISON: prevent inode cache removal to keep AS_HWPOISON
 sticky
References: <20120826222607.GD19235@dastard> <1346105106-26033-1-git-send-email-n-horiguchi@ah.jp.nec.com> <20120829025941.GD13691@dastard>
In-Reply-To: <20120829025941.GD13691@dastard>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/29/12 11:59, Dave Chinner wrote:
> On Mon, Aug 27, 2012 at 06:05:06PM -0400, Naoya Horiguchi wrote:
>> And yes, I understand it's ideal, but many applications choose not to
>> do that for performance reason.
>> So I think it's helpful if we can surely report to such applications.

I suspect "performance vs. integrity" is not a correct
description of the problem.

> If performance is chosen over data integrity, we are under no
> obligation to keep the error around indefinitely.  Fundamentally,
> ensuring a write completes successfully is the reponsibility of the
> application, not the kernel. There are so many different filesytem
> and storage errors that can be lost right now because data is not
> fsync()d, adding another one to them really doesn't change anything.
> IOWs, a memory error is no different to a disk failing or the system
> crashing when it comes to data integrity. If you care, you use
> fsync().

I agree that applications should fsync() or O_SYNC
when it wants to make sure the written data in on disk.

AFAIU, what Naoya is going to address is the case where
fsync() is not necessarily needed.

For example, if someone do:
  $ patch -p1 < ../a.patch
  $ tar cf . > ../a.tar

and disk failure occurred between "patch" and "tar",
"tar" will either see uptodate data or I/O error.
OTOH, if the failure was detected on dirty pagecache, the current memory
failure handler invalidates the dirty page and the "tar" command will
re-read old contents from disk without error.

(Well, the failures above are permanent failures. IOW, the current
 memory failure handler turns permanent failure into transient error,
 which is often more difficult to handle, I think.)

Naoya's patch will keep the failure information and allows the reader
to get I/O error when it reads from broken pagecache.

-- 
Jun'ichi Nomura, NEC Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
