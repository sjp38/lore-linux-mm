Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0496B007B
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 15:26:26 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id o13KQPAK026509
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 12:26:25 -0800
Received: from pzk7 (pzk7.prod.google.com [10.243.19.135])
	by wpaz13.hot.corp.google.com with ESMTP id o13KQ2jK020113
	for <linux-mm@kvack.org>; Wed, 3 Feb 2010 12:26:24 -0800
Received: by pzk7 with SMTP id 7so283202pzk.12
        for <linux-mm@kvack.org>; Wed, 03 Feb 2010 12:26:23 -0800 (PST)
Date: Wed, 3 Feb 2010 12:26:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <201002032112.33908.elendil@planet.nl>
Message-ID: <alpine.DEB.2.00.1002031220070.750@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <201002032029.34145.elendil@planet.nl> <alpine.DEB.2.00.1002031141350.27853@chino.kir.corp.google.com> <201002032112.33908.elendil@planet.nl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Frans Pop <elendil@planet.nl>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, l.lunak@suse.cz, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, jkosina@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, Frans Pop wrote:

> That doesn't take into account:
> - applications where the oom_adj value is hardcoded to a specific value
>   (for whatever reason)
> - sysadmin scripts that set oom_adj from the console
> 

The fundamentals are the same: negative values mean the task is less 
likely to be preferred and positive values mean the task is more likely, 
only the scale is different.  That scale is exported by the kernel via 
OOM_ADJUST_MIN and OOM_ADJUST_MAX and has been since 2006.  I don't think 
we need to preserve legacy applications or scripts that use hardcoded 
values without importing linux/oom.h.

> I would think that oom_adj is a documented part of the userspace ABI and 
> that the change you propose does not fit the normal backwards 
> compatibility requirements for exposed tunables.
> 

The range is documented (but it should have been documented as being from 
OOM_ADJUST_MIN to OOM_ADJUST_MAX) but its implementation as a bitshift is 
not; it simply says that positive values mean the task is more preferred 
and negative values mean it is less preferred.  Those semantics are 
preserved.

> I think that at least any user who's currently setting oom_adj to -17 has a 
> right to expect that to continue to mean "oom killer disabled". And for 
> any other value they should get a similar impact to the current impact, 
> and not one that's reduced by a factor 66.
> 

If the baseline changes as we all agree it needs to such that oom_adj no 
longer represents the same thing it did in the first place (it would 
become a linear bias), I think this breakage is actually beneficial.  
Users will now be able to tune their oom_adj values based on a fraction of 
system memory to bias their applications either preferrably or otherwise.

I think we should look at Linux over the next couple of years and decide 
if we want to be married to the current semantics of oom_adj that are 
going to change (as it would require being a factor of 66, as you 
mentioned) when the implementation it was designed for has vanished.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
