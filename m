Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8DF916B03A2
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 08:37:14 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 1so126559105pgz.5
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 05:37:14 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f5si10627857pgk.236.2017.03.03.05.37.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Mar 2017 05:37:13 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v23DXZi6100974
	for <linux-mm@kvack.org>; Fri, 3 Mar 2017 08:37:13 -0500
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28xs8egpd5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 03 Mar 2017 08:37:12 -0500
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 3 Mar 2017 23:37:10 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 06E2D3578056
	for <linux-mm@kvack.org>; Sat,  4 Mar 2017 00:37:07 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v23DaxxN43843704
	for <linux-mm@kvack.org>; Sat, 4 Mar 2017 00:37:07 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v23DaYLs004812
	for <linux-mm@kvack.org>; Sat, 4 Mar 2017 00:36:34 +1100
Subject: Re: [patch] mm, zoneinfo: print non-populated zones
References: <alpine.DEB.2.10.1703021525500.5229@chino.kir.corp.google.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 3 Mar 2017 19:05:53 +0530
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1703021525500.5229@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <4acf16c5-c64b-b4f8-9a41-1926eed23fe1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/03/2017 04:56 AM, David Rientjes wrote:
> Initscripts can use the information (protection levels) from
> /proc/zoneinfo to configure vm.lowmem_reserve_ratio at boot.
> 
> vm.lowmem_reserve_ratio is an array of ratios for each configured zone on
> the system.  If a zone is not populated on an arch, /proc/zoneinfo
> suppresses its output.
> 
> This results in there not being a 1:1 mapping between the set of zones
> emitted by /proc/zoneinfo and the zones configured by
> vm.lowmem_reserve_ratio.
> 
> This patch shows statistics for non-populated zones in /proc/zoneinfo.
> The zones exist and hold a spot in the vm.lowmem_reserve_ratio array.
> Without this patch, it is not possible to determine which index in the
> array controls which zone if one or more zones on the system are not
> populated.

Right, its a problem when it does not even display array elements with
an index value associated with it. But changing the array display will
break the interface where as displaying non populated zones in the
/proc/zoneinfo does not break anything.

> 
> Remaining users of walk_zones_in_node() are unchanged.  Files such as
> /proc/pagetypeinfo require certain zone data to be initialized properly
> for display, which is not done for unpopulated zones.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/vmstat.c | 22 +++++++++++++---------
>  1 file changed, 13 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1121,8 +1121,12 @@ static void frag_stop(struct seq_file *m, void *arg)
>  {
>  }
>  
> -/* Walk all the zones in a node and print using a callback */
> +/*
> + * Walk zones in a node and print using a callback.
> + * If @populated is true, only use callback for zones that are populated.
> + */
>  static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
> +		bool populated,
>  		void (*print)(struct seq_file *m, pg_data_t *, struct zone *))
>  {
>  	struct zone *zone;
> @@ -1130,7 +1134,7 @@ static void walk_zones_in_node(struct seq_file *m, pg_data_t *pgdat,
>  	unsigned long flags;
>  
>  	for (zone = node_zones; zone - node_zones < MAX_NR_ZONES; ++zone) {
> -		if (!populated_zone(zone))
> +		if (populated && !populated_zone(zone))

The name of the Boolean "populated" is bit misleading IMHO. What I think you
want here is to invoke the callback if the zone is populated as well as this
variable is true. The variable can be named something like 'assert_populated'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
