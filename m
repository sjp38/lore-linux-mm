Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7FA6B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 19:57:06 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id ma3so403880pbc.26
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 16:57:05 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id am2si1227401pad.328.2013.12.18.16.57.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 16:57:04 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 19 Dec 2013 06:27:01 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id D4E00E0053
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 06:29:25 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBJ0utfL56819920
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 06:26:55 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBJ0uwGT016629
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 06:26:58 +0530
Date: Thu, 19 Dec 2013 08:56:57 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/rmap: fix BUG at rmap_walk
Message-ID: <52b24460.02ff420a.5170.ffffc198SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1387412195-26498-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131218162858.6ec808c067baf4644532e110@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131218162858.6ec808c067baf4644532e110@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrew,
On Wed, Dec 18, 2013 at 04:28:58PM -0800, Andrew Morton wrote:
>On Thu, 19 Dec 2013 08:16:35 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>
>> page_get_anon_vma() called in page_referenced_anon() will lock and 
>> increase the refcount of anon_vma, page won't be locked for anonymous 
>> page. This patch fix it by skip check anonymous page locked.
>> 
>> [  588.698828] kernel BUG at mm/rmap.c:1663!
>
>Why is all this suddenly happening.  Did we change something, or did a
>new test get added to trinity?
>

They are introduced by Joonsoo's rmap_walk.

>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -1660,7 +1660,8 @@ done:
>>  
>>  int rmap_walk(struct page *page, struct rmap_walk_control *rwc)
>>  {
>> -	VM_BUG_ON(!PageLocked(page));
>> +	if (!PageAnon(page) || PageKsm(page))
>> +		VM_BUG_ON(!PageLocked(page));
>>  
>>  	if (unlikely(PageKsm(page)))
>>  		return rmap_walk_ksm(page, rwc);
>
>Is there any reason why rmap_walk_ksm() and rmap_walk_file() *need*
>PageLocked() whereas rmap_walk_anon() does not?  If so, let's implement
>it like this:

All callsites of rmap_walk() 

try_to_unmap() page should be lockecd (checked in rmap_walk()) 
try_to_munlock() pages should be locked (checked in try_to_munlock())
page_referenced() pages should be locked except anonymous page (checked in rmap_walk())
page_mkclean() pages should be locked (checked in page_mkclean())
remove_migration_ptes() pages should be locked (checked in rmap_walk())

We can move PageLocked(page) check to the callsites instead of in
rmap_walk() since anonymous page is not locked in page_referenced().

Regards,
Wanpeng Li 

>
>
>--- a/mm/rmap.c~a
>+++ a/mm/rmap.c
>@@ -1716,6 +1716,10 @@ static int rmap_walk_file(struct page *p
> 	struct vm_area_struct *vma;
> 	int ret = SWAP_AGAIN;
>
>+	/*
>+	 * page must be locked because <reason goes here>
>+	 */
>+	VM_BUG_ON(!PageLocked(page));
> 	if (!mapping)
> 		return ret;
> 	mutex_lock(&mapping->i_mmap_mutex);
>@@ -1737,8 +1741,6 @@ static int rmap_walk_file(struct page *p
> int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
> 		struct vm_area_struct *, unsigned long, void *), void *arg)
> {
>-	VM_BUG_ON(!PageLocked(page));
>-
> 	if (unlikely(PageKsm(page)))
> 		return rmap_walk_ksm(page, rmap_one, arg);
> 	else if (PageAnon(page))
>--- a/mm/ksm.c~a
>+++ a/mm/ksm.c
>@@ -2006,6 +2006,9 @@ int rmap_walk_ksm(struct page *page, int
> 	int search_new_forks = 0;
>
> 	VM_BUG_ON(!PageKsm(page));
>+	/*
>+	 * page must be locked because <reason goes here>
>+	 */
> 	VM_BUG_ON(!PageLocked(page));
>
> 	stable_node = page_stable_node(page);
>
>
>Or if there is no reason why the page must be locked for
>rmap_walk_ksm() and rmap_walk_file(), let's just remove rmap_walk()'s
>VM_BUG_ON()?  And rmap_walk_ksm()'s as well - it's duplicative anyway.
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
