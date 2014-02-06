Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 7DB0E6B0036
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:02:10 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id cm18so3922254qab.26
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:02:10 -0800 (PST)
Received: from qmta13.emeryville.ca.mail.comcast.net (qmta13.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:243])
        by mx.google.com with ESMTP id p9si611693qcr.35.2014.02.06.11.13.24
        for <linux-mm@kvack.org>;
        Thu, 06 Feb 2014 11:13:54 -0800 (PST)
Date: Thu, 6 Feb 2014 13:13:20 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH RFC] slub: do not drop slab_mutex for
 sysfs_slab_{add,remove}
In-Reply-To: <52F3CF12.70905@parallels.com>
Message-ID: <alpine.DEB.2.10.1402061312180.6137@nuc>
References: <1391702294-27289-1-git-send-email-vdavydov@parallels.com> <alpine.DEB.2.10.1402061021180.4927@nuc> <52F3CF12.70905@parallels.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: penberg@kernel.org, akpm@linux-foundation.org, rientjes@google.com, mhocko@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Thu, 6 Feb 2014, Vladimir Davydov wrote:

> Hmm... IIUC the only function of concern is kobject_uevent() -
> everything else called from sysfs_slab_{add,remove} is a mix of kmalloc,
> kfree, mutex_lock/unlock - in short, nothing dangerous. There we do
> call_usermodehelper(), but we do it with UMH_WAIT_EXEC, which means
> "wait for exec only, but not for the process to complete". An exec
> shouldn't issue any slab-related stuff AFAIU. At least, I tried to run
> the patched kernel with lockdep enabled and got no warnings at all when
> getting uevents about adding/removing caches. That's why I started to
> doubt whether we really need this lock...
>
> Please correct me if I'm wrong.

I have had this deadlock a couple of years ago. Sysfs seems to change over
time. Not sure if that is still the case.

> > I would be very thankful, if you can get that actually working reliably
> > without deadlock issues.
>
> If there is no choice rather than moving sysfs_slab_{add,remove} out of
> the slab_mutex critical section, I'll have to do it that way. But first
> I'd like to make sure it cannot be done with less footprint.

I am all for holding the lock as long as possible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
