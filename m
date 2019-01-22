Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 313CB8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 15:28:26 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id l1so12982914wrn.3
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 12:28:26 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id g18si47644729wrx.15.2019.01.22.12.28.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 22 Jan 2019 12:28:24 -0800 (PST)
Date: Tue, 22 Jan 2019 21:28:19 +0100
From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH] backing-dev: no need to check return value of
 debugfs_create functions
Message-ID: <20190122202817.vypepopx4sd757c3@linutronix.de>
References: <20190122152151.16139-8-gregkh@linuxfoundation.org>
 <20190122160759.mx3h7gjc23zmrvxc@linutronix.de>
 <20190122162503.GB22548@kroah.com>
 <20190122171908.c7geuvluezkjp3s7@linutronix.de>
 <20190122183348.GA31271@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190122183348.GA31271@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Anders Roxell <anders.roxell@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org

On 2019-01-22 19:33:48 [+0100], Greg Kroah-Hartman wrote:
> On Tue, Jan 22, 2019 at 06:19:08PM +0100, Sebastian Andrzej Siewior wrote:
> > but if you cat the stats file then it will dereference the bdi struct
> > which has been free(), right?
> 
> Maybe, I don't know, your code is long gone, it doesn't matter :)

may point is that you may remain with a stats file in debugfs' root
folder which you can cat and then crash.

> > > But step back, how could that original call be NULL?  That only happens
> > > if you pass it a bad parent dentry (which you didn't), or the system is
> > > totally out of memory (in which case you don't care as everything else
> > > is on fire).
> > 
> > debugfs_get_inode() could do -ENOMEM and then the directory creation
> > fails with NULL.
> 
> And if that happens, your system has worse problems :)

So we care to properly handle -ENOMEM in driver's probe function. Those
change find their way to stable kernels.
This unhandled -ENOMEM in debugfs_get_inode() will let
debugfs_create_dir() reuturn NULL. Then debugfs_create_file() will
create the stats in debugfs' root folder. This is a changed behaviour
which is not expected. And then on rmmod the stats file is still present
and will participate in use-after-free if it is read.

> As it's been that way for over a decade, I think we will be fine :)
> If it changes in the future, in some way that actually matters, I'll go
> back and fix up all of the callers.

That is okay then :).
I don't mind if the stats file does not show up due to an error on
probe. It is debugfs after all. However I don't think that it is okay
that the stats file remains in the root folder even after the module has
been removed (and access memory that does not belong to it).

> thanks,
> 
> greg k-h

Sebastian
