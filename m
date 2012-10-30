Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id DA0666B0062
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 12:00:58 -0400 (EDT)
Received: from mail-ee0-f41.google.com ([74.125.83.41])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TTEFM-0007ai-VN
	for linux-mm@kvack.org; Tue, 30 Oct 2012 16:00:56 +0000
Received: by mail-ee0-f41.google.com with SMTP id c4so326844eek.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2012 09:00:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.44L0.1210301112270.1363-100000@iolanthe.rowland.org>
References: <CACVXFVOPDu6wVgPmvtTkokn7VV41x3XVvL4g_E0pz0mikUbvUg@mail.gmail.com>
	<Pine.LNX.4.44L0.1210301112270.1363-100000@iolanthe.rowland.org>
Date: Wed, 31 Oct 2012 00:00:56 +0800
Message-ID: <CACVXFVO5-UPNrWsySzDE5AfOv1TMqbyitQX9ViidSJPM36fqAQ@mail.gmail.com>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: linux-kernel@vger.kernel.org, Oliver Neukum <oneukum@suse.de>, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 30, 2012 at 11:38 PM, Alan Stern <stern@rowland.harvard.edu> wrote:

>
> Okay, I see your point.  But acquiring the lock here doesn't solve the
> problem.  Suppose a thread is about to reset a USB mass-storage device.
> It acquires the lock and sees that the noio flag is clear.  But before
> it can issue the reset, another thread sets the noio flag.

If the USB mass-storage device is being reseted, the flag should be set
already generally.  If the flag is still unset, that means the disk/network
device isn't added into system(or removed just now), so memory allocation
with block I/O should be allowed during the reset. Looks it isn't one problem,
isn't it?

> I'm not sure what the best solution is.
>
>> The lock needn't to be held when the function is called inside
>> pm_runtime_set_memalloc_noio(),  so the bitfield flag should
>> be checked directly without holding power lock in dev_memalloc_noio().
>
> Yes.
>
> A couple of other things...  Runtime resume can be blocked by runtime
> suspend, if a resume is requested while the suspend is in progress.
> Therefore the runtime suspend code also needs to save-set-restore the
> noio flag.

Looks the simplest approach is to handle the noio flag thing at the start and
end of rpm_resume.

> Also, we should set the noio flag at the start of
> usb_stor_control_thread, because everything that thread does can
> potentially block an I/O operation.

Yes, it should be done, and all GFP_NOIO in usbcore should be converted
into GFP_KERNEL together. And the work shouldn't be started until
the patchset is merged.

> Lastly, pm_runtime_get_memalloc_noio always returns false when
> CONFIG_PM_RUNTIME is disabled.  But we still need to prevent I/O during
> usb_reset_device even when there's no runtime PM.  Maybe the simplest
> answer is always to set noio during resets.  That would also help with
> the race described above.

I have thought about this. IMO, pm_runtime_get_memalloc_noio should
return true always if CONFIG_PM_RUNTIME is unset.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
