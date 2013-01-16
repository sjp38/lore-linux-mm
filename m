Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 4F8198D0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:32:59 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id hg5so2928097qab.15
        for <linux-mm@kvack.org>; Tue, 15 Jan 2013 16:32:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130115160957.9ef860d7.akpm@linux-foundation.org>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
 <1357712474-27595-3-git-send-email-minchan@kernel.org> <20130109162602.53a60e77.akpm@linux-foundation.org>
 <20130110022306.GB14685@blaptop> <20130110135828.c88bcaf1.akpm@linux-foundation.org>
 <20130111044327.GB6183@blaptop> <20130115160957.9ef860d7.akpm@linux-foundation.org>
From: Sonny Rao <sonnyrao@google.com>
Date: Tue, 15 Jan 2013 16:32:38 -0800
Message-ID: <CAPz6YkWC+y+jqD+0UNe+cD6OyveursZaahxc26mH81DOGD7sNw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: forcely swapout when we are out of page cache
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sameer Nanda <snanda@chromium.org>

On Tue, Jan 15, 2013 at 4:09 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 11 Jan 2013 13:43:27 +0900
> Minchan Kim <minchan@kernel.org> wrote:
>
>> Hi Andrew,
>>
>> On Thu, Jan 10, 2013 at 01:58:28PM -0800, Andrew Morton wrote:
>> > On Thu, 10 Jan 2013 11:23:06 +0900
>> > Minchan Kim <minchan@kernel.org> wrote:
>> >
>> > > > I have a feeling that laptop mode has bitrotted and these patches are
>> > > > kinda hacking around as-yet-not-understood failures...
>> > >
>> > > Absolutely, this patch is last guard for unexpectable behavior.
>> > > As I mentioned in cover-letter, Luigi's problem could be solved either [1/2]
>> > > or [2/2] but I wanted to add this as last resort in case of unexpected
>> > > emergency. But you're right. It's not good to hide the problem like this path
>> > > so let's drop [2/2].
>> > >
>> > > Also, I absolutely agree it has bitrotted so for correcting it, we need a
>> > > volunteer who have to inverstigate power saveing experiment with long time.
>> > > So [1/2] would be band-aid until that.
>> >
>> > I'm inclined to hold off on 1/2 as well, really.
>>
>> Then, what's your plan?
>
> My plan is to sit here until someone gets down and fully tests and
> fixes laptop-mode.  Making it work properly, reliably and as-designed.
>

I think we should agree on what the goals are first.

> Or perhaps someone wants to make the case that we just don't need it
> any more (SSDs are silent!) and removes it all.
>
>> >
>> > The point of laptop_mode isn't to save power btw - it is to minimise
>> > the frequency with which the disk drive is spun up.  By deferring and
>> > then batching writeout operations, basically.
>>
>> I don't get it. Why should we minimise such frequency?
>
> Because my laptop was going clickety every minute and was keeping me
> awake.
>

Very interesting, I don't know if anyone realized that (or we just forgot) :-)

>> It's for saving the power to increase batter life.
>
> It might well have that effect, dunno.  That wasn't my intent.  Testing
> needed!
>

Power saving is certainly why we had it on originally for ChromeOS,
but we turned it off due to misbehavior.

Specifically, we saw a pathological behavior where we'd end up writing
to the disk every few seconds when laptop mode was turned on.  This
turned out to be because laptop-mode sets a timer which is used to
check for new dirty data after the initial flush and writes that out
before spinning the disk down, and on ChromeOS various chatty daemons
on the system were logging and dirtying data more or less constantly
so there was almost always something there to be written out.  So what
ended up happening was that we'd need to do a read, then wake up the
disk, and then keep writing every few seconds for a long period of
time, which had the opposite effect from what we wanted.  The issues
with zram swap just confirmed that we didn't want laptop mode.

Most of our devices have had SSDs rather than spinning disks, so noise
wasn't an issue, although when we finally did support an official
device with a spinning disk people certainly complained when the disk
started clicking all the time (due to the underflow in the writeback
code).   We do know that current SSDs save a significant amount of
power when they go into standby, so minimizing disk writes is still
useful on these devices.

A very simple laptop mode which only does a single sync when we spin
up the disk, and didn't bother with the timer behavior or muck with
swap behavior might be something that is more useful for us, and I
suspect it might simplify the writeback code somewhat as well.

>> As I real all document about laptop_mode, they all said about the power
>> or battery life saving.
>>
>> 1. Documentation/laptops/laptop-mode.txt
>> 2. http://linux.die.net/man/8/laptop_mode
>> 3. http://samwel.tk/laptop_mode/
>> 3. http://www.thinkwiki.org/wiki/Laptop-mode
>
> Documentation creep ;)
>
> Ten years ago, gad: http://lwn.net/Articles/1652/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
