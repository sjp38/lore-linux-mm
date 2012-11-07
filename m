Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 354FE6B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 22:32:05 -0500 (EST)
Received: from mail-ea0-f169.google.com ([209.85.215.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TVwN2-0006dr-A3
	for linux-mm@kvack.org; Wed, 07 Nov 2012 03:32:04 +0000
Received: by mail-ea0-f169.google.com with SMTP id k11so536655eaa.14
        for <linux-mm@kvack.org>; Tue, 06 Nov 2012 19:32:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121106152419.9155a366.akpm@linux-foundation.org>
References: <1351931714-11689-1-git-send-email-ming.lei@canonical.com>
	<1351931714-11689-3-git-send-email-ming.lei@canonical.com>
	<20121106152419.9155a366.akpm@linux-foundation.org>
Date: Wed, 7 Nov 2012 11:32:04 +0800
Message-ID: <CACVXFVNjffkKWEdboPLuL8CpeUm4H8eDPfL5X4ePVPXL2xFR8w@mail.gmail.com>
Subject: Re: [PATCH v4 2/6] PM / Runtime: introduce pm_runtime_set_memalloc_noio()
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Alan Stern <stern@rowland.harvard.edu>, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 7, 2012 at 7:24 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
>
> checkpatch finds a number of problems with this patch, all of which
> should be fixed.  Please always use checkpatch.

Sorry for missing the check.

>> +             /* only clear the flag for one device if all
>> +              * children of the device don't set the flag.
>> +              */
>
> Such a comment is usually laid out as
>
>                 /*
>                  * Only ...

Will do it in -v5.

> More significantly, the comment describes what the code is doing but
> not why the code is doing it.  The former is (usually) obvious from
> reading the C, and the latter is what good code comments address.
>
> And it's needed in this case.  Why does the code do this?

Suppose both two usb scsi disks which share the same usb
configuration(device) set the device memalloc_noio flag, and
its ancestors' memalloc_noio flag should be cleared only after
both the two usb scsi disk's flags have been cleared.

OK, we'll add comment on clearing flag.

>
> Also, can a device have more than one child?  If so, the code doesn't
> do what the comment says it does.

It should do that because device_for_each_child() returns true immediately
only if dev_memalloc_noio() for one child returns true.

>
>> +             if (!dev || (!enable &&
>> +                          device_for_each_child(dev, NULL,
>> +                                                dev_memalloc_noio)))
>> +                     break;
>> +     }
>> +     mutex_unlock(&dev_hotplug_mutex);
>> +}
>> +EXPORT_SYMBOL_GPL(pm_runtime_set_memalloc_noio);


Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
