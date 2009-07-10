Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5735B6B0082
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 02:49:40 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6A7CJsS032583
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 10 Jul 2009 16:12:19 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F95E45DE51
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 16:12:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EB0E45DE50
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 16:12:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DE0D1DB8037
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 16:12:19 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C47FF1DB8038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 16:12:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] bump up nr_to_write in xfs_vm_writepage
In-Reply-To: <20090709130134.GH18008@think>
References: <20090709110342.2386.A69D9226@jp.fujitsu.com> <20090709130134.GH18008@think>
Message-Id: <20090710153349.17EC.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 10 Jul 2009 16:12:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Christoph Hellwig <hch@infradead.org>, Eric Sandeen <sandeen@redhat.com>, xfs mailing list <xfs@oss.sgi.com>, linux-mm@kvack.org, Olaf Weber <olaf@sgi.com>
List-ID: <linux-mm.kvack.org>

> On Thu, Jul 09, 2009 at 11:04:32AM +0900, KOSAKI Motohiro wrote:
> > > On Tue, Jul 07, 2009 at 07:33:04PM +0900, KOSAKI Motohiro wrote:
> > > > At least, I agree with Olaf. if you got someone's NAK in past thread,
> > > > Could you please tell me its url?
> > > 
> > > The previous thread was simply dead-ended and nothing happened.
> > > 
> > 
> > Can you remember this thread subject? sorry, I haven't remember it.
> 
> This is the original thread, it did lead to a few different patches
> going in, but the nr_to_write change wasn't one of them.
> 
> http://kerneltrap.org/mailarchive/linux-kernel/2008/10/1/3472704/thread

Thanks good pointer. This thread have multiple interesting discussion.

1. making ext4_write_cache_pages() or modifying write_cache_pages()

I think this is Christoph's homework. he said

> I agree.  But I'm still not quite sure if that requirement is unique to
> ext4 anyway.  Give me some time to dive into the writeback code again,
> haven't been there for quite a while.

if he says modifying write_cache_pages() is necessary, I'd like to review it.


2. Current mapping->writeback_index updating is not proper?

I'm not sure which solution is better. but I think your first proposal is
enough acceptable.


3. Current wbc->nr_to_write value is not proper?

Current writeback_set_ratelimit() doesn't permit that ratelimit_pages exceed
4M byte. but it is too low restriction for nowadays.
(that's my understand. right?)

=======================================================
void writeback_set_ratelimit(void)
{
        ratelimit_pages = vm_total_pages / (num_online_cpus() * 32);
        if (ratelimit_pages < 16)
                ratelimit_pages = 16;
        if (ratelimit_pages * PAGE_CACHE_SIZE > 4096 * 1024)
                ratelimit_pages = (4096 * 1024) / PAGE_CACHE_SIZE;
}
=======================================================

Yes, 4M bytes are pretty magical constant. We have three choice
  A. Remove magical 4M constant simple (a bit danger)
  B. Decide high border from IO capability
  C. Introduce new /proc knob (as Olaf proposed)


In my personal prefer, B & C are better.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
