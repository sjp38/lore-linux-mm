Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 564866B0397
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 14:43:31 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id w11so2938077wrc.2
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 11:43:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e69si25461181wmc.151.2017.04.05.11.43.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 11:43:29 -0700 (PDT)
Date: Wed, 5 Apr 2017 20:43:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Heavy I/O causing slow interactivity
Message-ID: <20170405184325.GV6035@dhcp22.suse.cz>
References: <CAGDaZ_qvb7QcWr3MaqnYOFeuqBQzTwzzOKwHXOUxa+S256uc=g@mail.gmail.com>
 <20170405125322.GB9146@rapoport-lnx>
 <CAGDaZ_o745MVD8PDeGhp0-oehUVb8+Zrm4g7uUBBZNTAPODbmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGDaZ_o745MVD8PDeGhp0-oehUVb8+Zrm4g7uUBBZNTAPODbmQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>

On Wed 05-04-17 11:15:44, Raymond Jennings wrote:
> I have 32GiB of memory
> 
> Storage is an LVM volume group sitting on a pair of 2T western digital
> drives, one WD Green, and the other WD Blue
> 
> My CPU is an i7, model 4790K.
> 
> What I'd like is some way for my system to fairly share the available
> I/O bandwidth.  My youtube is sensitive to latency but doesn't chew up
> a lot of throughput.  My I/O heavy stuff isn't really urgent and I
> don't mind it yielding to the interactive stuff.
> 
> I remember a similiar concept being tried awhile ago with a scheduler
> that "punished" processes that sucked up too much CPU and made sure
> the short sporadic event driven interactive stuff got the scraps of
> CPU when it needed them.
> 
> /proc/sys/vm/dirty is set up as follows
> 
> dirty_ratio 90

So you allow 90% of your 32GB to be dirty and then get throttled which
will take quite some time until it gets synced to the disk. Even with a
fast storage. I would really recommend reducing dirty_ratio (and
background ratio as well) to something much more reasonable. E.g. start
the background IO at around 400MB and hard limit at 800MB. I am pretty
sure that the stalls you are seeing are related to the IO dirty
throttling.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
