Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D4F926B0279
	for <linux-mm@kvack.org>; Mon,  3 Jul 2017 06:24:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b20so18554658wmd.6
        for <linux-mm@kvack.org>; Mon, 03 Jul 2017 03:24:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 20si4985902wma.1.2017.07.03.03.23.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Jul 2017 03:23:59 -0700 (PDT)
Date: Mon, 3 Jul 2017 12:23:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: vmpressure: simplify pressure ratio calculation
Message-ID: <20170703102354.GG3217@dhcp22.suse.cz>
References: <b7riv0v73isdtxyi4coi6g7b.1499072995215@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b7riv0v73isdtxyi4coi6g7b.1499072995215@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "zbestahu@aliyun.com" <zbestahu@aliyun.com>
Cc: akpm <akpm@linux-foundation.org>, minchan <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, Yue Hu <huyue2@coolpad.com>, Anton Vorontsov <anton.vorontsov@linaro.org>

On Mon 03-07-17 17:45:25, zbestahu@aliyun.com wrote:
> Hi Michal
> 
> We can think the some of scanned pages is reclaimed as reclaimed pages
> and the rest of pages is just unsuccessful reclaimed pages. vmpressure
> is tend to unsuccessful reclaimed pages, so obviously the pressure
> percent is the ratio of unsuccessful reclaimed pages to scanned pages.

Yes this is correct and this is what the current code does as well.
The difference is in the rounding when the integer arithmetic is used.

Btw. are you trying to fix any existing problem or you merely checked
the code and considered this part too hard to understand and so you sent
a patch to make it simpler? Have you considered the original intention
of the code? Note that I am not saying your patch is incorrect I would
just like to uderstand your motivation and the original intention in the
code.

> -------- a??a??e?(R)a>>? --------
> a??a>>?aooi 1/4 ?Michal Hocko <mhocko@kernel.org>
> ae??e?'i 1/4 ?a??a,? 7ae??3ae?JPY 15:44
> ae??a>>?aooi 1/4 ?zbestahu <zbestahu@aliyun.com>
> ae??e??i 1/4 ?akpm <akpm@linux-foundation.org>,minchan <minchan@kernel.org>,linux-mm <linux-mm@kvack.org>,Yue Hu <huyue2@coolpad.com>,Anton Vorontsov <anton.vorontsov@linaro.org>
> a,>>ec?i 1/4 ?Re: [PATCH] mm: vmpressure: simplify pressure ratio calculation
> 
> >[CC Anton]
> >
> >On Sat 01-07-17 14:27:39, zbestahu@aliyun.com wrote:
> >> From: Yue Hu <huyue2@coolpad.com>
> >> 
> >> The patch removes the needless scale in existing caluation, it
> >> makes the calculation more simple and more effective.
> >
> >I suspect the construct is deliberate and done this way because of the
> >rounding. Your code will behave slightly differently. If that is
> >intentional then it should be described in the changedlog.
> >
> >> Signed-off-by: Yue Hu <huyue2@coolpad.com>
> >> ---
> >>A  mm/vmpressure.c | 4 +---
> >>A  1 file changed, 1 insertion(+), 3 deletions(-)
> >> 
> >> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> >> index 6063581..174b2f0 100644
> >> --- a/mm/vmpressure.c
> >> +++ b/mm/vmpressure.c
> >> @@ -111,7 +111,6 @@ static enum vmpressure_levels vmpressure_level(unsigned long pressure)
> >>A  static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
> >>A  						A A A  unsigned long reclaimed)
> >>A  {
> >> -	unsigned long scale = scanned + reclaimed;
> >>A  	unsigned long pressure = 0;
> >>A  
> >>A  	/*
> >> @@ -128,8 +127,7 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
> >>A  	 * scanned. This makes it possible to set desired reaction time
> >>A  	 * and serves as a ratelimit.
> >>A  	 */
> >> -	pressure = scale - (reclaimed * scale / scanned);
> >> -	pressure = pressure * 100 / scale;
> >> +	pressure = (scanned - reclaimed) * 100 / scanned;
> >>A  
> >>A  out:
> >>A  	pr_debug("%s: %3luA  (s: %luA  r: %lu)\n", __func__, pressure,
> >> -- 
> >> 1.9.1
> >> 
> >
> >-- 
> >Michal Hocko
> >SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
