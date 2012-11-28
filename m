Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 966476B007D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 08:51:14 -0500 (EST)
Received: from mail-ea0-f169.google.com ([209.85.215.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1Tdi2j-0002gA-IU
	for linux-mm@kvack.org; Wed, 28 Nov 2012 13:51:13 +0000
Received: by mail-ea0-f169.google.com with SMTP id a12so5566190eaa.14
        for <linux-mm@kvack.org>; Wed, 28 Nov 2012 05:51:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2254856.YsOm9y7BK1@vostro.rjw.lan>
References: <1353761958-12810-1-git-send-email-ming.lei@canonical.com>
	<5434404.G1ERYjuorE@vostro.rjw.lan>
	<CACVXFVP=3s3pawyEbogjb=PfbSeD1B+LFk7g04FAMkGuXDQUbQ@mail.gmail.com>
	<2254856.YsOm9y7BK1@vostro.rjw.lan>
Date: Wed, 28 Nov 2012 21:51:13 +0800
Message-ID: <CACVXFVN9RSU+j48cDVqc5mL=++y0BLc58BBRSxa_OWysysqQeg@mail.gmail.com>
Subject: Re: [PATCH v6 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 28, 2012 at 6:06 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
>
> Well, it may be unfrequent, but does it mean it has to do things that may
> be avoided (ie. walking the children of every node in the path in some cases)?

I agree so without introducing extra cost, :-)

> I don't really think that the counters would cost us that much anyway.

On ARM v7, sizeof(struct device) becomes 376 from 368 after introducing
'unsigned int            noio_cnt;' to 'struct dev_pm_info', and total memory
increases about 3752bytes in a small configuration(about 494 device instance).
The actual memory increase should be more than the data because 'struct device'
is generally embedded into other concrete device structure.

>> Also looks the current implementation of pm_runtime_set_memalloc_noio()
>> is simple and clean enough with the flag, IMO.
>
> I know you always know better. :-)

We still need to consider cost and the function calling frequency, :-)

>
>> > I would use the flag only to store the information that
>> > pm_runtime_set_memalloc_noio(dev, true) has been run for this device directly
>> > and I'd use a counter for everything else.
>> >
>> > That is, have power.memalloc_count that would be incremented when (1)
>> > pm_runtime_set_memalloc_noio(dev, true) is called for that device and (2) when
>> > power.memalloc_count for one of its children changes from 0 to 1 (and
>> > analogously for decrementation).  Then, check the counter in rpm_callback().
>>
>> Sorry, could you explain in a bit detail why we need the counter? Looks only
>> checking the flag in rpm_callback() is enough, doesn't it?
>
> Why would I want to use power.memalloc_count in addition to the
> power.memalloc_noio flag?
>
> Consider this:
>
> pm_runtime_set_memalloc_noio(dev):
>         return if power.memalloc_noio is set
>         set power.memalloc_noio
>   loop:
>         increment power.memalloc_count
>         if power.memalloc_count is 1 now switch to parent and go to loop

I am wondering if the above should be changed to below because the child
count of memalloc_noio device need to be recorded.

pm_runtime_set_memalloc_noio(dev):
         return if power.memalloc_noio is set
         set power.memalloc_noio
loop:
         increment power.memalloc_count
         switch to parent and go to loop

So pm_runtime_set_memalloc_noio(dev) will become worse than
the improved pm_runtime_set_memalloc_noio(dev, true), which
can return immediately if one dev or parent's flag is true.

> pm_runtime_clear_memalloc_noio(dev):
>         return if power.memalloc_noio is unset
>         unset power.memalloc_noio
>   loop:
>         decrement power.memalloc_count
>         if power.memalloc_count is 0 now switch to parent and go to loop

The above will perform well than pm_runtime_set_memalloc_noio(dev, false),
because the above avoids to walk children of device.

So one becomes worse and another becomes better, :-)

Also the children count of one device is generally very small, less than
10 for most devices, see the data obtained in one common x86 pc(thinkpad
t410) from below link:

        http://kernel.ubuntu.com/~ming/up/t410-dev-child-cnt.log

- about 8 devices whose child count is more than 10, top three are 18, 17 ,12,
and all the three are root devices.

- about 117 devices whose child count is between 1 and 9

- other 501 devices whose child count is zero

>From above data, walking device children should have not much effect on
performance of pm_runtime_set_memalloc_noio(), which is also called in
very infrequent path.

> Looks kind of simpler, doesn't it?

Looks simpler, but more code lines than single
pm_runtime_set_memalloc_noio(), :-)

>
> And why rpm_callback() should check power.memalloc_count instead of the count?
> Because power.memalloc_noio will only be set for devices that
> pm_runtime_set_memalloc_noio(dev) was called for directly (not necessarily for
> the parents).
>
> And that works even if someone calls any of them twice in a row for the same
> device (presumably by mistake) and doesn't have to make any assumptions
> about devices it is called for.

IMO, we can ignore the mistake usage because the function is called only
in network/block core code currently, not by individual driver.

>
>> > Besides, don't you need to check children for the arg device itself?
>>
>> It isn't needed since the children of network/block device can't be
>> involved of the deadlock in runtime PM path.
>>
>> Also, the function is only called by network device or block device
>> subsystem, both the two kind of device are class device and should
>> have no children.
>
> OK, so not walking the arg device's children is an optimization related to
> some assumptions regarding who's supposed to use this routine.  That should
> be clearly documented.

I think the patch already documents it in the comment of
pm_runtime_set_memalloc_noio().

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
