Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id CBA1260021B
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 21:21:05 -0500 (EST)
Message-ID: <4B15CEE0.2030503@redhat.com>
Date: Tue, 01 Dec 2009 21:20:16 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] high system time & lock contention running large mixed
 workload
References: <20091125133752.2683c3e4@bree.surriel.com>	 <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com>	 <20091201102645.5C0A.A69D9226@jp.fujitsu.com> <1259685662.2345.11.camel@dhcp-100-19-198.bos.redhat.com>
In-Reply-To: <1259685662.2345.11.camel@dhcp-100-19-198.bos.redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On 12/01/2009 11:41 AM, Larry Woodman wrote:
>
> Agreed.  The attached updated patch only does a trylock in the
> page_referenced() call from shrink_inactive_list() and only for
> anonymous pages when the priority is either 10, 11 or
> 12(DEF_PRIORITY-2).  I have never seen a problem like this with active
> pagecache pages and it does not alter the existing shrink_page_list
> behavior.  What do you think about this???
This is reasonable, except for the fact that pages that are moved
to the inactive list without having the referenced bit cleared are
guaranteed to be moved back to the active list.

You'll be better off without that excess list movement, by simply
moving pages directly back onto the active list if the trylock
fails.

Yes, this means that page_referenced can now return 3 different
return values (not accessed, accessed, lock contended), which
should probably be an enum so we can test for the values
symbolically in the calling functions.

That way only pages where we did manage to clear the referenced bit
will be moved onto the inactive list.  This not only reduces the
amount of excess list movement, it also makes sure that the pages
which do get onto the inactive list get a fair chance at being
referenced again, instead of potentially being flooded out by pages
where the trylock failed.

A minor nitpick: maybe it would be good to rename the "try" parameter
to "noblock".  That more closely matches the requested behaviour.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
