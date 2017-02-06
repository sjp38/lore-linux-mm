Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 24E6F6B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 08:09:05 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id w144so79169613oiw.0
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 05:09:05 -0800 (PST)
Received: from mail-ot0-x241.google.com (mail-ot0-x241.google.com. [2607:f8b0:4003:c0f::241])
        by mx.google.com with ESMTPS id 100si260168otd.315.2017.02.06.05.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 05:09:04 -0800 (PST)
Received: by mail-ot0-x241.google.com with SMTP id f9so10288001otd.0
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 05:09:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170206124037.GA10298@dhcp22.suse.cz>
References: <1486383850-30444-1-git-send-email-vinmenon@codeaurora.org>
 <1486383850-30444-2-git-send-email-vinmenon@codeaurora.org> <20170206124037.GA10298@dhcp22.suse.cz>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Mon, 6 Feb 2017 18:39:03 +0530
Message-ID: <CAOaiJ-kf+1xO9R5u33-JADpNpHiyyfbq0CKY014E8L+ErKioDA@mail.gmail.com>
Subject: Re: [PATCH 2/2 RESEND] mm: vmpressure: fix sending wrong events on underflow
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Mon, Feb 6, 2017 at 6:10 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 06-02-17 17:54:10, Vinayak Menon wrote:
> [...]
>> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
>> index 149fdf6..3281b34 100644
>> --- a/mm/vmpressure.c
>> +++ b/mm/vmpressure.c
>> @@ -112,8 +112,10 @@ static enum vmpressure_levels vmpressure_calc_level(unsigned long scanned,
>>                                                   unsigned long reclaimed)
>>  {
>>       unsigned long scale = scanned + reclaimed;
>> -     unsigned long pressure;
>> +     unsigned long pressure = 0;
>>
>> +     if (reclaimed >= scanned)
>> +             goto out;
>
> This deserves a comment IMHO. Besides that, why shouldn't we normalize
> the result already in vmpressure()? Please note that the tree == true
> path will aggregate both scanned and reclaimed and that already skews
> numbers.
Sure. Will add a comment.
IIUC, normalizing in vmpressure() means something like this which you
mentioned in one
of your previous emails right ?

+ if (reclaimed > scanned)
+          reclaimed = scanned;

Considering a scan window of 512 pages and without above piece of
code, if the first scanning is of a THP page
Scan=1,Reclaimed=512
If the next 511 scans results in 0 reclaimed pages
total_scan=512,Reclaimed=512 => vmpressure 0

Now with the above piece of code in place
Scan=1,Reclaimed=1, then
Scan=511, Reclaimed=0
total_scan=512,Reclaimed=1 => critical vmpressure

With the slab issue fixed separately, we need to fix only the
underflow right ? And if we do it in vmpressure_calc_level,
the check needs to done only once at the end of a scan window.

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
