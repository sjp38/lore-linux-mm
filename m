Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8801D6B0254
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 06:16:59 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l68so31284637wml.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 03:16:59 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id jo7si36811611wjc.179.2016.03.01.03.16.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 03:16:58 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id p65so28580830wmp.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 03:16:58 -0800 (PST)
Date: Tue, 1 Mar 2016 14:16:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: __delete_from_page_cache show Bad page if mapped
Message-ID: <20160301111656.GA19095@node.shutemov.name>
References: <alpine.LSU.2.11.1602282042110.1472@eggly.anvils>
 <20160229095216.GA9616@node.shutemov.name>
 <alpine.LSU.2.11.1602292217070.7377@eggly.anvils>
 <alpine.LSU.2.11.1602292244320.7377@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1602292244320.7377@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 29, 2016 at 10:45:59PM -0800, Hugh Dickins wrote:
> Commit e1534ae95004 ("mm: differentiate page_mapped() from page_mapcount()
> for compound pages") changed the famous BUG_ON(page_mapped(page)) in
> __delete_from_page_cache() to VM_BUG_ON_PAGE(page_mapped(page)): which
> gives us more info when CONFIG_DEBUG_VM=y, but nothing at all when not.
> 
> Although it has not usually been very helpul, being hit long after the
> error in question, we do need to know if it actually happens on users'
> systems; but reinstating a crash there is likely to be opposed :)
> 
> In the non-debug case, pr_alert("BUG: Bad page cache") plus dump_page(),
> dump_stack(), add_taint() - I don't really believe LOCKDEP_NOW_UNRELIABLE,
> but that seems to be the standard procedure now.  Move that, or the
> VM_BUG_ON_PAGE(), up before the deletion from tree: so that the
> unNULLified page->mapping gives a little more information.
> 
> If the inode is being evicted (rather than truncated), it won't have
> any vmas left, so it's safe(ish) to assume that the raised mapcount is
> erroneous, and we can discount it from page_count to avoid leaking the
> page (I'm less worried by leaking the occasional 4kB, than losing a
> potential 2MB page with each 4kB page leaked).
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
