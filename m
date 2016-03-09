Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id A90DA6B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 00:22:37 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id td3so3435474pab.2
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 21:22:37 -0800 (PST)
Received: from www9186uo.sakura.ne.jp (153.121.56.200.v6.sakura.ne.jp. [2001:e42:102:1109:153:121:56:200])
        by mx.google.com with ESMTP id yo8si1683320pac.27.2016.03.08.21.22.36
        for <linux-mm@kvack.org>;
        Tue, 08 Mar 2016 21:22:36 -0800 (PST)
Date: Wed, 9 Mar 2016 14:22:35 +0900
From: Naoya Horiguchi <nao.horiguchi@gmail.com>
Subject: Re: [PATCH v1] tools/vm/page-types.c: remove memset() in walk_pfn()
Message-ID: <20160309052235.GA28231@www9186uo.sakura.ne.jp>
References: <1457401652-9226-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <CALYGNiPgBRuZoi8nA-JQCxx-RGiXE9g-dfeeysvH0Rp2VAYz2A@mail.gmail.com>
 <20160308055834.GA9987@hori1.linux.bs1.fc.nec.co.jp>
 <CALYGNiPSHuZNgh33zy3KWrt0Y0Mt35HPeRxGPCZctO9aMQ=6Ow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <CALYGNiPSHuZNgh33zy3KWrt0Y0Mt35HPeRxGPCZctO9aMQ=6Ow@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Mar 09, 2016 at 07:28:21AM +0300, Konstantin Khlebnikov wrote:
> On Tue, Mar 8, 2016 at 8:58 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > On Tue, Mar 08, 2016 at 08:12:09AM +0300, Konstantin Khlebnikov wrote:
> >> On Tue, Mar 8, 2016 at 4:47 AM, Naoya Horiguchi
> >> <n-horiguchi@ah.jp.nec.com> wrote:
> >> > I found that page-types is very slow and my testing shows many timeout errors.
> >> > Here's an example with a simple program allocating 1000 thps.
> >> >
> >> >   $ time ./page-types -p $(pgrep -f test_alloc)
> >> >   ...
> >> >   real    0m17.201s
> >> >   user    0m16.889s
> >> >   sys     0m0.312s
> >> >
> >> >   $ time ./page-types.patched -p $(pgrep -f test_alloc)
> >> >   ...
> >> >   real    0m0.182s
> >> >   user    0m0.046s
> >> >   sys     0m0.135s
> >> >
> >> > Most of time is spent in memset(), which isn't necessary because we check
> >> > that the return of kpagecgroup_read() is equal to pages and uninitialized
> >> > memory is never used. So we can drop this memset().
> >>
> >> These zeros are used in show_page_range() - for merging pages into ranges.
> >
> > Hi Konstantin,
> >
> > Thank you for the response. The below code does solve the problem, so that's fine.
> >
> > But I don't understand how the zeros are used. show_page_range() is called
> > via add_page() which is called for i=0 to i=pages-1, and the buffer cgi is
> > already filled for the range [i, pages-1] by kpagecgroup_read(), so even if
> > without zero initialization, kpagecgroup_read() properly fills zeros, right?
> > IOW, is there any problem if we don't do this zero initialization?
> 
> kpagecgroup_read() reads only if kpagecgroup were opened,
> /proc/kpagecgroup might even not exist. Probably it's better to fill
> them with zeros here.
> Pre-memset was an optimization - it fills buffer only once instead on
> each kpagecgroup_read() call.

Ah, OK.

So here's ver.2.

Thanks,
Naoya
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2] tools/vm/page-types.c: avoid memset() in walk_pfn() when count == 1

I found that page-types is very slow and my testing shows many timeout errors.
Here's an example with a simple program allocating 1000 thps.

  $ time ./page-types -p $(pgrep -f test_alloc)
  ...
  real    0m17.201s
  user    0m16.889s
  sys     0m0.312s

Most of time is spent in memset(). Currently memset() clears over whole buffer
for every walk_pfn() call, which is inefficient when walk_pfn() is called from
walk_vma(), because in that case walk_pfn() is called for each pfn.
So this patch limits the zero initialization only for the first element.

  $ time ./page-types.patched -p $(pgrep -f test_alloc)
  ...
  real    0m0.182s
  user    0m0.046s
  sys     0m0.135s

Fixes: 954e95584579 ("tools/vm/page-types.c: add memory cgroup dumping and filtering")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Suggested-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 tools/vm/page-types.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
index dab61c377f54..e92903fc7113 100644
--- a/tools/vm/page-types.c
+++ b/tools/vm/page-types.c
@@ -633,7 +633,15 @@ static void walk_pfn(unsigned long voffset,
 	unsigned long pages;
 	unsigned long i;
 
-	memset(cgi, 0, sizeof cgi);
+	/*
+	 * kpagecgroup_read() reads only if kpagecgroup were opened, but
+	 * /proc/kpagecgroup might even not exist, so it's better to fill
+	 * them with zeros here.
+	 */
+	if (count == 1)
+		cgi[0] = 0;
+	else
+		memset(cgi, 0, sizeof cgi);
 
 	while (count) {
 		batch = min_t(unsigned long, count, KPAGEFLAGS_BATCH);
-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
