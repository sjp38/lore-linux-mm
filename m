Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3EC8E0001
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 01:46:50 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id i3so1059895pfj.4
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 22:46:50 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a2si18504556pfb.166.2019.01.22.22.46.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 22:46:49 -0800 (PST)
Date: Wed, 23 Jan 2019 07:46:46 +0100
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] backing-dev: no need to check return value of
 debugfs_create functions
Message-ID: <20190123064646.GA26885@kroah.com>
References: <20190122152151.16139-8-gregkh@linuxfoundation.org>
 <20190122160759.mx3h7gjc23zmrvxc@linutronix.de>
 <20190122162503.GB22548@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190122162503.GB22548@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Anders Roxell <anders.roxell@linaro.org>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org

On Tue, Jan 22, 2019 at 05:25:03PM +0100, Greg Kroah-Hartman wrote:
> On Tue, Jan 22, 2019 at 05:07:59PM +0100, Sebastian Andrzej Siewior wrote:
> > On 2019-01-22 16:21:07 [+0100], Greg Kroah-Hartman wrote:
> > > diff --git a/mm/backing-dev.c b/mm/backing-dev.c
> > > index 8a8bb8796c6c..85ef344a9c67 100644
> > > --- a/mm/backing-dev.c
> > > +++ b/mm/backing-dev.c
> > > @@ -102,39 +102,25 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
> > >  }
> > >  DEFINE_SHOW_ATTRIBUTE(bdi_debug_stats);
> > >  
> > > -static int bdi_debug_register(struct backing_dev_info *bdi, const char *name)
> > > +static void bdi_debug_register(struct backing_dev_info *bdi, const char *name)
> > >  {
> > > -	if (!bdi_debug_root)
> > > -		return -ENOMEM;
> > > -
> > >  	bdi->debug_dir = debugfs_create_dir(name, bdi_debug_root);
> > 
> > If this fails then ->debug_dir is NULL 
> 
> Wonderful, who cares :)

Ok, after sleeping on it, I'll change this function to return an error
if we are out of memory, that way you will not be creating any files in
any other location if you use the return value like this.  That should
solve this issue.

thanks,

greg k-h
