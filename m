Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id E8F538E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 13:33:52 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id b8so18876825pfe.10
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 10:33:52 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w2si16218840pfg.78.2019.01.22.10.33.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 10:33:51 -0800 (PST)
Date: Tue, 22 Jan 2019 19:33:48 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] backing-dev: no need to check return value of
 debugfs_create functions
Message-ID: <20190122183348.GA31271@kroah.com>
References: <20190122152151.16139-8-gregkh@linuxfoundation.org>
 <20190122160759.mx3h7gjc23zmrvxc@linutronix.de>
 <20190122162503.GB22548@kroah.com>
 <20190122171908.c7geuvluezkjp3s7@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190122171908.c7geuvluezkjp3s7@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Anders Roxell <anders.roxell@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org

On Tue, Jan 22, 2019 at 06:19:08PM +0100, Sebastian Andrzej Siewior wrote:
> On 2019-01-22 17:25:03 [+0100], Greg Kroah-Hartman wrote:
> > > >  }
> > > >  
> > > >  static void bdi_debug_unregister(struct backing_dev_info *bdi)
> > > >  {
> > > > -	debugfs_remove(bdi->debug_stats);
> > > > -	debugfs_remove(bdi->debug_dir);
> > > > +	debugfs_remove_recursive(bdi->debug_dir);
> > > 
> > > this won't remove it.
> > 
> > Which is fine, you don't care.
> 
> but if you cat the stats file then it will dereference the bdi struct
> which has been free(), right?

Maybe, I don't know, your code is long gone, it doesn't matter :)

> > But step back, how could that original call be NULL?  That only happens
> > if you pass it a bad parent dentry (which you didn't), or the system is
> > totally out of memory (in which case you don't care as everything else
> > is on fire).
> 
> debugfs_get_inode() could do -ENOMEM and then the directory creation
> fails with NULL.

And if that happens, your system has worse problems :)

> 
> > > If you return for "debug_dir == NULL" then it is a nice cleanup.
> > 
> > No, that's not a valid thing to check for, you should not care as it
> > will not happen.  And if it does happen, it's ok, it's only debugfs, no
> > one can rely on it, it is only for debugging.
> 
> It might happen with ENOMEM as of now. It could happen for other reasons
> in future if the code changes.

As it's been that way for over a decade, I think we will be fine :)
If it changes in the future, in some way that actually matters, I'll go
back and fix up all of the callers.

thanks,

greg k-h
