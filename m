Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3FC6C6B0036
	for <linux-mm@kvack.org>; Mon, 22 Sep 2014 14:40:35 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id rp18so6049401iec.17
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 11:40:35 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id x7si8386701ici.7.2014.09.22.11.40.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 22 Sep 2014 11:40:34 -0700 (PDT)
Received: by mail-ie0-f176.google.com with SMTP id ar1so8080544iec.35
        for <linux-mm@kvack.org>; Mon, 22 Sep 2014 11:40:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140919232348.1a2856c1.akpm@linux-foundation.org>
References: <20140830163834.29066.98205.stgit@zurg>
	<20140830164120.29066.8857.stgit@zurg>
	<20140912165143.86d5f83dcde4a9fd78069f79@linux-foundation.org>
	<CALYGNiM0Uh1KG8Z6pFEAn=uxZBRPfHDffXjKkKJoG-K0hCaqaA@mail.gmail.com>
	<20140912224221.9ee5888a.akpm@linux-foundation.org>
	<CALYGNiNg5yLbAvqwG3nPqWZHkqXc1-3p4yqdP2Eo2rNJbRo0rg@mail.gmail.com>
	<20140919143520.94f4a17f752398a6c7c927d8@linux-foundation.org>
	<CALYGNiOwrM+LiadZGh+jeFgXCuCA0z_1Vd_kdMxLjqnP9Fnmhw@mail.gmail.com>
	<20140919232348.1a2856c1.akpm@linux-foundation.org>
Date: Mon, 22 Sep 2014 22:40:34 +0400
Message-ID: <CALYGNiN0OEtWJVy6sTE_sOydMKbyHfRY3HQ3GjYTT-u05XHTfg@mail.gmail.com>
Subject: Re: [PATCH v2 4/6] mm: introduce common page state for ballooned memory
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, Rafael Aquini <aquini@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Sasha Levin <sasha.levin@oracle.com>

On Sat, Sep 20, 2014 at 10:23 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Sat, 20 Sep 2014 09:25:01 +0400 Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>
>> >
>> > So I'm going to send "fix for
>> > mm-balloon_compaction-use-common-page-ballooning-v2" to Linus
>> > separately, but it has no changelog at all.
>>
>> Probably it would be better if you drop everything except actually
>> fixes and stresstest. This is gone too far, now balloon won't compile
>> in the middle of patchset. Just tell me and I'll redo the rest.
>
> I think it's best if I drop everything:
>
> mm-balloon_compaction-ignore-anonymous-pages.patch
> mm-balloon_compaction-keep-ballooned-pages-away-from-normal-migration-path.patch
> mm-balloon_compaction-isolate-balloon-pages-without-lru_lock.patch
> selftests-vm-transhuge-stress-stress-test-for-memory-compaction.patch
> mm-introduce-common-page-state-for-ballooned-memory.patch
> mm-balloon_compaction-use-common-page-ballooning.patch
> mm-balloon_compaction-general-cleanup.patch
> mm-balloon_compaction-use-common-page-ballooning-v2-fix-1.patch
>
> Please go through it and send out a new version?
>
>

I've found yet another bug in this code. It seems here is a nest.
balloon_page_dequeue can race with  balloon_page_isolate:
balloon_page_isolate can remove page from list between
llist_for_each_entry_safe and trylock_page in balloon_page_dequeue.
balloon_page_dequeue runs under mutex_lock(&vb->balloon_lock);
both of them lock page using trylock_page so race is tight but it is
not impossible.
Probably it's really easier to rewrite it than to fix bugs one by one =/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
