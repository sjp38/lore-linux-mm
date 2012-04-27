Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id CC54F6B004D
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 09:37:40 -0400 (EDT)
Message-ID: <4F9AA11E.3040800@parallels.com>
Date: Fri, 27 Apr 2012 17:37:34 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] proc: report file/anon bit in /proc/pid/pagemap
References: <4F91BC8A.9020503@parallels.com> <20120427123901.2132.47969.stgit@zurg>
In-Reply-To: <20120427123901.2132.47969.stgit@zurg>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>

On 04/27/2012 04:39 PM, Konstantin Khlebnikov wrote:
> This is an implementation of Andrew's proposal to extend the pagemap file
> bits to report what is missing about tasks' working set.
> 
> The problem with the working set detection is multilateral. In the criu
> (checkpoint/restore) project we dump the tasks' memory into image files
> and to do it properly we need to detect which pages inside mappings are
> really in use. The mincore syscall I though could help with this did not.
> First, it doesn't report swapped pages, thus we cannot find out which
> parts of anonymous mappings to dump. Next, it does report pages from page
> cache as present even if they are not mapped, and it doesn't make
> difference between private pages that has been cow-ed and private pages
> that has not been cow-ed.
> 
> Note, that issue with swap pages is critical -- we must dump swap pages to
> image file. But the issues with file pages are optimization -- we can take
> all file pages to image, this would be correct, but if we know that a page
> is not mapped or not cow-ed, we can remove them from dump file. The dump
> would still be self-consistent, though significantly smaller in size (up
> to 10 times smaller on real apps).
> 
> Andrew noticed, that the proc pagemap file solved 2 of 3 above issues -- it
> reports whether a page is present or swapped and it doesn't report not
> mapped page cache pages. But, it doesn't distinguish cow-ed file pages from
> not cow-ed.
> 
> I would like to make the last unused bit in this file to report whether the
> page mapped into respective pte is PageAnon or not.
> 
> v2:
> * Rebase to uptodate kernel
> * Fix file/anon bit reporting for migration entries
> * Fix frame bits interval comment, it uses 55 lower bits (64 - 3 - 6)
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>

Acked-by: Pavel Emelyanov <xemul@parallels.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
