Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 246DE828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 03:15:25 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id yy13so261856909pab.3
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 00:15:25 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id cm4si367293pad.81.2016.01.13.00.15.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 00:15:24 -0800 (PST)
Date: Wed, 13 Jan 2016 09:14:57 +0100
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [Xen-devel] [PATCH v4 2/2] xen_balloon: support memory auto
 onlining policy
Message-ID: <20160113081457.GX3485@olila.local.net-space.pl>
References: <1452617777-10598-1-git-send-email-vkuznets@redhat.com>
 <1452617777-10598-3-git-send-email-vkuznets@redhat.com>
 <56953A18.2070407@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56953A18.2070407@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david.vrabel@citrix.com, vkuznets@redhat.com
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-doc@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kay Sievers <kay@vrfy.org>, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, xen-devel@lists.xenproject.org, Igor Mammedov <imammedo@redhat.com>, David Rientjes <rientjes@google.com>, Xishi Qiu <qiuxishi@huawei.com>, Dan Williams <dan.j.williams@intel.com>, "K. Y. Srinivasan" <kys@microsoft.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>

On Tue, Jan 12, 2016 at 05:38:32PM +0000, David Vrabel wrote:
> On 12/01/16 16:56, Vitaly Kuznetsov wrote:
> > Add support for the newly added kernel memory auto onlining policy to Xen
> > ballon driver.
> [...]
> > --- a/drivers/xen/Kconfig
> > +++ b/drivers/xen/Kconfig
> > @@ -37,23 +37,29 @@ config XEN_BALLOON_MEMORY_HOTPLUG
> >
> >  	  Memory could be hotplugged in following steps:
> >
> > -	    1) dom0: xl mem-max <domU> <maxmem>
> > +	    1) domU: ensure that memory auto online policy is in effect by
> > +	       checking /sys/devices/system/memory/auto_online_blocks file
> > +	       (should be 'online').
>
> Step 1 applies to dom0 and domUs.
>
> > --- a/drivers/xen/balloon.c
> > +++ b/drivers/xen/balloon.c
> > @@ -284,7 +284,7 @@ static void release_memory_resource(struct resource *resource)
> >  	kfree(resource);
> >  }
> >
> > -static enum bp_state reserve_additional_memory(void)
> > +static enum bp_state reserve_additional_memory(bool online)
> >  {
> >  	long credit;
> >  	struct resource *resource;
> > @@ -338,7 +338,18 @@ static enum bp_state reserve_additional_memory(void)
> >  	}
> >  #endif
> >
> > -	rc = add_memory_resource(nid, resource, false);
> > +	/*
> > +	 * add_memory_resource() will call online_pages() which in its turn
> > +	 * will call xen_online_page() callback causing deadlock if we don't
> > +	 * release balloon_mutex here. It is safe because there can only be
> > +	 * one balloon_process() running at a time and balloon_mutex is
> > +	 * internal to Xen driver, generic memory hotplug code doesn't mess
> > +	 * with it.
>
> There are multiple callers of reserve_additional_memory() and these are
> not all serialized via the balloon process.  Replace the "It is safe..."
> sentence with:
>
> "Unlocking here is safe because the callers drop the mutex before trying
> again."
>
> > +	 */
> > +	mutex_unlock(&balloon_mutex);
> > +	rc = add_memory_resource(nid, resource, online);
>
> This should always be memhp_auto_online, because...
>
> > @@ -562,14 +573,11 @@ static void balloon_process(struct work_struct *work)
> >
> >  		credit = current_credit();
> >
> > -		if (credit > 0) {
> > -			if (balloon_is_inflated())
> > -				state = increase_reservation(credit);
> > -			else
> > -				state = reserve_additional_memory();
> > -		}
> > -
> > -		if (credit < 0)
> > +		if (credit > 0 && balloon_is_inflated())
> > +			state = increase_reservation(credit);
> > +		else if (credit > 0)
> > +			state = reserve_additional_memory(memhp_auto_online);
> > +		else if (credit < 0)
> >  			state = decrease_reservation(-credit, GFP_BALLOON);
>
> I'd have preferred this refactored as:
>
> if (credit > 0) {
>     if (balloon_is_inflated())
>         ...
>     else
>         ...
> } else if (credit < 0) {
>     ...
> }
> >
> >  		state = update_schedule(state);
> > @@ -599,7 +607,7 @@ static int add_ballooned_pages(int nr_pages)
> >  	enum bp_state st;
> >
> >  	if (xen_hotplug_unpopulated) {
> > -		st = reserve_additional_memory();
> > +		st = reserve_additional_memory(false);
>
> ... we want to auto-online this memory as well.

Ugh... It looks that David is right. So, please forget everything which
I said about reserve_additional_memory() earlier. Sorry for confusion.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
