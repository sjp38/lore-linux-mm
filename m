Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5AB748E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 12:19:13 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id v16so12456425wru.8
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 09:19:13 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id h133si35824998wmf.41.2019.01.22.09.19.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 22 Jan 2019 09:19:12 -0800 (PST)
Date: Tue, 22 Jan 2019 18:19:08 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] backing-dev: no need to check return value of
 debugfs_create functions
Message-ID: <20190122171908.c7geuvluezkjp3s7@linutronix.de>
References: <20190122152151.16139-8-gregkh@linuxfoundation.org>
 <20190122160759.mx3h7gjc23zmrvxc@linutronix.de>
 <20190122162503.GB22548@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190122162503.GB22548@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Anders Roxell <anders.roxell@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org

On 2019-01-22 17:25:03 [+0100], Greg Kroah-Hartman wrote:
> > >  }
> > >  
> > >  static void bdi_debug_unregister(struct backing_dev_info *bdi)
> > >  {
> > > -	debugfs_remove(bdi->debug_stats);
> > > -	debugfs_remove(bdi->debug_dir);
> > > +	debugfs_remove_recursive(bdi->debug_dir);
> > 
> > this won't remove it.
> 
> Which is fine, you don't care.

but if you cat the stats file then it will dereference the bdi struct
which has been free(), right?

> But step back, how could that original call be NULL?  That only happens
> if you pass it a bad parent dentry (which you didn't), or the system is
> totally out of memory (in which case you don't care as everything else
> is on fire).

debugfs_get_inode() could do -ENOMEM and then the directory creation
fails with NULL.

> > If you return for "debug_dir == NULL" then it is a nice cleanup.
> 
> No, that's not a valid thing to check for, you should not care as it
> will not happen.  And if it does happen, it's ok, it's only debugfs, no
> one can rely on it, it is only for debugging.

It might happen with ENOMEM as of now. It could happen for other reasons
in future if the code changes.

> thanks,
> 
> greg k-h

Sebastian
