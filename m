Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B73516B0071
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 23:32:34 -0500 (EST)
Received: by vws10 with SMTP id 10so3991227vws.14
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 20:32:27 -0800 (PST)
Date: Tue, 23 Nov 2010 12:37:10 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] scripts: Fix gfp-translate for recent changes to gfp.h
Message-ID: <20101123043710.GA5187@cr0.nay.redhat.com>
References: <20101122120002.GB1890@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101122120002.GB1890@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Namhyung Kim <namhyung@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2010 at 12:00:02PM +0000, Mel Gorman wrote:
>The recent changes to gfp.h to satisfy sparse broke
>scripts/gfp-translate. This patch fixes it up to work with old and new
>versions of gfp.h .
>
>Signed-off-by: Mel Gorman <mel@csn.ul.ie>
>---
> scripts/gfp-translate |    7 ++++++-
> 1 files changed, 6 insertions(+), 1 deletions(-)
>
>diff --git a/scripts/gfp-translate b/scripts/gfp-translate
>index d81b968..128937e 100644
>--- a/scripts/gfp-translate
>+++ b/scripts/gfp-translate
>@@ -63,7 +63,12 @@ fi
> 
> # Extract GFP flags from the kernel source
> TMPFILE=`mktemp -t gfptranslate-XXXXXX` || exit 1
>-grep "^#define __GFP" $SOURCE/include/linux/gfp.h | sed -e 's/(__force gfp_t)//' | sed -e 's/u)/)/' | grep -v GFP_BITS | sed -e 's/)\//) \//' > $TMPFILE
>+grep ___GFP $SOURCE/include/linux/gfp.h > /dev/null

You might want 'grep -q'. :)


>+if [ $? -eq 0 ]; then
>+	grep "^#define ___GFP" $SOURCE/include/linux/gfp.h | sed -e 's/u$//' | grep -v GFP_BITS > $TMPFILE
>+else
>+	grep "^#define __GFP" $SOURCE/include/linux/gfp.h | sed -e 's/(__force gfp_t)//' | sed -e 's/u)/)/' | grep -v GFP_BITS | sed -e 's/)\//) \//' > $TMPFILE
>+fi
> 
> # Parse the flags
> IFS="

Other than that, this patch looks fine for me.

Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
