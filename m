Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30BF76B4665
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:17:43 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id p9so13418855pfj.3
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:17:43 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id be11si2866807plb.134.2018.11.26.23.17.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 23:17:42 -0800 (PST)
Subject: Re: [PATCH] mm, sparse: drop pgdat_resize_lock in
 sparse_add/remove_one_section()
References: <20181127023630.9066-1-richard.weiyang@gmail.com>
 <20181127062514.GJ12455@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <3356e00d-9135-12ef-a53f-49d815b8fbfc@intel.com>
Date: Mon, 26 Nov 2018 23:17:40 -0800
MIME-Version: 1.0
In-Reply-To: <20181127062514.GJ12455@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org

On 11/26/18 10:25 PM, Michal Hocko wrote:
> [Cc Dave who has added the lock into this path. Maybe he remembers why]

I don't remember specifically.  But, the pattern of:

	allocate
	lock
	set
	unlock

is _usually_ so we don't have two "sets" racing with each other.  In
this case, that would have been to ensure that two
sparse_init_one_section()'s didn't race and leak one of the two
allocated memmaps or worse.

I think mem_hotplug_lock protects this case these days, though.  I don't
think we had it in the early days and were just slumming it with the
pgdat locks.

I really don't like the idea of removing the lock by just saying it
doesn't protect anything without doing some homework first, though.  It
would actually be really nice to comment the entire call chain from the
mem_hotplug_lock acquisition to here.  There is precious little
commenting in there and it could use some love.
