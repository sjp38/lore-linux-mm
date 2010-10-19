Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E91245F0047
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 04:43:33 -0400 (EDT)
Received: by qyk34 with SMTP id 34so541716qyk.14
        for <linux-mm@kvack.org>; Tue, 19 Oct 2010 01:43:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101019101151.57c6dd56@notabene>
References: <20100915091118.3dbdc961@notabene>
	<4C90139A.1080809@redhat.com>
	<20100915122334.3fa7b35f@notabene>
	<20100915082843.GA17252@localhost>
	<20100915184434.18e2d933@notabene>
	<20101018151459.2b443221@notabene>
	<AANLkTimv_zXHdFDGa9ecgXyWmQynOKTDRPC59PZA9mvL@mail.gmail.com>
	<20101019101151.57c6dd56@notabene>
Date: Tue, 19 Oct 2010 10:43:31 +0200
Message-ID: <AANLkTin3wXWwA-HXhjx6wvzznp3p57Pg6fee8YNkZB79@mail.gmail.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
From: Torsten Kaiser <just.for.lkml@googlemail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Neil Brown <neilb@suse.de>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Shaohua <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Tue, Oct 19, 2010 at 1:11 AM, Neil Brown <neilb@suse.de> wrote:
> On Mon, 18 Oct 2010 12:58:17 +0200
> Torsten Kaiser <just.for.lkml@googlemail.com> wrote:
>
>> On Mon, Oct 18, 2010 at 6:14 AM, Neil Brown <neilb@suse.de> wrote:
>> > Testing shows that this patch seems to work.
>> > The test load (essentially kernbench) doesn't deadlock any more, thoug=
h it
>> > does get bogged down thrashing in swap so it doesn't make a lot more
>> > progress :-) =A0I guess that is to be expected.
>>
>> I just noticed this thread, as your mail from today pushed it up.
>>
>> In your original mail you wrote: " I recently had a customer (running
>> 2.6.32) report a deadlock during very intensive IO with lots of
>> processes. " and " Some threads that are blocked there, hold some IO
>> lock (probably in the filesystem) and are trying to allocate memory
>> inside the block device (md/raid1 to be precise) which is allocating
>> with GFP_NOIO and has a mempool to fall back on."
>>
>> I recently had the same problem (intense IO due to swapstorm created
>> by 20 gcc processes hung my system) and after initially blaming the
>> workqueue changes in 2.6.36 Tejun Heo determined that my problem was
>> not the workqueues getting locked up, but that it was cause by an
>> exhausted mempool:
>> http://marc.info/?l=3Dlinux-kernel&m=3D128655737012549&w=3D2
>>
>> Instrumenting mm/mempool.c and retrying my workload showed that
>> fs_bio_set from fs/bio.c looked like the mempool to blame and the code
>> in drivers/md/raid1.c to be the misuser:
>> http://marc.info/?l=3Dlinux-kernel&m=3D128671179817823&w=3D2
>>
>> I was even able to reproduce this hang with only using a normal RAID1
>> md device as swapspace and then using dd to fill a tmpfs until
>> swapping was needed:
>> http://marc.info/?l=3Dlinux-raid&m=3D128699402805191&w=3D2
>>
>> Looking back in the history of raid1.c and bio.c I found the following
>> interesting parts:
>>
>> =A0* the change to allocate more then one bio via bio_clone() is from
>> 2005, but it looks like it was OK back then, because at that point the
>> fs_bio_set was allocation 256 entries
>> =A0* in 2007 the size of the mempool was changed from 256 to only 2
>> entries (5972511b77809cb7c9ccdb79b825c54921c5c546 "A single unit is
>> enough, lets scale it down to 2 just to be on the safe side.")
>> =A0* only in 2009 the comment "To make this work, callers must never
>> allocate more than 1 bio at the time from this pool. Callers that need
>> to allocate more than 1 bio must always submit the previously allocate
>> bio for IO before attempting to allocate a new one. Failure to do so
>> can cause livelocks under memory pressure." was added to bio_alloc()
>> that is the base from my reasoning that raid1.c is broken. (And such a
>> comment was not added to bio_clone() although both calls use the same
>> mempool)
>>
>> So could please look someone into raid1.c to confirm or deny that
>> using multiple bio_clone() (one per drive) before submitting them
>> together could also cause such deadlocks?
>>
>> Thank for looking
>>
>> Torsten
>
> Yes, thanks for the report.
> This is a real bug exactly as you describe.
>
> This is how I think I will fix it, though it needs a bit of review and
> testing before I can be certain.
> Also I need to check raid10 etc to see if they can suffer too.
>
> If you can test it I would really appreciate it.

I did test it, but while it seemed to fix the deadlock, the system
still got unusable.
The still running "vmstat 1" showed that the swapout was still
progressing, but at a rate of ~20k sized bursts every 5 to 20 seconds.

I also tried to additionally add Wu's patch:
--- linux-next.orig/mm/vmscan.c 2010-10-13 12:35:14.000000000 +0800
+++ linux-next/mm/vmscan.c      2010-10-19 00:13:04.000000000 +0800
@@ -1163,6 +1163,13 @@ static int too_many_isolated(struct zone
               isolated =3D zone_page_state(zone, NR_ISOLATED_ANON);
       }

+       /*
+        * GFP_NOIO/GFP_NOFS callers are allowed to isolate more pages, so =
that
+        * they won't get blocked by normal ones and form circular deadlock=
