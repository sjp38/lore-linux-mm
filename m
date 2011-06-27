Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7765F9000BD
	for <linux-mm@kvack.org>; Mon, 27 Jun 2011 07:54:26 -0400 (EDT)
Message-ID: <4E086F51.50403@draigBrady.com>
Date: Mon, 27 Jun 2011 12:53:53 +0100
From: =?ISO-8859-1?Q?P=E1draig_Brady?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 0/2] fadvise: support POSIX_FADV_NOREUSE
References: <1308923350-7932-1-git-send-email-andrea@betterlinux.com> <4E07F349.2040900@jp.fujitsu.com> <20110627071139.GC1247@thinkpad> <4E0858CF.6070808@draigBrady.com> <20110627102933.GA1282@thinkpad>
In-Reply-To: <20110627102933.GA1282@thinkpad>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, minchan.kim@gmail.com, riel@redhat.com, peterz@infradead.org, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, hughd@google.com, jamesjer@betterlinux.com, marcus@bluehost.com, matt@bluehost.com, tytso@mit.edu, shaohua.li@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 27/06/11 11:29, Andrea Righi wrote:
> The actual problem I think is that apps expect that DONTNEED can be used
> to drop cache, but this is not written anywhere in the POSIX standard.
> 
> I would also like to have both functionalities: 1) be sure to drop page
> cache pages (now there's only a system-wide knob to do this:
> /proc/sys/vm/drop_caches), 2) give an advice to the kernel that I will
> not reuse some pages in the future.
> 
> The standard can only provide 2). If we also want 1) at the file
> granularity, I think we'd need to introduce something linux specific to
> avoid having portability problems.

True, though Linux is the reference for posix_fadvise() implementations,
given its lack of support on other platforms.

So just to summarize for _my_ reference.
You're changing DONTNEED to mean "drop if !PageActive()".
I.E. according to http://linux-mm.org/PageReplacementDesign
"drop if files only accessed once".

This will mean that there is no way currently to
remove a particular file from the cache on linux.
Hopefully that won't affect any of:
http://codesearch.google.com/#search/&q=POSIX_FADV_DONTNEED

Ideally I'd like cache functions for:
 DROP, ADD, ADD if space1
which could correspond to:
 DONTNEED, WILLNEED, NOREUSE
but what we're going for are these somewhat overlapping functions:
 DROP if used once2, ADD, ADD if space

cheers,
Padraig.

1 Not implemented yet.

2 Hopefully there are no access patterns a single
process can do to make a PageActive as that would
probably not be desired in relation to "Drop if used once"
functionality.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
