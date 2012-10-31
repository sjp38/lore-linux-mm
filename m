Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 6A7F46B0062
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 23:05:34 -0400 (EDT)
Received: from mail-ea0-f169.google.com ([209.85.215.169])
	by youngberry.canonical.com with esmtpsa (TLS1.0:RSA_ARCFOUR_SHA1:16)
	(Exim 4.71)
	(envelope-from <ming.lei@canonical.com>)
	id 1TTOcX-0000rA-Fs
	for linux-mm@kvack.org; Wed, 31 Oct 2012 03:05:33 +0000
Received: by mail-ea0-f169.google.com with SMTP id k11so470088eaa.14
        for <linux-mm@kvack.org>; Tue, 30 Oct 2012 20:05:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACVXFVMRJPfPSC_4ZamqfYUSYNsMEVYXMFmcs26T=4MdB_Kntw@mail.gmail.com>
References: <CACVXFVOPDu6wVgPmvtTkokn7VV41x3XVvL4g_E0pz0mikUbvUg@mail.gmail.com>
	<Pine.LNX.4.44L0.1210301112270.1363-100000@iolanthe.rowland.org>
	<CACVXFVO5-UPNrWsySzDE5AfOv1TMqbyitQX9ViidSJPM36fqAQ@mail.gmail.com>
	<2504263.kbM6W9JoH9@linux-lqwf.site>
	<CACVXFVMRJPfPSC_4ZamqfYUSYNsMEVYXMFmcs26T=4MdB_Kntw@mail.gmail.com>
Date: Wed, 31 Oct 2012 11:05:33 +0800
Message-ID: <CACVXFVNxucCVLS-=EQkmVop3LQMkeXW7RbZq4yfkiq_MUGndvg@mail.gmail.com>
Subject: Re: [PATCH v3 2/6] PM / Runtime: introduce pm_runtime_set[get]_memalloc_noio()
From: Ming Lei <ming.lei@canonical.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver Neukum <oneukum@suse.de>
Cc: Alan Stern <stern@rowland.harvard.edu>, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jens Axboe <axboe@kernel.dk>, "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org, linux-usb@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 31, 2012 at 10:08 AM, Ming Lei <ming.lei@canonical.com> wrote:
>> I am afraid it is, because a disk may just have been probed as the deviceis being reset.
>
> Yes, it is probable, and sounds like similar with 'root_wait' problem, see
> prepare_namespace(): init/do_mounts.c, so looks no good solution
> for the problem, and maybe we have to set the flag always before resetting
> usb device.

The below idea may help the problem which 'memalloc_noio' flag isn't set during
usb_reset_device().

- for usb mass storage device, call pm_runtime_set_memalloc_noio(true)
  inside usb_stor_probe2() and uas_probe(), and call
  pm_runtime_set_memalloc_noio(false) inside uas_disconnect()
  and usb_stor_disconnect().

- for usb network device, register_netdev() is always called inside usb
  interface's probe(),  looks no such problem.

Thanks,
--
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
