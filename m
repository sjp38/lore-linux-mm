Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 782526B0005
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 19:50:46 -0500 (EST)
Message-ID: <50F89C77.4010101@parallels.com>
Date: Thu, 17 Jan 2013 16:51:03 -0800
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/19] list_lru: per-node list infrastructure
References: <1354058086-27937-1-git-send-email-david@fromorbit.com> <1354058086-27937-10-git-send-email-david@fromorbit.com> <50F6FDC8.5020909@parallels.com> <20130116225521.GF2498@dastard> <50F7475F.90609@parallels.com> <20130117042245.GG2498@dastard> <50F84118.7030608@parallels.com> <20130118001029.GK2498@dastard>
In-Reply-To: <20130118001029.GK2498@dastard>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Suleiman Souhlal <suleiman@google.com>

On 01/17/2013 04:10 PM, Dave Chinner wrote:
> and we end up with:
> 
> lru_add(struct lru_list *lru, struct lru_item *item)
> {
> 	node_id = min(object_to_nid(item), lru->numnodes);
> 	
> 	__lru_add(lru, node_id, &item->global_list);
> 	if (memcg) {
> 		memcg_lru = find_memcg_lru(lru->memcg_lists, memcg_id)
> 		__lru_add_(memcg_lru, node_id, &item->memcg_list);
> 	}
> }

A follow up thought: If we have multiple memcgs, and global pressure
kicks in (meaning none of them are particularly under pressure),
shouldn't we try to maintain fairness among them and reclaim equal
proportions from them all the same way we do with sb's these days, for
instance?

I would argue that if your memcg is small, the list of dentries is
small: scan it all for the nodes you want shouldn't hurt.

if the memcg is big, it will have per-node lists anyway.

Given that, do we really want to pay the price of two list_heads in the
objects?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
