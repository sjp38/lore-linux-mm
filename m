Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id F325D6B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 19:32:45 -0400 (EDT)
Date: Mon, 26 Aug 2013 16:31:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 8/10] mm/hwpoison: fix memory failure still hold
 reference count after unpoison empty zero page
Message-Id: <20130826163150.72bb773c.akpm@linux-foundation.org>
In-Reply-To: <521be416.a5e8420a.6786.09d1SMTPIN_ADDED_BROKEN@mx.google.com>
References: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
	<1377506774-5377-8-git-send-email-liwanp@linux.vnet.ibm.com>
	<1377531937-15nx3q8e-mutt-n-horiguchi@ah.jp.nec.com>
	<521be416.a5e8420a.6786.09d1SMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 27 Aug 2013 07:26:04 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:

> Hi Naoya,
> On Mon, Aug 26, 2013 at 11:45:37AM -0400, Naoya Horiguchi wrote:
> >On Mon, Aug 26, 2013 at 04:46:12PM +0800, Wanpeng Li wrote:
> >> madvise hwpoison inject will poison the read-only empty zero page if there is 
> >> no write access before poison. Empty zero page reference count will be increased 
> >> for hwpoison, subsequent poison zero page will return directly since page has
> >> already been set PG_hwpoison, however, page reference count is still increased 
> >> by get_user_pages_fast. The unpoison process will unpoison the empty zero page 
> >> and decrease the reference count successfully for the fist time, however, 
> >> subsequent unpoison empty zero page will return directly since page has already 
> >> been unpoisoned and without decrease the page reference count of empty zero page.
> >> This patch fix it by decrease page reference count for empty zero page which has 
> >> already been unpoisoned and page count > 1.
> >
> >I guess that fixing on the madvise side looks reasonable to me, because this
> >refcount mismatch happens only when we poison with madvise(). The root cause
> >is that we can get refcount multiple times on a page, even if memory_failure()
> >or soft_offline_page() can do its work only once.
> >
> 
> I think this just happen in read-only before poison case against empty
> zero page. 
> 
> Hi Andrew,
> 
> I see you have already merged the patch, which method you prefer? 
> 

Addressing it within the madvise code does sound more appropriate.  The
change which
mm-hwpoison-fix-memory-failure-still-holding-reference-count-after-unpoisoning-empty-zero-page.patch
makes is pretty darn strange-looking at at least needs a comment
telling people what it's doing, and why.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
