Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 757206B0038
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 16:26:58 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c87so44605871pfl.6
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 13:26:58 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j63sor497784pfg.13.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Mar 2017 13:26:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170316195731.GA31479@cmpxchg.org>
References: <1489240264-3290-1-git-send-email-ysxie@foxmail.com>
 <CALvZod6dptidW33mpvSkQfMBM=xsfSPEEJzB+3u4ekr8m3bSOA@mail.gmail.com> <20170316195731.GA31479@cmpxchg.org>
From: Shakeel Butt <shakeelb@google.com>
Date: Thu, 16 Mar 2017 13:26:56 -0700
Message-ID: <CALvZod6vQa3L8crDtP5xv9vzJJsiu5MJVh-N8gX_J4pKWMD8+w@mail.gmail.com>
Subject: Re: [PATCH v2 RFC] mm/vmscan: more restrictive condition for retry in do_try_to_free_pages
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Yisheng Xie <ysxie@foxmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, riel@redhat.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, xieyisheng1@huawei.com, guohanjun@huawei.com, Xishi Qiu <qiuxishi@huawei.com>

On Thu, Mar 16, 2017 at 12:57 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Sat, Mar 11, 2017 at 09:52:15AM -0800, Shakeel Butt wrote:
>> On Sat, Mar 11, 2017 at 5:51 AM, Yisheng Xie <ysxie@foxmail.com> wrote:
>> > @@ -2808,7 +2826,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
>> >                 return 1;
>> >
>> >         /* Untapped cgroup reserves?  Don't OOM, retry. */
>> > -       if (!sc->may_thrash) {
>> > +       if (!may_thrash(sc)) {
>>
>> Thanks Yisheng. The name of the function may_thrash() is confusing in
>> the sense that it is returning exactly the opposite of what its name
>> implies. How about reversing the condition of may_thrash() function
>> and change the scan_control's field may_thrash to thrashed?
>
> How so?
>
> The user sets memory.low to a minimum below which the application will
> thrash. Hence, being allowed to break that minimum and causing the app
> to thrash, means you "may thrash".
>
Basically how I interpreted may_thrash() is "may I thrash" or may I
reclaim memory from memcgs which were already below memory.low. So, if
it returns true, we go for second pass with the authorization to
reclaim memory even from memcgs with usage below memory.low.

> OTOH, I'm not sure what "thrashed" would mean.
By 'thrashed', I wanted to say, hey I have already tried to reclaim
memory from memcgs below their memory.low, so no need to try again but
Yisheng correctly pointed out that it will cause confusion in
shrink_node().

Sorry for confusion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
