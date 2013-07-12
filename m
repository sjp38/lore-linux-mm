Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 236286B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 20:56:33 -0400 (EDT)
Message-ID: <51DF5404.4060004@asianux.com>
Date: Fri, 12 Jul 2013 08:55:32 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/slub.c: add parameter length checking for alloc_loc_track()
References: <51DA734B.4060608@asianux.com> <51DE549F.9070505@kernel.org> <51DE55C9.1060908@asianux.com> <0000013fce9f5b32-7d62f3c5-bb35-4dd9-ab19-d72bae4b5bdc-000000@email.amazonses.com> <51DEF935.4040804@kernel.org> <0000013fcf608df8-457e2029-51f9-4e49-9992-bf399a97d953-000000@email.amazonses.com> <51DF4540.8060700@asianux.com> <51DF4C94.3060103@asianux.com>
In-Reply-To: <51DF4C94.3060103@asianux.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Since alloc_loc_track() will alloc additional space, and already knows
about 'max', so need be sure of 'max' must be larger than 't->count'.

The caller may not notice about it, e.g. call from add_location() in
"mm/slub.c", which only let "max = 2 * max" when "t->count >= t->max"


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/slub.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 2b02d66..36f606d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3993,6 +3993,9 @@ static int alloc_loc_track(struct loc_track *t, unsigned long max, gfp_t flags)
 	struct location *l;
 	int order;
 
+	if (t->count >= max)
+		return 0;
+
 	order = get_order(sizeof(struct location) * max);
 
 	l = (void *)__get_free_pages(flags, order);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
