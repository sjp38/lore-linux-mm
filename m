Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id D43786B0313
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 10:43:56 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id 63so1982808otc.5
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 07:43:56 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id b16si97906oth.118.2017.06.26.07.43.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 07:43:55 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH 2/3] LSM: Convert security_hook_heads into explicit array of struct list_head
Date: Mon, 26 Jun 2017 17:41:15 +0300
Message-ID: <20170626144116.27599-3-igor.stoppa@huawei.com>
In-Reply-To: <20170626144116.27599-1-igor.stoppa@huawei.com>
References: <20170626144116.27599-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, labbott@redhat.com
Cc: penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, James Morris <james.l.morris@oracle.com>, Igor Stoppa <igor.stoppa@huawei.com>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Commit 3dfc9b02864b19f4 ("LSM: Initialize security_hook_heads upon
registration.") treats "struct security_hook_heads" as an implicit array
of "struct list_head" so that we can eliminate code for static
initialization. Although we haven't encountered compilers which do not
treat sizeof(security_hook_heads) != sizeof(struct list_head) *
(sizeof(security_hook_heads) / sizeof(struct list_head)), Casey does not
like the assumption that a structure of N elements can be assumed to be
the same as an array of N elements.

Now that Kees found that randstruct complains about such casting

  security/security.c: In function 'security_init':
  security/security.c:59:20: note: found mismatched op0 struct pointer
    types: 'struct list_head' and 'struct security_hook_heads'

    struct list_head *list = (struct list_head *) &security_hook_heads;

and Christoph thinks that we should fix it rather than make randstruct
whitelist it, this patch fixes it.

It would be possible to revert commit 3dfc9b02864b19f4, but this patch
converts security_hook_heads into an explicit array of struct list_head
by introducing an enum, due to reasons explained below.

Igor proposed a sealable memory allocator, and the LSM hooks
("struct security_hook_heads security_hook_heads" and
"struct security_hook_list ...[]") will benefit from that allocator via
protection using set_memory_ro()/set_memory_rw(), and that allocator
will remove CONFIG_SECURITY_WRITABLE_HOOKS config option. Thus, we will
likely be moving to that direction.

This means that these structures will be allocated at run time using
that allocator, and therefore the address of these structures will be
determined at run time rather than compile time.

But currently, LSM_HOOK_INIT() macro depends on the address of
security_hook_heads being known at compile time. If we use an enum
so that LSM_HOOK_INIT() macro does not need to know absolute address of
security_hook_heads, it will help us to use that allocator for LSM hooks.

As a result of introducing an enum, security_hook_heads becomes a local
variable. In order to pass 80 columns check by scripts/checkpatch.pl ,
rename security_hook_heads to hook_heads.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Rebased-by: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Paul Moore <paul@paul-moore.com>
Cc: Stephen Smalley <sds@tycho.nsa.gov>
Cc: Casey Schaufler <casey@schaufler-ca.com>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Christoph Hellwig <hch@infradead.org>
---
 include/linux/lsm_hooks.h | 420 +++++++++++++++++++++++-----------------------
 security/security.c       |  31 ++--
 2 files changed, 227 insertions(+), 224 deletions(-)

diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
index 3cc9d77..32f30fa 100644
--- a/include/linux/lsm_hooks.h
+++ b/include/linux/lsm_hooks.h
@@ -1694,225 +1694,226 @@ union security_list_options {
 #endif /* CONFIG_AUDIT */
 };
 
-struct security_hook_heads {
-	struct list_head binder_set_context_mgr;
-	struct list_head binder_transaction;
-	struct list_head binder_transfer_binder;
-	struct list_head binder_transfer_file;
-	struct list_head ptrace_access_check;
-	struct list_head ptrace_traceme;
-	struct list_head capget;
-	struct list_head capset;
-	struct list_head capable;
-	struct list_head quotactl;
-	struct list_head quota_on;
-	struct list_head syslog;
-	struct list_head settime;
-	struct list_head vm_enough_memory;
-	struct list_head bprm_set_creds;
-	struct list_head bprm_check_security;
-	struct list_head bprm_secureexec;
-	struct list_head bprm_committing_creds;
-	struct list_head bprm_committed_creds;
-	struct list_head sb_alloc_security;
-	struct list_head sb_free_security;
-	struct list_head sb_copy_data;
-	struct list_head sb_remount;
-	struct list_head sb_kern_mount;
-	struct list_head sb_show_options;
-	struct list_head sb_statfs;
-	struct list_head sb_mount;
-	struct list_head sb_umount;
-	struct list_head sb_pivotroot;
-	struct list_head sb_set_mnt_opts;
-	struct list_head sb_clone_mnt_opts;
-	struct list_head sb_parse_opts_str;
-	struct list_head dentry_init_security;
-	struct list_head dentry_create_files_as;
+enum security_hook_index {
+	LSM_binder_set_context_mgr,
+	LSM_binder_transaction,
+	LSM_binder_transfer_binder,
+	LSM_binder_transfer_file,
+	LSM_ptrace_access_check,
+	LSM_ptrace_traceme,
+	LSM_capget,
+	LSM_capset,
+	LSM_capable,
+	LSM_quotactl,
+	LSM_quota_on,
+	LSM_syslog,
+	LSM_settime,
+	LSM_vm_enough_memory,
+	LSM_bprm_set_creds,
+	LSM_bprm_check_security,
+	LSM_bprm_secureexec,
+	LSM_bprm_committing_creds,
+	LSM_bprm_committed_creds,
+	LSM_sb_alloc_security,
+	LSM_sb_free_security,
+	LSM_sb_copy_data,
+	LSM_sb_remount,
+	LSM_sb_kern_mount,
+	LSM_sb_show_options,
+	LSM_sb_statfs,
+	LSM_sb_mount,
+	LSM_sb_umount,
+	LSM_sb_pivotroot,
+	LSM_sb_set_mnt_opts,
+	LSM_sb_clone_mnt_opts,
+	LSM_sb_parse_opts_str,
+	LSM_dentry_init_security,
+	LSM_dentry_create_files_as,
 #ifdef CONFIG_SECURITY_PATH
-	struct list_head path_unlink;
-	struct list_head path_mkdir;
-	struct list_head path_rmdir;
-	struct list_head path_mknod;
-	struct list_head path_truncate;
-	struct list_head path_symlink;
-	struct list_head path_link;
-	struct list_head path_rename;
-	struct list_head path_chmod;
-	struct list_head path_chown;
-	struct list_head path_chroot;
+	LSM_path_unlink,
+	LSM_path_mkdir,
+	LSM_path_rmdir,
+	LSM_path_mknod,
+	LSM_path_truncate,
+	LSM_path_symlink,
+	LSM_path_link,
+	LSM_path_rename,
+	LSM_path_chmod,
+	LSM_path_chown,
+	LSM_path_chroot,
 #endif
-	struct list_head inode_alloc_security;
-	struct list_head inode_free_security;
-	struct list_head inode_init_security;
-	struct list_head inode_create;
-	struct list_head inode_link;
-	struct list_head inode_unlink;
-	struct list_head inode_symlink;
-	struct list_head inode_mkdir;
-	struct list_head inode_rmdir;
-	struct list_head inode_mknod;
-	struct list_head inode_rename;
-	struct list_head inode_readlink;
-	struct list_head inode_follow_link;
-	struct list_head inode_permission;
-	struct list_head inode_setattr;
-	struct list_head inode_getattr;
-	struct list_head inode_setxattr;
-	struct list_head inode_post_setxattr;
-	struct list_head inode_getxattr;
-	struct list_head inode_listxattr;
-	struct list_head inode_removexattr;
-	struct list_head inode_need_killpriv;
-	struct list_head inode_killpriv;
-	struct list_head inode_getsecurity;
-	struct list_head inode_setsecurity;
-	struct list_head inode_listsecurity;
-	struct list_head inode_getsecid;
-	struct list_head inode_copy_up;
-	struct list_head inode_copy_up_xattr;
-	struct list_head file_permission;
-	struct list_head file_alloc_security;
-	struct list_head file_free_security;
-	struct list_head file_ioctl;
-	struct list_head mmap_addr;
-	struct list_head mmap_file;
-	struct list_head file_mprotect;
-	struct list_head file_lock;
-	struct list_head file_fcntl;
-	struct list_head file_set_fowner;
-	struct list_head file_send_sigiotask;
-	struct list_head file_receive;
-	struct list_head file_open;
-	struct list_head task_create;
-	struct list_head task_alloc;
-	struct list_head task_free;
-	struct list_head cred_alloc_blank;
-	struct list_head cred_free;
-	struct list_head cred_prepare;
-	struct list_head cred_transfer;
-	struct list_head kernel_act_as;
-	struct list_head kernel_create_files_as;
-	struct list_head kernel_read_file;
-	struct list_head kernel_post_read_file;
-	struct list_head kernel_module_request;
-	struct list_head task_fix_setuid;
-	struct list_head task_setpgid;
-	struct list_head task_getpgid;
-	struct list_head task_getsid;
-	struct list_head task_getsecid;
-	struct list_head task_setnice;
-	struct list_head task_setioprio;
-	struct list_head task_getioprio;
-	struct list_head task_prlimit;
-	struct list_head task_setrlimit;
-	struct list_head task_setscheduler;
-	struct list_head task_getscheduler;
-	struct list_head task_movememory;
-	struct list_head task_kill;
-	struct list_head task_prctl;
-	struct list_head task_to_inode;
-	struct list_head ipc_permission;
-	struct list_head ipc_getsecid;
-	struct list_head msg_msg_alloc_security;
-	struct list_head msg_msg_free_security;
-	struct list_head msg_queue_alloc_security;
-	struct list_head msg_queue_free_security;
-	struct list_head msg_queue_associate;
-	struct list_head msg_queue_msgctl;
-	struct list_head msg_queue_msgsnd;
-	struct list_head msg_queue_msgrcv;
-	struct list_head shm_alloc_security;
-	struct list_head shm_free_security;
-	struct list_head shm_associate;
-	struct list_head shm_shmctl;
-	struct list_head shm_shmat;
-	struct list_head sem_alloc_security;
-	struct list_head sem_free_security;
-	struct list_head sem_associate;
-	struct list_head sem_semctl;
-	struct list_head sem_semop;
-	struct list_head netlink_send;
-	struct list_head d_instantiate;
-	struct list_head getprocattr;
-	struct list_head setprocattr;
-	struct list_head ismaclabel;
-	struct list_head secid_to_secctx;
-	struct list_head secctx_to_secid;
-	struct list_head release_secctx;
-	struct list_head inode_invalidate_secctx;
-	struct list_head inode_notifysecctx;
-	struct list_head inode_setsecctx;
-	struct list_head inode_getsecctx;
+	LSM_inode_alloc_security,
+	LSM_inode_free_security,
+	LSM_inode_init_security,
+	LSM_inode_create,
+	LSM_inode_link,
+	LSM_inode_unlink,
+	LSM_inode_symlink,
+	LSM_inode_mkdir,
+	LSM_inode_rmdir,
+	LSM_inode_mknod,
+	LSM_inode_rename,
+	LSM_inode_readlink,
+	LSM_inode_follow_link,
+	LSM_inode_permission,
+	LSM_inode_setattr,
+	LSM_inode_getattr,
+	LSM_inode_setxattr,
+	LSM_inode_post_setxattr,
+	LSM_inode_getxattr,
+	LSM_inode_listxattr,
+	LSM_inode_removexattr,
+	LSM_inode_need_killpriv,
+	LSM_inode_killpriv,
+	LSM_inode_getsecurity,
+	LSM_inode_setsecurity,
+	LSM_inode_listsecurity,
+	LSM_inode_getsecid,
+	LSM_inode_copy_up,
+	LSM_inode_copy_up_xattr,
+	LSM_file_permission,
+	LSM_file_alloc_security,
+	LSM_file_free_security,
+	LSM_file_ioctl,
+	LSM_mmap_addr,
+	LSM_mmap_file,
+	LSM_file_mprotect,
+	LSM_file_lock,
+	LSM_file_fcntl,
+	LSM_file_set_fowner,
+	LSM_file_send_sigiotask,
+	LSM_file_receive,
+	LSM_file_open,
+	LSM_task_create,
+	LSM_task_alloc,
+	LSM_task_free,
+	LSM_cred_alloc_blank,
+	LSM_cred_free,
+	LSM_cred_prepare,
+	LSM_cred_transfer,
+	LSM_kernel_act_as,
+	LSM_kernel_create_files_as,
+	LSM_kernel_read_file,
+	LSM_kernel_post_read_file,
+	LSM_kernel_module_request,
+	LSM_task_fix_setuid,
+	LSM_task_setpgid,
+	LSM_task_getpgid,
+	LSM_task_getsid,
+	LSM_task_getsecid,
+	LSM_task_setnice,
+	LSM_task_setioprio,
+	LSM_task_getioprio,
+	LSM_task_prlimit,
+	LSM_task_setrlimit,
+	LSM_task_setscheduler,
+	LSM_task_getscheduler,
+	LSM_task_movememory,
+	LSM_task_kill,
+	LSM_task_prctl,
+	LSM_task_to_inode,
+	LSM_ipc_permission,
+	LSM_ipc_getsecid,
+	LSM_msg_msg_alloc_security,
+	LSM_msg_msg_free_security,
+	LSM_msg_queue_alloc_security,
+	LSM_msg_queue_free_security,
+	LSM_msg_queue_associate,
+	LSM_msg_queue_msgctl,
+	LSM_msg_queue_msgsnd,
+	LSM_msg_queue_msgrcv,
+	LSM_shm_alloc_security,
+	LSM_shm_free_security,
+	LSM_shm_associate,
+	LSM_shm_shmctl,
+	LSM_shm_shmat,
+	LSM_sem_alloc_security,
+	LSM_sem_free_security,
+	LSM_sem_associate,
+	LSM_sem_semctl,
+	LSM_sem_semop,
+	LSM_netlink_send,
+	LSM_d_instantiate,
+	LSM_getprocattr,
+	LSM_setprocattr,
+	LSM_ismaclabel,
+	LSM_secid_to_secctx,
+	LSM_secctx_to_secid,
+	LSM_release_secctx,
+	LSM_inode_invalidate_secctx,
+	LSM_inode_notifysecctx,
+	LSM_inode_setsecctx,
+	LSM_inode_getsecctx,
 #ifdef CONFIG_SECURITY_NETWORK
-	struct list_head unix_stream_connect;
-	struct list_head unix_may_send;
-	struct list_head socket_create;
-	struct list_head socket_post_create;
-	struct list_head socket_bind;
-	struct list_head socket_connect;
-	struct list_head socket_listen;
-	struct list_head socket_accept;
-	struct list_head socket_sendmsg;
-	struct list_head socket_recvmsg;
-	struct list_head socket_getsockname;
-	struct list_head socket_getpeername;
-	struct list_head socket_getsockopt;
-	struct list_head socket_setsockopt;
-	struct list_head socket_shutdown;
-	struct list_head socket_sock_rcv_skb;
-	struct list_head socket_getpeersec_stream;
-	struct list_head socket_getpeersec_dgram;
-	struct list_head sk_alloc_security;
-	struct list_head sk_free_security;
-	struct list_head sk_clone_security;
-	struct list_head sk_getsecid;
-	struct list_head sock_graft;
-	struct list_head inet_conn_request;
-	struct list_head inet_csk_clone;
-	struct list_head inet_conn_established;
-	struct list_head secmark_relabel_packet;
-	struct list_head secmark_refcount_inc;
-	struct list_head secmark_refcount_dec;
-	struct list_head req_classify_flow;
-	struct list_head tun_dev_alloc_security;
-	struct list_head tun_dev_free_security;
-	struct list_head tun_dev_create;
-	struct list_head tun_dev_attach_queue;
-	struct list_head tun_dev_attach;
-	struct list_head tun_dev_open;
+	LSM_unix_stream_connect,
+	LSM_unix_may_send,
+	LSM_socket_create,
+	LSM_socket_post_create,
+	LSM_socket_bind,
+	LSM_socket_connect,
+	LSM_socket_listen,
+	LSM_socket_accept,
+	LSM_socket_sendmsg,
+	LSM_socket_recvmsg,
+	LSM_socket_getsockname,
+	LSM_socket_getpeername,
+	LSM_socket_getsockopt,
+	LSM_socket_setsockopt,
+	LSM_socket_shutdown,
+	LSM_socket_sock_rcv_skb,
+	LSM_socket_getpeersec_stream,
+	LSM_socket_getpeersec_dgram,
+	LSM_sk_alloc_security,
+	LSM_sk_free_security,
+	LSM_sk_clone_security,
+	LSM_sk_getsecid,
+	LSM_sock_graft,
+	LSM_inet_conn_request,
+	LSM_inet_csk_clone,
+	LSM_inet_conn_established,
+	LSM_secmark_relabel_packet,
+	LSM_secmark_refcount_inc,
+	LSM_secmark_refcount_dec,
+	LSM_req_classify_flow,
+	LSM_tun_dev_alloc_security,
+	LSM_tun_dev_free_security,
+	LSM_tun_dev_create,
+	LSM_tun_dev_attach_queue,
+	LSM_tun_dev_attach,
+	LSM_tun_dev_open,
 #endif	/* CONFIG_SECURITY_NETWORK */
 #ifdef CONFIG_SECURITY_INFINIBAND
-	struct list_head ib_pkey_access;
-	struct list_head ib_endport_manage_subnet;
-	struct list_head ib_alloc_security;
-	struct list_head ib_free_security;
+	LSM_ib_pkey_access,
+	LSM_ib_endport_manage_subnet,
+	LSM_ib_alloc_security,
+	LSM_ib_free_security,
 #endif	/* CONFIG_SECURITY_INFINIBAND */
 #ifdef CONFIG_SECURITY_NETWORK_XFRM
-	struct list_head xfrm_policy_alloc_security;
-	struct list_head xfrm_policy_clone_security;
-	struct list_head xfrm_policy_free_security;
-	struct list_head xfrm_policy_delete_security;
-	struct list_head xfrm_state_alloc;
-	struct list_head xfrm_state_alloc_acquire;
-	struct list_head xfrm_state_free_security;
-	struct list_head xfrm_state_delete_security;
-	struct list_head xfrm_policy_lookup;
-	struct list_head xfrm_state_pol_flow_match;
-	struct list_head xfrm_decode_session;
+	LSM_xfrm_policy_alloc_security,
+	LSM_xfrm_policy_clone_security,
+	LSM_xfrm_policy_free_security,
+	LSM_xfrm_policy_delete_security,
+	LSM_xfrm_state_alloc,
+	LSM_xfrm_state_alloc_acquire,
+	LSM_xfrm_state_free_security,
+	LSM_xfrm_state_delete_security,
+	LSM_xfrm_policy_lookup,
+	LSM_xfrm_state_pol_flow_match,
+	LSM_xfrm_decode_session,
 #endif	/* CONFIG_SECURITY_NETWORK_XFRM */
 #ifdef CONFIG_KEYS
-	struct list_head key_alloc;
-	struct list_head key_free;
-	struct list_head key_permission;
-	struct list_head key_getsecurity;
+	LSM_key_alloc,
+	LSM_key_free,
+	LSM_key_permission,
+	LSM_key_getsecurity,
 #endif	/* CONFIG_KEYS */
 #ifdef CONFIG_AUDIT
-	struct list_head audit_rule_init;
-	struct list_head audit_rule_known;
-	struct list_head audit_rule_match;
-	struct list_head audit_rule_free;
+	LSM_audit_rule_init,
+	LSM_audit_rule_known,
+	LSM_audit_rule_match,
+	LSM_audit_rule_free,
 #endif /* CONFIG_AUDIT */
+	LSM_MAX_HOOK_INDEX,
 };
 
 /*
@@ -1921,8 +1922,8 @@ struct security_hook_heads {
  */
 struct security_hook_list {
 	struct list_head		list;
-	struct list_head		*head;
 	union security_list_options	hook;
+	enum security_hook_index	idx;
 	char				*lsm;
 };
 
@@ -1933,9 +1934,8 @@ struct security_hook_list {
  * text involved.
  */
 #define LSM_HOOK_INIT(HEAD, HOOK) \
-	{ .head = &security_hook_heads.HEAD, .hook = { .HEAD = HOOK } }
+	{ .idx = LSM_##HEAD, .hook = { .HEAD = HOOK } }
 
-extern struct security_hook_heads security_hook_heads;
 extern char *lsm_names;
 
 extern void security_add_hooks(struct security_hook_list *hooks, int count,
diff --git a/security/security.c b/security/security.c
index 3013237..44c47b6 100644
--- a/security/security.c
+++ b/security/security.c
@@ -34,7 +34,8 @@
 /* Maximum number of letters for an LSM name string */
 #define SECURITY_NAME_MAX	10
 
-struct security_hook_heads security_hook_heads __lsm_ro_after_init;
+static struct list_head hook_heads[LSM_MAX_HOOK_INDEX]
+	__lsm_ro_after_init;
 static ATOMIC_NOTIFIER_HEAD(lsm_notifier_chain);
 
 char *lsm_names;
@@ -59,12 +60,10 @@ static void __init do_security_initcalls(void)
  */
 int __init security_init(void)
 {
-	int i;
-	struct list_head *list = (struct list_head *) &security_hook_heads;
+	enum security_hook_index i;
 
-	for (i = 0; i < sizeof(security_hook_heads) / sizeof(struct list_head);
-	     i++)
-		INIT_LIST_HEAD(&list[i]);
+	for (i = 0; i < LSM_MAX_HOOK_INDEX; i++)
+		INIT_LIST_HEAD(&hook_heads[i]);
 	pr_info("Security Framework initialized\n");
 
 	/*
@@ -161,8 +160,12 @@ void __init security_add_hooks(struct security_hook_list *hooks, int count,
 	int i;
 
 	for (i = 0; i < count; i++) {
+		enum security_hook_index idx = hooks[i].idx;
+
 		hooks[i].lsm = lsm;
-		list_add_tail_rcu(&hooks[i].list, hooks[i].head);
+		/* Can't hit this BUG_ON() unless LSM_HOOK_INIT() is broken. */
+		BUG_ON(idx < 0 || idx >= LSM_MAX_HOOK_INDEX);
+		list_add_tail_rcu(&hooks[i].list, &hook_heads[idx]);
 	}
 	if (lsm_append(lsm, &lsm_names) < 0)
 		panic("%s - Cannot get early memory.\n", __func__);
@@ -200,7 +203,7 @@ EXPORT_SYMBOL(unregister_lsm_notifier);
 	do {							\
 		struct security_hook_list *P;			\
 								\
-		list_for_each_entry(P, &security_hook_heads.FUNC, list)	\
+		list_for_each_entry(P, &hook_heads[LSM_##FUNC], list)	\
 			P->hook.FUNC(__VA_ARGS__);		\
 	} while (0)
 
@@ -209,7 +212,7 @@ EXPORT_SYMBOL(unregister_lsm_notifier);
 	do {							\
 		struct security_hook_list *P;			\
 								\
-		list_for_each_entry(P, &security_hook_heads.FUNC, list) { \
+		list_for_each_entry(P, &hook_heads[LSM_##FUNC], list) {	\
 			RC = P->hook.FUNC(__VA_ARGS__);		\
 			if (RC != 0)				\
 				break;				\
@@ -316,7 +319,7 @@ int security_vm_enough_memory_mm(struct mm_struct *mm, long pages)
 	 * agree that it should be set it will. If any module
 	 * thinks it should not be set it won't.
 	 */
-	list_for_each_entry(hp, &security_hook_heads.vm_enough_memory, list) {
+	list_for_each_entry(hp, &hook_heads[LSM_vm_enough_memory], list) {
 		rc = hp->hook.vm_enough_memory(mm, pages);
 		if (rc <= 0) {
 			cap_sys_admin = 0;
@@ -809,7 +812,7 @@ int security_inode_getsecurity(struct inode *inode, const char *name, void **buf
 	/*
 	 * Only one module will provide an attribute with a given name.
 	 */
-	list_for_each_entry(hp, &security_hook_heads.inode_getsecurity, list) {
+	list_for_each_entry(hp, &hook_heads[LSM_inode_getsecurity], list) {
 		rc = hp->hook.inode_getsecurity(inode, name, buffer, alloc);
 		if (rc != -EOPNOTSUPP)
 			return rc;
@@ -827,7 +830,7 @@ int security_inode_setsecurity(struct inode *inode, const char *name, const void
 	/*
 	 * Only one module will provide an attribute with a given name.
 	 */
-	list_for_each_entry(hp, &security_hook_heads.inode_setsecurity, list) {
+	list_for_each_entry(hp, &hook_heads[LSM_inode_setsecurity], list) {
 		rc = hp->hook.inode_setsecurity(inode, name, value, size,
 								flags);
 		if (rc != -EOPNOTSUPP)
@@ -1135,7 +1138,7 @@ int security_task_prctl(int option, unsigned long arg2, unsigned long arg3,
 	int rc = -ENOSYS;
 	struct security_hook_list *hp;
 
-	list_for_each_entry(hp, &security_hook_heads.task_prctl, list) {
+	list_for_each_entry(hp, &hook_heads[LSM_task_prctl], list) {
 		thisrc = hp->hook.task_prctl(option, arg2, arg3, arg4, arg5);
 		if (thisrc != -ENOSYS) {
 			rc = thisrc;
@@ -1638,7 +1641,7 @@ int security_xfrm_state_pol_flow_match(struct xfrm_state *x,
 	 * For speed optimization, we explicitly break the loop rather than
 	 * using the macro
 	 */
-	list_for_each_entry(hp, &security_hook_heads.xfrm_state_pol_flow_match,
+	list_for_each_entry(hp, &hook_heads[LSM_xfrm_state_pol_flow_match],
 				list) {
 		rc = hp->hook.xfrm_state_pol_flow_match(x, xp, fl);
 		break;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
