Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4E3448D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 08:16:36 -0400 (EDT)
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20110425111705.786ef0c5@neptune.home>
	<BANLkTi=2DK+iq-5NEFKexe0QhpW8G0RL8Q@mail.gmail.com>
	<20110425123444.639aad34@neptune.home>
	<20110425134145.048f7cc1@neptune.home>
	<BANLkTikpt7E5eE9vv9NFbNAwT_O6sHnQvA@mail.gmail.com>
In-Reply-To: <BANLkTikpt7E5eE9vv9NFbNAwT_O6sHnQvA@mail.gmail.com>
Message-Id: <201104252114.HID65107.FOHOQFMVJtOSFL@I-love.SAKURA.ne.jp>
Date: Mon, 25 Apr 2011 21:14:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org, bonbons@linux-vserver.org
Cc: vapier.adi@gmail.com, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, catalin.marinas@arm.com, adobriyan@gmail.com, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk, nickpiggin@yahoo.com.au

I don't know whether below is related with this bug. But...

static struct dentry *proc_pident_instantiate(struct inode *dir,
        struct dentry *dentry, struct task_struct *task, const void *ptr)
{
        const struct pid_entry *p = ptr;
        struct inode *inode;
        struct proc_inode *ei;
        struct dentry *error = ERR_PTR(-ENOENT);

        inode = proc_pid_make_inode(dir->i_sb, task);
        if (!inode)
                goto out;

        ei = PROC_I(inode);
        inode->i_mode = p->mode;
        if (S_ISDIR(inode->i_mode))
                inode->i_nlink = 2;     /* Use getattr to fix if necessary */
        if (p->iop)
                inode->i_op = p->iop;
        if (p->fop)
                inode->i_fop = p->fop;
        ei->op = p->op;
        d_set_d_op(dentry, &pid_dentry_operations);
        d_add(dentry, inode);
        /* Close the race of the process dying before we return the dentry */
        if (pid_revalidate(dentry, NULL))
                error = NULL;
out:
        return error;
}

proc_pid_make_inode() gets a ref on task, but return value of pid_revalidate()
(one of 0, 1, -ECHILD) may not be what above 'if (pid_revalidate(dentry, NULL))'
part expects. (-ECHILD is a new return value introduced by LOOKUP_RCU.)

static int pid_revalidate(struct dentry *dentry, struct nameidata *nd)
{
        struct inode *inode;
        struct task_struct *task;
        const struct cred *cred;

        if (nd && nd->flags & LOOKUP_RCU)
                return -ECHILD;

        inode = dentry->d_inode;
        task = get_proc_task(inode);

        if (task) {
                if ((inode->i_mode == (S_IFDIR|S_IRUGO|S_IXUGO)) ||
                    task_dumpable(task)) {
                        rcu_read_lock();
                        cred = __task_cred(task);
                        inode->i_uid = cred->euid;
                        inode->i_gid = cred->egid;
                        rcu_read_unlock();
                } else {
                        inode->i_uid = 0;
                        inode->i_gid = 0;
                }
                inode->i_mode &= ~(S_ISUID | S_ISGID);
                security_task_to_inode(task, inode);
                put_task_struct(task);
                return 1;
        }
        d_drop(dentry);
        return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
