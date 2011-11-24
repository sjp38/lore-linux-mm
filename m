Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 663EC6B009B
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 23:25:03 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0A8C73EE0C0
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 13:25:00 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DBA2B45DE53
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 13:24:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C651145DE4D
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 13:24:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id B9823E08007
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 13:24:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8277BE08002
	for <linux-mm@kvack.org>; Thu, 24 Nov 2011 13:24:59 +0900 (JST)
Date: Thu, 24 Nov 2011 13:23:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [V3 PATCH 1/2] tmpfs: add fallocate support
Message-Id: <20111124132349.ca862c9e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4ECDB87A.90106@redhat.com>
References: <1322038412-29013-1-git-send-email-amwang@redhat.com>
	<20111124105245.b252c65f.kamezawa.hiroyu@jp.fujitsu.com>
	<CAHGf_=oD0Coc=k5kAAQoP=GqK+nc0jd3qq3TmLZaitSjH-ZPmQ@mail.gmail.com>
	<20111124120126.9361b2c9.kamezawa.hiroyu@jp.fujitsu.com>
	<4ECDB87A.90106@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Pekka Enberg <penberg@kernel.org>, Christoph Hellwig <hch@lst.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Lennart Poettering <lennart@poettering.net>, Kay Sievers <kay.sievers@vrfy.org>, linux-mm@kvack.org

On Thu, 24 Nov 2011 11:22:34 +0800
Cong Wang <amwang@redhat.com> wrote:

> 于 2011年11月24日 11:01, KAMEZAWA Hiroyuki 写道:
> > On Wed, 23 Nov 2011 21:46:39 -0500
> > KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>  wrote:
> >
> >>>> +     while (index<  end) {
> >>>> +             ret = shmem_getpage(inode, index,&page, SGP_WRITE, NULL);
> >>>
> >>> If the 'page' for index exists before this call, this will return the page without
> >>> allocaton.
> >>>
> >>> Then, the page may not be zero-cleared. I think the page should be zero-cleared.
> >>
> >> No. fallocate shouldn't destroy existing data. It only ensure
> >> subsequent file access don't make ENOSPC error.
> >>
> >        FALLOC_FL_KEEP_SIZE
> >                This flag allocates and initializes to zero the disk  space
> >                within the range specified by offset and len. ....
> >
> > just manual is unclear ? it seems that the range [offset, offset+len) is
> > zero cleared after the call.
> 
> I think we should fix the man page, because at least ext4 doesn't clear
> the original contents,
> 
> % echo hi > /tmp/foobar
> % fallocate -n -l 1 -o 10 /tmp/foobar
> % hexdump -Cv /tmp/foobar
> 00000000  68 69 0a                                          |hi.|
> 00000003
> 

thank you for checking. So, at failure path, original data should not be
cleared, either.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
