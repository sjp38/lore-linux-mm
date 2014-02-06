Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f48.google.com (mail-la0-f48.google.com [209.85.215.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9ED0E6B0036
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:24:46 -0500 (EST)
Received: by mail-la0-f48.google.com with SMTP id mc6so2019298lab.21
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:24:45 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id kj3si1006243lbc.99.2014.02.06.10.06.14
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Feb 2014 10:06:44 -0800 (PST)
Message-ID: <52F3CF12.70905@parallels.com>
Date: Thu, 6 Feb 2014 22:06:10 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] slub: do not drop slab_mutex for sysfs_slab_{add,remove}
References: <1391702294-27289-1-git-send-email-vdavydov@parallels.com> <alpine.DEB.2.10.1402061021180.4927@nuc>
In-Reply-To: <alpine.DEB.2.10.1402061021180.4927@nuc>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: penberg@kernel.org, akpm@linux-foundation.org, rientjes@google.com, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On 02/06/2014 08:22 PM, Christoph Lameter wrote:
> On Thu, 6 Feb 2014, Vladimir Davydov wrote:
>
>> When creating/destroying a kmem cache, we do a lot of work holding the
>> slab_mutex, but we drop it for sysfs_slab_{add,remove} for some reason.
>> Since __kmem_cache_create and __kmem_cache_shutdown are extremely rare,
>> I propose to simplify locking by calling sysfs_slab_{add,remove} w/o
>> dropping the slab_mutex.
> The problem is that sysfs does nasty things like spawning a process in
> user space that may lead to something wanting to create slabs too. The
> module may then hang waiting on the lock ...

Hmm... IIUC the only function of concern is kobject_uevent() -
everything else called from sysfs_slab_{add,remove} is a mix of kmalloc,
kfree, mutex_lock/unlock - in short, nothing dangerous. There we do
call_usermodehelper(), but we do it with UMH_WAIT_EXEC, which means
"wait for exec only, but not for the process to complete". An exec
shouldn't issue any slab-related stuff AFAIU. At least, I tried to run
the patched kernel with lockdep enabled and got no warnings at all when
getting uevents about adding/removing caches. That's why I started to
doubt whether we really need this lock...

Please correct me if I'm wrong.

> I would be very thankful, if you can get that actually working reliably
> without deadlock issues.

If there is no choice rather than moving sysfs_slab_{add,remove} out of
the slab_mutex critical section, I'll have to do it that way. But first
I'd like to make sure it cannot be done with less footprint.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
