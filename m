Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 171746B6C78
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 22:04:19 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so7575629ede.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 19:04:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g17sor8477375edh.11.2018.12.03.19.04.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 19:04:17 -0800 (PST)
Date: Tue, 4 Dec 2018 03:04:15 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v2] memblock: Anonotate memblock_is_reserved() with
 __init_memblock.
Message-ID: <20181204030415.zpcvbzh5gxz5hxc6@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <BLUPR13MB02893411BF12EACB61888E80DFAE0@BLUPR13MB0289.namprd13.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BLUPR13MB02893411BF12EACB61888E80DFAE0@BLUPR13MB0289.namprd13.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yueyi Li <liyueyi@live.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.com" <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Dec 03, 2018 at 04:00:08AM +0000, Yueyi Li wrote:
>Found warning:
>
>WARNING: EXPORT symbol "gsi_write_channel_scratch" [vmlinux] version generation failed, symbol will not be versioned.
>WARNING: vmlinux.o(.text+0x1e0a0): Section mismatch in reference from the function valid_phys_addr_range() to the function .init.text:memblock_is_reserved()
>The function valid_phys_addr_range() references
>the function __init memblock_is_reserved().
>This is often because valid_phys_addr_range lacks a __init
>annotation or the annotation of memblock_is_reserved is wrong.
>
>Use __init_memblock instead of __init.

Not familiar with this error, the change looks good to me while have
some questions.

1. I don't see valid_phys_addr_range() reference memblock_is_reserved().
   This is in which file or arch?
2. In case a function reference memblock_is_reserved(), should it has
   the annotation of __init_memblock too? Or just __init is ok? If my
   understanding is correct, annotation __init is ok. Well, I don't see
   valid_phys_addr_range() has an annotation.
3. The only valid_phys_addr_range() reference some memblock function is
   the one in arch/arm64/mm/mmap.c. Do we suppose to add an annotation to
   this?

>
>Signed-off-by: liyueyi <liyueyi@live.com>
>---
>
> Changes v2: correct typo in 'warning'.
>
> mm/memblock.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>
>diff --git a/mm/memblock.c b/mm/memblock.c
>index 9a2d5ae..81ae63c 100644
>--- a/mm/memblock.c
>+++ b/mm/memblock.c
>@@ -1727,7 +1727,7 @@ static int __init_memblock memblock_search(struct memblock_type *type, phys_addr
> 	return -1;
> }
> 
>-bool __init memblock_is_reserved(phys_addr_t addr)
>+bool __init_memblock memblock_is_reserved(phys_addr_t addr)
> {
> 	return memblock_search(&memblock.reserved, addr) != -1;
> }
>-- 
>2.7.4

-- 
Wei Yang
Help you, Help me
