Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 248F16B005A
	for <linux-mm@kvack.org>; Thu, 20 Sep 2012 18:27:50 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so2572060qcs.14
        for <linux-mm@kvack.org>; Thu, 20 Sep 2012 15:27:49 -0700 (PDT)
Date: Thu, 20 Sep 2012 15:27:11 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 6/7] mm: add CONFIG_DEBUG_VM_RB build option
In-Reply-To: <20120920213938.GA7959@localhost>
Message-ID: <alpine.LSU.2.00.1209201520410.15904@eggly.anvils>
References: <20120920213938.GA7959@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Dave Jones <davej@redhat.com>, Jiri Slaby <jslaby@suse.cz>

On Fri, 21 Sep 2012, Fengguang Wu wrote:
> On Sat, Sep 15, 2012 at 11:26:23AM +0200, Sasha Levin wrote:
> > On 09/15/2012 02:00 AM, Michel Lespinasse wrote:
> > > All right. Hugh managed to reproduce the issue on his suse laptop, and
> > > I came up with a fix.
> > >
> > > The problem was that in mremap, the new vma's vm_{start,end,pgoff}
> > > fields need to be updated before calling anon_vma_clone() so that the
> > > new vma will be properly indexed.
> > >
> > > Patch attached. I expect this should also explain Jiri's reported
> > > failure involving splitting THP pages during mremap(), even though we
> > > did not manage to reproduce that one.
> >
> > Initially I've stumbled on it by running trinity inside a KVM tools guest. fwiw,
> > the guest is pretty custom and isn't based on suse.
> >
> > I re-ran tests with patch applied and looks like it fixed the issue, I haven't
> > seen the warnings even though it runs for quite a while now.
> 
> Not sure if it's the same problem you are talking about, but I got the
> below warning and it's still happening in linux-next 20120920:

It is (almost certainly) the same problem, for which Michel provided
the fix earlier in this thread (some of us find we have to delete a
" {" from the context at the end to get it to apply).

That fix has gone into akpm's tree, but linux-next is still using an
older rollup of akpm's tree.

Thanks,
Hugh

> 
> [   38.482925] scsi_nl_rcv_msg: discarding partial skb
> [   62.679879] ------------[ cut here ]------------
> [   62.680380] WARNING: at /c/kernel-tests/src/linux/mm/interval_tree.c:109 anon_vma_interval_tree_verify+0x33/0x80()
> [   62.681356] Pid: 195, comm: trinity-child0 Not tainted 3.6.0-rc6-next-20120918-08732-g3de9d1a #1
> [   62.682130] Call Trace:
> [   62.682356]  [<ffffffff810c249f>] ? anon_vma_interval_tree_verify+0x33/0x80
> [   62.682968]  [<ffffffff81044356>] warn_slowpath_common+0x5d/0x74
> [   62.683577]  [<ffffffff81044424>] warn_slowpath_null+0x15/0x19
> [   62.684098]  [<ffffffff810c249f>] anon_vma_interval_tree_verify+0x33/0x80
> [   62.684714]  [<ffffffff810ca57c>] validate_mm+0x32/0x15b
> [   62.685202]  [<ffffffff810ca767>] vma_link+0x95/0xa4
> [   62.685637]  [<ffffffff810cbc31>] copy_vma+0x1c7/0x1fe
> [   62.686168]  [<ffffffff810cdd50>] move_vma+0x90/0x1ef
> [   62.686614]  [<ffffffff810ce250>] sys_mremap+0x3a1/0x429
> [   62.687094]  [<ffffffff813caafe>] ? trace_hardirqs_on_thunk+0x3a/0x3f
> [   62.687670]  [<ffffffff81b505b9>] system_call_fastpath+0x16/0x1b
> 
> Bisected down to 
> 
> commit cb58d445d2ec3a06f313e29d6f6af5bef6c9e43c
> Author: Michel Lespinasse <walken@google.com>
> Date:   Thu Sep 13 10:58:56 2012 +1000
> 
>     mm: add CONFIG_DEBUG_VM_RB build option
> 
> Thanks,
> Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
