Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BCDA06B003B
	for <linux-mm@kvack.org>; Fri, 29 Aug 2014 15:37:33 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id z10so1093828pdj.3
        for <linux-mm@kvack.org>; Fri, 29 Aug 2014 12:37:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e1si1966213pdb.51.2014.08.29.12.37.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Aug 2014 12:37:32 -0700 (PDT)
Date: Fri, 29 Aug 2014 12:37:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] Introduce dump_vma
Message-Id: <20140829123730.ac09a559320224f7ed84f1c7@linux-foundation.org>
In-Reply-To: <1409324059-28692-1-git-send-email-sasha.levin@oracle.com>
References: <1409324059-28692-1-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: kirill.shutemov@linux.intel.com, khlebnikov@openvz.org, riel@redhat.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, mhocko@suse.cz, hughd@google.com, vbabka@suse.cz, walken@google.com, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 29 Aug 2014 10:54:17 -0400 Sasha Levin <sasha.levin@oracle.com> wrote:

> Introduce a helper to dump information about a VMA, this also
> makes dump_page_flags more generic and re-uses that so the
> output looks very similar to dump_page:
> 

That's another kilobyte which we don't actually use unless
CONFIG_DEBUG_VM, so how about we do

--- a/mm/page_alloc.c~introduce-dump_vma-fix
+++ a/mm/page_alloc.c
@@ -6683,6 +6683,8 @@ void dump_page(struct page *page, const
 }
 EXPORT_SYMBOL(dump_page);
 
+#ifdef CONFIG_DEBUG_VM
+
 static const struct trace_print_flags vmaflags_names[] = {
 	{VM_READ,			"read"		},
 	{VM_WRITE,			"write"		},
@@ -6740,3 +6742,5 @@ void dump_vma(const struct vm_area_struc
 	dump_flags(vma->vm_flags, vmaflags_names, ARRAY_SIZE(vmaflags_names));
 }
 EXPORT_SYMBOL(dump_vma);
+
+#endif		/* CONFIG_DEBUG_VM */

until someone needs it from non-debug code?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
