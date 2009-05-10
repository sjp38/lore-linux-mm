Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 156866B0083
	for <linux-mm@kvack.org>; Sun, 10 May 2009 05:35:47 -0400 (EDT)
Received: by gxk20 with SMTP id 20so4968764gxk.14
        for <linux-mm@kvack.org>; Sun, 10 May 2009 02:36:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1241946446.6317.42.camel@laptop>
References: <20090430181340.6f07421d.akpm@linux-foundation.org>
	 <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost>
	 <20090507151039.GA2413@cmpxchg.org>
	 <20090507134410.0618b308.akpm@linux-foundation.org>
	 <20090508081608.GA25117@localhost>
	 <20090508125859.210a2a25.akpm@linux-foundation.org>
	 <20090508230045.5346bd32@lxorguk.ukuu.org.uk>
	 <2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com>
	 <1241946446.6317.42.camel@laptop>
Date: Sun, 10 May 2009 18:36:19 +0900
Message-ID: <2f11576a0905100236u15d45f7fm32d470776659cfec@mail.gmail.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
	citizen
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, hannes@cmpxchg.org, riel@redhat.com, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, elladan@eskimo.com, npiggin@suse.de, cl@linux-foundation.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

>> How about this?
>> if priority < DEF_PRIORITY-2, aggressive lumpy reclaim in
>> shrink_inactive_list() already
>> reclaim the active page forcely.
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
>>
>> please don't ask performance number. I haven't reproduce Wu's patch
>> improvemnt ;)
>>
>> Wu, What do you think?
>
> I don't think this is desirable, like Andrew already said, there's tons
> of ways to defeat any of this and we've so far always priorized mappings
> over !mappings. Limiting this to only PROT_EXEC mappings is already less
> than it used to be.

I don't oppose this policy. PROT_EXEC seems good viewpoint.
The problem is PROT_EXEC'ed page isn't gurantee rarely.

if all pages claim "Hey, I'm higher priority page, please don't
reclaim me", end-user get
suck result easily.

before 2.6.27 kernel have similar problems. many mapped page cause bad late=
ncy
easily. I don't want reproduce this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
