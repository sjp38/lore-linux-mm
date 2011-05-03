Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0E5006B0023
	for <linux-mm@kvack.org>; Tue,  3 May 2011 12:26:07 -0400 (EDT)
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p43GN92Q010856
	for <linux-mm@kvack.org>; Tue, 3 May 2011 10:23:09 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p43GPu6Z130778
	for <linux-mm@kvack.org>; Tue, 3 May 2011 10:25:56 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p43GPtcE011470
	for <linux-mm@kvack.org>; Tue, 3 May 2011 10:25:56 -0600
Subject: Re: [PATCH V2 2/2] mm: Extend memory hotplug API to allow memory
 hotplug in virtual machines
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110502214921.GH4623@router-fw-old.local.net-space.pl>
References: <20110502214921.GH4623@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 03 May 2011 09:25:52 -0700
Message-ID: <1304439952.30823.68.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2011-05-02 at 23:49 +0200, Daniel Kiper wrote:
> +int register_online_page_callback(online_page_callback_t callback)
> +{
> +       int rc = -EPERM;
> +
> +       lock_memory_hotplug();
> +
> +       if (online_page_callback == generic_online_page) {
> +               online_page_callback = callback;
> +               rc = 0;
> +       }
> +
> +       unlock_memory_hotplug();
> +
> +       return rc;
> +}
> +EXPORT_SYMBOL_GPL(register_online_page_callback);

-EPERM is a bit uninformative here.  How about -EEXIST, plus a printk?

I also don't seen the real use behind having a "register" that can only
take a single callback.  At worst, it should be
"set_online_page_callback()" so it's more apparent that there can only
be one of these.

> +int unregister_online_page_callback(online_page_callback_t callback)
> +{
> +       int rc = -EPERM;
> +
> +       lock_memory_hotplug();
> +
> +       if (online_page_callback == callback) {
> +               online_page_callback = generic_online_page;
> +               rc = 0;
> +       }
> +
> +       unlock_memory_hotplug();
> +
> +       return rc;
> +}
> +EXPORT_SYMBOL_GPL(unregister_online_page_callback); 

Again, -EPERM is a bad code here. -EEXIST, perhaps?  It also deserves a
WARN_ON() or a printk on failure here.  

Your changelog doesn't mention, but what ever happened to doing
something dirt-simple like this?  I have a short memory.

> void arch_free_hotplug_page(struct page *page)
> {
>       if (xen_need_to_inflate_balloon())
>               put_page_in_balloon(page);
>       else
>               __free_page(page);
> }

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
