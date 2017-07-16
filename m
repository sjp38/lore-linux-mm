Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 24AAB6B04FC
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 09:28:05 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id z37so129270956ybh.15
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 06:28:05 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id r128si3593184ywd.385.2017.07.16.06.28.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 06:28:03 -0700 (PDT)
Date: Sun, 16 Jul 2017 14:27:35 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH] mm: make allocation counters per-order
Message-ID: <20170716132735.GA757@castle>
References: <1499346271-15653-1-git-send-email-guro@fb.com>
 <20170706131941.omod4zl4cyuscmjo@techsingularity.net>
 <20170706144634.GB14840@castle>
 <20170706154704.owxsnyizel6bcgku@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170706154704.owxsnyizel6bcgku@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Rik van Riel <riel@redhat.com>, kernel-team@fb.com, linux-kernel@vger.kernel.org

On Thu, Jul 06, 2017 at 04:47:05PM +0100, Mel Gorman wrote:
> On Thu, Jul 06, 2017 at 03:46:34PM +0100, Roman Gushchin wrote:
> > > The alloc counter updates are themselves a surprisingly heavy cost to
> > > the allocation path and this makes it worse for a debugging case that is
> > > relatively rare. I'm extremely reluctant for such a patch to be added
> > > given that the tracepoints can be used to assemble such a monitor even
> > > if it means running a userspace daemon to keep track of it. Would such a
> > > solution be suitable? Failing that if this is a severe issue, would it be
> > > possible to at least make this a compile-time or static tracepoint option?
> > > That way, only people that really need it have to take the penalty.
> > 
> > I've tried to measure the difference with my patch applied and without
> > any accounting at all (__count_alloc_event() redefined to an empty function),
> > and I wasn't able to find any measurable difference.
> > Can you, please, provide more details, how your scenario looked like,
> > when alloc coutners were costly?
> > 
> 
> At the time I used a page allocator microbenchmark from mmtests to call
> the allocator directly without zeroing pages. Triggering allocations from
> userspace generally mask the overhead by the zeroing costs. It's just a few
> cycles but given the budget for the page allocator in some circumstances
> is tiny, it was noticable. perf was used to examine the cost.
> 
> > As new counters replace an old one, and both are per-cpu counters, I believe,
> > that the difference should be really small.
> > 
> 
> Minimally you add a new branch and a small number of computations. It's
> small but it's there. The cache footprint of the counters is also increased.
> That is hard to take given that it's overhead for everybody on the off-chance
> it can debug something.
> 
> It's not a strong objection and I won't nak it on this basis but given
> that the same information can be easily obtained using tracepoints
> (optionally lower overhead with systemtap), the information is rarely
> going to be useful (no latency information for example) and there is an
> increased maintenance cost then it does not seem to be that useful.

I ran page allocator microbenchmark on raw 4.12 and 4.12 + the change
on my hardware.

Here are the results (raw 4.12 and patched 4.12 corrspondigly):
order  0 batch      1 alloc 1942 free 1041     order  0 batch      1 alloc 822 free 451
order  0 batch      1 alloc 596 free 306       order  0 batch      1 alloc 493 free 290
order  0 batch      1 alloc 417 free 245       order  0 batch      1 alloc 526 free 286
order  0 batch      1 alloc 419 free 243       order  0 batch      1 alloc 435 free 255
order  0 batch      1 alloc 411 free 243       order  0 batch      1 alloc 423 free 240
order  0 batch      1 alloc 417 free 241       order  0 batch      1 alloc 406 free 239
order  0 batch      1 alloc 376 free 225       order  0 batch      1 alloc 383 free 219
order  0 batch      1 alloc 416 free 222       order  0 batch      1 alloc 355 free 205
order  0 batch      1 alloc 312 free 183       order  0 batch      1 alloc 438 free 216
order  0 batch      1 alloc 315 free 181       order  0 batch      1 alloc 347 free 194
order  0 batch      1 alloc 305 free 181       order  0 batch      1 alloc 317 free 185
order  0 batch      1 alloc 307 free 179       order  0 batch      1 alloc 329 free 191
order  0 batch      1 alloc 308 free 178       order  0 batch      1 alloc 335 free 192
order  0 batch      1 alloc 314 free 180       order  0 batch      1 alloc 350 free 190
order  0 batch      1 alloc 301 free 180       order  0 batch      1 alloc 319 free 184
order  0 batch      1 alloc 1807 free 1002     order  0 batch      1 alloc 813 free 459
order  0 batch      1 alloc 633 free 302       order  0 batch      1 alloc 500 free 287
order  0 batch      1 alloc 331 free 194       order  0 batch      1 alloc 609 free 300
order  0 batch      1 alloc 332 free 194       order  0 batch      1 alloc 443 free 255
order  0 batch      1 alloc 330 free 194       order  0 batch      1 alloc 410 free 239
order  0 batch      1 alloc 331 free 194       order  0 batch      1 alloc 383 free 222
order  0 batch      1 alloc 386 free 214       order  0 batch      1 alloc 372 free 212
order  0 batch      1 alloc 370 free 212       order  0 batch      1 alloc 342 free 203
order  0 batch      1 alloc 360 free 208       order  0 batch      1 alloc 428 free 216
order  0 batch      1 alloc 324 free 186       order  0 batch      1 alloc 350 free 195
order  0 batch      1 alloc 298 free 179       order  0 batch      1 alloc 320 free 186
order  0 batch      1 alloc 293 free 173       order  0 batch      1 alloc 323 free 187
order  0 batch      1 alloc 296 free 173       order  0 batch      1 alloc 320 free 188
order  0 batch      1 alloc 294 free 173       order  0 batch      1 alloc 321 free 186
order  0 batch      1 alloc 312 free 174       order  0 batch      1 alloc 320 free 189
order  0 batch      1 alloc 1927 free 1042     order  0 batch      1 alloc 2016 free 10
order  0 batch      1 alloc 856 free 522       order  0 batch      1 alloc 1805 free 10
order  0 batch      1 alloc 372 free 225       order  0 batch      1 alloc 1485 free 73
order  0 batch      1 alloc 375 free 224       order  0 batch      1 alloc 732 free 419
order  0 batch      1 alloc 419 free 234       order  0 batch      1 alloc 576 free 327
order  0 batch      1 alloc 389 free 233       order  0 batch      1 alloc 488 free 280
order  0 batch      1 alloc 376 free 223       order  0 batch      1 alloc 390 free 233
order  0 batch      1 alloc 331 free 196       order  0 batch      1 alloc 409 free 227
order  0 batch      1 alloc 328 free 191       order  0 batch      1 alloc 338 free 198
order  0 batch      1 alloc 307 free 182       order  0 batch      1 alloc 320 free 186
order  0 batch      1 alloc 307 free 183       order  0 batch      1 alloc 322 free 187
order  0 batch      1 alloc 304 free 183       order  0 batch      1 alloc 296 free 173
order  0 batch      1 alloc 303 free 183       order  0 batch      1 alloc 297 free 173
order  0 batch      1 alloc 303 free 176       order  0 batch      1 alloc 296 free 173
order  0 batch      1 alloc 294 free 176       order  0 batch      1 alloc 296 free 173
order  0 batch      1 alloc 716 free 433       order  0 batch      1 alloc 725 free 421
order  0 batch      1 alloc 487 free 286       order  0 batch      1 alloc 485 free 287
order  0 batch      1 alloc 499 free 296       order  0 batch      1 alloc 627 free 300
order  0 batch      1 alloc 437 free 253       order  0 batch      1 alloc 406 free 238
order  0 batch      1 alloc 412 free 242       order  0 batch      1 alloc 390 free 226
order  0 batch      1 alloc 391 free 228       order  0 batch      1 alloc 364 free 218
order  0 batch      1 alloc 379 free 220       order  0 batch      1 alloc 353 free 213
order  0 batch      1 alloc 349 free 210       order  0 batch      1 alloc 334 free 200
order  0 batch      1 alloc 350 free 207       order  0 batch      1 alloc 328 free 194
order  0 batch      1 alloc 402 free 229       order  0 batch      1 alloc 406 free 202
order  0 batch      1 alloc 329 free 188       order  0 batch      1 alloc 333 free 188
order  0 batch      1 alloc 310 free 182       order  0 batch      1 alloc 318 free 188
order  0 batch      1 alloc 307 free 180       order  0 batch      1 alloc 319 free 186
order  0 batch      1 alloc 304 free 180       order  0 batch      1 alloc 320 free 183
order  0 batch      1 alloc 307 free 180       order  0 batch      1 alloc 317 free 185
order  0 batch      1 alloc 827 free 479       order  0 batch      1 alloc 667 free 375
order  0 batch      1 alloc 389 free 228       order  0 batch      1 alloc 479 free 276
order  0 batch      1 alloc 509 free 256       order  0 batch      1 alloc 599 free 294
order  0 batch      1 alloc 338 free 204       order  0 batch      1 alloc 412 free 243
order  0 batch      1 alloc 331 free 194       order  0 batch      1 alloc 376 free 227
order  0 batch      1 alloc 318 free 189       order  0 batch      1 alloc 363 free 211
order  0 batch      1 alloc 305 free 180       order  0 batch      1 alloc 343 free 204
order  0 batch      1 alloc 307 free 191       order  0 batch      1 alloc 332 free 200
order  0 batch      1 alloc 304 free 180       order  0 batch      1 alloc 415 free 206
order  0 batch      1 alloc 351 free 195       order  0 batch      1 alloc 328 free 199
order  0 batch      1 alloc 351 free 193       order  0 batch      1 alloc 321 free 185
order  0 batch      1 alloc 315 free 184       order  0 batch      1 alloc 318 free 185
order  0 batch      1 alloc 317 free 194       order  0 batch      1 alloc 319 free 193
order  0 batch      1 alloc 298 free 179       order  0 batch      1 alloc 323 free 187
order  0 batch      1 alloc 293 free 175       order  0 batch      1 alloc 324 free 184

TBH, I can't see any meaningful difference here, but it might
depend on hardware, of course. As most of the allocations are
order 0, and all other nearby counters are not so hot,
the cache footprint increase should be not so important.

Anyway, I've added a config option.

Thanks!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
