Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 44C7A6B0032
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:28:35 -0400 (EDT)
Received: by widdi4 with SMTP id di4so158014194wid.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:28:34 -0700 (PDT)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id h2si40826729wjq.17.2015.04.28.15.28.33
        for <linux-mm@kvack.org>;
        Tue, 28 Apr 2015 15:28:33 -0700 (PDT)
Date: Wed, 29 Apr 2015 01:28:28 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] compaction: fix isolate_migratepages_block() for THP=n
Message-ID: <20150428222828.GA6072@node.dhcp.inet.fi>
References: <1430134006-215317-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20150428151420.227e7ac34745e9fe8e9bc145@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150428151420.227e7ac34745e9fe8e9bc145@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>

On Tue, Apr 28, 2015 at 03:14:20PM -0700, Andrew Morton wrote:
> On Mon, 27 Apr 2015 14:26:46 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > PageTrans* helpers are always-false if THP is disabled compile-time.
> > It means the fucntion will fail to detect hugetlb pages in this case.
> > 
> > Let's use PageCompound() instead. With small tweak to how we calculate
> > next low_pfn it will make function ready to see tail pages.
> 
> <scratches head>
> 
> So this patch has no runtime effects at present?  It is preparation for
> something else?

I wrote this to fix bug I originally attributed to refcounting patchset,
but Sasha triggered the same bug on -next without the patchset applied:

http://lkml.kernel.org/g/553EB993.7030401@oracle.com

Now I think it's related to changing of PageLRU() behaviour on tail page
by my page flags patchset. PageLRU() on tail pages now reports true if
head page is on LRU. It means no we can go futher insede
isolate_migratepages_block() with tail page.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
