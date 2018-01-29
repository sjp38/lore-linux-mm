Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8226B0007
	for <linux-mm@kvack.org>; Sun, 28 Jan 2018 19:20:42 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id b184so6460877iof.21
        for <linux-mm@kvack.org>; Sun, 28 Jan 2018 16:20:42 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t124si5218792itf.146.2018.01.28.16.20.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 28 Jan 2018 16:20:41 -0800 (PST)
Message-Id: <201801290020.w0T0KK8V015938@www262.sakura.ne.jp>
Subject: Re: kernel panic: Out of memory and no killable processes... (2)
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Mon, 29 Jan 2018 09:20:20 +0900
References: <001a1144b0caee2e8c0563d9de0a@google.com>
In-Reply-To: <001a1144b0caee2e8c0563d9de0a@google.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: davem@davemloft.net, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev@vger.kernel.org
Cc: aarcange@redhat.com, akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, syzkaller-bugs@googlegroups.com, yang.s@alibaba-inc.com

syzbot wrote:
> syzbot hit the following crash on net-next commit
> 6bb46bc57c8e9ce947cc605e555b7204b44d2b10 (Fri Jan 26 16:00:23 2018 +0000)
> Merge branch 'cxgb4-fix-dump-collection-when-firmware-crashed'
> 
> C reproducer is attached.
> syzkaller reproducer is attached.
> Raw console output is attached.
> compiler: gcc (GCC) 7.1.1 20170620
> .config is attached.
> 
> IMPORTANT: if you fix the bug, please add the following tag to the commit:
> Reported-by: syzbot+8630e35fc7287b392aac@syzkaller.appspotmail.com
> It will help syzbot understand when the bug is fixed. See footer for  
> details.
> If you forward the report, please keep this part and the footer.
> 
> [ 3685]     0  3685    17821        1   184320        0             0 sshd
> [ 3692]     0  3692     4376        0    32768        0             0  
> syzkaller025682
> [ 3695]     0  3695     4376        0    36864        0             0  
> syzkaller025682
> Kernel panic - not syncing: Out of memory and no killable processes...
> 

This sounds like too huge vmalloc() request where size is controlled by userspace.

----------
[   27.738855] syzkaller025682 invoked oom-killer: gfp_mask=0x14002c2(GFP_KERNEL|__GFP_HIGHMEM|__GFP_NOWARN), nodemask=(null), order=0, oom_score_adj=0
[   27.754960] syzkaller025682 cpuset=/ mems_allowed=0
[   27.760386] CPU: 0 PID: 3689 Comm: syzkaller025682 Not tainted 4.15.0-rc9+ #212
[   27.767820] Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
[   27.777166] Call Trace:
[   27.779739]  dump_stack+0x194/0x257
[   27.793194]  dump_header+0x28c/0xe1e
[   27.888997]  oom_kill_process+0x8b5/0x14a0
[   27.981648]  out_of_memory+0x86d/0x1220
[   28.003684]  __alloc_pages_slowpath+0x1d1b/0x2d00
[   28.054140]  __alloc_pages_nodemask+0x9fb/0xd80
[   28.090590]  alloc_pages_current+0xb6/0x1e0
[   28.094927]  __vmalloc_node_range+0x409/0x650
[   28.103837]  __vmalloc_node_flags_caller+0x50/0x60
[   28.113166]  kvmalloc_node+0x82/0xd0
[   28.116869]  xt_alloc_table_info+0x64/0xe0
[   28.121097]  do_ip6t_set_ctl+0x29b/0x5f0
[   28.139158]  nf_setsockopt+0x67/0xc0
[   28.142862]  ipv6_setsockopt+0x115/0x150
[   28.146912]  udpv6_setsockopt+0x45/0x80
[   28.150867]  sock_common_setsockopt+0x95/0xd0
[   28.155359]  SyS_setsockopt+0x189/0x360
[   28.177379]  entry_SYSCALL_64_fastpath+0x29/0xa0
----------

struct xt_table_info *xt_alloc_table_info(unsigned int size)
{
(...snipped...)
	info = kvmalloc(sz, GFP_KERNEL);
(...snipped...)
}

static int
do_ip6t_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
{
        int ret;

        if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
                return -EPERM;

        switch (cmd) {
        case IP6T_SO_SET_REPLACE:
                ret = do_replace(sock_net(sk), user, len);
                break;

        case IP6T_SO_SET_ADD_COUNTERS:
                ret = do_add_counters(sock_net(sk), user, len, 0);
                break;

        default:
                ret = -EINVAL;
        }

        return ret;
}

vmalloc() once became killable by commit 5d17a73a2ebeb8d1 ("vmalloc: back
off when the current task is killed") but then became unkillable by commit
b8c8a338f75e052d ("Revert "vmalloc: back off when the current task is
killed""). Therefore, we can't handle this problem from MM side.
Please consider adding some limit from networking side.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
