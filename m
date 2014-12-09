Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1005C6B0032
	for <linux-mm@kvack.org>; Tue,  9 Dec 2014 05:55:34 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so7430708wiw.14
        for <linux-mm@kvack.org>; Tue, 09 Dec 2014 02:55:33 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cs8si1524422wjc.11.2014.12.09.02.55.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Dec 2014 02:55:33 -0800 (PST)
Date: Tue, 9 Dec 2014 11:55:32 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] Drivers: hv: balloon: Fix the deadlock issue in the
 memory hot-add code
Message-ID: <20141209105532.GB11373@dhcp22.suse.cz>
References: <1417826471-21131-1-git-send-email-kys@microsoft.com>
 <1417826498-21172-1-git-send-email-kys@microsoft.com>
 <1417826498-21172-2-git-send-email-kys@microsoft.com>
 <20141208150445.GB29102@dhcp22.suse.cz>
 <54864F27.8010008@jp.fujitsu.com>
 <20141209090843.GA11373@dhcp22.suse.cz>
 <5486CE2E.4070409@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5486CE2E.4070409@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, linux-mm@kvack.org

On Tue 09-12-14 19:25:50, Yasuaki Ishimatsu wrote:
> (2014/12/09 18:08), Michal Hocko wrote:
[...]
> >Doesn't udev retry the operation if it gets EBUSY or EAGAIN?
> 
> It depend on implementation of udev.rules. So we can retry online/offline
> operation in udev.rules.
[...]

# Memory hotadd request
SUBSYSTEM=="memory", ACTION=="add", DEVPATH=="/devices/system/memory/memory*[0-9]", TEST=="/sys$devpath/state", RUN+="/bin/sh -c 'echo online > /sys$devpath/state'"

OK so this is not prepared for a temporary failures and retries.

> >And again, why cannot we simply make the onlining fail or try_lock and
> >retry internally if the event consumer cannot cope with errors?
> 
> Did you mean the following Srinivasan's first patch looks good to you?
>   https://lkml.org/lkml/2014/12/2/662

Heh, I was just about to post this. Because I haven't noticed the
previous patch yet. Yeah, Something like that. Except that I would
expect EAGAIN or EBUSY rather than ERESTARTSYS which should never leak
into userspace. And that would happen here AFAICS because signal_pending
will not be true usually.

So there are two options. Either make the udev rule more robust and
retry within RUN section or do the retry withing online_pages (try_lock
and go into interruptible sleep which gets signaled by finished
add_memory()). The later option is safer wrt. the userspace because the
operation wouldn't fail unexpectedly.
Another option would be generating the sysfs file after all the internal
initialization is done and call it outside of the memory hotplug lock.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
