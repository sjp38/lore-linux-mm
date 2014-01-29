Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5029A6B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 15:07:48 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id hq11so1482207vcb.14
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 12:07:48 -0800 (PST)
Received: from mail-vb0-f50.google.com (mail-vb0-f50.google.com [209.85.212.50])
        by mx.google.com with ESMTPS id d1si1116402vck.125.2014.01.29.12.07.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 12:07:47 -0800 (PST)
Received: by mail-vb0-f50.google.com with SMTP id w8so1471411vbj.37
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 12:07:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20140129101631.GC6732@suse.de>
References: <CALCETrV2mtkKCMp6H+5gzoxi9kj9mx0GgsfiXqgn53AikCzFMw@mail.gmail.com>
 <20140129101631.GC6732@suse.de>
From: Andy Lutomirski <luto@amacapital.net>
Date: Wed, 29 Jan 2014 12:07:27 -0800
Message-ID: <CALCETrWE6-tjUkUfyPso65otidk5tg73ZSUkthYsnE6U+G-LJQ@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM ATTEND] Other tracks I'm interested in (was Re:
 Persistent memory)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux FS Devel <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Jan 29, 2014 at 2:16 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Tue, Jan 28, 2014 at 09:30:25AM -0800, Andy Lutomirski wrote:
>> On Thu, Jan 16, 2014 at 4:56 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>> > I'm interested in a persistent memory track.  There seems to be plenty
>> > of other emails about this, but here's my take:
>>
>> I should add that I'm also interested in topics relating to the
>> performance of mm and page cache under various abusive workloads.
>> These include database-like things and large amounts of locked memory.
>>
>
> Out of curiousity, is there any data available on this against a recent
> kernel? Locked memory should not cause the kernel to go to hell as the
> pages should end up on the unevictable LRU list. If that is not happening,
> it could be a bug. More details on the database configuration and test
> case would also be welcome as it would help establish if the problem is
> a large amount of memory being dirtied and then an fsync destroying the
> world or something else.
>

On (IIRC) 3.5, this stuff worked very poorly.  On 3.9, with a lot of
extra memory in the system, I seem to do okay.  I'm planning on trying
3.13 with a more moderate amount of memory soon.

On 3.11, with normal amounts of memory, something is still not so
good.  I'm seeing this on development boxes, so it may be
filesystem-dependent.

The performance things I actually care about lately are more in the
category of getting decent page-fault performance on locked pages.
Even better would be no page faults at all, but that may be a large
project.

The database in question is a proprietary thing (which I hope to
open-source some day) that creates and fallocates 10-20MB files,
mlocks them, reads a byte from every page to prefault them, then
writes them once, reads them quite a few times, and, after a while,
reads them one last time and deletes them.  At any given time, there
are a couple GB of these files open and mlocked.  Performance seems to
be okay (modulo page faults) once everything is up and running, but,
at startup, the system can go out to lunch for a while.

On a completely different workload (Mozilla Thunderbird's "Compact
Now" button on btrfs), something certainly still destroys the world.
I suspect that complaining about pathological cases in btrfs will get
me nowhere, though... :-/.

--Andy

> --
> Mel Gorman
> SUSE Labs



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
