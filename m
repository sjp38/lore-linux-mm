Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2846B0253
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:32:14 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id p41so35615219lfi.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:32:14 -0700 (PDT)
Received: from mail.ud19.udmedia.de (ud19.udmedia.de. [194.117.254.59])
        by mx.google.com with ESMTPS id b6si1631271wjq.171.2016.07.13.08.32.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 08:32:12 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Wed, 13 Jul 2016 17:32:12 +0200
From: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Subject: Re: Page Allocation Failures/OOM with dm-crypt on software RAID10
 (Intel Rapid Storage)
In-Reply-To: <20160713134717.GL28723@dhcp22.suse.cz>
References: <02580b0a303da26b669b4a9892624b13@mail.ud19.udmedia.de>
 <20160712095013.GA14591@dhcp22.suse.cz>
 <d9dbe0328e938eb7544fdb2aa8b5a9c7@mail.ud19.udmedia.de>
 <20160712114920.GF14586@dhcp22.suse.cz>
 <e6c2087730e530e77c2b12d50495bdc9@mail.ud19.udmedia.de>
 <20160712140715.GL14586@dhcp22.suse.cz>
 <459d501038de4d25db6d140ac5ea5f8d@mail.ud19.udmedia.de>
 <20160713112126.GH28723@dhcp22.suse.cz>
 <20160713121828.GI28723@dhcp22.suse.cz>
 <74b9325c37948cf2b460bd759cff23dd@mail.ud19.udmedia.de>
 <20160713134717.GL28723@dhcp22.suse.cz>
Message-ID: <a6e48e37cce530f286e6669fdfc0b3f8@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-raid@vger.kernel.org, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org, Mike Snitzer <snitzer@redhat.com>

Hello...

On 2016-07-13 15:47, Michal Hocko wrote:

> This is getting out of my area of expertise so I am not sure I can help
> you much more, I am afraid.

That's okay. Thank you so much for investing the time.

For what it is worth, I did some further tests and here is what I came
up with:

If I create the plain dm-crypt device with 
--perf-submit_from_crypt_cpus,
I can run the tests for as long as I want but the memory problem never
occurs, meaning buffer/cache increase accordingly and thus free memory
decreases but used mem stays pretty constant low. Yet the problem here
is, the system becomes sluggish and throughput is severely impacted.
ksoftirqd is hovering at 100% the whole time.

Somehow my guess is that normally dm-crypt simply takes every request,
encrypts it and queues it internally by itself. And that queue is then
slowly emptied to the underlying device kernel queue. That is why I am
seeing the exploding increase in used memory (rather than in 
buffer/cache)
which in the end causes a OOM situation. But that is just my guess. And
IMHO that is not the right thing to do (tm), as can be seen in this 
case.

No matter what, I have no clue how to further diagnose this issue. And
given that I already had unsolvable issues with dm-crypt a couple of
months ago with my old machine where the system simply hang itself or
went OOM when the swap was encrypted and just a few kilobytes needed to
be swapped out, I am not so sure anymore I can trust dm-crypt with a
full disk encryption to the point where I feel "safe"... as-in, nothing
bad will happen or the system won't suddenly hang itself due to it. Or
if a bug is introduced, that it will actually be possible to diagnose it
and help fix it or that it will even be eventually fixed. Which is 
really
a pity, since I would really have liked to help solve this. With the
swap issue, I did git bisects, tests, narrowed it down to kernel 
versions
when said bug was introduced... but in the end, the bug is still present
as far as I know. :(

I will probably look again into ext4 fs encryption. My whole point is
just that in case any of disks go faulty and needs to be replaced or
sent in for warranty, I don't have to worry about mails, personal or
business data still being left on the device (e.g. if it is no longer
accessible or has reallocated sectors or whatever) in a readable form.

Oh well. Pity, really.

Thanks again,
Matthias

-- 
Dipl.-Inf. (FH) Matthias Dahl | Software Engineer | binary-island.eu
  services: custom software [desktop, mobile, web], server administration

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
