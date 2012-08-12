Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 932136B0044
	for <linux-mm@kvack.org>; Sun, 12 Aug 2012 11:58:03 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/3] HWPOISON: improve handling/reporting of memory error on dirty pagecache
Date: Sun, 12 Aug 2012 11:57:54 -0400
Message-Id: <1344787074-6795-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F19375BFE@ORSMSX104.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Tony,

Thank you for the comment.

On Sat, Aug 11, 2012 at 10:41:49PM +0000, Luck, Tony wrote:
> > dirty pagecache error recoverable under some conditions. Consider that
> > if there is a copy of the corrupted dirty pagecache on user buffer and
> > you write() over the error page with the copy data, then we can ignore
> > the effect of the error because no one consumes the corrupted data.
> 
> This sounds like a quite rare corner case. If the page is already dirty, it is
> most likely because someone recently did a write(2) (or touched it via
> mmap(2)).

Yes, that's right.

> Now you are hoping that some process is going to write the
> same page again.  Do you have an application in mind where this would
> be common.

No, I don't, particularly.

> Remember that the write(2), memory-error, new write(2)
> have to happen close together (before Linux decides to write out the
> dirty page).

Maybe this is different from my scenario, where I assumed that a hwpoison-
aware application kicks the second write(2) when it catches a memory error
report from kernel, and this write(2) copies from the same buffer from
which the first write(2) copied into pagecache.
In many case, user space applications keep their buffers for a while after
calling write(2), so then we can consider that dirty pagecaches also can
have copies in the buffers. This is a key idea of error recovery.

And let me discuss about another point. When memory errors happen on
dirty pagecaches, they are isolated from pagecache trees. So neither
fsync(2) nor writeback can write out the corrupted data on the backing
devices. So I don't think that we have to be careful about closeness
between two write(2)s.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
