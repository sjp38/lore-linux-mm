Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA25353
	for <linux-mm@kvack.org>; Tue, 24 Mar 1998 20:03:55 -0500
Date: Wed, 25 Mar 1998 00:03:09 +0100 (MET)
From: "H.H.vanRiel" <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: free_memory_available() bug in pre-91-1
Message-ID: <Pine.LNX.3.91.980324235724.469A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Linus,

I've just found a bug in free_memory_available() as
implemented in pre-91-1...
It reacts the same on finding _no_ free item on a list
as it reacts on _multiple_ free items on the list.
So it'll return the same value regardless of whether
there is lots of free memory or there's no free memory...
(notice the 'break;' at two places...)

	do {
		list--;
		/* Empty list? Bad - we need more memory */
		if (list->next == memory_head(list))
			break;
		/* One item on the list? Look further */
		if (list->next->next == memory_head(list))
			continue;
		/* More than one item? We're ok */
		break;
	} while (--nr >= 0);
	spin_unlock_irqrestore(&page_alloc_lock, flags);
	return nr + 1;
}

Rik.
+-------------------------------------------+--------------------------+
| Linux: - LinuxHQ MM-patches page          | Scouting       webmaster |
|        - kswapd ask-him & complain-to guy | Vries    cubscout leader |
|     http://www.fys.ruu.nl/~riel/          | <H.H.vanRiel@fys.ruu.nl> |
+-------------------------------------------+--------------------------+
