Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED8F828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 04:04:46 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id f206so203856942wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 01:04:46 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id br5si104461211wjb.69.2016.01.11.01.04.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 01:04:45 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id l65so202077602wmf.1
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 01:04:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160110203906.GA16888@node.shutemov.name>
References: <CACT4Y+Zu95tBs-0EvdiAKzUOsb4tczRRfCRTpLr4bg_OP9HuVg@mail.gmail.com>
 <20160108232352.GA13046@node.shutemov.name> <CACT4Y+bbrEoQs2Od3gPQwqk-Y6nLWrXJJCbSFrRduwSrZk7vRA@mail.gmail.com>
 <20160110203906.GA16888@node.shutemov.name>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 11 Jan 2016 10:04:25 +0100
Message-ID: <CACT4Y+Z=Tcpp1BUFX0HOMDNf29wzKqPZ96mbXo2eah-3qgTw1w@mail.gmail.com>
Subject: Re: mm: possible deadlock in mm_take_all_locks
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Michal Hocko <mhocko@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>, Eric Dumazet <edumazet@google.com>, Sasha Levin <sasha.levin@oracle.com>

On Sun, Jan 10, 2016 at 9:39 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Sun, Jan 10, 2016 at 09:05:32AM +0100, Dmitry Vyukov wrote:
>> On Sat, Jan 9, 2016 at 12:23 AM, Kirill A. Shutemov
>> <kirill@shutemov.name> wrote:
>> > On Fri, Jan 08, 2016 at 05:58:33PM +0100, Dmitry Vyukov wrote:
>> >> Hello,
>> >>
>> >> I've hit the following deadlock warning while running syzkaller fuzzer
>> >> on commit b06f3a168cdcd80026276898fd1fee443ef25743. As far as I
>> >> understand this is a false positive, because both call stacks are
>> >> protected by mm_all_locks_mutex.
>> >
>> > +Michal
>> >
>> > I don't think it's false positive.
>> >
>> > The reason we don't care about order of taking i_mmap_rwsem is that we
>> > never takes i_mmap_rwsem under other i_mmap_rwsem, but that's not true for
>> > i_mmap_rwsem vs. hugetlbfs_i_mmap_rwsem_key. That's why we have the
>> > annotation in the first place.
>> >
>> > See commit b610ded71918 ("hugetlb: fix lockdep splat caused by pmd
>> > sharing").
>>
>> Description of b610ded71918 suggests that that code takes hugetlb
>> mutex first and them normal page mutex. In this patch you take them in
>> the opposite order: normal mutex, then hugetlb mutex. Won't this patch
>> only increase probability of deadlocks? Shouldn't you take them in the
>> opposite order?
>
> You are right. I got it wrong. Conditions should be reversed.
>
> The comment around hugetlbfs_i_mmap_rwsem_key definition is somewhat
> confusing:
>
> "This needs an annotation because huge_pmd_share() does an allocation
> under i_mmap_rwsem."
>
> I read this as we do hugetlb allocation when i_mmap_rwsem already taken
> and made locking order respectively. I guess i_mmap_rwsem should be
> replaced with hugetlbfs_i_mmap_rwsem_key in the comment.


Comment on mm_take_all_locks probably also needs updating.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
