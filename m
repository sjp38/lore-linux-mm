Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7751F6B467A
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:30:28 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e29so10532281ede.19
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:30:28 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n7si1473660edv.183.2018.11.26.23.30.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 23:30:27 -0800 (PST)
Date: Tue, 27 Nov 2018 08:30:25 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
Message-ID: <20181127073025.GN12455@dhcp22.suse.cz>
References: <20181127023630.9066-1-richard.weiyang@gmail.com>
 <20181127062514.GJ12455@dhcp22.suse.cz>
 <3356e00d-9135-12ef-a53f-49d815b8fbfc@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3356e00d-9135-12ef-a53f-49d815b8fbfc@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org

On Mon 26-11-18 23:17:40, Dave Hansen wrote:
> On 11/26/18 10:25 PM, Michal Hocko wrote:
> > [Cc Dave who has added the lock into this path. Maybe he remembers why]
> 
> I don't remember specifically.  But, the pattern of:
> 
> 	allocate
> 	lock
> 	set
> 	unlock
> 
> is _usually_ so we don't have two "sets" racing with each other.  In
> this case, that would have been to ensure that two
> sparse_init_one_section()'s didn't race and leak one of the two
> allocated memmaps or worse.
> 
> I think mem_hotplug_lock protects this case these days, though.  I don't
> think we had it in the early days and were just slumming it with the
> pgdat locks.
> 
> I really don't like the idea of removing the lock by just saying it
> doesn't protect anything without doing some homework first, though.  It
> would actually be really nice to comment the entire call chain from the
> mem_hotplug_lock acquisition to here.  There is precious little
> commenting in there and it could use some love.

Agreed. It really seems like the lock is not needed anymore but a more
trhougout analysis and explanation is definitely due.

Thanks!

-- 
Michal Hocko
SUSE Labs
