Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 5961D6B0035
	for <linux-mm@kvack.org>; Thu, 13 Mar 2014 16:01:41 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kp14so1587028pab.19
        for <linux-mm@kvack.org>; Thu, 13 Mar 2014 13:01:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id s3si1714514pbo.332.2014.03.13.13.01.17
        for <linux-mm@kvack.org>;
        Thu, 13 Mar 2014 13:01:17 -0700 (PDT)
Date: Thu, 13 Mar 2014 13:01:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv2] mm: implement POSIX_FADV_NOREUSE
Message-Id: <20140313130115.e5abf7da216e6a7610d4cd36@linux-foundation.org>
In-Reply-To: <1394736229-30684-1-git-send-email-matthias.wirth@gmail.com>
References: <1394533550-18485-1-git-send-email-matthias.wirth@gmail.com>
	<1394736229-30684-1-git-send-email-matthias.wirth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Wirth <matthias.wirth@gmail.com>
Cc: Lukas Senger <lukas@fridolin.com>, i4passt@lists.cs.fau.de, Dave Hansen <dave.hansen@linux.intel.com>, Matthew Wilcox <matthew@wil.cx>, Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, Lisa Du <cldu@marvell.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Sasha Levin <sasha.levin@oracle.com>, Al Viro <viro@zeniv.linux.org.uk>, Steven Whitehouse <swhiteho@redhat.com>, Fengguang Wu <fengguang.wu@intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Lukas Czerner <lczerner@redhat.com>, Damien Ramonda <damien.ramonda@intel.com>, Mark Rutland <mark.rutland@arm.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 13 Mar 2014 19:43:41 +0100 Matthias Wirth <matthias.wirth@gmail.com> wrote:

> Backups, logrotation and indexers don't need files they read to remain
> in the page cache. Their pages can be reclaimed early and should not
> displace useful pages. POSIX specifices the POSIX_FADV_NOREUSE flag for
> these use cases but it's currently a noop.

As far as I can tell, POSIX_FADV_DONTNEED suits these applications
quite well.  Why is this patch happening?

> Pages coming from files with FMODE_NOREUSE that are to be added to the
> page cache via add_to_page_cache_lru get their page struct pointer saved
> in a per_cpu variable which gets checked further along the way in
> __lru_cache_add. If the variable is set they get added to the new
> lru_add_tail_pvec which as a whole later gets added to the tail of the
> LRU list. Therefore these pages are the first to be reclaimed.
> 
> It might happen that a page is brought in via readahead for a file that
> has NOREUSE set and is then requested by another process. This can lead
> to the page being dropped from the page cache earlier even though the
> competing process still needs it. The impact of this however, is small
> as the likelihood of the page getting dropped is reduced because it
> probably moves to the active list when the page is accessed by the
> second process.

opengroup.org sayeth:

: The posix_fadvise() function shall advise the implementation on the
: expected behavior of the application with respect to the data in the
: file associated with the open file descriptor, fd, starting at offset
: and continuing for len bytes.  The specified range need not currently
: exist in the file.  If len is zero, all data following offset is
: specified.  The implementation may use this information to optimize
: handling of the specified data.  The posix_fadvise() function shall
: have no effect on the semantics of other operations on the specified
: data, although it may affect the performance of other operations.
:
: ...
:
: POSIX_FADV_NOREUSE
:   Specifies that the application expects to access the specified data
:   once and then not reuse it thereafter.

My proposal to deactivate the pages within the fadvise() call violates
that, because the spec wants us to act *after* the app has touched the
pages.

Your proposed implementation violates it because it affects data
outside the specified range.

It would be interesting to know what the *bsd guys chose to do, but I
don't understand it from the amount of context in
http://lists.freebsd.org/pipermail/svn-src-stable-9/2012-August/002608.html

Ignoring the range and impacting the entire file (for this fd) is a
bit lame.  Alternatives include:

a) Implement a per-fd tree of (start,len) ranges and maintain and
   search that.  blah.

b) violate the spec in a different fashion and implement NOREUSE
   synchronously within fadvise.

>From a practical point of view, I'm currently inclining toward b). 
Yes, we require NOREUSE be run *after* the read() instead of before it,
but what's wrong with that?  It's just as easy to implement from
userspace.  Perhaps we should call it POSIX_FADV_NOREUSE_LINUX to make
it clear that we went our own way.

It's difficult.  The spec's a-priori aspect makes implementation much
more difficult.


Your patch doesn't apply to current mainline, btw.  Minor rejects.

I don't think that per-cpu page thing is suitable, really.  If this
task context-switches to a different CPU then we get the wrong page. 
This will happen pretty often as the task is performing physical IO. 
This can be fixed by putting the page* into the task_struct instead,
but passing function args via current-> is a bit of a hack.  Why not
create add_to_page_cache_lru_tail()?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
