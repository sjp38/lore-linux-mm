Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B2CCD6B0333
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 16:34:56 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 187so6259852itk.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 13:34:56 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g14si20235ioe.11.2017.03.23.13.34.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 13:34:55 -0700 (PDT)
Subject: Re: security, hugetlbfs: write to user memory in
 hugetlbfs_destroy_inode
References: <CACT4Y+Z1eodoxayi1qP-x05UoQ3nscXYUwA3UTN8ypOHfGJwjg@mail.gmail.com>
 <CACT4Y+ZHqNYPE_uMrc1NwX3Rb1FXYoN47D4eJFn=T07bSQ7YEw@mail.gmail.com>
 <201703232249.CCF09362.LVtHFOFFOMOQJS@I-love.SAKURA.ne.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <844751a3-f77b-4319-a908-6f7237536812@oracle.com>
Date: Thu, 23 Mar 2017 13:34:35 -0700
MIME-Version: 1.0
In-Reply-To: <201703232249.CCF09362.LVtHFOFFOMOQJS@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, dvyukov@google.com, nyc@holomorphy.com, linux-kernel@vger.kernel.org, paul@paul-moore.com, sds@tycho.nsa.gov, eparis@parisplace.org, james.l.morris@oracle.com, serge@hallyn.com, keescook@chromium.org, anton@enomsg.org, ccross@android.com, tony.luck@intel.com, selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org, linux-mm@kvack.org
Cc: syzkaller@googlegroups.com

On 03/23/2017 06:49 AM, Tetsuo Handa wrote:
> Dmitry Vyukov wrote:
>> On Thu, Mar 23, 2017 at 2:06 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>> Hello,
>>>
>>> I've got the following report while running syzkaller fuzzer on
>>> 093b995e3b55a0ae0670226ddfcb05bfbf0099ae. Note the preceding injected
>>> kmalloc failure in inode_alloc_security, most likely it's the root
>>> cause.
> 
> I don't think inode_alloc_security() failure is the root cause.
> I think this is a bug in hugetlbfs or mm part.
> 
> If inode_alloc_security() fails, inode->i_security remains NULL
> which was initialized to NULL at security_inode_alloc(). Thus,
> security_inode_alloc() is irrelevant to this problem.
> 
> inode_init_always() returned -ENOMEM due to fault injection and
> 
> 	if (unlikely(inode_init_always(sb, inode))) {
> 		if (inode->i_sb->s_op->destroy_inode)
> 			inode->i_sb->s_op->destroy_inode(inode);
> 		else
> 			kmem_cache_free(inode_cachep, inode);
> 		return NULL;
> 	}
> 
> hugetlbfs_destroy_inode() was called via inode->i_sb->s_op->destroy_inode()
> when inode initialization failed
> 
> static void hugetlbfs_destroy_inode(struct inode *inode)
> {
> 	hugetlbfs_inc_free_inodes(HUGETLBFS_SB(inode->i_sb));
> 	mpol_free_shared_policy(&HUGETLBFS_I(inode)->policy);
> 	call_rcu(&inode->i_rcu, hugetlbfs_i_callback);
> }
> 
> but mpol_shared_policy_init() is called only when new_inode() succeeds.
> 
> 	inode = new_inode(sb);
> 	if (inode) {
> (...snipped...)
> 		info = HUGETLBFS_I(inode);
> 		/*
> 		 * The policy is initialized here even if we are creating a
> 		 * private inode because initialization simply creates an
> 		 * an empty rb tree and calls rwlock_init(), later when we
> 		 * call mpol_free_shared_policy() it will just return because
> 		 * the rb tree will still be empty.
> 		 */
> 		mpol_shared_policy_init(&info->policy, NULL);
> 

Thank you for analysis (and Dmitry for reporting).

This certainly does look like a hugetlbfs bug.  I will put together a
patch to fix.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
