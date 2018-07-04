Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2E6906B000D
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 03:54:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x5-v6so1798239edh.8
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 00:54:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x3-v6si2590463edb.263.2018.07.04.00.54.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 00:54:12 -0700 (PDT)
Date: Wed, 4 Jul 2018 09:54:10 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 3/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
Message-ID: <20180704075410.GF22503@dhcp22.suse.cz>
References: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530685696-14672-4-git-send-email-rppt@linux.vnet.ibm.com>
 <CAMuHMdWEHSz34bN-U3gHW972w13f_Jrx_ObEsP3w8XZ1Gx65OA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMuHMdWEHSz34bN-U3gHW972w13f_Jrx_ObEsP3w8XZ1Gx65OA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed 04-07-18 09:44:14, Geert Uytterhoeven wrote:
[...]
> ------------[ cut here ]------------
> WARNING: CPU: 0 PID: 0 at mm/memblock.c:230
> memblock_find_in_range_node+0x11c/0x1be
> memblock: bottom-up allocation failed, memory hotunplug may be affected

This only means that hotplugable memory might contain non-movable memory
now. But does your system even support memory hotplug. I would be really
surprised. So I guess we just want this instead
diff --git a/mm/memblock.c b/mm/memblock.c
index cc16d70b8333..c0dde95593fd 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -228,7 +228,8 @@ phys_addr_t __init_memblock memblock_find_in_range_node(phys_addr_t size,
 		 * so we use WARN_ONCE() here to see the stack trace if
 		 * fail happens.
 		 */
-		WARN_ONCE(1, "memblock: bottom-up allocation failed, memory hotunplug may be affected\n");
+		WARN_ONCE(IS_ENABLED(CONFIG_MEMORY_HOTREMOVE),
+					"memblock: bottom-up allocvation failed, memory hotunplug may be affected\n");
 	}
 
 	return __memblock_find_range_top_down(start, end, size, align, nid,
-- 
Michal Hocko
SUSE Labs
