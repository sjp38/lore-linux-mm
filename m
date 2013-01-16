Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id E7D996B0069
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 15:08:48 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id d13so1512057qak.11
        for <linux-mm@kvack.org>; Wed, 16 Jan 2013 12:08:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130116044742.GB11461@blaptop>
References: <1357712474-27595-1-git-send-email-minchan@kernel.org>
 <1357712474-27595-3-git-send-email-minchan@kernel.org> <20130109162602.53a60e77.akpm@linux-foundation.org>
 <20130110022306.GB14685@blaptop> <20130110135828.c88bcaf1.akpm@linux-foundation.org>
 <20130111044327.GB6183@blaptop> <20130115160957.9ef860d7.akpm@linux-foundation.org>
 <CAPz6YkWC+y+jqD+0UNe+cD6OyveursZaahxc26mH81DOGD7sNw@mail.gmail.com>
 <20130115165042.1daadec2.akpm@linux-foundation.org> <CAPz6YkXNECSitpQvUNst0HW-uEWWssix-H1Cm_QfWSTMQE0m8Q@mail.gmail.com>
 <20130116044742.GB11461@blaptop>
From: Sonny Rao <sonnyrao@google.com>
Date: Wed, 16 Jan 2013 12:08:27 -0800
Message-ID: <CAPz6YkWUhMUScZ1we9enbnGyXH_2SS7mqoKE5gakAeBQNR3aHw@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm: forcely swapout when we are out of page cache
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Sameer Nanda <snanda@chromium.org>

On Tue, Jan 15, 2013 at 8:47 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Tue, Jan 15, 2013 at 05:21:15PM -0800, Sonny Rao wrote:
>> On Tue, Jan 15, 2013 at 4:50 PM, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>> > On Tue, 15 Jan 2013 16:32:38 -0800
>> > Sonny Rao <sonnyrao@google.com> wrote:
>> >
>> >> >> It's for saving the power to increase batter life.
>> >> >
>> >> > It might well have that effect, dunno.  That wasn't my intent.  Testing
>> >> > needed!
>> >> >
>> >>
>> >> Power saving is certainly why we had it on originally for ChromeOS,
>> >> but we turned it off due to misbehavior.
>> >>
>> >> Specifically, we saw a pathological behavior where we'd end up writing
>> >> to the disk every few seconds when laptop mode was turned on.  This
>> >> turned out to be because laptop-mode sets a timer which is used to
>> >> check for new dirty data after the initial flush and writes that out
>> >> before spinning the disk down, and on ChromeOS various chatty daemons
>> >> on the system were logging and dirtying data more or less constantly
>> >> so there was almost always something there to be written out.  So what
>> >> ended up happening was that we'd need to do a read, then wake up the
>> >> disk, and then keep writing every few seconds for a long period of
>> >> time, which had the opposite effect from what we wanted.
>> >
>> > So after the read, the disk would chatter away doing a dribble of
>> > writes?  That sounds like plain brokenness (and why did the chrome guys
>> > not tell anyone about it?!?!?).
>>
>> Yes, either read or fsync.  I ranted about it a little (here:
>> http://marc.info/?l=linux-mm&m=135422986220016&w=4), but mostly
>> assumed it was working as expected, and that ChromeOS was just
>> dirtying data at an absurd pace.  Might have been a bad assumption and
>> I could have been more explicit about reporting it, sorry about that.
>>
>> > The idea is that when the physical
>> > read occurs, we should opportunistically flush out all pending writes,
>> > while the disk is running.  Then go back into
>> > buffer-writes-for-a-long-time mode.
>> >
>>
>> See the comment in page-writeback.c above laptop_io_completion():
>>
>> /*
>>  * We've spun up the disk and we're in laptop mode: schedule writeback
>>  * of all dirty data a few seconds from now.  If the flush is already
>> scheduled
>>  * then push it back - the user is still using the disk.
>>  */
>> void laptop_io_completion(struct backing_dev_info *info)
>>
>> What ends up happening fairly often is that there's always something
>> dirty with that few seconds (or even one second) on our system.
>>
>> > I forget what we did with fsync() and friends.  Quite a lot of
>> > pestiferous applications like to do fsync quite frequently.  I had a
>> > special kernel in which fsync() consisted of "return 0;", but ISTR
>> > there being some resistance to productizing that idea.
>> >
>>
>> Yeah, we have this problem and we try to fix up users of fsync() as we
>> find them but it's a bit of a never-ending battle.  Such a feature
>> would be useful.
>>
>> >>  The issues
>> >> with zram swap just confirmed that we didn't want laptop mode.
>> >>
>> >> Most of our devices have had SSDs rather than spinning disks, so noise
>> >> wasn't an issue, although when we finally did support an official
>> >> device with a spinning disk people certainly complained when the disk
>> >> started clicking all the time
>> >
>> > hm, it's interesting that the general idea still has vailidity.  It
>> > would be a fun project for someone to sniff out all the requirements,
>> > fixup/enhance/rewrite the current implementation and generally make it
>> > all spiffy and nice.
>> >
>> >> (due to the underflow in the writeback code).
>> >
>> > To what underflow do you refer?
>> >
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commit;h=c8b74c2f6604923de91f8aa6539f8bb934736754
>>
>> That particular bug caused writes to happen almost instantly after the
>> underflow ocurred, and consequently slowed write throughput to a crawl
>> because there was no chance for contiguous writes to gather.
>>
>> >> We do know that current SSDs save a significant amount of
>> >> power when they go into standby, so minimizing disk writes is still
>> >> useful on these devices.
>> >>
>> >> A very simple laptop mode which only does a single sync when we spin
>> >> up the disk, and didn't bother with the timer behavior or muck with
>> >> swap behavior might be something that is more useful for us, and I
>> >> suspect it might simplify the writeback code somewhat as well.
>> >
>> > I don't think I understand the problem with the timer.  My original RFC
>> > said
>> >
>> > : laptop_writeback_centisecs
>> > : --------------------------
>> > :
>> > : This tunable determines the maximum age of dirty data when the machine
>> > : is operating in Laptop mode.  The default value is 30000 - five
>> > : minutes.  This means that if applications are generating a small amount
>> > : of write traffic, the disk will spin up once per five minutes.
>> > :
>> > : If the disk is spun up for any other reason (such as for a read) then
>> > : all dirty data will be flushed anyway, and this timer is reset to zero.
>> >
>> > which all sounds very sensible and shouldn't exhibit the behavior you
>> > observed.
>> >
>>
>> The laptop-mode timer get re-armed after each writeback (see above
>> laptop_io_completion function), even if it was caused by laptop-mode
>> itself.  So, if something is continually dirtying a little bit of
>> data, we end up getting a chain of small writes which keeps the disk
>> awake for long periods of time.
>
> Out of curiosity, for saving the power, why don' you increase the value for
> laptop_mode?
>

We want to keep the disk in the active state for as short a time as
possible, in order to save power.  The minimum time before we can go
to standby is 5 seconds, so that would be the upper limit on where
we'd want to set the laptop mode timer.  But the real issue here is
that the longer we wait, the greater the chance that something on the
system has dirtyed something which will get flushed, and cause the
chain of writes I mentioned above.  So, really we want to minimize
this time (down to 0), not maximize it.

>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
