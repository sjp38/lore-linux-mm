Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id C4B9A6B0038
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 18:14:10 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id x10so15346631pdj.22
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 15:14:10 -0800 (PST)
Received: from mail-pd0-x22c.google.com (mail-pd0-x22c.google.com [2607:f8b0:400e:c02::22c])
        by mx.google.com with ESMTPS id pp3si15241599pbb.229.2014.02.17.15.14.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Feb 2014 15:14:09 -0800 (PST)
Received: by mail-pd0-f172.google.com with SMTP id p10so15406935pdj.17
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 15:14:09 -0800 (PST)
Date: Mon, 17 Feb 2014 15:14:06 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH V5] mm readahead: Fix readahead fail for no local
 memory and limit readahead pages
In-Reply-To: <20140217192803.GA14586@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1402171501001.25724@chino.kir.corp.google.com>
References: <52F8C556.6090006@linux.vnet.ibm.com> <alpine.DEB.2.02.1402101333160.15624@chino.kir.corp.google.com> <52FC6F2A.30905@linux.vnet.ibm.com> <alpine.DEB.2.02.1402130003320.11689@chino.kir.corp.google.com> <52FC98A6.1000701@linux.vnet.ibm.com>
 <alpine.DEB.2.02.1402131416430.13899@chino.kir.corp.google.com> <20140214001438.GB1651@linux.vnet.ibm.com> <CA+55aFwH8BqyLSqyLL7g-08nOtnOrJ9vKj4ebiSqrxc5ooEjLw@mail.gmail.com> <20140214043235.GA21999@linux.vnet.ibm.com> <alpine.DEB.2.02.1402140244330.12099@chino.kir.corp.google.com>
 <20140217192803.GA14586@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, 17 Feb 2014, Nishanth Aravamudan wrote:

> Here is what I'm running into now:
> 
> setup_arch ->
> 	do_init_bootmem ->
> 		cpu_numa_callback ->
> 			numa_setup_cpu ->
> 				map_cpu_to_node -> 
> 					update_numa_cpu_lookup_table
> 
> Which current updates the powerpc specific numa_cpu_lookup_table. I
> would like to update that function to use set_cpu_numa_node() and
> set_cpu_numa_mem(), but local_memory_node() is not yet functional
> because build_all_zonelists is called later in start_kernel. Would it
> make sense for first_zones_zonelist() to return NUMA_NO_NODE if we
> don't have a zone?
> 

Hmm, I don't think we'll want to modify the generic first_zones_zonelist() 
for a special case that is only true during boot.  Instead, would it make 
sense to modify numa_setup_cpu() to use the generic cpu_to_node() instead 
of using a powerpc mapping and then do the set_cpu_numa_mem() after 
paging_init() when the zonelists will have been built and zones without 
present pages are properly excluded?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
