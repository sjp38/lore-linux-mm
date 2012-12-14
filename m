Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 01DE86B0062
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 10:44:04 -0500 (EST)
Message-ID: <50CB493B.8000900@redhat.com>
Date: Fri, 14 Dec 2012 10:43:55 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 2/8] mm: vmscan: disregard swappiness shortly before going
 OOM
References: <1355348620-9382-1-git-send-email-hannes@cmpxchg.org> <1355348620-9382-3-git-send-email-hannes@cmpxchg.org> <20121213103420.GW1009@suse.de> <20121213152959.GE21644@dhcp22.suse.cz> <20121213160521.GG21644@dhcp22.suse.cz> <8631DC5930FA9E468F04F3FD3A5D007214AD2FA2@USINDEM103.corp.hds.com> <20121214045030.GE6317@cmpxchg.org> <20121214083738.GA6898@dhcp22.suse.cz>
In-Reply-To: <20121214083738.GA6898@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Satoru Moriya <satoru.moriya@hds.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 12/14/2012 03:37 AM, Michal Hocko wrote:

> I can answer the later. Because memsw comes with its price and
> swappiness is much cheaper. On the other hand it makes sense that
> swappiness==0 doesn't swap at all. Or do you think we should get back to
> _almost_ doesn't swap at all?

swappiness==0 will swap in emergencies, specifically when we have
almost no page cache left, we will still swap things out:

         if (global_reclaim(sc)) {
                 free  = zone_page_state(zone, NR_FREE_PAGES);
                 if (unlikely(file + free <= high_wmark_pages(zone))) {
                         /*
                          * If we have very few page cache pages, force-scan
                          * anon pages.
                          */
                         fraction[0] = 1;
                         fraction[1] = 0;
                         denominator = 1;
                         goto out;

This makes sense, because people who set swappiness==0 but
do have swap space available would probably prefer some
emergency swapping over an OOM kill.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
