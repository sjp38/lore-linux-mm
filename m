Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f170.google.com (mail-ea0-f170.google.com [209.85.215.170])
	by kanga.kvack.org (Postfix) with ESMTP id 001596B0031
	for <linux-mm@kvack.org>; Mon, 30 Dec 2013 05:48:57 -0500 (EST)
Received: by mail-ea0-f170.google.com with SMTP id k10so5062379eaj.29
        for <linux-mm@kvack.org>; Mon, 30 Dec 2013 02:48:57 -0800 (PST)
Received: from jenni1.inet.fi (mta-out.inet.fi. [195.156.147.13])
        by mx.google.com with ESMTP id m49si51750322eeg.136.2013.12.30.02.48.56
        for <linux-mm@kvack.org>;
        Mon, 30 Dec 2013 02:48:57 -0800 (PST)
Date: Mon, 30 Dec 2013 12:48:54 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: dump page when hitting a VM_BUG_ON using
 VM_BUG_ON_PAGE fix
Message-ID: <20131230104854.GA7647@node.dhcp.inet.fi>
References: <1388184018-11396-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1388184018-11396-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 27, 2013 at 05:40:18PM -0500, Sasha Levin wrote:
> I messed up and forgot to commit this fix before sending out the original
> patch.
> 
> It fixes build issues in various files using VM_BUG_ON_PAGE.

With the patch applied I see this:

  CC      kernel/bounds.s
In file included from /home/space/kas/git/public/linux-next/include/linux/page-flags.h:10:0,
                 from /home/space/kas/git/public/linux-next/kernel/bounds.c:9:
/home/space/kas/git/public/linux-next/include/linux/mmdebug.h:5:30: warning: a??struct pagea?? declared inside parameter list [enabled by default]
 extern void dump_page(struct page *page);
                              ^
/home/space/kas/git/public/linux-next/include/linux/mmdebug.h:5:30: warning: its scope is only this definition or declaration, which is probably not what you want [enabled by default]

We need to declare struct page here as well.

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 8bb64900da25..e8cec8bdda05 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -2,6 +2,7 @@
 #define LINUX_MM_DEBUG_H 1
 
 #ifdef CONFIG_DEBUG_VM
+struct page;
 extern void dump_page(struct page *page);
 #define VM_BUG_ON(cond) BUG_ON(cond)
 #define VM_BUG_ON_PAGE(cond, page) \
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
