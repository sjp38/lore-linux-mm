Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id A13906B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 20:07:09 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id y14so3595896pdi.30
        for <linux-mm@kvack.org>; Thu, 18 Jul 2013 17:07:08 -0700 (PDT)
Message-ID: <51E882E1.4000504@gmail.com>
Date: Fri, 19 Jul 2013 08:05:53 +0800
From: Chen Gang F T <chen.gang.flying.transformer@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/slub.c: add parameter length checking for alloc_loc_track()
References: <51DA734B.4060608@asianux.com> <51DE549F.9070505@kernel.org> <51DE55C9.1060908@asianux.com> <0000013fce9f5b32-7d62f3c5-bb35-4dd9-ab19-d72bae4b5bdc-000000@email.amazonses.com> <51DEF935.4040804@kernel.org> <0000013fcf608df8-457e2029-51f9-4e49-9992-bf399a97d953-000000@email.amazonses.com> <51DF4540.8060700@asianux.com> <51DF4C94.3060103@asianux.com> <51DF5404.4060004@asianux.com> <0000013fd3250e40-1832fd38-ede3-41af-8fe3-5a0c10f5e5ce-000000@email.amazonses.com> <51E33F98.8060201@asianux.com> <0000013fe2e73e30-817f1bdb-8dc7-4f7b-9b60-b42d5d244fda-000000@email.amazonses.com> <51E49BDF.30008@asianux.com> <0000013fed280250-85b17e35-d4d4-468d-abed-5b2e29cedb94-000000@email.amazonses.com> <51E73A16.8070406@asianux.com> <0000013ff2076fb0-b52e0245-8fb5-4842-b0dd-d812ce2c9f62-000000@email.amazonses.com>
In-Reply-To: <0000013ff2076fb0-b52e0245-8fb5-4842-b0dd-d812ce2c9f62-000000@email.amazonses.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Chen Gang <gang.chen@asianux.com>, Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 07/18/2013 09:45 PM, Christoph Lameter wrote:
> On Thu, 18 Jul 2013, Chen Gang wrote:
> 
>> > Hmm... when anybody says "need respect original authors' willing and
>> > opinions", I think it often means we have found the direct issue, but
>> > none of us find the root issue.
> Is there an actual problem / failure being addressed by this patch?
> 

No, at least, this patch (add parameter length checking) is useless.

>> > e.g. for our this case:
>> >   the direct issue is:
>> >     "whether need check the length with 'max' parameter".
>> >   but maybe the root issue is:
>> >     "whether use 'size' as related parameter name instead of 'max'".
>> >     in alloc_loc_track(), 'max' just plays the 'size' role.
> "max" determines the size of the loc_track structure. So these can
> roughly mean the same thing.


Yes, "'max' can roughly mean the same thing", but they are still a
little different.

'max' also means: "the caller tells callee: I have told you the
maximize buffer length, so I need not check the buffer length to be
sure of no memory overflow, you need be sure of it".

'size' means: "the caller tells callee: you should use the size which I
give you, I am sure it is OK, do not care about whether it can cause
memory overflow or not".


The diff may like this:

--------------------------------diff begin------------------------------

diff --git a/mm/slub.c b/mm/slub.c
index 2b02d66..8564677 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3988,12 +3988,12 @@ static void free_loc_track(struct loc_track *t)
 			get_order(sizeof(struct location) * t->max));
 }
 
-static int alloc_loc_track(struct loc_track *t, unsigned long max, gfp_t flags)
+static int alloc_loc_track(struct loc_track *t, unsigned long size, gfp_t flags)
 {
 	struct location *l;
 	int order;
 
-	order = get_order(sizeof(struct location) * max);
+	order = get_order(sizeof(struct location) * size);
 
 	l = (void *)__get_free_pages(flags, order);
 	if (!l)
@@ -4003,7 +4003,7 @@ static int alloc_loc_track(struct loc_track *t, unsigned long max, gfp_t flags)
 		memcpy(l, t->loc, sizeof(struct location) * t->count);
 		free_loc_track(t);
 	}
-	t->max = max;
+	t->max = size;
 	t->loc = l;
 	return 1;
 }

--------------------------------diff end--------------------------------

Thanks
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
