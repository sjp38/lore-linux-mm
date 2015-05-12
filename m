Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id E0ACB6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 06:54:40 -0400 (EDT)
Received: by wicmc15 with SMTP id mc15so50764096wic.1
        for <linux-mm@kvack.org>; Tue, 12 May 2015 03:54:40 -0700 (PDT)
Received: from johanna1.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id ex8si1781243wjb.106.2015.05.12.03.54.38
        for <linux-mm@kvack.org>;
        Tue, 12 May 2015 03:54:39 -0700 (PDT)
Date: Tue, 12 May 2015 13:54:31 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 3/3] pagemap: switch to the new format and do some
 cleanup
Message-ID: <20150512105431.GD18365@node.dhcp.inet.fi>
References: <20150512090156.24768.2521.stgit@buzz>
 <20150512094306.24768.51325.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150512094306.24768.51325.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mark Williamson <mwilliamson@undo-software.com>, Pavel Emelyanov <xemul@parallels.com>, linux-api@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Machek <pavel@ucw.cz>, Mark Seaborn <mseaborn@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Daniel James <djames@undo-software.com>, Finn Grimwood <fgrimwood@undo-software.com>

On Tue, May 12, 2015 at 12:43:06PM +0300, Konstantin Khlebnikov wrote:
> This patch removes page-shift bits (scheduled to remove since 3.11) and
> completes migration to the new bit layout. Also it cleans messy macro.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  fs/proc/task_mmu.c    |  152 ++++++++++++++++---------------------------------
>  tools/vm/page-types.c |   29 +++------
>  2 files changed, 58 insertions(+), 123 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 0b7a8ffec95f..66bc7207ce90 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -710,23 +710,6 @@ const struct file_operations proc_tid_smaps_operations = {
>  	.release	= proc_map_release,
>  };
>  
> -/*
> - * We do not want to have constant page-shift bits sitting in
> - * pagemap entries and are about to reuse them some time soon.
> - *
> - * Here's the "migration strategy":
> - * 1. when the system boots these bits remain what they are,
> - *    but a warning about future change is printed in log;
> - * 2. once anyone clears soft-dirty bits via clear_refs file,
> - *    these flag is set to denote, that user is aware of the
> - *    new API and those page-shift bits change their meaning.
> - *    The respective warning is printed in dmesg;
> - * 3. In a couple of releases we will remove all the mentions
> - *    of page-shift in pagemap entries.
> - */

Wouldn't it be better to just have v2=1 by default for couple releases to
see if anything breaks? This way we can revert easily if regression reported.
I guess someone could miss this change coming if he didn't touch clear_refs.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
