Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 24 Mar 2014 15:07:43 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] aio: ensure access to ctx->ring_pages is correctly serialised
Message-ID: <20140324190743.GJ4173@kvack.org>
References: <532A80B1.5010002@cn.fujitsu.com> <20140320143207.GA3760@redhat.com> <20140320163004.GE28970@kvack.org> <532B9C54.80705@cn.fujitsu.com> <20140321183509.GC23173@kvack.org> <533077CE.6010204@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <533077CE.6010204@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Dave Jones <davej@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, jmoyer@redhat.com, kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, miaox@cn.fujitsu.com, linux-aio@kvack.org, fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Mar 24, 2014 at 02:22:06PM -0400, Sasha Levin wrote:
> On 03/21/2014 02:35 PM, Benjamin LaHaise wrote:
> >Hi all,
> >
> >Based on the issues reported by Tang and Gu, I've come up with the an
> >alternative fix that avoids adding additional locking in the event read
> >code path.  The fix is to take the ring_lock mutex during page migration,
> >which is already used to syncronize event readers and thus does not add
> >any new locking requirements in aio_read_events_ring().  I've dropped
> >the patches from Tang and Gu as a result.  This patch is now in my
> >git://git.kvack.org/~bcrl/aio-next.git tree and will be sent to Linus
> >once a few other people chime in with their reviews of this change.
> >Please review Tang, Gu.  Thanks!
> 
> Hi Benjamin,
> 
> This patch seems to trigger:
> 
> [  433.476216] ======================================================
> [  433.478468] [ INFO: possible circular locking dependency detected ]
...

Yeah, that's a problem -- thanks for the report.  The ring_lock mutex can't 
be nested inside of mmap_sem, as aio_read_events_ring() can take a page 
fault while holding ring_mutex.  That makes the following change required.  
I'll fold this change into the patch that caused this issue.

		-ben
-- 
"Thought is the essence of where you are now."

diff --git a/fs/aio.c b/fs/aio.c
index c97cee8..f645e7e 100644
--- a/fs/aio.c
+++ b/fs/aio.c
@@ -300,7 +300,10 @@ static int aio_migratepage(struct address_space *mapping, struct page *new,
 	if (!ctx)
 		return -EINVAL;
 
-	mutex_lock(&ctx->ring_lock);
+	if (!mutex_trylock(&ctx->ring_lock)) {
+		percpu_ref_put(&ctx->users);
+		return -EAGAIN;
+	}
 
 	/* Make sure the old page hasn't already been changed */
 	spin_lock(&mapping->private_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
