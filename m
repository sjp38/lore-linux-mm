Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A8B1C6B0062
	for <linux-mm@kvack.org>; Sun, 10 May 2009 05:29:17 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so1190816yxh.26
        for <linux-mm@kvack.org>; Sun, 10 May 2009 02:29:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090510092053.GA7651@localhost>
References: <20090501123541.7983a8ae.akpm@linux-foundation.org>
	 <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost>
	 <20090507151039.GA2413@cmpxchg.org>
	 <20090507134410.0618b308.akpm@linux-foundation.org>
	 <20090508081608.GA25117@localhost>
	 <20090508125859.210a2a25.akpm@linux-foundation.org>
	 <20090508230045.5346bd32@lxorguk.ukuu.org.uk>
	 <2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com>
	 <20090510092053.GA7651@localhost>
Date: Sun, 10 May 2009 18:29:43 +0900
Message-ID: <2f11576a0905100229m2c5e6a67md555191dc8c374ae@mail.gmail.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
	citizen
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

>> >> The patch seems reasonable but the changelog and the (non-existent)
>> >> design documentation could do with a touch-up.
>> >
>> > Is it right that I as a user can do things like mmap my database
>> > PROT_EXEC to get better database numbers by making other
>> > stuff swap first ?
>> >
>> > You seem to be giving everyone a "nice my process up" hack.
>>
>> How about this?
>
> Why it deserves more tricks? PROT_EXEC pages are rare.
> If user space is to abuse PROT_EXEC, let them be for it ;-)

yes, typicall rare.
tha problem is, user program _can_ use PROT_EXEC for get higher priority
ahthough non-executable memory.

In general, static priority mechanism have one weakness. if all object
have higher
priority, it break priority mechanism.


>> if priority < DEF_PRIORITY-2, aggressive lumpy reclaim in
>> shrink_inactive_list() already
>> reclaim the active page forcely.
>
> Isn't lumpy reclaim now enabled by (and only by) non-zero order?

you are right. but I only say the kernel already have policy changing threa=
shold
for preventing worst case.


>> then, this patch don't change kernel reclaim policy.
>>
>> anyway, user process non-changable preventing "nice my process up
>> hack" seems makes sense to me.
>>
>> test result:
>>
>> echo 100 > /proc/sys/vm/dirty_ratio
>> echo 100 > /proc/sys/vm/dirty_background_ratio
>> run modified qsbench (use mmap(PROT_EXEC) instead malloc)
>>
>> =A0 =A0 =A0 =A0 =A0 =A0active2active vs active2inactive ratio
>> before =A0 =A05:5
>> after =A0 =A0 =A0 1:9
>
> Do you have scripts for producing such numbers? I'm dreaming to have
> such tools :-)

I made stastics showing patch for testing, hehe :)

---
 include/linux/vmstat.h |    1 +
 mm/vmstat.c            |    1 +
 2 files changed, 2 insertions(+)

Index: b/include/linux/vmstat.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- a/include/linux/vmstat.h    2009-02-17 07:34:38.000000000 +0900
+++ b/include/linux/vmstat.h    2009-05-10 02:36:37.000000000 +0900
@@ -51,6 +51,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
                UNEVICTABLE_PGSTRANDED, /* unable to isolate on unlock */
                UNEVICTABLE_MLOCKFREED,
 #endif
+               FOR_ALL_ZONES(PGA2A),
                NR_VM_EVENT_ITEMS
 };

Index: b/mm/vmstat.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- a/mm/vmstat.c       2009-05-10 01:08:36.000000000 +0900
+++ b/mm/vmstat.c       2009-05-10 02:37:18.000000000 +0900
@@ -708,6 +708,7 @@ static const char * const vmstat_text[]
        "unevictable_pgs_stranded",
        "unevictable_pgs_mlockfreed",
 #endif
+       TEXTS_FOR_ZONES("pga2a")
 #endif
 };



>> please don't ask performance number. I haven't reproduce Wu's patch
>> improvemnt ;)
>
> That's why I decided to "explain" instead of "benchmark" the benefits
> of my patch, hehe.

okey, I see.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
