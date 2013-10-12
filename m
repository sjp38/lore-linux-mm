Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 82E576B0031
	for <linux-mm@kvack.org>; Fri, 11 Oct 2013 22:32:34 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id kp14so5188257pab.38
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 19:32:34 -0700 (PDT)
Received: by mail-vb0-f47.google.com with SMTP id h10so3410416vbh.34
        for <linux-mm@kvack.org>; Fri, 11 Oct 2013 19:32:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <000001ceba6a$997d0490$cc770db0$%yang@samsung.com>
References: <000201ceb836$4c549740$e4fdc5c0$%yang@samsung.com>
	<20130924010308.GG17725@bbox>
	<000001ceba6a$997d0490$cc770db0$%yang@samsung.com>
Date: Sat, 12 Oct 2013 10:32:31 +0800
Message-ID: <CAA_GA1dE+Cw+bi=+Kr=BHSW5Xe71M5KN_sApOzkHiHWeriqOFw@mail.gmail.com>
Subject: Re: [PATCH v3 2/3] mm/zswap: bugfix: memory leak when invalidate and
 reclaim occur concurrently
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Bob Liu <bob.liu@oracle.com>, Weijie Yang <weijie.yang.kh@gmail.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, d.j.shin@samsung.com, heesub.shin@samsung.com, Kyungmin Park <kyungmin.park@samsung.com>, hau.chen@samsung.com, bifeng.tong@samsung.com, rui.xie@samsung.com

On Thu, Sep 26, 2013 at 11:42 AM, Weijie Yang <weijie.yang@samsung.com> wrote:
> On Tue, Sep 24, 2013 at 9:03 AM, Minchan Kim <minchan@kernel.org> wrote:
>> On Mon, Sep 23, 2013 at 04:21:49PM +0800, Weijie Yang wrote:
>> >
>> > Modify:
>> >  - check the refcount in fail path, free memory if it is not referenced.
>>
>> Hmm, I don't like this because zswap refcount routine is already mess for me.
>> I'm not sure why it was designed from the beginning. I hope we should fix it first.
>>
>> 1. zswap_rb_serach could include zswap_entry_get semantic if it founds a entry from
>>    the tree. Of course, we should ranme it as find_get_zswap_entry like find_get_page.
>> 2. zswap_entry_put could hide resource free function like zswap_free_entry so that
>>    all of caller can use it easily following pattern.
>>
>>   find_get_zswap_entry
>>   ...
>>   ...
>>   zswap_entry_put
>>
>> Of course, zswap_entry_put have to check the entry is in the tree or not
>> so if someone already removes it from the tree, it should avoid double remove.
>>
>> One of the concern I can think is that approach extends critical section
>> but I think it would be no problem because more bottleneck would be [de]compress
>> functions. If it were really problem, we can mitigate a problem with moving
>> unnecessary functions out of zswap_free_entry because it seem to be rather
>> over-enginnering.
>
> I refactor the zswap refcount routine according to Minchan's idea.
> Here is the new patch, Any suggestion is welcomed.
>
> To Seth and Bob, would you please review it again?
>

I have nothing in addition to Minchan's review.

Since the code is a bit complex, I'd suggest you to split it into two patches.
[1/2]: fix the memory leak
[2/2]: clean up the entry_put

And run some testing..

Thanks,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
