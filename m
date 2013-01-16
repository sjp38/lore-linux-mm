Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id A29556B005D
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 20:08:28 -0500 (EST)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 18:08:27 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B30993E4003E
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 18:08:19 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G18Mjg088816
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 18:08:22 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G18L7j001538
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 18:08:21 -0700
Message-ID: <50F5FD7E.4080901@linux.vnet.ibm.com>
Date: Tue, 15 Jan 2013 17:08:14 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01/17] mm/compaction: rename var zone_end_pfn to avoid
 conflicts with new function
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com> <1358295894-24167-2-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-2-git-send-email-cody@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>

On 01/15/2013 04:24 PM, Cody P Schafer wrote:
> Patches that follow add a inline function zone_end_pfn(), which
> conflicts with the naming of a local variable in isolate_freepages().
> 
> Rename the variable so it does not conflict.

It's probably worth a note here that you _will_ be migrating this use
over to the new function anyway.

> @@ -706,7 +706,7 @@ static void isolate_freepages(struct zone *zone,
>  		 * only scans within a pageblock
>  		 */
>  		end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
> -		end_pfn = min(end_pfn, zone_end_pfn);
> +		end_pfn = min(end_pfn, z_end_pfn);

Is there any reason not to just completely get rid of z_end_pfn (in the
later patches after you introduce zone_end_pfn() of course):

> +		end_pfn = min(end_pfn, zone_end_pfn(zone));

I wouldn't be completely opposed to you just introducing zone_end_pfn()
and doing all the replacements in a single patch.  It would make it
somewhat easier to review, and it would also save the juggling you have
to do with this one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
