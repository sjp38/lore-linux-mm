Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id BBAFE6B0069
	for <linux-mm@kvack.org>; Wed, 16 Jan 2013 21:45:46 -0500 (EST)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Thu, 17 Jan 2013 08:14:35 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 9DE79125804C
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 08:15:54 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0H2jXIB46792886
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 08:15:34 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0H2jYSx018393
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 13:45:34 +1100
Message-ID: <50F765CC.9040608@linux.vnet.ibm.com>
Date: Thu, 17 Jan 2013 10:45:32 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] [Patch] mmu_notifier_unregister NULL Pointer deref fix.
References: <20130115162956.GH3438@sgi.com> <20130116200018.GA3460@sgi.com> <20130116210124.GB3460@sgi.com>
In-Reply-To: <20130116210124.GB3460@sgi.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hughd@google.com>, Marcelo Tosatti <mtosatti@redhat.com>, Sagi Grimberg <sagig@mellanox.co.il>, Haggai Eran <haggaie@mellanox.com>

On 01/17/2013 05:01 AM, Robin Holt wrote:
> 
> There is a race condition between mmu_notifier_unregister() and
> __mmu_notifier_release().
> 
> Assume two tasks, one calling mmu_notifier_unregister() as a result
> of a filp_close() ->flush() callout (task A), and the other calling
> mmu_notifier_release() from an mmput() (task B).
> 
>                 A                               B
> t1                                              srcu_read_lock()
> t2              if (!hlist_unhashed())
> t3                                              srcu_read_unlock()
> t4              srcu_read_lock()
> t5                                              hlist_del_init_rcu()
> t6                                              synchronize_srcu()
> t7              srcu_read_unlock()
> t8              hlist_del_rcu()  <--- NULL pointer deref.

The detailed code here is:
	hlist_del_rcu(&mn->hlist);

Can mn be NULL? I do not think so since mn is always the embedded struct
of the caller, it be freed after calling mmu_notifier_unregister.

> 
> Tested with this patch applied.  My test case which was failing
> approximately every 300th iteration passed 25,000 tests.

Could you please share your test case?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
