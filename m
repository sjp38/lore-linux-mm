Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 75BFA6B02F1
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 05:44:09 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id o124so271440ioo.20
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:44:09 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d23sor14164191ioj.250.2017.11.28.02.44.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Nov 2017 02:44:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171128104114.GL5977@quack2.suse.cz>
References: <1506592464-30962-1-git-send-email-laoar.shao@gmail.com>
 <cdfce9d0-9542-3fd1-098c-492d8d9efc11@I-love.SAKURA.ne.jp>
 <20171127091939.tahb77nznytcxw55@dhcp22.suse.cz> <CALOAHbDNbFs51mW0kUFXcqqyJy+ydpHPaRbvquPVrPTY5HGeRg@mail.gmail.com>
 <20171128102559.GJ5977@quack2.suse.cz> <CALOAHbBRiv48N_puVW18QX3MHoDU3CvMaa7BwxONAKWSOGWJcg@mail.gmail.com>
 <20171128104114.GL5977@quack2.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 28 Nov 2017 18:44:07 +0800
Message-ID: <CALOAHbCkXqRTYnrG20X-b6LqhiiPNYFAjF9BY-OePn_w2jYn1g@mail.gmail.com>
Subject: Re: [PATCH] Revert "mm/page-writeback.c: print a warning if the vm
 dirtiness settings are illogical" (was: Re: [PATCH] mm: print a warning once
 the vm dirtiness settings is illogical)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

2017-11-28 18:41 GMT+08:00 Jan Kara <jack@suse.cz>:
> On Tue 28-11-17 18:33:02, Yafang Shao wrote:
>> 2017-11-28 18:25 GMT+08:00 Jan Kara <jack@suse.cz>:
>> > Hi Yafang,
>> >
>> > On Tue 28-11-17 11:11:40, Yafang Shao wrote:
>> >> What about bellow change ?
>> >> It makes the function  domain_dirty_limits() more clear.
>> >> And the result will have a higher precision.
>> >
>> > Frankly, I don't find this any better and you've just lost the additional
>> > precision of ratios computed in the "if (gdtc)" branch the multiplication by
>> > PAGE_SIZE got us.
>> >
>>
>> What about bellow change? It won't be lost any more, becasue
>> bytes and bg_bytes are both PAGE_SIZE aligned.
>>
>> -       if (bytes)
>> -           ratio = min(DIV_ROUND_UP(bytes, global_avail),
>> -                   PAGE_SIZE);
>> -       if (bg_bytes)
>> -           bg_ratio = min(DIV_ROUND_UP(bg_bytes, global_avail),
>> -                      PAGE_SIZE);
>> +       if (bytes) {
>> +           pages = DIV_ROUND_UP(bytes, PAGE_SIZE);
>> +           ratio = DIV_ROUND_UP(pages * 100, global_avail);
>> +
>> +       }
>> +
>> +       if (bg_bytes) {
>> +           pages = DIV_ROUND_UP(bg_bytes, PAGE_SIZE);
>> +           bg_ratio = DIV_ROUND_UP(pages * 100, global_avail);
>> +       }
>
> Not better... Look, in the original code the 'ratio' and 'bg_ratio'
> variables contain a number between 0 and 1 as fractions of 1/PAGE_SIZE. In
> your code you have in these variables fractions of 1/100. That's certainly
> less precise no matter how you get to those numbers.
>

Understood.
Thanks :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
