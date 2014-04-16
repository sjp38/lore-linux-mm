Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 67B896B006E
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 19:07:44 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so11172754pdj.6
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 16:07:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id pc9si13503318pac.66.2014.04.16.16.07.43
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 16:07:43 -0700 (PDT)
Date: Wed, 16 Apr 2014 16:07:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [v2] mm: pass VM_BUG_ON() reason to dump_page()
Message-Id: <20140416160742.96794b2e97d43ed615e6b9bd@linux-foundation.org>
In-Reply-To: <20140411204232.C8CF1A7A@viggo.jf.intel.com>
References: <20140411204232.C8CF1A7A@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com, kirill.shutemov@linux.intel.com

On Fri, 11 Apr 2014 13:42:32 -0700 Dave Hansen <dave@sr71.net> wrote:

> 
> I recently added a patch to let folks pass a "reason" string
> dump_page() which gets dumped out along with the page's data.
> This essentially saves the bug-reader a trip in to the source
> to figure out why we BUG_ON()'d.
> 
> The new VM_BUG_ON_PAGE() passes in NULL for "reason".  It seems
> like we might as well pass the BUG_ON() condition if we have it.
> This will bloat kernels a bit with ~160 new strings, but this
> is all under a debugging option anyway.
> 
> 	page:ffffea0008560280 count:1 mapcount:0 mapping:(null) index:0x0
> 	page flags: 0xbfffc0000000001(locked)
> 	page dumped because: VM_BUG_ON_PAGE(PageLocked(page))
> 	------------[ cut here ]------------
> 	kernel BUG at /home/davehans/linux.git/mm/filemap.c:464!
> 	invalid opcode: 0000 [#1] SMP
> 	CPU: 0 PID: 1 Comm: swapper/0 Not tainted 3.14.0+ #251
> 	Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
> 	...
>
> ...
>
> --- a/include/linux/mmdebug.h~pass-VM_BUG_ON-reason-to-dump_page	2014-04-11 13:39:26.313125298 -0700
> +++ b/include/linux/mmdebug.h	2014-04-11 13:40:26.417835916 -0700
> @@ -9,8 +9,13 @@ extern void dump_page_badflags(struct pa
>  
>  #ifdef CONFIG_DEBUG_VM
>  #define VM_BUG_ON(cond) BUG_ON(cond)
> -#define VM_BUG_ON_PAGE(cond, page) \
> -	do { if (unlikely(cond)) { dump_page(page, NULL); BUG(); } } while (0)
> +#define VM_BUG_ON_PAGE(cond, page)						\
> +	do {									\
> +		if (unlikely(cond)) {						\
> +			dump_page(page, "VM_BUG_ON_PAGE(" __stringify(cond)")");\
> +			BUG();							\
> +		}								\
> +	} while (0)

This seems prudent:

--- a/include/linux/mmdebug.h~mm-pass-vm_bug_on-reason-to-dump_page-fix
+++ a/include/linux/mmdebug.h
@@ -1,6 +1,8 @@
 #ifndef LINUX_MM_DEBUG_H
 #define LINUX_MM_DEBUG_H 1
 
+#include <linux/stringify.h>
+
 struct page;
 
 extern void dump_page(struct page *page, const char *reason);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
