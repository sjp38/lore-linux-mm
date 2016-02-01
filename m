Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id AA5EA6B0005
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 09:38:56 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id p63so74292656wmp.1
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 06:38:56 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id i142si12146305wmd.8.2016.02.01.06.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 06:38:55 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id l66so9428078wml.2
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 06:38:55 -0800 (PST)
Date: Mon, 1 Feb 2016 16:38:53 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/2] mm: fix bogus VM_BUG_ON_PAGE() in isolate_lru_page()
Message-ID: <20160201143853.GA30090@node.shutemov.name>
References: <1454333169-121369-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1454333169-121369-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20160201142446.GB24008@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160201142446.GB24008@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 01, 2016 at 03:24:46PM +0100, Michal Hocko wrote:
> On Mon 01-02-16 16:26:08, Kirill A. Shutemov wrote:
> > We don't care if there's a tail pages which is not on LRU. We are not
> > going to isolate them anyway.
> 
> yes we are not going to isolate them but calling this function on a
> tail page is wrong in principle, no? PageLRU check is racy outside of
> lru_lock so what if we are racing here. I know, highly unlikely but not
> impossible. So I am not really sure this is an improvement. When would
> we hit this VM_BUG_ON and it wouldn't be a bug or at least suspicious
> usage?

Yes, there is no point in calling isolate_lru_page() for tail pages, but
we do this anyway -- see the second patch.

And we need to validate all drivers, that they don't forget to set VM_IO
or make vma_migratable() return false in other way.

Alternative approach would be to downgrate the VM_BUG_ON_PAGE() to
WARN_ONCE_ON(). This way we would have chance to catch bad callers.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
