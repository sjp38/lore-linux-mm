Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 923E96B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 05:45:20 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b184so9243443wme.14
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 02:45:20 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n64si4970971wma.129.2017.06.28.02.45.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 02:45:19 -0700 (PDT)
Date: Wed, 28 Jun 2017 11:45:16 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memory_hotplug: just build zonelist for new added node
Message-ID: <20170628094516.GE5225@dhcp22.suse.cz>
References: <20170626035822.50155-1-richard.weiyang@gmail.com>
 <20170628092329.GC5225@dhcp22.suse.cz>
 <f92958f9-e831-8dc7-f8e6-2f4a46171e71@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f92958f9-e831-8dc7-f8e6-2f4a46171e71@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 28-06-17 11:35:00, Vlastimil Babka wrote:
> On 06/28/2017 11:23 AM, Michal Hocko wrote:
> > On Mon 26-06-17 11:58:22, Wei Yang wrote:
> >> In commit (9adb62a5df9c0fbef7) "mm/hotplug: correctly setup fallback
> >> zonelists when creating new pgdat" tries to build the correct zonelist for
> >> a new added node, while it is not necessary to rebuild it for already exist
> >> nodes.
> >>
> >> In build_zonelists(), it will iterate on nodes with memory. For a new added
> >> node, it will have memory until node_states_set_node() is called in
> >> online_pages().
> >>
> >> This patch will avoid to rebuild the zonelists for already exist nodes.
> > 
> > It is not very clear from the changelog why that actually matters. The
> > only effect I can see is that other zonelists on other online nodes will
> > not learn about the currently memory less node. This is a good think
> > because we do not pointlessly try to allocate from that node.
> 
> build_zonelists_node() seems to use managed_zone(zone) checks, so it
> should not include empty zones anyway. So effectively seems to me we
> just avoid some pointless work under stop_machine().

Ohh, you are right. I was looking for populated_zone and didn't find any
so I thought we just do not care. So, indeed the patch has no functional
effect it just reduces the stop_machine overhead tiny bit.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
