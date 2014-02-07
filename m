Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id ABF566B0031
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 17:01:04 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so1796221eae.5
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 14:01:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 43si10731947eeh.73.2014.02.07.14.01.02
        for <linux-mm@kvack.org>;
        Fri, 07 Feb 2014 14:01:03 -0800 (PST)
Date: Fri, 07 Feb 2014 17:00:19 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <52f5579f.c3030e0a.4440.3f94SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <20140207134329.a305b169351a2538ab03785f@linux-foundation.org>
References: <52f54d29.89cfe00a.4277.4d3dSMTPIN_ADDED_BROKEN@mx.google.com>
 <20140207134329.a305b169351a2538ab03785f@linux-foundation.org>
Subject: Re: [PATCH] mm/memory-failure.c: move refcount only in
 !MF_COUNT_INCREASED
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Feb 07, 2014 at 01:43:29PM -0800, Andrew Morton wrote:
> On Fri, 07 Feb 2014 16:16:04 -0500 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > # Resending due to sending failure. Sorry if you received twice.
> > ---
> > mce-test detected a test failure when injecting error to a thp tail page.
> > This is because we take page refcount of the tail page in madvise_hwpoison()
> > while the fix in commit a3e0f9e47d5e ("mm/memory-failure.c: transfer page
> > count from head page to tail page after split thp") assumes that we always
> > take refcount on the head page.
> > 
> > When a real memory error happens we take refcount on the head page where
> > memory_failure() is called without MF_COUNT_INCREASED set, so it seems to me
> > that testing memory error on thp tail page using madvise makes little sense.
> > 
> > This patch cancels moving refcount in !MF_COUNT_INCREASED for valid testing.
> > 
> > ...
> >
> > --- v3.14-rc1.orig/mm/memory-failure.c
> > +++ v3.14-rc1/mm/memory-failure.c
> > @@ -1042,8 +1042,10 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
> >  			 * to it. Similarly, page lock is shifted.
> >  			 */
> >  			if (hpage != p) {
> > -				put_page(hpage);
> > -				get_page(p);
> > +				if (!(flags && MF_COUNT_INCREASED)) {
> 
> s/&&/&/
> 
> Please carefully retest this, make sure that both cases are covered?

Sorry for silly mistake, flags is MF_COUNT_INCREASED from madvise()
and 0 from /sys/devices/system/memory/soft_offline_page, so the above
logic accidentally made no difference from the correct one in comparing
with these two cases.

I retested it and confirmed that replaced one fixes the problem.

Thanks,
Naoya
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Fri, 7 Feb 2014 06:33:30 -0500
Subject: [PATCH v2] mm/memory-failure.c: move refcount only in
 !MF_COUNT_INCREASED

mce-test detected a test failure when injecting error to a thp tail page.
This is because we take page refcount of the tail page in madvise_hwpoison()
while the fix in commit a3e0f9e47d5e ("mm/memory-failure.c: transfer page
count from head page to tail page after split thp") assumes that we always
take refcount on the head page.

When a real memory error happens we take refcount on the head page where
memory_failure() is called without MF_COUNT_INCREASED set, so it seems to me
that testing memory error on thp tail page using madvise makes little sense.

This patch cancels moving refcount in !MF_COUNT_INCREASED for valid testing.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org # 3.9+: a3e0f9e47d5e
---
 mm/memory-failure.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index ab55d489eb05..b68d14d59784 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1042,8 +1042,10 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
 			 * to it. Similarly, page lock is shifted.
 			 */
 			if (hpage != p) {
-				put_page(hpage);
-				get_page(p);
+				if (!(flags & MF_COUNT_INCREASED)) {
+					put_page(hpage);
+					get_page(p);
+				}
 				lock_page(p);
 				unlock_page(hpage);
 				*hpagep = p;
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
