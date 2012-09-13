Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id F2BFA6B016A
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 15:17:20 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so4984281vbk.14
        for <linux-mm@kvack.org>; Thu, 13 Sep 2012 12:17:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1347324112-14134-1-git-send-email-minchan@kernel.org>
References: <1347324112-14134-1-git-send-email-minchan@kernel.org>
Date: Thu, 13 Sep 2012 21:17:19 +0200
Message-ID: <CAMuHMdXWZ=Jeggd7cT_LXK0MTnmFAf+cWEhC75B1gCcSd3eWeg@mail.gmail.com>
Subject: Re: [PATCH] mm: cma: Discard clean pages during contiguous allocation
 instead of migration
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kmpark@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Linux-Next <linux-next@vger.kernel.org>

On Tue, Sep 11, 2012 at 2:41 AM, Minchan Kim <minchan@kernel.org> wrote:
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -674,8 +674,10 @@ static enum page_references page_check_references(struct page *page,
>  static unsigned long shrink_page_list(struct list_head *page_list,
>                                       struct zone *zone,
>                                       struct scan_control *sc,
> +                                     enum ttu_flags ttu_flags,

"enum ttu_flags" is defined on CONFIG_MMU=y only, causing on nommu:

mm/vmscan.c:677:26: error: parameter 4 ('ttu_flags') has incomplete type
mm/vmscan.c:987:5: error: 'TTU_UNMAP' undeclared (first use in this function)
mm/vmscan.c:987:15: error: 'TTU_IGNORE_ACCESS' undeclared (first use
in this function)
mm/vmscan.c:1312:56: error: 'TTU_UNMAP' undeclared (first use in this function)

E.g.
http://kisskb.ellerman.id.au/kisskb/buildresult/7191694/ (h8300-defconfig)
http://kisskb.ellerman.id.au/kisskb/buildresult/7191858/ (sh-allnoconfig)

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
