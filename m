Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 6BBAE6B0002
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 10:11:03 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 17 Apr 2013 00:01:58 +1000
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [9.190.234.17])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 55EA12CE8053
	for <linux-mm@kvack.org>; Wed, 17 Apr 2013 00:10:55 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3GAQiY58847694
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 20:26:44 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3GAQgHp012304
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 20:26:43 +1000
Message-ID: <516D275C.8040406@linux.vnet.ibm.com>
Date: Tue, 16 Apr 2013 18:26:36 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: mmu_notifier: re-fix freed page still mapped in secondary
 MMU
References: <516CF235.4060103@linux.vnet.ibm.com> <20130416093131.GJ3658@sgi.com>
In-Reply-To: <20130416093131.GJ3658@sgi.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Avi Kivity <avi.kivity@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On 04/16/2013 05:31 PM, Robin Holt wrote:
> On Tue, Apr 16, 2013 at 02:39:49PM +0800, Xiao Guangrong wrote:
>> The commit 751efd8610d3 (mmu_notifier_unregister NULL Pointer deref
>> and multiple ->release()) breaks the fix:
>>     3ad3d901bbcfb15a5e4690e55350db0899095a68
>>     (mm: mmu_notifier: fix freed page still mapped in secondary MMU)
> 
> Can you describe how the page is still mapped?  I thought I had all
> cases covered.  Whichever call hits first, I thought we had one callout
> to the registered notifiers.  Are you saying we need multiple callouts?

No.

You patch did this:

                hlist_del_init_rcu(&mn->hlist);    1 <======
+               spin_unlock(&mm->mmu_notifier_mm->lock);
+
+               /*
+                * Clear sptes. (see 'release' description in mmu_notifier.h)
+                */
+               if (mn->ops->release)
+                       mn->ops->release(mn, mm);    2 <======
+
+               spin_lock(&mm->mmu_notifier_mm->lock);

At point 1, you delete the notify, but the page is still on LRU. Other
cpu can reclaim the page but without call ->invalid_page().

At point 2, you call ->release(), the secondary MMU make page Accessed/Dirty
but that page has already been on the free-list of page-alloctor.

> 
> Also, shouldn't you be asking for a revert commit and then supply a
> subsequent commit for the real fix?  I thought that was the process for
> doing a revert.

Can not do that pure reversion since your patch moved hlist_for_each_entry_rcu
which has been modified now.

Should i do pure-eversion + hlist_for_each_entry_rcu update first?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
