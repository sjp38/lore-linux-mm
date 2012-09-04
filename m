Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id C39816B007D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 10:15:14 -0400 (EDT)
Message-ID: <50460CED.6060006@redhat.com>
Date: Tue, 04 Sep 2012 10:15:09 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch v4]swap: add a simple random read swapin detection
References: <20120827040037.GA8062@kernel.org> <503B8997.4040604@openvz.org> <20120830103612.GA12292@kernel.org> <20120830174223.GB2141@barrios> <20120903072137.GA26821@kernel.org> <20120903083245.GA7674@bbox> <20120903114631.GA5410@kernel.org> <5044FEE3.4050009@openvz.org> <5044FF89.5090400@redhat.com> <5045AF14.7040309@openvz.org>
In-Reply-To: <5045AF14.7040309@openvz.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "fengguang.wu@intel.com" <fengguang.wu@intel.com>

On 09/04/2012 03:34 AM, Konstantin Khlebnikov wrote:

> It disables reahahead if it is ineffective in one particular VMA,
> but in recovering-case this does not important -- we really want to read
> whole swap back, no matter which VMA around pages belongs to.
> [BTW this case was mentioned in you patch which added skipping-over-holes]

This is a good point.  It is entirely possible that we may
be better off deciding this on a system wide level, and not
a VMA level, since that would allow for the statistic to
move faster.

On the other hand, keeping readahead enabled for some VMAs
at any times may be required to get the hits we need to
re-enable it for others :)

> And its metric is strange, looks like it just disables headahead for all
> VMAs
> after hundred swapins and never enables it back. Why we cannot disable
> it from
> the beginning and turn it on when needed? This ways is even more simple.

Take a careful look at the code, specifically do_swap_page().
If a page is found in the swap cache, it is counted as a hit.
If enough pages are found in the swap cache, readahead is
enabled again for the VMA.

Having swap readahead enabled by default is probably the best
thing to do, since IO clustering is generally useful.

How would you determine when to "turn it on when needed"?

What kind of criteria would you use?

What would be the threshold for enabling it?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
