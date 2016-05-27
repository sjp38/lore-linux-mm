Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 637D26B026A
	for <linux-mm@kvack.org>; Fri, 27 May 2016 11:03:23 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id r64so170851194oie.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 08:03:23 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0118.outbound.protection.outlook.com. [157.56.112.118])
        by mx.google.com with ESMTPS id 21si14107128otd.3.2016.05.27.08.03.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 May 2016 08:03:22 -0700 (PDT)
Date: Fri, 27 May 2016 18:03:14 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH RESEND 7/8] pipe: account to kmemcg
Message-ID: <20160527150313.GD26059@esperanza>
References: <cover.1464079537.git.vdavydov@virtuozzo.com>
 <2c2545563b6201f118946f96dd8cfc90e564aff6.1464079538.git.vdavydov@virtuozzo.com>
 <1464094742.5939.46.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160524161336.GA11150@esperanza>
 <1464120273.5939.53.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160525103011.GF11150@esperanza>
 <20160526070455.GF9661@bbox>
 <20160526135930.GA26059@esperanza>
 <1464272149.5939.92.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1464272149.5939.92.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org

On Thu, May 26, 2016 at 07:15:49AM -0700, Eric Dumazet wrote:
> On Thu, 2016-05-26 at 16:59 +0300, Vladimir Davydov wrote:
> > On Thu, May 26, 2016 at 04:04:55PM +0900, Minchan Kim wrote:
> > > On Wed, May 25, 2016 at 01:30:11PM +0300, Vladimir Davydov wrote:
> > > > On Tue, May 24, 2016 at 01:04:33PM -0700, Eric Dumazet wrote:
> > > > > On Tue, 2016-05-24 at 19:13 +0300, Vladimir Davydov wrote:
> > > > > > On Tue, May 24, 2016 at 05:59:02AM -0700, Eric Dumazet wrote:
> > > > > > ...
> > > > > > > > +static int anon_pipe_buf_steal(struct pipe_inode_info *pipe,
> > > > > > > > +			       struct pipe_buffer *buf)
> > > > > > > > +{
> > > > > > > > +	struct page *page = buf->page;
> > > > > > > > +
> > > > > > > > +	if (page_count(page) == 1) {
> > > > > > > 
> > > > > > > This looks racy : some cpu could have temporarily elevated page count.
> > > > > > 
> > > > > > All pipe operations (pipe_buf_operations->get, ->release, ->steal) are
> > > > > > supposed to be called under pipe_lock. So, if we see a pipe_buffer->page
> > > > > > with refcount of 1 in ->steal, that means that we are the only its user
> > > > > > and it can't be spliced to another pipe.
> > > > > > 
> > > > > > In fact, I just copied the code from generic_pipe_buf_steal, adding
> > > > > > kmemcg related checks along the way, so it should be fine.
> > > > > 
> > > > > So you guarantee that no other cpu might have done
> > > > > get_page_unless_zero() right before this test ?
> > > > 
> > > > Each pipe_buffer holds a reference to its page. If we find page's
> > > > refcount to be 1 here, then it can be referenced only by our
> > > > pipe_buffer. And the refcount cannot be increased by a parallel thread,
> > > > because we hold pipe_lock, which rules out splice, and otherwise it's
> > > > impossible to reach the page as it is not on lru. That said, I think I
> > > > guarantee that this should be safe.
> > > 
> > > I don't know kmemcg internal and pipe stuff so my comment might be
> > > totally crap.
> > > 
> > > No one cannot guarantee any CPU cannot held a reference of a page.
> > > Look at get_page_unless_zero usecases.
> > > 
> > > 1. balloon_page_isolate
> > > 
> > > It can hold a reference in random page and then verify the page
> > > is balloon page. Otherwise, just put.
> > > 
> > > 2. page_idle_get_page
> > > 
> > > It has PageLRU check but it's racy so it can hold a reference
> > > of randome page and then verify within zone->lru_lock. If it's
> > > not LRU page, just put.
> > 
> > Well, I see your concern now - even if a page is not on lru and we
> > locked all structs pointing to it, it can always get accessed by pfn in
> > a completely unrelated thread, like in examples you gave above. That's a
> > fair point.
> > 
> > However, I still think that it's OK in case of pipe buffers. What can
> > happen if somebody takes a transient reference to a pipe buffer page? At
> > worst, we'll see page_count > 1 due to temporary ref and abort stealing,
> > falling back on copying instead. That's OK, because stealing is not
> > guaranteed. Can a function that takes a transient ref to page by pfn
> > mistakenly assume that this is a page it's interested in? I don't think
> > so, because this page has no marks on it except special _mapcount value,
> > which should only be set on kmemcg pages.
> 
> Well, all this information deserve to be in the changelog.
> 
> Maybe in 6 months, this will be incredibly useful for bug hunting.
> 
> pipes can be used to exchange data (or pages) between processes in
> different domains.
> 
> If kmemcg is not precise, this could be used by some attackers to force
> some processes to consume all their budget and eventually not be able to
> allocate new pages.
> 

Here goes the patch with updated change log.
---
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH] pipe: account to kmemcg

Pipes can consume a significant amount of system memory, hence they
should be accounted to kmemcg.

This patch marks pipe_inode_info and anonymous pipe buffer page
allocations as __GFP_ACCOUNT so that they would be charged to kmemcg.
Note, since a pipe buffer page can be "stolen" and get reused for other
purposes, including mapping to userspace, we clear PageKmemcg thus
resetting page->_mapcount and uncharge it in anon_pipe_buf_steal, which
is introduced by this patch.

A note regarding anon_pipe_buf_steal implementation. We allow to steal
the page if its ref count equals 1. It looks racy, but it is correct for
anonymous pipe buffer pages, because:

 - We lock out all other pipe users, because ->steal is called with
   pipe_lock held, so the page can't be spliced to another pipe from
   under us.

 - The page is not on LRU and it never was.

 - Thus a parallel thread can access it only by PFN. Although this is
   quite possible (e.g. see page_idle_get_page and balloon_page_isolate)
   this is not dangerous, because all such functions do is increase page
   ref count, check if the page is the one they are looking for, and
   decrease ref count if it isn't. Since our page is clean except for
   PageKmemcg mark, which doesn't conflict with other _mapcount users,
   the worst that can happen is we see page_count > 2 due to a transient
   ref, in which case we false-positively abort ->steal, which is still
   fine, because ->steal is not guaranteed to succeed.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>

diff --git a/fs/pipe.c b/fs/pipe.c
index 0d3f5165cb0b..4b32928f5426 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -21,6 +21,7 @@
 #include <linux/audit.h>
 #include <linux/syscalls.h>
 #include <linux/fcntl.h>
+#include <linux/memcontrol.h>
 
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
@@ -137,6 +138,22 @@ static void anon_pipe_buf_release(struct pipe_inode_info *pipe,
 		put_page(page);
 }
 
+static int anon_pipe_buf_steal(struct pipe_inode_info *pipe,
+			       struct pipe_buffer *buf)
+{
+	struct page *page = buf->page;
+
+	if (page_count(page) == 1) {
+		if (memcg_kmem_enabled()) {
+			memcg_kmem_uncharge(page, 0);
+			__ClearPageKmemcg(page);
+		}
+		__SetPageLocked(page);
+		return 0;
+	}
+	return 1;
+}
+
 /**
  * generic_pipe_buf_steal - attempt to take ownership of a &pipe_buffer
  * @pipe:	the pipe that the buffer belongs to
@@ -219,7 +236,7 @@ static const struct pipe_buf_operations anon_pipe_buf_ops = {
 	.can_merge = 1,
 	.confirm = generic_pipe_buf_confirm,
 	.release = anon_pipe_buf_release,
-	.steal = generic_pipe_buf_steal,
+	.steal = anon_pipe_buf_steal,
 	.get = generic_pipe_buf_get,
 };
 
@@ -227,7 +244,7 @@ static const struct pipe_buf_operations packet_pipe_buf_ops = {
 	.can_merge = 0,
 	.confirm = generic_pipe_buf_confirm,
 	.release = anon_pipe_buf_release,
-	.steal = generic_pipe_buf_steal,
+	.steal = anon_pipe_buf_steal,
 	.get = generic_pipe_buf_get,
 };
 
@@ -405,7 +422,7 @@ pipe_write(struct kiocb *iocb, struct iov_iter *from)
 			int copied;
 
 			if (!page) {
-				page = alloc_page(GFP_HIGHUSER);
+				page = alloc_page(GFP_HIGHUSER | __GFP_ACCOUNT);
 				if (unlikely(!page)) {
 					ret = ret ? : -ENOMEM;
 					break;
@@ -611,7 +628,7 @@ struct pipe_inode_info *alloc_pipe_info(void)
 {
 	struct pipe_inode_info *pipe;
 
-	pipe = kzalloc(sizeof(struct pipe_inode_info), GFP_KERNEL);
+	pipe = kzalloc(sizeof(struct pipe_inode_info), GFP_KERNEL_ACCOUNT);
 	if (pipe) {
 		unsigned long pipe_bufs = PIPE_DEF_BUFFERS;
 		struct user_struct *user = get_current_user();
@@ -619,7 +636,9 @@ struct pipe_inode_info *alloc_pipe_info(void)
 		if (!too_many_pipe_buffers_hard(user)) {
 			if (too_many_pipe_buffers_soft(user))
 				pipe_bufs = 1;
-			pipe->bufs = kzalloc(sizeof(struct pipe_buffer) * pipe_bufs, GFP_KERNEL);
+			pipe->bufs = kcalloc(pipe_bufs,
+					     sizeof(struct pipe_buffer),
+					     GFP_KERNEL_ACCOUNT);
 		}
 
 		if (pipe->bufs) {
@@ -1010,7 +1029,8 @@ static long pipe_set_size(struct pipe_inode_info *pipe, unsigned long nr_pages)
 	if (nr_pages < pipe->nrbufs)
 		return -EBUSY;
 
-	bufs = kcalloc(nr_pages, sizeof(*bufs), GFP_KERNEL | __GFP_NOWARN);
+	bufs = kcalloc(nr_pages, sizeof(*bufs),
+		       GFP_KERNEL_ACCOUNT | __GFP_NOWARN);
 	if (unlikely(!bufs))
 		return -ENOMEM;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
