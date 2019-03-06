Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38210C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 07:41:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6ADD20661
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 07:41:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6ADD20661
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7434A8E0003; Wed,  6 Mar 2019 02:41:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F2A38E0001; Wed,  6 Mar 2019 02:41:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E1838E0003; Wed,  6 Mar 2019 02:41:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 295628E0001
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 02:41:17 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id q26so4786050otf.19
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 23:41:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=tesYcPVNIA7PVSfrjSvMlkiL/8etY7ECB6hnqNcVvzY=;
        b=P+H5mkfTYUGJlaUExJYJNCbSfsFS620mmCwdW8yLjLaQPC0m6A4/J9FgUO2QNv0ob7
         l5WMbkybm2fuy8Yj98QXHvykC8h/j0383haK0IJ7bvOqcSSg7/A3IxmokEKAp4y0N2N3
         1nJ3komL71nX3z06VkGZAMwm5qgfl8Zr+AryworPTh6AmTnJ85Tk0sghJYxWQDYDzD/f
         haQ0BYDTd92gjDIxmu+ti8FHNJDihi9bwURbzUktfz6IEG78MnISTPFXy+0XX1Zgw+R6
         gGc6h0TCVOhpcKGHOXwrlh8OmQ1expK5I+PSKzkWocZ+JDDzdEVgu4zzIfGHAYFSEYV+
         soHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAXLqW/KuL9xl8apF1cdRVkI371vL6c1omI7r1dYF/Lx3YdHokh9
	3Aia8VFZ3zhQyKWdZyUIpsbilOlgO/BgiCZPH4D5rvCzQWBR3Q0EyX//LoJ+adlLI1jB/mqnPrx
	tDK7dP8DNHk6jj9FhpOFhxengYrKyjSTJOWDeTyie72x8dIM/9urc2WFBpGuz+lteCQ==
X-Received: by 2002:a9d:5a14:: with SMTP id v20mr3680249oth.298.1551858076799;
        Tue, 05 Mar 2019 23:41:16 -0800 (PST)
X-Google-Smtp-Source: APXvYqyBPJQKKmBTotg3gRYUfDOsIbrKf3iU33UTRXm+Efl6wQFWeC2/zSZX4Ip74jTDHRiuNNUb
X-Received: by 2002:a9d:5a14:: with SMTP id v20mr3680211oth.298.1551858075849;
        Tue, 05 Mar 2019 23:41:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551858075; cv=none;
        d=google.com; s=arc-20160816;
        b=KAarX6cf01tx524k30ZGu0THhi0P1uGtrdUy8JHlT2cz71XFoOWyKwVezycP63F3yP
         dZ01Pi2NxPl8jyqZB3DlxDLukKxX9vs1IHu+P+nlZLwBtIbkvmmrX9VFh3aYCg42btzH
         qKjxDEoDiOoxoy0PZ1E4TvQ6Qr8xiU/pPLq0JSdWhFhc90CJwNPtcl3VbKqNR4oZuC7u
         tiVYpEpc7w2tzT1ZoBeCShmwbJ7dHhgWQVa0ARGbUCfN7FFkiet2Czx+l3jBFKuOYeZa
         tVE+MSCyyFrKDYRTvmbbuODFg7P4lmrlDYNqtXJHId4C07//wnUeacbu2/YBZNakoHfI
         wiSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=tesYcPVNIA7PVSfrjSvMlkiL/8etY7ECB6hnqNcVvzY=;
        b=UAuO9202R7YvJ5eYF/uiws9qHawQLrLXUcudQPCcSaB9gewvziQtS+FeJbzjMy4toR
         zz5uyJRC4wZXf90DHSiXJhwfM/eFd+07NruvQE9uZcuE2fCCIQEzceRn4quIUV6j5hp1
         /vgfWebS++JiSmi3iZrL7Pq4NJb56kZ0+W+xrRf8tefvEJ9Lp1VCnyR2rKK33I5JZh0+
         Qzy4gkONDuLalL0shMeA+mibTNX6IPR5gwW6CXwbDDyqNybyUjyGRCdAC87ZeG30Ok6J
         r/kwAKrS+s+85xpw/xgR/hyhoF5+boA6GPIWgEFy+1826miw9YNsFixN7Imov9VV46jV
         Y+jg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id e189si403992oif.123.2019.03.05.23.41.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 23:41:15 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS402-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id 450DFBF8FE01670BA136;
	Wed,  6 Mar 2019 15:41:11 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS402-HUB.china.huawei.com
 (10.3.19.202) with Microsoft SMTP Server id 14.3.408.0; Wed, 6 Mar 2019
 15:41:08 +0800
Message-ID: <5C7F7992.7050806@huawei.com>
Date: Wed, 6 Mar 2019 15:41:06 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Mike Rapoport <rppt@linux.ibm.com>
CC: Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov
	<dvyukov@google.com>, syzbot
	<syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>, Michal Hocko
	<mhocko@kernel.org>, <cgroups@vger.kernel.org>, Johannes Weiner
	<hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM
	<linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes
	<rientjes@google.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox
	<willy@infradead.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka
	<vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Peter Xu
	<peterx@redhat.com>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
References: <00000000000006457e057c341ff8@google.com> <5C7BFE94.6070500@huawei.com> <CACT4Y+Z+CH0UTdSz-w_woMPrBwg-GuobV1Su4qd9ReffTkyfVg@mail.gmail.com> <5C7D2F82.40907@huawei.com> <CACT4Y+agwaszODNGJHCqn4fSk4Le9exn3Cau0nornJ0RaTpDJw@mail.gmail.com> <5C7D4500.3070607@huawei.com> <CACT4Y+b6y_3gTpR8LvNREHOV0TP7jB=Zp1L03dzpaz_SaeESng@mail.gmail.com> <5C7E1A38.2060906@huawei.com> <20190306020540.GA23850@redhat.com> <5C7F6048.2050802@huawei.com> <20190306062625.GA3549@rapoport-lnx>
In-Reply-To: <20190306062625.GA3549@rapoport-lnx>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/3/6 14:26, Mike Rapoport wrote:
> Hi,
>
> On Wed, Mar 06, 2019 at 01:53:12PM +0800, zhong jiang wrote:
>> On 2019/3/6 10:05, Andrea Arcangeli wrote:
>>> Hello everyone,
>>>
>>> [ CC'ed Mike and Peter ]
>>>
>>> On Tue, Mar 05, 2019 at 02:42:00PM +0800, zhong jiang wrote:
>>>> On 2019/3/5 14:26, Dmitry Vyukov wrote:
>>>>> On Mon, Mar 4, 2019 at 4:32 PM zhong jiang <zhongjiang@huawei.com> wrote:
>>>>>> On 2019/3/4 22:11, Dmitry Vyukov wrote:
>>>>>>> On Mon, Mar 4, 2019 at 3:00 PM zhong jiang <zhongjiang@huawei.com> wrote:
>>>>>>>> On 2019/3/4 15:40, Dmitry Vyukov wrote:
>>>>>>>>> On Sun, Mar 3, 2019 at 5:19 PM zhong jiang <zhongjiang@huawei.com> wrote:
>>>>>>>>>> Hi, guys
>>>>>>>>>>
>>>>>>>>>> I also hit the following issue. but it fails to reproduce the issue by the log.
>>>>>>>>>>
>>>>>>>>>> it seems to the case that we access the mm->owner and deference it will result in the UAF.
>>>>>>>>>> But it should not be possible that we specify the incomplete process to be the mm->owner.
>>>>>>>>>>
>>>>>>>>>> Any thoughts?
>>>>>>>>> FWIW syzbot was able to reproduce this with this reproducer.
>>>>>>>>> This looks like a very subtle race (threaded reproducer that runs
>>>>>>>>> repeatedly in multiple processes), so most likely we are looking for
>>>>>>>>> something like few instructions inconsistency window.
>>>>>>>>>
>>>>>>>> I has a little doubtful about the instrustions inconsistency window.
>>>>>>>>
>>>>>>>> I guess that you mean some smb barriers should be taken into account.:-)
>>>>>>>>
>>>>>>>> Because IMO, It should not be the lock case to result in the issue.
>>>>>>> Since the crash was triggered on x86 _most likley_ this is not a
>>>>>>> missed barrier. What I meant is that one thread needs to executed some
>>>>>>> code, while another thread is stopped within few instructions.
>>>>>>>
>>>>>>>
>>>>>> It is weird and I can not find any relationship you had said with the issue.:-(
>>>>>>
>>>>>> Because It is the cause that mm->owner has been freed, whereas we still deference it.
>>>>>>
>>>>>> From the lastest freed task call trace, It fails to create process.
>>>>>>
>>>>>> Am I miss something or I misunderstand your meaning. Please correct me.
>>>>> Your analysis looks correct. I am just saying that the root cause of
>>>>> this use-after-free seems to be a race condition.
>>>>>
>>>>>
>>>>>
>>>> Yep, Indeed,  I can not figure out how the race works. I will dig up further.
>>> Yes it's a race condition.
>>>
>>> We were aware about the non-cooperative fork userfaultfd feature
>>> creating userfaultfd file descriptor that gets reported to the parent
>>> uffd, despite they belong to mm created by failed forks.
>>>
>>> https://www.spinics.net/lists/linux-mm/msg136357.html
>>>
>> Hi, Andrea
>>
>> I still not clear why uffd ioctl can use the incomplete process as the mm->owner.
>> and how to produce the race.
> There is a C reproducer in  the syzcaller report:
>
> https://syzkaller.appspot.com/x/repro.c?x=172fa5a3400000
>  
>> From your above explainations,   My underdtanding is that the process handling do_exexve
>> will have a temporary mm,  which will be used by the UUFD ioctl.
> The race is between userfaultfd operation and fork() failure:
>
> forking thread                  | userfaultfd monitor thread
> --------------------------------+-------------------------------
> fork()                          |
>   dup_mmap()                    |
>     dup_userfaultfd()           |
>     dup_userfaultfd_complete()  |
>                                 |  read(UFFD_EVENT_FORK)
>                                 |  uffdio_copy()
>                                 |    mmget_not_zero()
>     goto bad_fork_something     |
>     ...                         |
> bad_fork_free:                  |
>       free_task()               |
>                                 |  mem_cgroup_from_task()
>                                 |       /* access stale mm->owner */
>  
Hi, Mike

forking thread fails to create the process ,and then free the allocated task struct.
Other userfaultfd monitor thread should not access the stale mm->owner.

The parent process and child process do not share the mm struct.  Userfaultfd monitor thread's
mm->owner should not point to the freed child task_struct.

and due to the existence of tasklist_lock,  we can not specify the mm->owner to freed task_struct.

I miss something,=-O

Thanks,
zhong jiang
>> Thanks,
>> zhong jiang


