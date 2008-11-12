Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAC2KBWQ003473
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 12 Nov 2008 11:20:11 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D8A7945DD9A
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 11:20:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A6BCF45DD84
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 11:20:10 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7A7541DB804F
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 11:20:10 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D665E08004
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 11:20:09 +0900 (JST)
Date: Wed, 12 Nov 2008 11:19:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
Message-Id: <20081112111931.0e40c27d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081111222421.GL10818@random.random>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
	<1226409701-14831-2-git-send-email-ieidus@redhat.com>
	<1226409701-14831-3-git-send-email-ieidus@redhat.com>
	<20081111114555.eb808843.akpm@linux-foundation.org>
	<4919F1C0.2050009@redhat.com>
	<Pine.LNX.4.64.0811111520590.27767@quilx.com>
	<4919F7EE.3070501@redhat.com>
	<Pine.LNX.4.64.0811111527500.27767@quilx.com>
	<20081111222421.GL10818@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Tue, 11 Nov 2008 23:24:21 +0100
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Tue, Nov 11, 2008 at 03:31:18PM -0600, Christoph Lameter wrote:
> > > ksm need the pte inside the vma to point from anonymous page into filebacked
> > > page
> > > can migrate.c do it without changes?
> > 
> > So change anonymous to filebacked page?
> >
> > Currently page migration assumes that the page will continue to be part
> > of the existing file or anon vma.
> > 
> > What you want sounds like assigning a swap pte to an anonymous page? That
> > way a anon page gains membership in a file backed mapping.
> 
> KSM needs to convert anonymous pages to PageKSM, which means a page
> owned by ksm.c and only known by ksm.c. The Linux VM will free this
> page in munmap but that's about it, all we do is to match the number
> of anon-ptes pointing to the page with the page_count. So besides
> freeing the page when the last user exit()s or cows it, the VM will do
> nothing about it. Initially. Later it can swap it in a nonlinear way.
> 
Can I make a question ? (I'm working for memory cgroup.)

Now, we do charge to anonymous page when
  - charge(+1) when it's mapped firstly (mapcount 0->1)
  - uncharge(-1) it's fully unmapped (mapcount 1->0) vir page_remove_rmap().

My quesion is
 - PageKSM pages are not necessary to be tracked by memory cgroup ?
 - Can we know that "the page is just replaced and we don't necessary to do
   charge/uncharge".
 - annonymous page from KSM is worth to be tracked by memory cgroup ?
   (IOW, it's on LRU and can be swapped-out ?)

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
