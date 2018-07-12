Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0F12F6B000D
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 07:34:14 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b25-v6so7743901eds.17
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 04:34:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s35-v6si1170030edm.70.2018.07.12.04.34.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 04:34:12 -0700 (PDT)
Date: Thu, 12 Jul 2018 13:34:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Caching/buffers become useless after some time
Message-ID: <20180712113411.GB328@dhcp22.suse.cz>
References: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marinko Catovic <marinko.catovic@gmail.com>
Cc: linux-mm@kvack.org

On Wed 11-07-18 15:18:30, Marinko Catovic wrote:
> hello guys
> 
> 
> I tried in a few IRC, people told me to ask here, so I'll give it a try.
> 
> 
> I have a very weird issue with mm on several hosts.
> The systems are for shared hosting, so lots of users there with lots of
> files.
> Maybe 5TB of files per host, several million at least, there is lots of I/O
> which can be handled perfectly fine with buffers/cache
> 
> The kernel version is the latest stable, 4.17.4, I had 3.x before and did
> not notice any issues until now. the same is for 4.16 which was in use
> before:
> 
> The hosts altogether have 64G of RAM and operate with SSD+HDD.
> HDDs are the issue here, since those 5TB of data are stored there, there
> goes the high I/O.
> Running applications need about 15GB, so say 40GB of RAM are left for
> buffers/caching.
> 
> Usually this works perfectly fine. The buffers take about 1-3G of RAM, the
> cache the rest, say 35GB as an example.
> But every now and then, maybe every 2 days it happens that both drop to
> really low values, say 100MB buffers, 3GB caches and the rest of the RAM is
> not in use, so there are about 35GB+ of totally free RAM.
> 
> The performance of the host goes down significantly then, as it becomes
> unusable at some point, since it behaves as if the buffers/cache were
> totally useless.
> After lots and lots of playing around I noticed that when shutting down all
> services that access the HDDs on the system and restarting them, that this
> does *not* make any difference.
> 
> But what did make a difference was stopping and umounting the fs, mounting
> it again and starting the services.
> Then the buffers+cache built up to 5GB/35GB as usual after a while and
> everything was perfectly fine again!
> 
> I noticed that what happens when umount is called, that the caches are
> being dropped. So I gave it a try:
> 
> sync; echo 2 > /proc/sys/vm/drop_caches
> 
> has the exactly same effect. Note that echo 1 > .. does not.
> 
> So if that low usage like 100MB/3GB occurs I'd have to drop the caches by
> echoing 2 to drop_caches. The 3GB then become even lower, which is
> expected, but then at least the buffers/cache built up again to ordinary
> values and the usual performance is restored after a few minutes.
> I have never seen this before, this happened after I switched the systems
> to newer ones, where the old ones had kernel 3.x, this behavior was never
> observed before.
> 
> Do you have *any idea* at all what could be causing this? that issue is
> bugging me since over a month and seriously really disturbs everything I'm
> doing since lot of people access that data and all of them start to
> complain at some point where I see that the caches became useless at that
> time, having to drop them to rebuild again.
> 
> Some guys in IRC suggested that his could be a fragmentation problem or
> something, or about slab shrinking.

Well, the page cache shouldn't really care about fragmentation because
single pages are used. Btw. what is the filesystem that you are using?

> The problem is that I can not reproduce this, I have to wait a while, maybe
> 2 days to observe that, until that the buffers/caches are fully in use and
> at some point they decrease within a few hours to those useless values.
> Sadly this is a production system and I can not play that much around,
> already causing downtime when dropping caches (populating caches needs
> maybe 5-10 minutes until the performance is ok again).

This doesn't really ring bells for me.

> Please tell me whatever info you need me to pastebin and when (before/after
> what event).
> Any hints are appreciated a lot, it really gives me lots of headache, since
> I am really busy with other things. Thank you very much!

Could you collect /proc/vmstat every few seconds over that time period?
Maybe it will tell us more.
-- 
Michal Hocko
SUSE Labs
