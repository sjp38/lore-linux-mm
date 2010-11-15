Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id CF5138D0017
	for <linux-mm@kvack.org>; Mon, 15 Nov 2010 14:16:09 -0500 (EST)
Date: Mon, 15 Nov 2010 20:16:02 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Oops while rebalancing, now unmountable.
Message-ID: <20101115191602.GK6809@random.random>
References: <1289236257.3611.3.camel@mars>
 <1289310046-sup-839@think>
 <1289326892.4231.2.camel@mars>
 <1289764507.4303.9.camel@mars>
 <20101114204206.GV6809@random.random>
 <20101114220018.GA4512@infradead.org>
 <20101114221222.GX6809@random.random>
 <20101115182314.GA2493@infradead.org>
 <20101115184657.GJ6809@random.random>
 <1289847339-sup-4591@think>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1289847339-sup-4591@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Shane Shrybman <shrybman@teksavvy.com>, linux-btrfs <linux-btrfs@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 15, 2010 at 02:03:55PM -0500, Chris Mason wrote:
> It always returns either -EIO or -EAGAIN, so the caller will try again
> and then end up waiting on PageWriteback?

Returning any error from ->writepage will make writeout return -EIO so
aborting the migration for that page. If no error is returned from
->writepage, writeout will return -EAGAIN the caller will try again
after wait_on_page_writeback. I think I misread the code when in prev
mail I worried about not waiting on PG_writeback after writeout()... :)

So the ideal would be not to return errors when ->writepage submitted
the writeback I/O successfully but if it returns -EIO/-EAGAIN there's
no risk whatsoever (except compaction will be less effective).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
