Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 414376B0033
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 17:34:17 -0400 (EDT)
Date: Tue, 27 Aug 2013 14:34:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 3/3] mm/hwpoison: fix return value of
 madvise_hwpoison
Message-Id: <20130827143415.fa284d67f0ae838079b5a5aa@linux-foundation.org>
In-Reply-To: <521c5ddd.c9fc440a.2724.ffff8c70SMTPIN_ADDED_BROKEN@mx.google.com>
References: <1377571171-9958-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<1377571171-9958-3-git-send-email-liwanp@linux.vnet.ibm.com>
	<1377574096-y8hxgzdw-mutt-n-horiguchi@ah.jp.nec.com>
	<521c1f3f.813d320a.6ba7.5a17SMTPIN_ADDED_BROKEN@mx.google.com>
	<1377574896-5k1diwl4-mutt-n-horiguchi@ah.jp.nec.com>
	<20130827073701.GA23035@gchen.bj.intel.com>
	<521c5ddd.c9fc440a.2724.ffff8c70SMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Chen Gong <gong.chen@linux.intel.com>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 27 Aug 2013 16:02:29 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:

> Hi Chen,
> On Tue, Aug 27, 2013 at 03:37:01AM -0400, Chen Gong wrote:
> >> On Tue, Aug 27, 2013 at 11:38:27AM +0800, Wanpeng Li wrote:
> >> > Hi Naoya,
> >> > On Mon, Aug 26, 2013 at 11:28:16PM -0400, Naoya Horiguchi wrote:
> >> > >On Tue, Aug 27, 2013 at 10:39:31AM +0800, Wanpeng Li wrote:
> >> > >> The return value outside for loop is always zero which means madvise_hwpoison 
> >> > >> return success, however, this is not truth for soft_offline_page w/ failure
> >> > >> return value.
> >> > >
> >> > >I don't understand what you want to do for what reason. Could you clarify
> >> > >those?
> >> > 
> >> > int ret is defined in two place in madvise_hwpoison. One is out of for
> >> > loop and its value is always zero(zero means success for madvise), the 
> >> > other one is in for loop. The soft_offline_page function maybe return 
> >> > -EBUSY and break, however, the ret out of for loop is return which means 
> >> > madvise_hwpoison success. 
> >> 
> >> Oh, I see. Thanks.
> >> 
> >I don't think such change is a good idea. The original code is obviously
> >easy to confuse people. Why not removing redundant local variable?
> >
> 
> I think the trick here is get_user_pages_fast will return the number of
> pages pinned. It is always 1 in madvise_hwpoison, the return value of 
> memory_failure is ignored. Therefore we still need to reset ret to 0 
> before return madvise_hwpoison. 

erk, madvise_hwpoison() has two locals with the same name.   Bad.


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm/madvise.c:madvise_hwpoison(): remove local `ret'

madvise_hwpoison() has two locals called "ret".  Fix it all up.

Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/madvise.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff -puN mm/madvise.c~a mm/madvise.c
--- a/mm/madvise.c~a
+++ a/mm/madvise.c
@@ -343,15 +343,16 @@ static long madvise_remove(struct vm_are
  */
 static int madvise_hwpoison(int bhv, unsigned long start, unsigned long end)
 {
-	int ret = 0;
-
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 	for (; start < end; start += PAGE_SIZE) {
 		struct page *p;
-		int ret = get_user_pages_fast(start, 1, 0, &p);
+		int ret;
+		
+		ret = get_user_pages_fast(start, 1, 0, &p);
 		if (ret != 1)
 			return ret;
+
 		if (PageHWPoison(p)) {
 			put_page(p);
 			continue;
@@ -369,7 +370,7 @@ static int madvise_hwpoison(int bhv, uns
 		/* Ignore return value for now */
 		memory_failure(page_to_pfn(p), 0, MF_COUNT_INCREASED);
 	}
-	return ret;
+	return 0;
 }
 #endif
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
