Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 5FD8F6B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:13:49 -0500 (EST)
Received: by mail-qc0-f175.google.com with SMTP id x13so4467942qcv.6
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:13:49 -0800 (PST)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id g16si942786qgd.15.2014.02.06.08.23.01
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 08:23:31 -0800 (PST)
Date: Thu, 6 Feb 2014 10:22:58 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC] slub: do not drop slab_mutex for
 sysfs_slab_{add,remove}
In-Reply-To: <1391702294-27289-1-git-send-email-vdavydov@parallels.com>
Message-ID: <alpine.DEB.2.10.1402061021180.4927@nuc>
References: <1391702294-27289-1-git-send-email-vdavydov@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: penberg@kernel.org, akpm@linux-foundation.org, rientjes@google.com, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Thu, 6 Feb 2014, Vladimir Davydov wrote:

> When creating/destroying a kmem cache, we do a lot of work holding the
> slab_mutex, but we drop it for sysfs_slab_{add,remove} for some reason.
> Since __kmem_cache_create and __kmem_cache_shutdown are extremely rare,
> I propose to simplify locking by calling sysfs_slab_{add,remove} w/o
> dropping the slab_mutex.

The problem is that sysfs does nasty things like spawning a process in
user space that may lead to something wanting to create slabs too. The
module may then hang waiting on the lock ...

I would be very thankful, if you can get that actually working reliably
without deadlock issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
