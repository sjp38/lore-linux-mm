Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA10984
	for <linux-mm@kvack.org>; Sat, 23 Jan 1999 20:52:24 -0500
Date: Sun, 24 Jan 1999 02:51:55 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: 2.2.0-final
In-Reply-To: <Pine.LNX.3.96.990123210422.2856A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990124024902.199B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>, Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 23 Jan 1999, Andrea Arcangeli wrote:

> where buffer_get() is this:

Just for the record, I cut-and-pasted a wrong buffer_get() (due a
last-minute wrong hack, I noticed it now when I powerup the machine now
;), the right one is this: 

extern inline void buffer_get(struct buffer_head *bh)
{
	struct page * page = mem_map + MAP_NR(bh->b_data);

	switch (atomic_read(&page->count))
	{
	case 1:
		nr_freeable_pages--;
	default:
		atomic_inc(&page->count);
		break;
#if 1 /* PARANOID */
	case 0:
		printk(KERN_ERR "buffer_get: page was unused!\n");
#endif
	}
}

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
