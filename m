Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3255C6B0032
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 16:06:04 -0400 (EDT)
Received: by wggv3 with SMTP id v3so49018938wgg.1
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 13:06:03 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0059.outbound.protection.outlook.com. [157.55.234.59])
        by mx.google.com with ESMTPS id ln3si19715174wic.72.2015.03.16.13.06.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Mar 2015 13:06:02 -0700 (PDT)
Message-ID: <5507379E.8000607@ezchip.com>
Date: Mon, 16 Mar 2015 16:05:50 -0400
From: Chris Metcalf <cmetcalf@ezchip.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] tile/elf: reorganize notify_exec()
References: <1424901517-25069-1-git-send-email-dave@stgolabs.net> <1424901517-25069-2-git-send-email-dave@stgolabs.net>
In-Reply-To: <1424901517-25069-2-git-send-email-dave@stgolabs.net>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

On 2/25/2015 4:58 PM, Davidlohr Bueso wrote:
> In the future mm->exe_file will be done without mmap_sem
> serialization, thus isolate and reorganize the tile elf
> code to make the transition easier. Good users will, make
> use of the more standard get_mm_exe_file(), requiring only
> holding the mmap_sem to read the value, and relying on reference
> counting to make sure that the exe file won't dissappear
> underneath us.
>
> The visible effects of this patch are:
>
>     o We now take and drop the mmap_sem more often. Instead of
>       just in arch_setup_additional_pages(), we also do it in:
>
>       1) get_mm_exe_file()
>       2) to get the mm->vm_file and notify the simulator.
>
>      [Note that 1) will disappear once we change the locking
>       rules for exe_file.]
>
>     o We avoid getting a free page and doing d_path() while
>       holding the mmap_sem. This requires reordering the checks.
>
> Cc: Chris Metcalf<cmetcalf@ezchip.com>
> Signed-off-by: Davidlohr Bueso<dbueso@suse.de>
> ---
>
> completely untested.
>
>   arch/tile/mm/elf.c | 47 +++++++++++++++++++++++++++++------------------
>   1 file changed, 29 insertions(+), 18 deletions(-)

This looks OK to me and passes basic testing.  So here is my

Acked-by: Chris Metcalf <cmetcalf@ezchip.com>

Or would you prefer I took this through the tile tree?

-- 
Chris Metcalf, EZChip Semiconductor
http://www.ezchip.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
