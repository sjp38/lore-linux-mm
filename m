Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDFB6B00A6
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 16:01:46 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so5366667pbc.29
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 13:01:46 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id em3si31748606pbb.194.2014.06.09.13.01.45
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 13:01:45 -0700 (PDT)
Message-ID: <539612A8.8080303@intel.com>
Date: Mon, 09 Jun 2014 13:01:44 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] mm/pagewalk: replace mm_walk->skip with more general
 mm_walk->control
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1402095520-10109-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402095520-10109-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

On 06/06/2014 03:58 PM, Naoya Horiguchi wrote:
> +enum mm_walk_control {
> +	PTWALK_NEXT = 0,	/* Go to the next entry in the same level or
> +				 * the next vma. This is default behavior. */
> +	PTWALK_DOWN,		/* Go down to lower level */
> +	PTWALK_BREAK,		/* Break current loop and continue from the
> +				 * next loop */
> +};

I think this is a bad idea.

The page walker should be for the common cases of walking page tables,
and it should be simple.  It *HAS* to be better (shorter/faster) than if
someone was to just open-code a page table walk, or it's not really useful.

The only place this is used is in the ppc walker, and it saves a single
line of code, but requires some comments to explain what is going on:

 arch/powerpc/mm/subpage-prot.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

So, it adds infrastructure, but saves a single line of code.  Seems like
a bad trade off to me. :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
