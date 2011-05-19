Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id A71B2900001
	for <linux-mm@kvack.org>; Wed, 18 May 2011 23:36:20 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p4J3aHlx016922
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:36:17 -0700
Received: from pwi15 (pwi15.prod.google.com [10.241.219.15])
	by hpaq13.eem.corp.google.com with ESMTP id p4J3a9EV001037
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 May 2011 20:36:10 -0700
Received: by pwi15 with SMTP id 15so1347274pwi.5
        for <linux-mm@kvack.org>; Wed, 18 May 2011 20:36:04 -0700 (PDT)
Date: Wed, 18 May 2011 20:36:02 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V3 2/2] mm: Extend memory hotplug API to allow memory
 hotplug in virtual machines
In-Reply-To: <20110517213858.GC30232@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1105182026390.20651@chino.kir.corp.google.com>
References: <20110517213858.GC30232@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 17 May 2011, Daniel Kiper wrote:

> This patch contains online_page_callback and apropriate functions for
> setting/restoring online page callbacks. It allows to do some machine
> specific tasks during online page stage which is required to implement
> memory hotplug in virtual machines. Additionally, __online_page_set_limits(),
> __online_page_increment_counters() and __online_page_free() function
> was added to ease generic hotplug operation.
> 

There are several issues with this.

First, this is completely racy and only allows one global callback to be 
in use at a time without looping, which is probably why you had to pass an 
argument to restore_online_page_callback().  Your implementation also 
requires that a callback must be synchronized with itself for the 
comparison to generic_online_page to make any sense.  Nobody knows which 
callback is effective at any given moment and has no guarantees that when 
they've set the callback that it will be the one called, otherwise.

Second, there's no explanation offered about why you have to split 
online_page() into three separate functions.  In addition, you've exported 
all of them so presumably modules will need to be doing this when loading 
or unloading and that further complicates the race mentioned above.

Third, there are no followup patches that use this interface or show how 
you plan on using it (other than eluding that it will be used for virtual 
machines in the changelog) so we're left guessing as to why we need it 
implemented in this fashion and restricts the amount of help I can offer 
because I don't know the problem you're facing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
