Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 92D7D6B0345
	for <linux-mm@kvack.org>; Sun, 28 Oct 2018 02:27:25 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 14-v6so4289434pfk.22
        for <linux-mm@kvack.org>; Sat, 27 Oct 2018 23:27:25 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f10-v6si16135287pgs.362.2018.10.27.23.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Oct 2018 23:27:24 -0700 (PDT)
Date: Sun, 28 Oct 2018 14:27:22 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: simplify get_next_ra_size
Message-ID: <20181028062722.hfomc3davarmzojw@wfg-t540p.sh.intel.com>
References: <1540707206-19649-1-git-send-email-hsiangkao@aol.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1540707206-19649-1-git-send-email-hsiangkao@aol.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gao Xiang <hsiangkao@aol.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Looks good to me, thanks!

Reviewed-by: Fengguang Wu <fengguang.wu@intel.com>

On Sun, Oct 28, 2018 at 02:13:26PM +0800, Gao Xiang wrote:
>It's a trivial simplification for get_next_ra_size and
>clear enough for humans to understand.
>
>It also fixes potential overflow if ra->size(< ra_pages) is too large.
>
>Cc: Fengguang Wu <fengguang.wu@intel.com>
>Signed-off-by: Gao Xiang <hsiangkao@aol.com>
>---
> mm/readahead.c | 12 +++++-------
> 1 file changed, 5 insertions(+), 7 deletions(-)
>
>diff --git a/mm/readahead.c b/mm/readahead.c
>index 4e63014..205ac34 100644
>--- a/mm/readahead.c
>+++ b/mm/readahead.c
>@@ -272,17 +272,15 @@ static unsigned long get_init_ra_size(unsigned long size, unsigned long max)
>  *  return it as the new window size.
>  */
> static unsigned long get_next_ra_size(struct file_ra_state *ra,
>-						unsigned long max)
>+				      unsigned long max)
> {
> 	unsigned long cur = ra->size;
>-	unsigned long newsize;
>
> 	if (cur < max / 16)
>-		newsize = 4 * cur;
>-	else
>-		newsize = 2 * cur;
>-
>-	return min(newsize, max);
>+		return 4 * cur;
>+	if (cur <= max / 2)
>+		return 2 * cur;
>+	return max;
> }
>
> /*
>-- 
>2.7.4
>
