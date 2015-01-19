Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8896B0032
	for <linux-mm@kvack.org>; Sun, 18 Jan 2015 22:49:38 -0500 (EST)
Received: by mail-lb0-f181.google.com with SMTP id u14so16561460lbd.12
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 19:49:37 -0800 (PST)
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com. [209.85.217.182])
        by mx.google.com with ESMTPS id w19si9716691lbg.119.2015.01.18.19.49.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 Jan 2015 19:49:37 -0800 (PST)
Received: by mail-lb0-f182.google.com with SMTP id l4so618681lbv.13
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 19:49:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150116165506.GA10856@samba2>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
	<20150115223157.GB25884@quack.suse.cz>
	<CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
	<20150116165506.GA10856@samba2>
Date: Sun, 18 Jan 2015 22:49:36 -0500
Message-ID: <CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace apps
From: Milosz Tanski <milosz@adfin.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Allison <jra@samba.org>
Cc: Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jens Axboe <axboe@kernel.dk>

On Fri, Jan 16, 2015 at 11:55 AM, Jeremy Allison <jra@samba.org> wrote:
> On Fri, Jan 16, 2015 at 10:44:12AM -0500, Milosz Tanski wrote:
>> On Thu, Jan 15, 2015 at 5:31 PM, Jan Kara <jack@suse.cz> wrote:
>> > On Thu 15-01-15 12:43:23, Milosz Tanski wrote:
>> >> I would like to talk about enhancing the user interfaces for doing
>> >> async buffered disk IO for userspace applications. There's a whole
>> >> class of distributed web applications (most new applications today)
>> >> that would benefit from such an API. Most of them today rely on
>> >> cobbling one together in user space using a threadpool.
>> >>
>> >> The current in kernel AIO interfaces that only support DIRECTIO, they
>> >> were generally designed by and for big database vendors. The consensus
>> >> is that the current AIO interfaces usually lead to decreased
>> >> performance for those app.
>> >>
>> >> I've been developing a new read syscall that allows non-blocking
>> >> diskio read (provided that data is in the page cache). It's analogous
>> >> to what exists today in the network world with recvmsg with MSG_NOWAIT
>> >> flag. The work has been previously described by LWN here:
>> >> https://lwn.net/Articles/612483/
>> >>
>> >> Previous attempts (over the last 12+ years) at non-blocking buffered
>> >> diskio has stalled due to their complexity. I would like to talk about
>> >> the problem, my solution, and get feedback on the course of action.
>> >>
>> >> Over the years I've been building the low level guys of various "web
>> >> applications". That usually involves async network based applications
>> >> (epoll based servers) and the biggest pain point for the last 8+ years
>> >> has been async disk IO.
>> >   Maybe this topic will be sorted out before LSF/MM. I know Andrew had some
>> > objections about doc and was suggesting a solution using fincore() (which
>> > Christoph refuted as being racy). Also there was a pending question
>> > regarding whether the async read in this form will be used by applications.
>> > But if it doesn't get sorted out a short session on the pending issues
>> > would be probably useful.
>> >
>> >                                                                 Honza
>> > --
>> > Jan Kara <jack@suse.cz>
>> > SUSE Labs, CR
>>
>> I've spent the better part of yesterday wrapping up the first cut of
>> samba support to FIO so we can test a modified samba file server with
>> these changes in a few scenarios. Right now it's only sync but I hope
>> to have async in the future. I hope that by the time the summit rolls
>> around I'll have data to share from samba and maybe some other common
>> apps (node.js / twisted).
>
> Don't forget to share the code changes :-). We @ Samba would
> love to see them to keep track !

I have the first version of the FIO cifs support via samba in my fork
of FIO here: https://github.com/mtanski/fio/tree/samba

Right now it only supports sync mode of FIO (eg. can't submit multiple
outstanding requests) but I'm looking into how to make it work with
smb2 read/write calls with the async flag.

Additionally, I'm sure I'm doing some things not quite right in terms
of smbcli usage as it was a decent amount of trial and error to get it
to connect (esp. the setup before smbcli_full_connection). Finally, it
looks like the more complex api I'm using (as opposed to smbclient,
because I want the async calls) doesn't quite fully export all calls I
need via headers / public dyn libs so it's a bit of a hack to get it
to build: https://github.com/mtanski/fio/commit/7fd35359259b409ed023b924cb2758e9efb9950c#diff-1

But it works for my randread tests with zipf and the great part is
that it should provide a flexible way to test samba with many fake
clients and access patterns. So... progress.

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
