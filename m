Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9BA6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 23:28:23 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id l68so54218433wml.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 20:28:23 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id y3si7758296wjy.136.2016.03.08.20.28.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 20:28:22 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id n186so160303543wmn.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 20:28:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160308055834.GA9987@hori1.linux.bs1.fc.nec.co.jp>
References: <1457401652-9226-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<CALYGNiPgBRuZoi8nA-JQCxx-RGiXE9g-dfeeysvH0Rp2VAYz2A@mail.gmail.com>
	<20160308055834.GA9987@hori1.linux.bs1.fc.nec.co.jp>
Date: Wed, 9 Mar 2016 07:28:21 +0300
Message-ID: <CALYGNiPSHuZNgh33zy3KWrt0Y0Mt35HPeRxGPCZctO9aMQ=6Ow@mail.gmail.com>
Subject: Re: [PATCH v1] tools/vm/page-types.c: remove memset() in walk_pfn()
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Mar 8, 2016 at 8:58 AM, Naoya Horiguchi
<n-horiguchi@ah.jp.nec.com> wrote:
> On Tue, Mar 08, 2016 at 08:12:09AM +0300, Konstantin Khlebnikov wrote:
>> On Tue, Mar 8, 2016 at 4:47 AM, Naoya Horiguchi
>> <n-horiguchi@ah.jp.nec.com> wrote:
>> > I found that page-types is very slow and my testing shows many timeout errors.
>> > Here's an example with a simple program allocating 1000 thps.
>> >
>> >   $ time ./page-types -p $(pgrep -f test_alloc)
>> >   ...
>> >   real    0m17.201s
>> >   user    0m16.889s
>> >   sys     0m0.312s
>> >
>> >   $ time ./page-types.patched -p $(pgrep -f test_alloc)
>> >   ...
>> >   real    0m0.182s
>> >   user    0m0.046s
>> >   sys     0m0.135s
>> >
>> > Most of time is spent in memset(), which isn't necessary because we check
>> > that the return of kpagecgroup_read() is equal to pages and uninitialized
>> > memory is never used. So we can drop this memset().
>>
>> These zeros are used in show_page_range() - for merging pages into ranges.
>
> Hi Konstantin,
>
> Thank you for the response. The below code does solve the problem, so that's fine.
>
> But I don't understand how the zeros are used. show_page_range() is called
> via add_page() which is called for i=0 to i=pages-1, and the buffer cgi is
> already filled for the range [i, pages-1] by kpagecgroup_read(), so even if
> without zero initialization, kpagecgroup_read() properly fills zeros, right?
> IOW, is there any problem if we don't do this zero initialization?

kpagecgroup_read() reads only if kpagecgroup were opened,
/proc/kpagecgroup might even not exist. Probably it's better to fill
them with zeros here.
Pre-memset was an optimization - it fills buffer only once instead on
each kpagecgroup_read() call.

>
> Thanks,
> Naoya Horiguchi
>
>> You could add fast-path for count=1
>>
>> @@ -633,7 +633,10 @@ static void walk_pfn(unsigned long voffset,
>>         unsigned long pages;
>>         unsigned long i;
>>
>> -       memset(cgi, 0, sizeof cgi);
>> +       if (count == 1)
>> +               cgi[0] = 0;
>> +       else
>> +               memset(cgi, 0, sizeof cgi);
>>
>>         while (count) {
>>                 batch = min_t(unsigned long, count, KPAGEFLAGS_BATCH);
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
