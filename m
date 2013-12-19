Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6AA4B6B0039
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 20:12:59 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id kl14so429244pab.33
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 17:12:59 -0800 (PST)
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com. [202.81.31.140])
        by mx.google.com with ESMTPS id ye6si1288717pbc.140.2013.12.18.17.12.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 17:12:58 -0800 (PST)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 19 Dec 2013 11:12:54 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 68B763578050
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 12:12:52 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBJ0sLMa60293344
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 11:54:21 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBJ1CpsM003223
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 12:12:51 +1100
Date: Thu, 19 Dec 2013 09:12:49 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/rmap: fix BUG at rmap_walk
Message-ID: <52b2481a.86f7440a.60bb.ffffe762SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1387412195-26498-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20131218162858.6ec808c067baf4644532e110@linux-foundation.org>
 <20131219005805.GA25161@lge.com>
 <20131218170429.0858bb069d51a469e8c237d8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131218170429.0858bb069d51a469e8c237d8@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrew,
On Wed, Dec 18, 2013 at 05:04:29PM -0800, Andrew Morton wrote:
>On Thu, 19 Dec 2013 09:58:05 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
>
>> On Wed, Dec 18, 2013 at 04:28:58PM -0800, Andrew Morton wrote:
>> > On Thu, 19 Dec 2013 08:16:35 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
>> > 
>> > > page_get_anon_vma() called in page_referenced_anon() will lock and 
>> > > increase the refcount of anon_vma, page won't be locked for anonymous 
>> > > page. This patch fix it by skip check anonymous page locked.
>> > > 
>> > > [  588.698828] kernel BUG at mm/rmap.c:1663!
>> > 
>> > Why is all this suddenly happening.  Did we change something, or did a
>> > new test get added to trinity?
>> 
>> It is my fault.
>> I should remove this VM_BUG_ON() since rmap_walk() can be called
>> without holding PageLock() in this case.
>> 
>> I think that adding VM_BUG_ON() to each rmap_walk calllers is better
>> than this patch, because, now, rmap_walk() is called by many places and
>> each places has different contexts.
>
>I don't think that putting the assertion into the caller makes a lot of
>sense, particularly if that code just did a lock_page()!  If a *callee*
>needs PageLocked() then that callee should assert that the page is
>locked.  So
>
>	VM_BUG_ON(!PageLocked(page));
>
>means "this code requires that the page be locked".  And if that code
>requires PageLocked(), there must be reasons for this.  Let's also
>include an explanation of those reasons.

I will add this check and explanation to the callee rmap_one hook of 
rmap_walk_control and send another version of the patch. ;-)

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
