Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2045B6B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 00:38:39 -0400 (EDT)
Received: by vxj3 with SMTP id 3so3146894vxj.14
        for <linux-mm@kvack.org>; Thu, 18 Aug 2011 21:38:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110819023406.GA12732@localhost>
References: <CAFPAmTSrh4r71eQqW-+_nS2KFK2S2RQvYBEpa3QnNkZBy8ncbw@mail.gmail.com>
	<20110818094824.GA25752@localhost>
	<1313669702.6607.24.camel@sauron>
	<20110818131343.GA17473@localhost>
	<CAFPAmTShNRykOEbUfRan_2uAAbBoRHE0RhOh4DrbWKq7a4-Z9Q@mail.gmail.com>
	<20110819023406.GA12732@localhost>
Date: Fri, 19 Aug 2011 10:08:36 +0530
Message-ID: <CAFPAmTSzYg5n150_ykv-Vvc4QVbz14Oxn_Mm+EqxzbUL3c39tg@mail.gmail.com>
Subject: Re: [PATCH] writeback: Per-block device bdi->dirty_writeback_interval
 and bdi->dirty_expire_interval.
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Artem Bityutskiy <dedekind1@gmail.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>

HI Wu,

On Fri, Aug 19, 2011 at 8:04 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> Hi Kautuk,
>
> On Fri, Aug 19, 2011 at 12:25:58AM +0800, Kautuk Consul wrote:
>>
>> Lines: 59
>>
>> Hi Wu,
>>
>> On Thu, Aug 18, 2011 at 6:43 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
>> > Hi Artem,
>> >
>> >> Here is a real use-case we had when developing the N900 phone. We had
>> >> internal flash and external microSD slot. Internal flash is soldered in
>> >> and cannot be removed by the user. MicroSD, in contrast, can be removed
>> >> by the user.
>> >>
>> >> For the internal flash we wanted long intervals and relaxed limits to
>> >> gain better performance.
>> >>
>> >> For MicroSD we wanted very short intervals and tough limits to make sure
>> >> that if the user suddenly removes his microSD (users do this all the
>> >> time) - we do not lose data.
>> >
>> > Thinking twice about it, I find that the different requirements for
>> > interval flash/external microSD can also be solved by this scheme.
>> >
>> > Introduce a per-bdi dirty_background_time (and optionally dirty_time)
>> > as the counterpart of (and works in parallel to) global dirty[_background]_ratio,
>> > however with unit "milliseconds worth of data".
>> >
>> > The per-bdi dirty_background_time will be set low for external microSD
>> > and high for internal flash. Then you get timely writeouts for microSD
>> > and reasonably delayed writes for internal flash (controllable by the
>> > global dirty_expire_centisecs).
>> >
>> > The dirty_background_time will actually work more reliable than
>> > dirty_expire_centisecs because it will checked immediately after the
>> > application dirties more pages. And the dirty_time could provide
>> > strong data integrity guarantee -- much stronger than
>> > dirty_expire_centisecs -- if used.

The dirty_writeback_centisecs is the value we are also actually
interested in, and not just
dirty_expire_interval. This value is what is actually used to reset
the per-BDI timeout in the code.

>> >
>> > Does that sound reasonable?
>> >
>> > Thanks,
>> > Fengguang
>> >
>>
>> My understanding of your email appears that you are agreeing in
>> principle that the temporal
>> aspect of this problem needs to be addressed along with your spatial
>> pattern analysis technique.
>
> Yup.
>
>> I feel a more generic solution to the problem is required because the
>> problem faced by Artem can appear
>> in a different situation for a different application.
>>
>> I can re-implement my original patch in either centiseconds or
>> milliseconds as suggested by you.
>
> My concern on your patch is the possible conflicts and confusions
> between the global and the per-bdi dirty_expire_centisecs. To maintain
> compatibility you need to keep the global one. Then there is the hard

If you refer to my original email, I have addressed this as follows:
When the global value is set, then all the per-BDI dirty*_centisecs
are also reset
to the global value.
This is essential for retaining the functionality across Linux
distributions using
the global values.
This amounts to compatibility as the global values will take effect.
After that point, if the user/admin feels, he/she can adjust/tune the
per-BDI counters to
certain empirical value as per the specific application. This will not
alter the global values.

> question of "what to do with the per-bdi values when the global value
> is changed". Whatever policy you choose, there will be user unexpected
> behaviors.
>

How ?
Of course, if the user tuned some per-BDI values and then chose to
reset the global values
we need to reset the per-BDI interfaces also as that is what the
original functionality of those
counters is.
Worst case scenario : The timeout might not take effect immediately as
per the newer global value.
The first timeout might still happen as per the older per-BDI value.

Individual per-BDI tuning should be done after the global values have been set.
Worst case scenario: Again, the timeout might not take effect
immediately as per the newer
per-BDI value. This first timeout might still happen as per the older
global value that the per-BDI had
before its individual tuning.

Both of the above worst case scenarios can lead to unexpected
behaviours but for short intervals
and only in the first timeout.
i)  The above timeout scenario can also happen if you don't alter this
interface.
      The first timeout might be at the end of the older interval time
and only after that the new value will
       take effect in terms of intervals.
ii)   Since these values would be quite important for the overall
functionality of the device, I don't
expect that the globals and the individual values would be frequently set/reset.
iii)   Anyways, only an advanced user would try to tune these per-BDI
values and would take care of
the point at which she/he set/reset these values in the system.
Or, maybe we solve this by fiddling around with the timeout values to
modify/cancel the timer based
on the new value ?

Is there any other possible worst-case scenario I left out ?

> I don't like such conflicting/inconsistent interfaces.
>

Well, I believe that the inconsistency or the lack of functionality
existed earlier, when global
values were all that existed. When the logical decision of having
per-block device threads
came around most of the /proc/sys/vm/dirty_* functionality can and
needs to be split.
This decision is as natural as your decision to have per-BDI dirty
bandwidth estimation.
Again, this problem is due to the advent of removable disk devices and
needs to be addressed
at a per-BDI level.

> Given that we'll need to introduce the dirty_background_time interface
> anyway, and it happen to can address the N900 internal/removable storage
> problem (mostly), I'm more than glad to cancel the dirty_expire_centisecs
> problem.
>

I have following doubts with respect to your dirty_background_time
interface suggestion:
i)   You say that you'll do this only for the N900 problem for solving
the unexpected disk removal
      problem.
      I believe you are ignoring the problem of rate of undirtying of
the block device pages for
      making reclamation of that block device's file-cache pages at a
sooner possible future time.
      I mentioned this in my earlier emails also.
ii)   Will you be changing the dirty_background_time dynamically with
your algorithm ?
      According to your description, I think not.
iii)  I cannot see how your implementation of dirty_background_time is
different from mine, except
      maybe for the first time interval taking effect properly.
      However, we can also think that the first time interval should
probably be honoured with the older
      value to make the transition from the old timer value to new
timer value smoother in terms of
      periodic writeback functionality.

> Or, do you have better way out of the dirty_expire_centisecs dilemma?
>

Maybe we can delete the global value entirely. However as you
correctly mentioned above, this
will impact other tools distributions altering these global values.

You mentioned the close relationship between the dirty_background_time
and the global dirty
[_background]_ratio.
Do you mean to say that you intend to change the dirty_background_time
based on changes to
the dirty_background_ratio ?
Since the global dirty_background_ratio doesn't result in changes to
the dirty_writeback_centisecs
wouldn't this amount to a radical change in the existing relationship
of these configurable values ?

> Thanks,
> Fengguang
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
