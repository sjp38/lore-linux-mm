Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f48.google.com (mail-bk0-f48.google.com [209.85.214.48])
	by kanga.kvack.org (Postfix) with ESMTP id DD6D16B0035
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 01:24:30 -0500 (EST)
Received: by mail-bk0-f48.google.com with SMTP id r7so1229503bkg.35
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 22:24:30 -0800 (PST)
Received: from mail-la0-x22c.google.com (mail-la0-x22c.google.com [2a00:1450:4010:c03::22c])
        by mx.google.com with ESMTPS id uo7si257371bkb.64.2013.12.12.22.24.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 22:24:29 -0800 (PST)
Received: by mail-la0-f44.google.com with SMTP id ep20so1067202lab.31
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 22:24:29 -0800 (PST)
Date: Fri, 13 Dec 2013 10:24:27 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: fix use-after-free in sys_remap_file_pages
Message-ID: <20131213062427.GH8167@moon>
References: <20131212220757.GA14928@www.outflux.net>
 <20131212224118.17a951c2@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131212224118.17a951c2@annuminas.surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, PaX Team <pageexec@freemail.hu>, Dmitry Vyukov <dvyukov@google.com>

On Thu, Dec 12, 2013 at 10:41:18PM -0500, Rik van Riel wrote:
> 
> If the vma has been freed by the time the code jumps to the
> out label (because it was freed by a function called from
> mmap_region), surely it will also already have been freed
> by the time this patch dereferences it?
> 
> Also, setting vma = NULL to avoid the if (vma) branch at
> the out: label is unnecessarily obfuscated. Lets make things
> clear by documenting what is going on, and having a label
> after that dereference.

This patch is a bit easier to read, at least for me. And if
I understand the code flow right, the issue is due to
remap_file_pages -> mmap_region -> find_vma_links -> do_munmap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
