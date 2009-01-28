Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BBC486B0044
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 00:04:34 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0S54WPm015441
	for <linux-mm@kvack.org> (envelope-from y-goto@jp.fujitsu.com);
	Wed, 28 Jan 2009 14:04:32 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F094D45DE54
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 14:04:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CF74C45DE51
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 14:04:31 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A7D211DB8042
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 14:04:31 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5620C1DB803A
	for <linux-mm@kvack.org>; Wed, 28 Jan 2009 14:04:31 +0900 (JST)
Date: Wed, 28 Jan 2009 14:04:24 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] mm: get_nid_for_pfn() returns int
In-Reply-To: <20090127210727.GA9592@us.ibm.com>
References: <20090126223350.610b0283.akpm@linux-foundation.org> <20090127210727.GA9592@us.ibm.com>
Message-Id: <20090128135408.DC38.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Roel Kluin <roel.kluin@gmail.com>, Ingo Molnar <mingo@elte.hu>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Gary Hade <garyhade@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> On Mon, Jan 26, 2009 at 10:33:50PM -0800, Andrew Morton wrote:
> > On Mon, 19 Jan 2009 09:59:19 -0800 Gary Hade <garyhade@us.ibm.com> wrote:
> > 
> > > On Sun, Jan 18, 2009 at 11:36:28PM +0100, Roel Kluin wrote:
> > > > get_nid_for_pfn() returns int
> > > > 
> > > > Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> > > > ---
> > > > vi drivers/base/node.c +256
> > > > static int get_nid_for_pfn(unsigned long pfn)
> > > > 
> > > > diff --git a/drivers/base/node.c b/drivers/base/node.c
> > > > index 43fa90b..f8f578a 100644
> > > > --- a/drivers/base/node.c
> > > > +++ b/drivers/base/node.c
> > > > @@ -303,7 +303,7 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk)
> > > >  	sect_start_pfn = section_nr_to_pfn(mem_blk->phys_index);
> > > >  	sect_end_pfn = sect_start_pfn + PAGES_PER_SECTION - 1;
> > > >  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> > > > -		unsigned int nid;
> > > > +		int nid;
> > > > 
> > > >  		nid = get_nid_for_pfn(pfn);
> > > >  		if (nid < 0)
> > > 
> > > My mistake.  Good catch.
> > > 
> > 
> > Presumably the (nid < 0) case has never happened.
> 
> We do know that it is happening on one system while creating
> a symlink for a memory section so it should also happen on
> the same system if unregister_mem_sect_under_nodes() were
> called to remove the same symlink.
> 
> The test was actually added in response to a problem with an
> earlier version reported by Yasunori Goto where one or more
> of the leading pages of a memory section on the 2nd node of
> one of his systems was uninitialized because I believe they
> coincided with a memory hole. 

Yes. There are some memory hole pages which are occupied by firmware in
our box.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
