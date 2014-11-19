Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id AF3186B0069
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 13:04:07 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id r5so861000qcx.30
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 10:04:07 -0800 (PST)
Received: from mail-qc0-x22c.google.com (mail-qc0-x22c.google.com. [2607:f8b0:400d:c01::22c])
        by mx.google.com with ESMTPS id q12si2684165qam.96.2014.11.19.10.04.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Nov 2014 10:04:05 -0800 (PST)
Received: by mail-qc0-f172.google.com with SMTP id m20so851751qcx.31
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 10:04:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141119012110.GA2608@cucumber.iinet.net.au>
References: <20141119012110.GA2608@cucumber.iinet.net.au>
From: Andrey Korolyov <andrey@xdel.ru>
Date: Wed, 19 Nov 2014 22:03:44 +0400
Message-ID: <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Marie <christian@ponies.io>
Cc: linux-mm@kvack.org

On Wed, Nov 19, 2014 at 4:21 AM, Christian Marie <christian@ponies.io> wrote:
>> Hello,
>>
>> I had found recently that the OSD daemons under certain conditions
>> (moderate vm pressure, moderate I/O, slightly altered vm settings) can
>> go into loop involving isolate_freepages and effectively hit Ceph
>> cluster performance.
>
> Hi! I'm the creator of the server fault issue you reference:
>
> http://serverfault.com/questions/642883/cause-of-page-fragmentation-on-large-server-with-xfs-20-disks-and-ceph
>
> I'd like to get to the bottom of this very much, I'm seeing a very similar
> pattern on 3.10.0-123.9.3.el7.x86_64, if this is fixed in later versions
> perhaps we could backport something.
>
> Here is some perf output:
>
> http://ponies.io/raw/compaction.png
>
> Looks pretty similar. I also have hundreds of MB logs and traces should we need
> some specific question answered.
>
> I've managed to reproduce many failed compactions with this:
>
> https://gist.github.com/christian-marie/cde7e80c5edb889da541
>
> I took some compaction stress test code and bolted on a little loop to mmap a
> large sparse file and read every PAGE_SIZEth byte.
>
> Run it once, compactions seem to do okay, run it again and they're really slow.
> This seems to be because my little trick to fill up cache memory only seems to
> work exactly half the time. Note that transhuge pages are only used to
> introduce fragmentation/pressure here, turning transparent huge pages off
> doesn't seem to make the slightest difference to the spinning-in-reclaim issue.
>
> We are using Mellanox ipoib drivers which do not do scatter-gather, so I'm
> currently working on adding support for that (the hardware supports it). Are
> you also using ipoib or have something else doing high order allocations? It's
> a bit concerning for me if you don't as it would suggest that cutting down on
> those allocations won't help.

So do I. On a test environment with regular tengig cards I was unable
to reproduce the issue. Honestly, I thought that almost every
contemporary driver for high-speed cards is working with
scatter-gather, so I had not mlx in mind as a potential cause of this
problem from very beginning. There are a couple of reports in ceph
lists, complaining for OSD flapping/unresponsiveness without clear
reason on certain (not always clear though) conditions which may have
same root cause. Wonder if numad-like mechanism will help there, but
its usage is generally an anti-performance pattern in my experience.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
