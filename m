Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 828B26B0038
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 08:14:50 -0400 (EDT)
Received: by wifw1 with SMTP id w1so142149641wif.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 05:14:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qo2si30114680wjc.150.2015.06.02.05.14.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Jun 2015 05:14:48 -0700 (PDT)
Date: Tue, 2 Jun 2015 13:14:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: swap: nfs: Sleeping function called from an rcu read section in
 nfs_swap_activate
Message-ID: <20150602121442.GD26425@suse.de>
References: <5564732E.4090607@redhat.com>
 <20150526095614.5b3d0e84@synchrony.poochiereds.net>
 <20150526212929.71b28344@synchrony.poochiereds.net>
 <20150528082619.GC13750@suse.de>
 <20150528072434.2e7123b1@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150528072434.2e7123b1@synchrony.poochiereds.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Jerome Marchand <jmarchan@redhat.com>, Jeff Layton <jlayton@primarydata.com>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

On Thu, May 28, 2015 at 07:24:34AM -0400, Jeff Layton wrote:
> > > 1) this is not done under a lock, so the non-atomic ++/-- is racy if
> > > there are multiple swapons/swapoffs running concurrently on the same
> > > xprt. Shouldn't those use an atomic?
> > > 
> > 
> > It would be more appropriate to use atomics. It's a long time ago but I
> > doubt I considered the possibility of multiple swapons racing at the
> > time of implementation. Activation is typically a serialised task run
> > from init.
> > 
> > > 2) on enable, "swapper" is incremented and memalloc is set on the
> > > socket. Do we need to do xs_set_memalloc every time swapon is called,
> > > or only on a 0->1 swapper transition.
> > > 
> > 
> > Every time because the static_key_slow_inc call is for the total number
> > of connections.
> > 
> 
> That still seems wrong. The static_key would still be active even if
> you just did it once per xprt.
> 

True. As long as it is active while one swapfile exists then it's good.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
