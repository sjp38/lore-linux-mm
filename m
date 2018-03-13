Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 97EA76B0009
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:22:39 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id p203so11681647itc.1
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 05:22:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id d64si60001ioe.42.2018.03.13.05.22.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Mar 2018 05:22:37 -0700 (PDT)
Subject: Re: KVM hang after OOM
References: <CABXGCsOv040dsCkQNYzROBmZtYbqqnqLdhfGnCjU==N_nYQCKw@mail.gmail.com>
 <20180312090054.mqu56pju7nijjufh@node.shutemov.name>
 <CABXGCsOKkqXTA417GQLE-aj_kYxuQF9W++2HQ=JO-BV3vjCqdQ@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <9eb2de80-aa1b-3900-9a37-f1a17e5fac38@i-love.sakura.ne.jp>
Date: Tue, 13 Mar 2018 21:22:25 +0900
MIME-Version: 1.0
In-Reply-To: <CABXGCsOKkqXTA417GQLE-aj_kYxuQF9W++2HQ=JO-BV3vjCqdQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org

Mikhail Gavrilov wrote:
> On 12 March 2018 at 14:00, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > On Sun, Mar 11, 2018 at 11:11:52PM +0500, Mikhail Gavrilov wrote:
> >> $ uname -a
> >> Linux localhost.localdomain 4.15.7-300.fc27.x86_64+debug #1 SMP Wed
> >> Feb 28 17:32:16 UTC 2018 x86_64 x86_64 x86_64 GNU/Linux
> >>
> >>
> >> How reproduce:
> >> 1. start virtual machine
> >> 2. open https://oom.sy24.ru/ in Firefox which will helps occurred OOM.
> >> Sorry I can't attach here html page because my message will rejected
> >> as message would contained HTML subpart.
> >>
> >> Actual result virtual machine hang and even couldn't be force off.
> >>
> >> Expected result virtual machine continue work.
> >>
> >> [ 2335.903277] INFO: task CPU 0/KVM:7450 blocked for more than 120 seconds.
> >> [ 2335.903284]A A A A A A  Not tainted 4.15.7-300.fc27.x86_64+debug #1
> >> [ 2335.903287] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
> >> disables this message.
> >> [ 2335.903291] CPU 0/KVMA A A A A A  D10648A  7450A A A A A  1 0x00000000
> >> [ 2335.903298] Call Trace:
> >> [ 2335.903308]A  ? __schedule+0x2e9/0xbb0
> >> [ 2335.903318]A  ? __lock_page+0xad/0x180
> >> [ 2335.903322]A  schedule+0x2f/0x90
> >> [ 2335.903327]A  io_schedule+0x12/0x40
> >> [ 2335.903331]A  __lock_page+0xed/0x180
> >> [ 2335.903338]A  ? page_cache_tree_insert+0x130/0x130
> >> [ 2335.903347]A  deferred_split_scan+0x318/0x340
> >
> > I guess it's bad idea to wait the page to be unlocked in the relaim path.
> > Could you check if this makes a difference:
> >
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 87ab9b8f56b5..529cf36b7edb 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -2783,11 +2783,13 @@ static unsigned long deferred_split_scan(struct shrinker *shrink,
> >
> >A A A A A A A A  list_for_each_safe(pos, next, &list) {
> >A A A A A A A A A A A A A A A A  page = list_entry((void *)pos, struct page, mapping);
> > -A A A A A A A A A A A A A A  lock_page(page);
> > +A A A A A A A A A A A A A A  if (!trylock_page(page))
> > +A A A A A A A A A A A A A A A A A A A A A A  goto next;
> >A A A A A A A A A A A A A A A A  /* split_huge_page() removes page from list on success */
> >A A A A A A A A A A A A A A A A  if (!split_huge_page(page))
> >A A A A A A A A A A A A A A A A A A A A A A A A  split++;
> >A A A A A A A A A A A A A A A A  unlock_page(page);
> > +next:
> >A A A A A A A A A A A A A A A A  put_page(page);
> >A A A A A A A A  }
> >
>
> Kiril,thanks for pay attention to the problem.
> But your patch couldn't help. Virtual machine was hang after OOM.
> New dmesg is attached.
>

Indeed, but the location of hungup seems to be different. dmesg.txt was
hanging at io_schedule() waiting for lock_page() and dmesg2.txt was
hanging at down_write(&mm->mmap_sem)/down_read(&mm->mmap_sem). But
dmesg3.txt was not hanging at io_schedule() waiting for lock_page().

What activities are performed between lock_page() and unlock_page()?
Do the activities (directly or indirectly) depend on __GFP_DIRECT_RECLAIM
memory allocation requests (e.g. GFP_NOFS/GFP_NOIO)? If yes, it will be
unsafe to call lock_page() unconditionally (i.e. without checking GFP
context where the shrinker function was called), won't it?
