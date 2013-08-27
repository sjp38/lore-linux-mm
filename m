Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id C684E6B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 21:34:30 -0400 (EDT)
Date: Mon, 26 Aug 2013 21:34:13 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1377567253-wwcptjmf-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <521bfe37.83892b0a.1b94.2e7cSMTPIN_ADDED_BROKEN@mx.google.com>
References: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377506774-5377-8-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377531937-15nx3q8e-mutt-n-horiguchi@ah.jp.nec.com>
 <20130826232604.GA12498@hacker.(null)>
 <1377562349-97tgdeoj-mutt-n-horiguchi@ah.jp.nec.com>
 <521bf0fc.4950320a.76ab.0f2dSMTPIN_ADDED_BROKEN@mx.google.com>
 <1377564414-igez3xdx-mutt-n-horiguchi@ah.jp.nec.com>
 <521bfe37.83892b0a.1b94.2e7cSMTPIN_ADDED_BROKEN@mx.google.com>
Subject: Re: [PATCH v4 8/10] mm/hwpoison: fix memory failure still hold
 reference count after unpoison empty zero page
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, ong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 27, 2013 at 09:17:29AM +0800, Wanpeng Li wrote:
> On Mon, Aug 26, 2013 at 08:46:54PM -0400, Naoya Horiguchi wrote:
> >On Tue, Aug 27, 2013 at 08:21:05AM +0800, Wanpeng Li wrote:
> >> Hi Naoya,
> >> On Mon, Aug 26, 2013 at 08:12:29PM -0400, Naoya Horiguchi wrote:
> >> >Hi Wanpeng,
> >> >
> >> >On Tue, Aug 27, 2013 at 07:26:04AM +0800, Wanpeng Li wrote:
> >> >> Hi Naoya,
> >> >> On Mon, Aug 26, 2013 at 11:45:37AM -0400, Naoya Horiguchi wrote:
> >> >> >On Mon, Aug 26, 2013 at 04:46:12PM +0800, Wanpeng Li wrote:
> >> >> >> madvise hwpoison inject will poison the read-only empty zero page if there is 
> >> >> >> no write access before poison. Empty zero page reference count will be increased 
> >> >> >> for hwpoison, subsequent poison zero page will return directly since page has
> >> >> >> already been set PG_hwpoison, however, page reference count is still increased 
> >> >> >> by get_user_pages_fast. The unpoison process will unpoison the empty zero page 
> >> >> >> and decrease the reference count successfully for the fist time, however, 
> >> >> >> subsequent unpoison empty zero page will return directly since page has already 
> >> >> >> been unpoisoned and without decrease the page reference count of empty zero page.
> >> >> >> This patch fix it by decrease page reference count for empty zero page which has 
> >> >> >> already been unpoisoned and page count > 1.
> >> >> >
> >> >> >I guess that fixing on the madvise side looks reasonable to me, because this
> >> >> >refcount mismatch happens only when we poison with madvise(). The root cause
> >> >> >is that we can get refcount multiple times on a page, even if memory_failure()
> >> >> >or soft_offline_page() can do its work only once.
> >> >> >
> >> >> 
> >> >> I think this just happen in read-only before poison case against empty
> >> >> zero page. 
> >> >
> >> >OK. I agree.
> >> >
> >> >> Hi Andrew,
> >> >> 
> >> >> I see you have already merged the patch, which method you prefer? 
> >> >>
> >> >> >How about making madvise_hwpoison() put a page and return immediately
> >> >> >(without calling memory_failure() or soft_offline_page()) when the page
> >> >> >is already hwpoisoned? 
> >> >> >I hope it also helps us avoid meaningless printk flood.
> >> >> >
> >> >> 
> >> >> Btw, Naoya, how about patch 10/10, any input are welcome! ;-)
> >> >
> >> >No objection if you (and Andrew) decide to go with current approach.
> >> 
> >> Andrew prefer your method, I will resend the patch w/ your suggested-by. ;-)
> >
> >Thanks you :)
> >
> >> >But I think that if we shift to fix this problem in madvise(),
> >> >we don't need 10/10 any more. So it looks simpler to me.
> >> 
> >> I don't think it's same issue. There is just one page in my test case.
> >> #define PAGES_TO_TEST 1
> >> If I miss something?
> >
> >Ah, OK.
> 
> I complete do it in madvise codes, however, the bug mentioned in patch
> 10/10 is still there. ;-)
> 
> >
> >BTW, in my understanding, zero pages are not exist physically (I mean that
> >no real page is allocated to store 4096 bytes of 0.) So there can't happen
> >any real MCE SRAO on zero page. So one possible solution might be that we
> >completely ignore all of madvise(MADV_HWPOISON) over zero pages.
> 
> What's the userland visible difference against mmap w/o write access before poison 
> you expect?

In this case the userland is a test program like mce-test, so my expectation
is that the test program shouldn't detect false test failures when it
accidentally calls madvise(MADV_HWPOISON) on zero pages, because there's no
real test target associated with such testcases. So I think just returning
with success return code without doing anything looks good.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
