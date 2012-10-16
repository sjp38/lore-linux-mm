Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 408846B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 03:58:40 -0400 (EDT)
Date: Tue, 16 Oct 2012 08:58:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: dma_alloc_coherent fails in framebuffer
Message-ID: <20121016075835.GF29125@suse.de>
References: <1350192523.10946.4.camel@gitbox>
 <1350246895.11504.6.camel@gitbox>
 <20121015094547.GC29125@suse.de>
 <1350325704.31162.16.camel@gitbox>
 <CAA_GA1cPE+m8N1LQA2iOym4jbFwcHG+K2p-3iBovPWuf1N1q+g@mail.gmail.com>
 <1350366893.26424.5.camel@gitbox>
 <1350370207.26424.13.camel@gitbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1350370207.26424.13.camel@gitbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Prisk <linux@prisktech.co.nz>
Cc: linux-mm@kvack.org, Arm Kernel Mailing List <linux-arm-kernel@lists.infradead.org>, Arnd Bergmann <arnd@arndb.de>

On Tue, Oct 16, 2012 at 07:50:07PM +1300, Tony Prisk wrote:
> > > > Why it caused a problem on that particular commit I don't know - but it
> > > > was reproducible by adding/removing it.
> > > >
> > 
> > I finally found the link to this patch which caused the problem - and
> > may still be the cause of my problems :)
> > 

Blast, thanks. This was already identified as being a problem and "fixed"
in https://lkml.org/lkml/2012/10/5/164 but I missed that the fix did not
get picked up before RC1 after all the patches got collapsed together. I'm
very sorry about that, I should have spotted that it didn't make it through.

> Any suggestions on how to fix this?
> 

Can you test this to be sure and if it's fine I'll push it to Andrew.

---8<---
mm: compaction: Correct the strict_isolated check for CMA

Thierry reported that the "iron out" patch for isolate_freepages_block()
had problems due to the strict check being too strict with "mm: compaction:
Iron out isolate_freepages_block() and isolate_freepages_range() -fix1".
It's possible that more pages than necessary are isolated but the check
still fails and I missed that this fix was not picked up before RC1. This
has also been identified in RC1 by Tony Prisk and should be addressed by
the following patch.

Signed-off-by: Mel Gorman <mgorman@suse.de>
--- 
 compaction.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 2c4ce17..9eef558 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -346,7 +346,7 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 	 * pages requested were isolated. If there were any failures, 0 is
 	 * returned and CMA will fail.
 	 */
-	if (strict && nr_strict_required != total_isolated)
+	if (strict && nr_strict_required > total_isolated)
 		total_isolated = 0;
 
 	if (locked)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
