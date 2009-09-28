Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1709B6B005C
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 11:12:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8S3xHx9020323
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 28 Sep 2009 12:59:17 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2990745DE51
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:59:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A67445DE4F
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:59:17 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E971F1DB803C
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:59:16 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A48251DB8038
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 12:59:16 +0900 (JST)
Date: Mon, 28 Sep 2009 12:57:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: No more bits in vm_area_struct's vm_flags.
Message-Id: <20090928125705.6656e8c5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090928033624.GA11191@localhost>
References: <4AB9A0D6.1090004@crca.org.au>
	<20090924100518.78df6b93.kamezawa.hiroyu@jp.fujitsu.com>
	<4ABC80B0.5010100@crca.org.au>
	<20090925174009.79778649.kamezawa.hiroyu@jp.fujitsu.com>
	<4AC0234F.2080808@crca.org.au>
	<20090928120450.c2d8a4e2.kamezawa.hiroyu@jp.fujitsu.com>
	<20090928033624.GA11191@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Nigel Cunningham <ncunningham@crca.org.au>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Sep 2009 11:36:24 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Mon, Sep 28, 2009 at 11:04:50AM +0800, KAMEZAWA Hiroyuki wrote:
 
> > But, yes it implies to add a new argument to several functions in mmap.c
> > and maybe a patch will be ugly.
> > 
> > How about addding this check ?
> > 
> > is_mergeable_vma(...)
> > ....
> >   if (vma->vm_hints)
> > 	return 0;
> > 
> > And not calling vma_merge() at madvice(ACCESS_PATTERN_HINT).
> > 
> > I wonder there are little chances when madice(ACCESS_PATTERN_HINT) is
> > given against mapped-file-vma...
> 
> Me wonder too. The access hints should be rarely used.
> A simple solution is reasonable for them.
> 
> But what if more flags going into vm_hints in future?
> 

yes, that's concern...

But I wonder there are several flags which implies that the vma is not for
merge. as....

#define VM_GROWSDOWN    0x00000100      /* general info on the segment */
#define VM_GROWSUP      0x00000200

or some PFN_MAP flags...
(At least, we can have 4 flags of not-for-merge in vm_hints ;)

Then, Nigel, you have 2 choices I think.

  (1) don't merge if vm_hints is set  or
  (2) pass vm_hints to all __merge() functions.

One of above will be accesptable for stakeholders...
I personally like (1) but just trying (2) may be accepted.

What I dislike is making vm_flags to be long long ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
