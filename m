Subject: Re: [PATCH 11/12] mm: per device dirty threshold
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <E1Heakt-0006jg-00@dorka.pomaz.szeredi.hu>
References: <20070417071046.318415445@chello.nl>
	 <20070417071703.959920360@chello.nl>
	 <E1Heakt-0006jg-00@dorka.pomaz.szeredi.hu>
Content-Type: text/plain
Date: Thu, 19 Apr 2007 20:04:14 +0200
Message-Id: <1177005854.2934.6.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-04-19 at 19:49 +0200, Miklos Szeredi wrote:
> > +static inline unsigned long bdi_stat_delta(void)
> > +{
> > +#ifdef CONFIG_SMP
> > +	return NR_CPUS * FBC_BATCH;
> 
> Shouln't this be multiplied by the number of counters to sum?  I.e. 3
> if dirty and unstable are separate, and 2 if they are not.

Ah, yes, good catch. How about this:

---

Since we're adding 3 stat counters, tripple the per counter delta as
well.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/page-writeback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2007-04-19 19:59:26.000000000 +0200
+++ linux-2.6/mm/page-writeback.c	2007-04-19 20:00:09.000000000 +0200
@@ -321,7 +321,7 @@ static void balance_dirty_pages(struct a
 			get_dirty_limits(&background_thresh, &dirty_thresh,
 				       &bdi_thresh, bdi);
 
-			if (bdi_thresh < bdi_stat_delta()) {
+			if (bdi_thresh < 3*bdi_stat_delta()) {
 				bdi_nr_reclaimable =
 					bdi_stat_sum(bdi, BDI_DIRTY) +
 					bdi_stat_sum(bdi, BDI_UNSTABLE);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
