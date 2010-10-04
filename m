Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E3DAA6B0047
	for <linux-mm@kvack.org>; Sun,  3 Oct 2010 20:22:18 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o940MFgS003177
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 4 Oct 2010 09:22:15 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 880D645DE50
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 09:22:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A02745DE4E
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 09:22:15 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4CE651DB8050
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 09:22:15 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DE9FF1DB8045
	for <linux-mm@kvack.org>; Mon,  4 Oct 2010 09:22:14 +0900 (JST)
Date: Mon, 4 Oct 2010 09:16:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH][RESEND] nommu: add anonymous page memcg accounting
Message-Id: <20101004091653.707cc5d1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1285951267.2558.69.camel@iscandar.digidescorp.com>
References: <WC20101001143139.810346@digidescorp.com>
	<1285929315-2856-1-git-send-email-steve@digidescorp.com>
	<5206.1285943095@redhat.com>
	<5867.1285945621@redhat.com>
	<1285951267.2558.69.camel@iscandar.digidescorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: steve@digidescorp.com
Cc: David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 01 Oct 2010 11:41:07 -0500
"Steven J. Magnani" <steve@digidescorp.com> wrote:
> > However, I suppose there's little harm in letting the patch in.  I would guess
> > the additions all optimise away if memcg isn't enabled.
> > 
> > A question for you: why does struct page_cgroup need a page pointer?  If an
> > array of page_cgroup structs is allocated per array of page structs, then you
> > should be able to use the array index to map between them.
> 
No reason. It was not array in the 1st implemenation and ->page still remains. At 2nd
implementation, I didn't know embeded people has any interests on memcg. And I wasn't
sure how
	page_cgroup_to_page() : pfn_to_page(pagec_cgroup_to_pfn(pc))
will be widely used.

Now, we know page_cgroup->page is not used in very critical path _if_ node-id
and zone-id can be directly got from page_cgroup.

I'm now preparing a patch to remove struct page* pointer. I'm wondering
whether it's ok that some architecuture cannot drop struct page pointer.
If SPARSEMEM is used on 32bit arch, I'm not sure whether # of bits isn't enough.
I may have to add overhead to get nid, zid in critical path.
(for example, s390/32bit, x86-32/HIGHMEM, ARM/HIGHMEM?)

Current out priority is supporting dirty_ratio rather than memory usage diet.
Please wait. Removing page_cgroup->page patch will add something a bit complex.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
