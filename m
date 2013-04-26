Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 2054B6B0032
	for <linux-mm@kvack.org>; Fri, 26 Apr 2013 11:29:06 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <5163155D.7030401@sr71.net>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1365163198-29726-33-git-send-email-kirill.shutemov@linux.intel.com>
 <5163155D.7030401@sr71.net>
Subject: Re: [PATCHv3, RFC 32/34] thp: handle write-protect exception to
 file-backed huge pages
Content-Transfer-Encoding: 7bit
Message-Id: <20130426153104.92450E0085@blue.fi.intel.com>
Date: Fri, 26 Apr 2013 18:31:04 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> > +			if (!PageAnon(page)) {
> > +				add_mm_counter(mm, MM_FILEPAGES, -HPAGE_PMD_NR);
> > +				add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
> > +			}
> 
> This seems like a bit of a hack.  Shouldn't we have just been accounting
> to MM_FILEPAGES in the first place?

No, it's not.

It handles MAP_PRIVATE file mappings. The page was read first and
accounted to MM_FILEPAGES and then COW'ed by anon page here, so we have to
adjust counters. do_wp_page() has similar code.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
