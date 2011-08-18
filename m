Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AFE72900138
	for <linux-mm@kvack.org>; Thu, 18 Aug 2011 11:26:33 -0400 (EDT)
Received: by gyg10 with SMTP id 10so1879912gyg.14
        for <linux-mm@kvack.org>; Thu, 18 Aug 2011 08:26:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110818123523.GB1883@localhost>
References: <CAFPAmTSrh4r71eQqW-+_nS2KFK2S2RQvYBEpa3QnNkZBy8ncbw@mail.gmail.com>
	<20110818094824.GA25752@localhost>
	<1313669702.6607.24.camel@sauron>
	<20110818123523.GB1883@localhost>
Date: Thu, 18 Aug 2011 20:56:29 +0530
Message-ID: <CAFPAmTSot4+ohQGX7wmgYPdEVAvh7jr+e3LeUKx0m7guea+rtQ@mail.gmail.com>
Subject: Re: [PATCH] writeback: Per-block device bdi->dirty_writeback_interval
 and bdi->dirty_expire_interval.
From: Kautuk Consul <consul.kautuk@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Artem Bityutskiy <dedekind1@gmail.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>

Please find my comments inline to the email below:

On Thu, Aug 18, 2011 at 6:05 PM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
> On Thu, Aug 18, 2011 at 08:14:57PM +0800, Artem Bityutskiy wrote:
>> On Thu, 2011-08-18 at 17:48 +0800, Wu Fengguang wrote:
>> > > For example, the user might want to write-back pages in smaller
>> > > intervals to a block device which has a
>> > > faster known writeback speed.
>> >
>> > That's not a complete rational. What does the user ultimately want by
>> > setting a smaller interval? What would be the problems to the other
>> > slow devices if the user does so by simply setting a small value
>> > _globally_?
>> >
>> > We need strong use cases for doing such user interface changes.
>> > Would you detail the problem and the pains that can only (or best)
>> > be addressed by this patch?
>>
>> Here is a real use-case we had when developing the N900 phone. We had
>> internal flash and external microSD slot. Internal flash is soldered in
>> and cannot be removed by the user. MicroSD, in contrast, can be removed
>> by the user.

Yes, of course. I forgot this aspect also.
In fact I, too work on embedded platforms and I have faced this
problem with removable USB
disks. Our embedded applications don't even tell the user when it
would be a good time to remove
the USB stick.
Hence we run into data integrity problems for our filesystems when
some writebacks have not been
completed before removal of the USB disk.
Thanks for mentioning this as this adds to a use-case for this feature.

>>
>> For the internal flash we wanted long intervals and relaxed limits to
>> gain better performance.
>
> Understand -- it's backed by the battery anyway.
>
> Yeah it's a practical way. It might even optimize away some of the
> writes if they are truncated some time later. It also allows possible
> optimization of deferring the writes to user inactive periods.
>
> However the ultimate optimization could be to prioritize READs over
> WRITEs in the IO scheduler, so that async WRITEs have minimal impact
> on normal operations. It's the only option for the MicroSD case,
> anyway.
>
>> For MicroSD we wanted very short intervals and tough limits to make sure
>> that if the user suddenly removes his microSD (users do this all the
>> time) - we do not lose data.
>
> Pretty reasonable.
>
>> The discussed capability would be very useful in that case, AFAICS.
>
> Agreed.
>
>> IOW, this is not only about fast/slow devices and how quickly you want
>> to be able to sync the FS, this is also about data integrity guarantees.
>
> In fact I never think it would matter for fast/slow devices. =A0It's the

As I mentioned, if there is a comparitively faster device, you might want t=
o set
smaller intervals in which your pages are synced with disk for quicker
memory reclamation
purposes. This can be used on servers that run apps that have high
disk accesses as
well as need a lot of memory. As I explained before, in that case, the
direct reclamation
procedure will cause the usermode apps to sleep while trying to free
up pages by flushing
them to disk via the filesystem's writepage().

> dirty_ratio/dirty_bytes interfaces that ask for improvement if care
> about too many pages being cached.
>

The dirty_ratio/dirty_bytes interface is good as a spatial approach in
terms of number of pages
to actually write after each interval.
This still cannot solve the problem Artem is mentioning, because the
time at which removable disks
can be detached is indeterminable as the user can do this anytime he wants.
Whatever algorithm you use, you will eventually run into some
situation where the user detaches a
disk before the writeback can really happen.
I think it is up to the user/admin to determine how much write-back
interval is actually required for his/her
specific application.

> The intervals interfaces are intended for data integrity and nothing
> more.

Yes. That is correct, but do you feel that this data integrity is
possible in this age of removable
disks ?
That said, I would say that your patches are a very nice spatial
approach to a part of the solution.
Do you feel that combining a temporal approach along with your spatial
pattern analysis technique would
be the best way to ensure data integrity along with proper bandwidth
estimation for specific applications ?

>
> Thanks,
> Fengguang
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
