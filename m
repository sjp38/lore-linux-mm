Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 24ED48D0039
	for <linux-mm@kvack.org>; Wed,  2 Mar 2011 00:23:25 -0500 (EST)
Received: by qyk30 with SMTP id 30so5453663qyk.14
        for <linux-mm@kvack.org>; Tue, 01 Mar 2011 21:23:23 -0800 (PST)
Date: Tue, 1 Mar 2011 23:23:20 -0600
From: Shaun Ruffell <sruffell@sruffell.net>
Subject: Re: [PATCH] mm/dmapool.c: Do not create/destroy sysfs file while
	holding pools_lock
Message-ID: <20110302052320.GB7463@kilby.digium.internal>
References: <20110228224124.GA31769@blackmagic.digium.internal> <20110301170117.258e06e2.akpm@linux-foundation.org> <m1wrki3zrq.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m1wrki3zrq.fsf@fess.ebiederm.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russ Meyerriecks <rmeyerriecks@digium.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg KH <greg@kroah.com>

On Tue, Mar 01, 2011 at 08:35:53PM -0800, Eric W. Biederman wrote:
> Andrew Morton <akpm@linux-foundation.org> writes:
> > One way of fixing this would be to create another singleton lock:
> >
> >
> > 	{
> > 		static DEFINE_MUTEX(pools_sysfs_lock);
> > 		static bool pools_sysfs_done;
> >
> > 		mutex_lock(&pools_sysfs_lock);
> > 		if (pools_sysfs_done == false) {
> > 			create_sysfs_stuff();
> > 			pools_sysfs_done = true;
> > 		}
> > 		mutex_unlock(&pools_sysfs_lock);
> > 	}
> >
> > That's not terribly pretty.
> 
> Or possibly use module_init style magic.  Where use module
> initialization and remove to trigger creation and deletion of the sysfs.
> 

I'm not following how module initialization can help here. Are you suggesting
that all devices get a 'pools' attribute regardless of whether any dma pools
are actually created?

Shaun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
