Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id E0AB96B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 16:05:35 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e190so117922956pfe.3
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:05:35 -0700 (PDT)
Received: from mail-pf0-f193.google.com (mail-pf0-f193.google.com. [209.85.192.193])
        by mx.google.com with ESMTPS id 15si5645927pfw.133.2016.04.27.13.05.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 13:05:34 -0700 (PDT)
Received: by mail-pf0-f193.google.com with SMTP id r187so6886974pfr.2
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 13:05:34 -0700 (PDT)
Date: Wed, 27 Apr 2016 22:05:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: add PF_MEMALLOC_NOFS
Message-ID: <20160427200530.GB22544@dhcp22.suse.cz>
References: <1461671772-1269-1-git-send-email-mhocko@kernel.org>
 <1461671772-1269-2-git-send-email-mhocko@kernel.org>
 <32e220de-6028-a32c-e6a5-6935b97d277d@I-love.SAKURA.ne.jp>
 <20160427111555.GJ2179@dhcp22.suse.cz>
 <201604272344.JHJ05701.JFSQtLHFOOMVOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604272344.JHJ05701.JFSQtLHFOOMVOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, david@fromorbit.com, tytso@mit.edu, clm@fb.com, jack@suse.cz, linux-kernel@vger.kernel.org, zohar@linux.vnet.ibm.com

On Wed 27-04-16 23:44:35, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 27-04-16 19:53:21, Tetsuo Handa wrote:
> > [...]
> > > > Let's hope that filesystems will drop direct GFP_NOFS (resp. ~__GFP_FS)
> > > > usage as much and possible and only use a properly documented
> > > > memalloc_nofs_{save,restore} checkpoints where they are appropriate.
> > > 
> > > Is the story simple enough to monotonically replace GFP_NOFS/GFP_NOIO
> > > with GFP_KERNEL after memalloc_no{fs,io}_{save,restore} are inserted?
> > > We sometimes delegate some operations to somebody else. Don't we need to
> > > convey PF_MEMALLOC_NOFS/PF_MEMALLOC_NOIO flags to APIs which interact with
> > > other threads?
> > 
> > We can add an api to do that if that is really needed.
> > 
> 
> I'm not familiar with integrity subsystem.
> But if call traces shown below is possible and evm_verify_hmac() is called from
> genuine GFP_NOFS context, we are currently using GFP_KERNEL incorrectly.
> Therefore, inserting memalloc_nofs_{save,restore} would avoid possible memory
> reclaim deadlock by __GFP_FS.

I am not familiar with this code as well but you are definitely right
that scope GFP_NOFS would be better. I have a suspicious that NOFS is
used here improperly and it just copies the same gfp mask used for
all allocations in the same file without any good reason.

This would be a question for Mimi. Could you clarify please?

> ----------
> static enum integrity_status evm_verify_hmac(struct dentry *dentry, const char *xattr_name, char *xattr_value, size_t xattr_value_len, struct integrity_iint_cache *iint) {
>   rc = vfs_getxattr_alloc(dentry, XATTR_NAME_EVM, (char **)&xattr_data, 0, GFP_NOFS); /***** GFP_NOFS is used here. *****/
>   rc = integrity_digsig_verify(INTEGRITY_KEYRING_EVM, (const char *)xattr_data, xattr_len, calc.digest, sizeof(calc.digest)) {
>     keyring[id] = request_key(&key_type_keyring, keyring_name[id], NULL) {
>       key = request_key_and_link(type, description, callout_info, callout_len, NULL, NULL, KEY_ALLOC_IN_QUOTA) {
>         key = construct_key_and_link(&ctx, callout_info, callout_len, aux, dest_keyring, flags) {
>           ret = construct_alloc_key(ctx, dest_keyring, flags, user, &key) {
>             key = key_alloc(ctx->index_key.type, ctx->index_key.description, ctx->cred->fsuid, ctx->cred->fsgid, ctx->cred, perm, flags) {
>               key = kmem_cache_zalloc(key_jar, GFP_KERNEL); /***** Needs to use GFP_NOFS here if above GFP_NOFS usage is correct. *****/
>             }
>           }
>           ret = construct_key(key, callout_info, callout_len, aux, dest_keyring) {
>             cons = kmalloc(sizeof(*cons), GFP_KERNEL); /***** Ditto. *****/
>             actor = call_sbin_request_key;
>             ret = actor(cons, "create", aux) {
>               ret = call_usermodehelper_keys(argv[0], argv, envp, keyring, UMH_WAIT_PROC) {
>                 info = call_usermodehelper_setup(path, argv, envp, GFP_KERNEL, umh_keys_init, umh_keys_cleanup, session_keyring); /***** Ditto. *****/
>                 return call_usermodehelper_exec(info, wait) {
>                   queue_work(system_unbound_wq, &sub_info->work); /***** Queuing a GFP_NOFS work item here if above GFP_NOFS usage is correct. *****/
>                   wait_for_completion(&done); /***** But kworker uses GFP_KERNEL to create process for executing userspace program. *****/
>                 }
>               }
>             }
>           }
>         }
>       }
>     }
>   }
> }
> ----------
> 
> But there is a path where evm_verify_hmac() calls usermode helper.
> If evm_verify_hmac() calls usermode helper from genuine GFP_NOFS context,
> we will be still failing to tell kworker to use GFP_NOFS.

This would be a terrible thing to do. Because ...

> More problematic thing might be that we queue both GFP_KERNEL work item
> and GFP_NOFS work item into the same work queue. This means that the
> kworker will try __GFP_FS reclaim if current GFP_KERNEL work item
> and be blocked on a fs lock held by next GFP_NOFS work item. Then, simply
> conveying PF_MEMALLOC_NOFS/PF_MEMALLOC_NOIO flags to other threads is not
> sufficient, and we need to create separate workqueues (and respective
> consumers) for GFP_KERNEL work items and GFP_NOFS work items?

... of this very reason. If some GFP_NOFS code path relies on kworkers
and wait for the work synchronously then it really has to make sure that
the WQ has a rescuer and there are no __GFP_FS allocation requeuests
enqueued on the same WQ.

> (Or we have no such problem because khelper_wq was replaced with
> system_unbound_wq ?)

I do not think so. system_unbound_wq still depends to have some workers
and that might be not true under memory pressure.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
