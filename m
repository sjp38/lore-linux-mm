Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5811C6B003C
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 08:35:15 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so1311751eek.23
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 05:35:14 -0700 (PDT)
Received: from moutng.kundenserver.de (moutng.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id r9si10041963eew.18.2014.03.14.05.35.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Mar 2014 05:35:13 -0700 (PDT)
Message-ID: <1394800460.3853.8.camel@dinghy>
Subject: Re: [PATCHv2] mm: implement POSIX_FADV_NOREUSE
From: Lukas Senger <lukas@fridolin.com>
Date: Fri, 14 Mar 2014 13:34:20 +0100
In-Reply-To: <20140313130115.e5abf7da216e6a7610d4cd36@linux-foundation.org>
References: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
	 <1394736229-30684-1-git-send-email-matthias.wirth@gmail.com>
	 <20140313130115.e5abf7da216e6a7610d4cd36@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthias Wirth <matthias.wirth@gmail.com>, i4passt@lists.cs.fau.de, Dave Hansen <dave.hansen@linux.intel.com>, Matthew Wilcox <matthew@wil.cx>, Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Lisa Du <cldu@marvell.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Lukas Czerner <lczerner@redhat.com>, Damien Ramonda <damien.ramonda@intel.com>, Mark Rutland <mark.rutland@arm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2014-03-13 at 13:01 -0700, Andrew Morton wrote:
> On Thu, 13 Mar 2014 19:43:41 +0100 Matthias Wirth <matthias.wirth@gmail.com> wrote:
> 
> > Backups, logrotation and indexers don't need files they read to remain
> > in the page cache. Their pages can be reclaimed early and should not
> > displace useful pages. POSIX specifices the POSIX_FADV_NOREUSE flag for
> > these use cases but it's currently a noop.
> 
> As far as I can tell, POSIX_FADV_DONTNEED suits these applications
> quite well.  Why is this patch happening?

Using DONTNEED means the application will throw out its pages even if
they are used by other processes. If the application wants to be more
polite it needs a way to find out whether thats the case. One way is to
use mincore to get a snapshot of pages before mmaping the file and then
keeping pages that were already cached before we accessed them. This of
course ignores all accesses by other processes occuring while we use the
file and doesn't work with read. Apart from those flaws, does that kind
of page cache management belong into userspace?

> My proposal to deactivate the pages within the fadvise() call violates
> that, because the spec wants us to act *after* the app has touched the
> pages.
> 
> Your proposed implementation violates it because it affects data
> outside the specified range.
> 
> It would be interesting to know what the *bsd guys chose to do, but I
> don't understand it from the amount of context in
> http://lists.freebsd.org/pipermail/svn-src-stable-9/2012-August/002608.html
> 
> Ignoring the range and impacting the entire file (for this fd) is a
> bit lame.  Alternatives include:
> 
> a) Implement a per-fd tree of (start,len) ranges and maintain and
>    search that.  blah.
> 
> b) violate the spec in a different fashion and implement NOREUSE
>    synchronously within fadvise.
> 
> From a practical point of view, I'm currently inclining toward b). 
> Yes, we require NOREUSE be run *after* the read() instead of before it,
> but what's wrong with that?  It's just as easy to implement from
> userspace.  Perhaps we should call it POSIX_FADV_NOREUSE_LINUX to make
> it clear that we went our own way.

The problem with calling fadvise with NOREUSE_LINUX after read is that
it makes writing applications in a portable way harder. As you point
out, our version doesn't adhere to the spec perfectly either, but I'd
wager it covers the most common use case. And a) would at least allow a
spec faithful implementation in the future.

> I don't think that per-cpu page thing is suitable, really.  If this
> task context-switches to a different CPU then we get the wrong page. 
> This will happen pretty often as the task is performing physical IO. 
> This can be fixed by putting the page* into the task_struct instead,
> but passing function args via current-> is a bit of a hack.  Why not
> create add_to_page_cache_lru_tail()?

We agree and will send a new version with add_to_page_cache_lru_tail.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
