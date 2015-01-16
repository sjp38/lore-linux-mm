Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id C53AA6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 10:40:25 -0500 (EST)
Received: by mail-la0-f47.google.com with SMTP id hz20so19547849lab.6
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 07:40:24 -0800 (PST)
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com. [209.85.217.169])
        by mx.google.com with ESMTPS id ga1si3260803lbc.122.2015.01.16.07.40.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 07:40:24 -0800 (PST)
Received: by mail-lb0-f169.google.com with SMTP id p9so19095903lbv.0
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 07:40:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <x49zj9jaocy.fsf@segfault.boston.devel.redhat.com>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
	<x49zj9jaocy.fsf@segfault.boston.devel.redhat.com>
Date: Fri, 16 Jan 2015 10:40:23 -0500
Message-ID: <CANP1eJF0m-48--2ysYgymgBXES1nCefU-06SxZOv0hKzia8AUg@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] async buffered diskio read for userspace apps
From: Milosz Tanski <milosz@adfin.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: lsf-pc@lists.linux-foundation.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>

On Thu, Jan 15, 2015 at 1:30 PM, Jeff Moyer <jmoyer@redhat.com> wrote:
> Milosz Tanski <milosz@adfin.com> writes:
>
>> I would like to talk about enhancing the user interfaces for doing
>> async buffered disk IO for userspace applications. There's a whole
>> class of distributed web applications (most new applications today)
>> that would benefit from such an API. Most of them today rely on
>> cobbling one together in user space using a threadpool.
>>
>> The current in kernel AIO interfaces that only support DIRECTIO, they
>> were generally designed by and for big database vendors. The consensus
>> is that the current AIO interfaces usually lead to decreased
>> performance for those app.
>>
>> I've been developing a new read syscall that allows non-blocking
>> diskio read (provided that data is in the page cache). It's analogous
>> to what exists today in the network world with recvmsg with MSG_NOWAIT
>> flag. The work has been previously described by LWN here:
>> https://lwn.net/Articles/612483/
>>
>> Previous attempts (over the last 12+ years) at non-blocking buffered
>> diskio has stalled due to their complexity. I would like to talk about
>> the problem, my solution, and get feedback on the course of action.
>
> This email seems to conflate async I/O and non-blocking I/O.  Could you
> please be more specific about what you're proposing to talk about?  Is
> it just the non-blocking read support?
>
> Cheers,
> Jeff

Jeff, I'm sorry if I wasn't clear, let me restate why we should care
and why it matters.

The current applications that power the lower levels of the web stacks
as generally process streams of network data. Many of them (and the
frameworks for building them) are structured as a large async
processing loop. Disk IO a big pain point; the way are structured
(threadpools for diskio) introduces additional latency. sendfile() is
only helpful if you need to do additional processing (say SSL).

Non-blocking diskio can help us lower the response latency in those
webapps applications in the common cases (cached data, sequential
scan).

-- 
Milosz Tanski
CTO
16 East 34th Street, 15th floor
New York, NY 10016

p: 646-253-9055
e: milosz@adfin.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
