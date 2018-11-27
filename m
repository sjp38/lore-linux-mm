Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 20C1B6B469F
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:52:17 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t2so10309801edb.22
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:52:17 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Tue, 27 Nov 2018 08:52:14 +0100
From: osalvador@suse.de
Subject: Re: [PATCH] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
In-Reply-To: <3356e00d-9135-12ef-a53f-49d815b8fbfc@intel.com>
References: <20181127023630.9066-1-richard.weiyang@gmail.com>
 <20181127062514.GJ12455@dhcp22.suse.cz>
 <3356e00d-9135-12ef-a53f-49d815b8fbfc@intel.com>
Message-ID: <4fe3f8203a35ea01c9e0ed87c361465e@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, owner-linux-mm@kvack.org

> I think mem_hotplug_lock protects this case these days, though.  I 
> don't
> think we had it in the early days and were just slumming it with the
> pgdat locks.

Yes, it does.

> 
> I really don't like the idea of removing the lock by just saying it
> doesn't protect anything without doing some homework first, though.  It
> would actually be really nice to comment the entire call chain from the
> mem_hotplug_lock acquisition to here.  There is precious little
> commenting in there and it could use some love.

[hot-add operation]
add_memory_resource     : acquire mem_hotplug lock
  arch_add_memory
   add_pages
    __add_pages
     __add_section
      sparse_add_one_section
       sparse_init_one_section

[hot-remove operation]
__remove_memory         : acquire mem_hotplug lock
  arch_remove_memory
   __remove_pages
    __remove_section
     sparse_remove_one_section

Both operations are serialized by the mem_hotplug lock, so they cannot 
step on each other's feet.

Now, there seems to be an agreement/thought to remove the global 
mem_hotplug lock, in favor of a range locking for hot-add/remove and 
online/offline stage.
So, although removing the lock here is pretty straightforward, it does 
not really get us closer to that goal IMHO, if that is what we want to 
do in the end.
