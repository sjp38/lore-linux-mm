Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0F6846B004D
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 01:33:06 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6O5X428019107
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 24 Jul 2009 14:33:04 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7042D45DE4E
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 14:33:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 451D645DE4D
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 14:33:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BC321DB8038
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 14:33:04 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A1AB3E08002
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 14:33:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] bump up nr_to_write in xfs_vm_writepage
In-Reply-To: <7149D747-2769-4559-BAF6-AAD2B6C6C941@sgi.com>
References: <20090710153349.17EC.A69D9226@jp.fujitsu.com> <7149D747-2769-4559-BAF6-AAD2B6C6C941@sgi.com>
Message-Id: <20090724143159.67B6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 24 Jul 2009 14:33:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Felix Blyakher <felixb@sgi.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Chris Mason <chris.mason@oracle.com>, Eric Sandeen <sandeen@redhat.com>, xfs mailing list <xfs@oss.sgi.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Olaf Weber <olaf@sgi.com>
List-ID: <linux-mm.kvack.org>

> 
> On Jul 10, 2009, at 2:12 AM, KOSAKI Motohiro wrote:
> 
> >> On Thu, Jul 09, 2009 at 11:04:32AM +0900, KOSAKI Motohiro wrote:
> >>>> On Tue, Jul 07, 2009 at 07:33:04PM +0900, KOSAKI Motohiro wrote:
> >>>>> At least, I agree with Olaf. if you got someone's NAK in past  
> >>>>> thread,
> >>>>> Could you please tell me its url?
> >>>>
> >>>> The previous thread was simply dead-ended and nothing happened.
> >>>>
> >>>
> >>> Can you remember this thread subject? sorry, I haven't remember it.
> >>
> >> This is the original thread, it did lead to a few different patches
> >> going in, but the nr_to_write change wasn't one of them.
> >>
> >> http://kerneltrap.org/mailarchive/linux-kernel/2008/10/1/3472704/thread
> >
> > Thanks good pointer. This thread have multiple interesting discussion.
> >
> > 1. making ext4_write_cache_pages() or modifying write_cache_pages()
> >
> > I think this is Christoph's homework. he said
> >
> >> I agree.  But I'm still not quite sure if that requirement is  
> >> unique to
> >> ext4 anyway.  Give me some time to dive into the writeback code  
> >> again,
> >> haven't been there for quite a while.
> >
> > if he says modifying write_cache_pages() is necessary, I'd like to  
> > review it.
> >
> >
> > 2. Current mapping->writeback_index updating is not proper?
> >
> > I'm not sure which solution is better. but I think your first  
> > proposal is
> > enough acceptable.
> >
> >
> > 3. Current wbc->nr_to_write value is not proper?
> >
> > Current writeback_set_ratelimit() doesn't permit that  
> > ratelimit_pages exceed
> > 4M byte. but it is too low restriction for nowadays.
> > (that's my understand. right?)
> >
> > =======================================================
> > void writeback_set_ratelimit(void)
> > {
> >        ratelimit_pages = vm_total_pages / (num_online_cpus() * 32);
> >        if (ratelimit_pages < 16)
> >                ratelimit_pages = 16;
> >        if (ratelimit_pages * PAGE_CACHE_SIZE > 4096 * 1024)
> >                ratelimit_pages = (4096 * 1024) / PAGE_CACHE_SIZE;
> > }
> > =======================================================
> >
> > Yes, 4M bytes are pretty magical constant. We have three choice
> >  A. Remove magical 4M constant simple (a bit danger)
> 
> That's will be outside the xfs, and seems like there is no much interest
> from mm people.

That's ok. you can join mm people :)



> >  B. Decide high border from IO capability
> 
> It's not clear to me how to calculate that high border, but again
> it's outside of the xfs scope, and we don't have much control here.
> 
> >  C. Introduce new /proc knob (as Olaf proposed)
> 
> We need at least to play with different numbers, and putting the
> knob (xfs tunable) would be one way to do it. Also, different
> configurations may need different nr_to_write value.
> 
> In either way it seems hackish, but with the knob at least there is
> some control of it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
