Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 527536B0038
	for <linux-mm@kvack.org>; Mon, 29 Dec 2014 13:45:24 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id m20so9877012qcx.3
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 10:45:24 -0800 (PST)
Received: from mail-qa0-x232.google.com (mail-qa0-x232.google.com. [2607:f8b0:400d:c00::232])
        by mx.google.com with ESMTPS id b90si41123600qgb.50.2014.12.29.10.45.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 29 Dec 2014 10:45:22 -0800 (PST)
Received: by mail-qa0-f50.google.com with SMTP id dc16so9545536qab.9
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 10:45:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141229174030.GD32618@dhcp22.suse.cz>
References: <20141217130807.GB24704@dhcp22.suse.cz>
	<201412182111.JCE48417.QFOJSFtMOHFLOV@I-love.SAKURA.ne.jp>
	<20141218153341.GB832@dhcp22.suse.cz>
	<201412192122.DJI13055.OOVSQLOtFHFFMJ@I-love.SAKURA.ne.jp>
	<20141220020331.GM1942@devil.localdomain>
	<201412202141.ADF87596.tOSLJHFFOOFMVQ@I-love.SAKURA.ne.jp>
	<20141220223504.GI15665@dastard>
	<20141229174030.GD32618@dhcp22.suse.cz>
Date: Mon, 29 Dec 2014 10:45:22 -0800
Message-ID: <CA+55aFw5uQpHkSWnKy-CKGgg1QQ6-kix+kfqEcQWKXx2bU1q4A@mail.gmail.com>
Subject: Re: [PATCH] mm: get rid of radix tree gfp mask for pagecache_get_page
 (was: Re: How to handle TIF_MEMDIE stalls?)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Dave Chinner <dchinner@redhat.com>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>

So I think this patch is definitely going in the right direction, but
at least the __GFP_WRITE handling is insane:

(Patch edited to show the resulting code, without the old deleted lines)

On Mon, Dec 29, 2014 at 9:40 AM, Michal Hocko <mhocko@suse.cz> wrote:
> @@ -1105,13 +1102,11 @@ no_page:
>         if (!page && (fgp_flags & FGP_CREAT)) {
>                 int err;
>                 if ((fgp_flags & FGP_WRITE) && mapping_cap_account_dirty(mapping))
> +                       gfp_mask |= __GFP_WRITE;
> +               if (fgp_flags & FGP_NOFS)
> +                       gfp_mask &= ~__GFP_FS;
>
> +               page = __page_cache_alloc(gfp_mask);
>                 if (!page)
>                         return NULL;
>
> @@ -1122,7 +1117,7 @@ no_page:
>                 if (fgp_flags & FGP_ACCESSED)
>                         __SetPageReferenced(page);
>
> +               err = add_to_page_cache_lru(page, mapping, offset, gfp_mask);

Passing __GFP_WRITE into the radix tree allocation routines is not
sane. So you'd have to mask the bit out again here (unconditionally is
fine).

But other than that this seems to be a sane cleanup.

                            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
