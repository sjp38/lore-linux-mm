Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 74E1B6B0032
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 17:13:43 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so1694018pdj.29
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 14:13:43 -0700 (PDT)
Message-ID: <5244A368.4080208@sr71.net>
Date: Thu, 26 Sep 2013 14:13:12 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv6 00/22] Transparent huge page cache: phase 1, everything
 but mmap()
References: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1379937950-8411-1-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Ning Qu <quning@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Luck, Tony" <tony.luck@intel.com>Andi Kleen <ak@linux.intel.com>

On 09/23/2013 05:05 AM, Kirill A. Shutemov wrote:
> To proof that the proposed changes are functional we enable the feature
> for the most simple file system -- ramfs. ramfs is not that useful by
> itself, but it's good pilot project.

This does, at the least, give us a shared memory mechanism that can move
between large and small pages.  We don't have anything which can do that
today.

Tony Luck was just mentioning that if we have a small (say 1-bit) memory
failure in a hugetlbfs page, then we end up tossing out the entire 2MB.
 The app gets a chance to recover the contents, but it has to do it for
the entire 2MB.  Ideally, we'd like to break the 2M down in to 4k pages,
which lets us continue using the remaining 2M-4k, and leaves the app to
rebuild 4k of its data instead of 2M.

If you look at the diffstat, it's also pretty obvious that virtually
none of this code is actually specific to ramfs.  It'll all get used as
the foundation for the "real" filesystems too.  I'm very interested in
how those end up looking, too, but I think Kirill is selling his patches
a bit short calling this a toy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
