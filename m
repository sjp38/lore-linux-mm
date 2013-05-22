Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 251C16B00DE
	for <linux-mm@kvack.org>; Wed, 22 May 2013 11:31:41 -0400 (EDT)
Message-ID: <519CE4DB.9070303@sr71.net>
Date: Wed, 22 May 2013 08:31:39 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCHv4 09/39] thp, mm: introduce mapping_can_have_hugepages()
 predicate
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com> <1368321816-17719-10-git-send-email-kirill.shutemov@linux.intel.com> <519BCACD.4020106@sr71.net> <20130522135112.32C3EE0090@blue.fi.intel.com>
In-Reply-To: <20130522135112.32C3EE0090@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 05/22/2013 06:51 AM, Kirill A. Shutemov wrote:
> Dave Hansen wrote:
>> Also, what happens if "transparent_hugepage_flags &
>> (1<<TRANSPARENT_HUGEPAGE_PAGECACHE)" becomes false at runtime and you
>> have some already-instantiated huge page cache mappings around?  Will
>> things like mapping_align_mask() break?
> 
> We will not touch existing huge pages in existing VMAs. The userspace can
> use them until they will be unmapped or split. It's consistent with anon
> THP pages.
> 
> If anybody mmap() the file after disabling the feature, we will not
> setup huge pages anymore: transparent_hugepage_enabled() check in
> handle_mm_fault will fail and the page fill be split.
> 
> mapping_align_mask() is part of mmap() call path, so there's only chance
> that we will get VMA aligned more strictly then needed. Nothing to worry
> about.

Could we get a little blurb along those lines somewhere?  Maybe even in
your docs that you've added to Documentation/.  Oh, wait, you don't have
any documentation? :)

You did add a sysfs knob, so you do owe us some docs for it.

"If the THP-cache sysfs tunable is disabled, huge pages will no longer
be mapped with new mmap()s, but they will remain in place in the page
cache.  You might still see some benefits from read/write operations,
etc..."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
