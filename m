Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 570036B0005
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 10:47:19 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g18so72163095lfg.2
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 07:47:19 -0700 (PDT)
Received: from mail.ud19.udmedia.de (ud19.udmedia.de. [194.117.254.59])
        by mx.google.com with ESMTPS id o10si145974wjz.233.2016.07.11.07.47.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 07:47:17 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Mon, 11 Jul 2016 16:47:17 +0200
From: Matthias Dahl <ml_linux-kernel@binary-island.eu>
Subject: Re: [dm-devel] [4.7.0rc6] Page Allocation Failures with dm-crypt
In-Reply-To: <20160711133051.GA28308@redhat.com>
References: <28dc911645dce0b5741c369dd7650099@mail.ud19.udmedia.de>
 <e7af885e08e1ced4f75313bfdfda166d@mail.ud19.udmedia.de>
 <20160711131818.GA28102@redhat.com> <20160711133051.GA28308@redhat.com>
Message-ID: <2786d2f951a90eb00502096aca71e05b@mail.ud19.udmedia.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org

Hello Mike...

On 2016-07-11 15:30, Mike Snitzer wrote:

> But that is expected given you're doing an unbounded buffered write to
> the device.  What isn't expected, to me anyway, is that the mm 
> subsystem
> (or the default knobs for buffered writeback) would be so aggressive
> about delaying writeback.

Ok. But, and please correct me if I am wrong, I was under the impression
that only the file caches/buffers were affected, iow, if I use free to
monitor the memory usage, the used memory increases to the point where 
it
consumes all memory, not the buffers/file caches... that is what I am
seeing here.

Also, if I use dd directly on the device w/o dm-crypt in-between, there
is no problem. Sure, buffers increase hugely also... but only those.

> Why are you doing this test anyway?  Such a large buffered write 
> doesn't
> seem to accurately model any application I'm aware of (but obviously it
> should still "work").

It is not a test per se. I simply wanted to fill the partition with 
noise.
And doing it this way is faster than using urandom or anything. ;-) That 
is
why I stumbled over this issue in the first place.

> Now that is weird.  Are you (or the distro you're using) setting any mm
> subsystem tunables to really broken values?

You can see those in my initial mail. I attached the kernel warnings, 
all
sysctl tunables and more. Maybe that helps.

> What is your raid10's full stripesize?

4 disks in RAID10, with a stripe size of 64k.

> Is your dd IO size of 512K somehow triggering excess R-M-W cycles which
> is exacerbating the problem?

The partitions are properly aligned. And as you can see, with that 
stripe
size, there is no issue.

In the meantime I did some further tests: I created an ext2 on the
partition as well as a 60GiB container image on it. I used that image
with dm-crypt, same parameters as before. No matter what I do here, I
cannot trigger the same behavior.

Maybe it is an interaction issue between dm-crypt and the s/w RAID. But
at this point, I have no idea how to further diagnose/test it. If you
can point me in any direction that would be great...

With Kind Regards from Germany
Matthias

-- 
Dipl.-Inf. (FH) Matthias Dahl | Software Engineer | binary-island.eu
  services: custom software [desktop, mobile, web], server administration

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
