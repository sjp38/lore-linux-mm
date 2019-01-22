Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 985648E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 11:25:07 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id r13so16773795pgb.7
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 08:25:07 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l96si16227856plb.292.2019.01.22.08.25.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 08:25:06 -0800 (PST)
Date: Tue, 22 Jan 2019 17:25:03 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] backing-dev: no need to check return value of
 debugfs_create functions
Message-ID: <20190122162503.GB22548@kroah.com>
References: <20190122152151.16139-8-gregkh@linuxfoundation.org>
 <20190122160759.mx3h7gjc23zmrvxc@linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190122160759.mx3h7gjc23zmrvxc@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Anders Roxell <anders.roxell@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org

On Tue, Jan 22, 2019 at 05:07:59PM +0100, Sebastian Andrzej Siewior wrote:
> On 2019-01-22 16:21:07 [+0100], Greg Kroah-Hartman wrote:
> > diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> > index 8a8bb8796c6c..85ef344a9c67 100644
> > --- a/mm/backing-dev.c
> > +++ b/mm/backing-dev.c
> > @@ -102,39 +102,25 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
> >  }
> >  DEFINE_SHOW_ATTRIBUTE(bdi_debug_stats);
> >  
> > -static int bdi_debug_register(struct backing_dev_info *bdi, const char *name)
> > +static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
> >  {
> > -	if (!bdi_debug_root)
> > -		return -ENOMEM;
> > -
> >  	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
> 
> If this fails then ->debug_dir is NULL 

Wonderful, who cares :)

> > -	if (!bdi->debug_dir)
> > -		return -ENOMEM;
> > -
> > -	bdi->debug_stats = debugfs_create_file("stats", 0444, bdi->debug_dir,
> > -					       bdi, &bdi_debug_stats_fops);
> > -	if (!bdi->debug_stats) {
> > -		debugfs_remove(bdi->debug_dir);
> > -		bdi->debug_dir = NULL;
> > -		return -ENOMEM;
> > -	}
> >  
> > -	return 0;
> > +	debugfs_create_file("stats", 0444, bdi->debug_dir, bdi,
> > +			    &bdi_debug_stats_fops);
> 
> then this creates the stats file in the root folder and

True.

> >  }
> >  
> >  static void bdi_debug_unregister(struct backing_dev_info *bdi)
> >  {
> > -	debugfs_remove(bdi->debug_stats);
> > -	debugfs_remove(bdi->debug_dir);
> > +	debugfs_remove_recursive(bdi->debug_dir);
> 
> this won't remove it.

Which is fine, you don't care.

But step back, how could that original call be NULL?  That only happens
if you pass it a bad parent dentry (which you didn't), or the system is
totally out of memory (in which case you don't care as everything else
is on fire).

> If you return for "debug_dir == NULL" then it is a nice cleanup.

No, that's not a valid thing to check for, you should not care as it
will not happen.  And if it does happen, it's ok, it's only debugfs, no
one can rely on it, it is only for debugging.

thanks,

greg k-h
