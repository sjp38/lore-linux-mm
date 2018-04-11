Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id C0FB06B0005
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 21:28:41 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id o2-v6so198808plk.14
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 18:28:41 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g7si6403pfi.310.2018.04.10.18.28.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 18:28:40 -0700 (PDT)
Message-Id: <201804110128.w3B1S6M6092645@www262.sakura.ne.jp>
Subject: Re: Re: WARNING in =?ISO-2022-JP?B?a2lsbF9ibG9ja19zdXBlcg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 11 Apr 2018 10:28:06 +0900
References: <6c95e826-4b9f-fb21-b311-830411e58480@I-love.SAKURA.ne.jp> <20180411005938.GN30522@ZenIV.linux.org.uk>
In-Reply-To: <20180411005938.GN30522@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: Michal Hocko <mhocko@suse.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, syzkaller-bugs@googlegroups.com, linux-mm <linux-mm@kvack.org>, Dmitry Vyukov <dvyukov@google.com>, syzbot <syzbot+5a170e19c963a2e0df79@syzkaller.appspotmail.com>

Al Viro wrote:
> On Wed, Apr 04, 2018 at 07:53:07PM +0900, Tetsuo Handa wrote:
> > Al and Michal, are you OK with this patch?
> 
> First of all, it does *NOT* fix the problems with careless ->kill_sb().
> The fuse-blk case is the only real rationale so far.  Said that,
> 

Please notice below one as well. Fixing all careless ->kill_sb() will be too
difficult to backport. For now, avoid calling deactivate_locked_super() is
safer.


[upstream] WARNING: refcount bug in put_pid_ns
https://syzkaller.appspot.com/bug?id=17e202b4794da213570ba33ac2f70277ef1ce015

static __latent_entropy struct task_struct *copy_process(unsigned long clone_flags, unsigned long stack_start, unsigned long stack_size, int __user *child_tidptr, struct pid *pid, int trace, unsigned long tls, int node)
{
(...snipped...)
  if (pid != &init_struct_pid) {
    pid = alloc_pid(p->nsproxy->pid_ns_for_children) {
      pid_ns_prepare_proc(ns) {
        mnt = kern_mount_data(&proc_fs_type, ns) {
          mnt = vfs_kern_mount(type, SB_KERNMOUNT, type->name, data) {
            root = mount_fs(type, flags, name, data) {
              root = type->mount(type, flags, name, data) {
                return mount_ns(fs_type, flags, data, ns, ns->user_ns, proc_fill_super) {
                  sb = sget_userns(fs_type, ns_test_super, ns_set_super, flags, user_ns, ns) {
                    err = register_shrinker(&s->s_shrink); // <= failed by fault injection.
                    if (err) {
                      deactivate_locked_super(s) {
                        fs->kill_sb(s) {
                          put_pid_ns(ns) {
                            kref_put(&ns->kref, free_pid_ns) // <= ns->kref is decremented here.
                          }
                        }
                      }
                      s = ERR_PTR(err);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    if (IS_ERR(pid)) {
      retval = PTR_ERR(pid);
      goto bad_fork_cleanup_thread;
    }
  }
(...snipped...)
bad_fork_cleanup_thread:
  exit_thread(p);
bad_fork_cleanup_io:
  if (p->io_context) exit_io_context(p);
bad_fork_cleanup_namespaces:
  exit_task_namespaces(p) {
     switch_task_namespaces(p, NULL) {
       if (ns && atomic_dec_and_test(&ns->count)) { // <= ns->count becomes 0
         free_nsproxy(ns) {
           if (ns->pid_ns_for_children) {
             put_pid_ns(ns->pid_ns_for_children) {
               kref_put(&ns->kref, free_pid_ns) // <= ns->kref is decremented again and underflows.
             }
           }
         }
       }
     }
  }
(...snipped...)
}
