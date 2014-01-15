Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f208.google.com (mail-ve0-f208.google.com [209.85.128.208])
	by kanga.kvack.org (Postfix) with ESMTP id 9CE0F6B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 11:20:26 -0500 (EST)
Received: by mail-ve0-f208.google.com with SMTP id jw12so21006veb.11
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 08:20:26 -0800 (PST)
Received: from mail.active-venture.com (mail.active-venture.com. [67.228.131.205])
        by mx.google.com with ESMTP id bx5si3527932oec.143.2014.01.15.02.31.52
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 02:31:53 -0800 (PST)
Message-ID: <52D66396.5050104@roeck-us.net>
Date: Wed, 15 Jan 2014 02:31:50 -0800
From: Guenter Roeck <linux@roeck-us.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Make {,set}page_address() static inline if WANT_PAGE_VIRTUAL
References: <1389778426-14836-1-git-send-email-geert@linux-m68k.org>
In-Reply-To: <1389778426-14836-1-git-send-email-geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, linux-bcache@vger.kernel.org, Vineet Gupta <vgupta@synopsys.com>, sparclinux@vger.kernel.org, linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org

On 01/15/2014 01:33 AM, Geert Uytterhoeven wrote:
> {,set}page_address() are macros if WANT_PAGE_VIRTUAL.
> If !WANT_PAGE_VIRTUAL, they're plain C functions.
>
> If someone calls them with a void *, this pointer is auto-converted to
> struct page * if !WANT_PAGE_VIRTUAL, but causes a build failure on
> architectures using WANT_PAGE_VIRTUAL (arc, m68k and sparc):
>
> drivers/md/bcache/bset.c: In function a??__btree_sorta??:
> drivers/md/bcache/bset.c:1190: warning: dereferencing a??void *a?? pointer
> drivers/md/bcache/bset.c:1190: error: request for member a??virtuala?? in something not a structure or union
>
> Convert them to static inline functions to fix this. There are already
> plenty of  users of struct page members inside <linux/mm.h>, so there's no
> reason to keep them as macros.
>
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Tested-by: Guenter Roeck <linux@roeck-us.net>

That also fixes the problem seen in stable-queue for 3.10 and 3.12,
so it may be a better fix for the problem seen there than the patch
provided by Michael.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
