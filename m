Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id F143D6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 01:14:22 -0400 (EDT)
Received: by mail-da0-f43.google.com with SMTP id u36so25292dak.30
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 22:14:22 -0700 (PDT)
Date: Mon, 1 Apr 2013 22:13:58 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC] mm: remove swapcache page early
In-Reply-To: <20130402020429.GD30444@blaptop>
Message-ID: <alpine.LNX.2.00.1304012147440.5037@eggly.anvils>
References: <1364350932-12853-1-git-send-email-minchan@kernel.org> <alpine.LNX.2.00.1303271230210.29687@eggly.anvils> <433aaa17-7547-4e39-b472-7060ee15e85f@default> <20130328010706.GB22908@blaptop> <5f1504e7-8b07-4109-8271-b214b496ca61@default>
 <20130329011801.GA32245@blaptop> <alpine.LNX.2.00.1303291250160.3741@eggly.anvils> <20130402020429.GD30444@blaptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <bob.liu@oracle.com>

On Tue, 2 Apr 2013, Minchan Kim wrote:
> On Fri, Mar 29, 2013 at 01:01:14PM -0700, Hugh Dickins wrote:
> > On Fri, 29 Mar 2013, Minchan Kim wrote:
> > > On Thu, Mar 28, 2013 at 11:19:12AM -0700, Dan Magenheimer wrote:
> > > > 
> > > > I wonder if something like this would have a similar result for zram?
> > > > (Completely untested... snippet stolen from swap_entry_free with
> > > > SetPageDirty added... doesn't compile yet, but should give you the idea.)
> > 
> > Be careful, although Dan is right that something like this can be
> > done for zram, I believe you will find that it needs a little more:
> > either a separate new entry point (not my preference) or a flags arg
> > (or boolean) added to swap_slot_free_notify.
> > 
> > Because this is a different operation: end_swap_bio_read() wants
> > to free up zram's compressed copy of the page, but the swp_entry_t
> > must remain valid until swap_entry_free() can clear up the rest.
> > Precisely how much of the work each should do, you will discover.
> 
> First of all, Thanks for noticing it for me!
> 
> If I parse your concern correctly, you are concerning about
> different semantic on two functions.
> (end_swap_bio_read's swap_slot_free_notify VS swap_entry_free's one).
> 
> But current implementatoin on zram_slot_free_notify could cover both cases
> properly with luck.
> 
> zram_free_page caused by end_swap_bio_read will free compressed copy
> of the page and zram_free_page caused by swap_entry_free later won't find
> right index from zram->table and just return.
> So I think there is no problem.
> 
> Remained problem is zram->stats.notify_free, which could be counted
> redundantly but not sure it's valuable to count exactly.
> 
> If I miss your point, please pinpoint your concern. :)

Looking at it again, I do believe you and Dan are perfectly correct,
and I was again the confused one.  Though I'd be happier if I could
see just how I was misreading it: makes me wonder if I had a great
insight that I can no longer grasp hold of!  I think I was paranoid
about a swp_entry_t getting recycled prematurely: but swap_entry_free
remains in control of that - freeing a swap entry is no part of what
notify_free gets up to.  Sorry for wasting your time.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
