Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0B8EB6B0038
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 07:51:46 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id g16so25210083ywb.9
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 04:51:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v207sor443410ywc.212.2017.10.31.04.51.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Oct 2017 04:51:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171031105030.GE8989@quack2.suse.cz>
References: <1508448056-21779-1-git-send-email-yang.s@alibaba-inc.com>
 <CAOQ4uxhPhXrMLu18TGKDA=ezUVHara95qJQ+BTCio8BHm-u6NA@mail.gmail.com>
 <b530521e-5215-f735-444a-13f722d90e40@alibaba-inc.com> <CAOQ4uxhFOoSknnG-0Jyv+=iCDjVNnAg6SiO-msxw4tORkVKJGQ@mail.gmail.com>
 <20171031105030.GE8989@quack2.suse.cz>
From: Amir Goldstein <amir73il@gmail.com>
Date: Tue, 31 Oct 2017 13:51:40 +0200
Message-ID: <CAOQ4uxgqR1GvuTiMreDQrx2m=V4pzcn3o2T7_YQAj46AZ7fHQQ@mail.gmail.com>
Subject: Re: [RFC PATCH] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Yang Shi <yang.s@alibaba-inc.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-api@vger.kernel.org

On Tue, Oct 31, 2017 at 12:50 PM, Jan Kara <jack@suse.cz> wrote:
> On Sun 22-10-17 11:24:17, Amir Goldstein wrote:
>> But I think there is another problem, not introduced by your change, but could
>> be amplified because of it - when a non-permission event allocation fails, the
>> event is silently dropped, AFAICT, with no indication to listener.
>> That seems like a bug to me, because there is a perfectly safe way to deal with
>> event allocation failure - queue the overflow event.
>>
>> I am not going to be the one to determine if fixing this alleged bug is a
>> prerequisite for merging your patch, but I think enforcing memory limits on
>> event allocation could amplify that bug, so it should be fixed.
>>
>> The upside is that with both your accounting fix and ENOMEM = overlflow
>> fix, it going to be easy to write a test that verifies both of them:
>> - Run a listener in memcg with limited kmem and unlimited (or very
>> large) event queue
>> - Produce events inside memcg without listener reading them
>> - Read event and expect an OVERFLOW event
>>
>> This is a simple variant of LTP tests inotify05 and fanotify05.
>>
>> I realize that is user application behavior change and that documentation
>> implies that an OVERFLOW event is not expected when using
>> FAN_UNLIMITED_QUEUE, but IMO no one will come shouting
>> if we stop silently dropping events, so it is better to fix this and update
>> documentation.
>>
>> Attached a compile-tested patch to implement overflow on ENOMEM
>> Hope this helps to test your patch and then we can merge both, accompanied
>> with LTP tests for inotify and fanotify.
>>
>> Amir.
>
>> From 112ecd54045f14aff2c42622fabb4ffab9f0d8ff Mon Sep 17 00:00:00 2001
>> From: Amir Goldstein <amir73il@gmail.com>
>> Date: Sun, 22 Oct 2017 11:13:10 +0300
>> Subject: [PATCH] fsnotify: queue an overflow event on failure to allocate
>>  event
>>
>> In low memory situations, non permissions events are silently dropped.
>> It is better to queue an OVERFLOW event in that case to let the listener
>> know about the lost event.
>>
>> With this change, an application can now get an FAN_Q_OVERFLOW event,
>> even if it used flag FAN_UNLIMITED_QUEUE on fanotify_init().
>>
>> Signed-off-by: Amir Goldstein <amir73il@gmail.com>
>
> So I agree something like this is desirable but I'm uneasy about using
> {IN|FAN}_Q_OVERFLOW for this. Firstly, it is userspace visible change for
> FAN_UNLIMITED_QUEUE queues which could confuse applications as you properly
> note. Secondly, the event is similar to queue overflow but not quite the
> same (it is not that the application would be too slow in processing
> events, it is just that the system is in a problematic state overall). What
> are your thoughts on adding a new event flags like FAN_Q_LOSTEVENT or
> something like that? Probably the biggest downside there I see is that apps
> would have to learn to use it...
>

Well, I can't say I like FAN_Q_LOSTEVENT, but I can't really think of
a better option. I guess apps that would want to provide better protection
against loosing event will have to opt-in with a new fanotify_init() flag.
OTOH, if apps opts-in for this feature, we can also report Q_OVERFLOW
and document that it *is* expected in OOM situation.

If we have FAN_Q_LOSTEVENT, we can use it to handle both the case of
error to queue event (-ENOMEM) and the case of error on copy event to user
(e.g. -ENODEV), which is another case where we silently drop events
(in case buffer already contains good events).
In latter case, the error would be reported to user on event->fd.
In the former case, event->fd will also hold the error, as long as we can only
report -ENOMEM from this sort of error, because like overflow event, there
should probably be only one event of that sort in the queue.

Another option for API name is {IN|FAN}_Q_ERR, which implies that event->fd
carries the error. And of course user can get an event with mask
FAN_Q_OVERFLOW|FAN_Q_ERR, where event->fd is -ENOMEM or
-EOVERFLOW and then there is no ambiguity between different kind of
queue overflows.

Amir.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
