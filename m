Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id XAA21204
	for <linux-mm@kvack.org>; Wed, 25 Sep 2002 23:26:05 -0700 (PDT)
Message-ID: <3D92A87D.3BB631B9@digeo.com>
Date: Wed, 25 Sep 2002 23:26:05 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [1/13] add __GFP_NOKILL
References: <20020926054220.GH22942@holomorphy.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea just disabled out_of_memory().

We need to find out why these oom-killings are happening
in the first place.  They probably all have a common cause.

Please arrange to dump the state of all zones and page_states[]
when it happens.

Adding:

static struct page_state wli_state;

get_page_state(struct page_state *ps)
{
	...
	*wli = *ps;
	return;
}

in page_alloc.c makes the latter easier.

As we discussed, be suspicious of your fallback lists.  Otherwise
it _might_ be the zone-unaware throttling.  I want to know, please,
before I go and add lots of sleep/wakeup gunk to try_to_free_pages()
and end_page_writeback().

Critical question: how much dirty memory is in the normal
zone?  To determine this, look at the last three functions
in mm/page_writeback.c.  Make them do

	atomic_inc/dec(&page_zone(page)->nr-dirty);

thanks.

Also it is important to know the size of the active/inactive
lists in those zones.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
