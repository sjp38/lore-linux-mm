Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id C603B6B0080
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 08:35:49 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id v19so37771obq.14
        for <linux-mm@kvack.org>; Fri, 07 Dec 2012 05:35:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAA_GA1fiQfOqApE05oh=2Wr-GejbHtOd4o7sqcGdQFH6cxWPpQ@mail.gmail.com>
References: <1354810175-4338-1-git-send-email-js1304@gmail.com>
	<CAA_GA1fiQfOqApE05oh=2Wr-GejbHtOd4o7sqcGdQFH6cxWPpQ@mail.gmail.com>
Date: Fri, 7 Dec 2012 22:35:48 +0900
Message-ID: <CAAmzW4O0EY=-ZBytrWmGVax47_ygNh+hcGpbGOCt9cnXH7HU-g@mail.gmail.com>
Subject: Re: [RFC PATCH 0/8] remove vm_struct list management
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King <rmk+kernel@arm.linux.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kexec@lists.infradead.org

Hello, Bob.

2012/12/7 Bob Liu <lliubbo@gmail.com>:
> Hi Joonsoo,
>
> On Fri, Dec 7, 2012 at 12:09 AM, Joonsoo Kim <js1304@gmail.com> wrote:
>> This patchset remove vm_struct list management after initializing vmalloc.
>> Adding and removing an entry to vmlist is linear time complexity, so
>> it is inefficient. If we maintain this list, overall time complexity of
>> adding and removing area to vmalloc space is O(N), although we use
>> rbtree for finding vacant place and it's time complexity is just O(logN).
>>
>> And vmlist and vmlist_lock is used many places of outside of vmalloc.c.
>> It is preferable that we hide this raw data structure and provide
>> well-defined function for supporting them, because it makes that they
>> cannot mistake when manipulating theses structure and it makes us easily
>> maintain vmalloc layer.
>>
>> I'm not sure that "7/8: makes vmlist only for kexec" is fine.
>> Because it is related to userspace program.
>> As far as I know, makedumpfile use kexec's output information and it only
>> need first address of vmalloc layer. So my implementation reflect this
>> fact, but I'm not sure. And now, I don't fully test this patchset.
>> Basic operation work well, but I don't test kexec. So I send this
>> patchset with 'RFC'.
>>
>> Please let me know what I am missing.
>>
>
> Nice work!
> I also thought about this several weeks ago but I think the efficiency
> may be a problem.
>
> As you know two locks(vmap_area_lock and vmlist_lock) are used
> currently so that some
> work may be done in parallel(not proved).
> If removed vmlist, i'm afraid vmap_area_lock will become a bottleneck
> which will reduce the efficiency.

Thanks for comment!

Yes, there were some place that work may be done in parallel.
For example, access to '/proc/meminfo', '/proc/vmallocinfo' and '/proc/kcore'
may be done in parallel. But, access to these are not main
functionality of vmalloc layer.
Optimizing main function like vmalloc, vfree is more preferable than above.
And this patchset optimize main function with removing vmlist iteration.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
