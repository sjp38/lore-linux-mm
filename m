Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 48A756B005D
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 18:13:47 -0400 (EDT)
Received: by weys10 with SMTP id s10so3230424wey.14
        for <linux-mm@kvack.org>; Fri, 14 Sep 2012 15:13:45 -0700 (PDT)
Message-ID: <5053AC2F.3070203@gmail.com>
Date: Sat, 15 Sep 2012 00:14:07 +0200
From: Sasha Levin <levinsasha928@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 6/7] mm: add CONFIG_DEBUG_VM_RB build option
References: <1346750457-12385-1-git-send-email-walken@google.com> <1346750457-12385-7-git-send-email-walken@google.com>
In-Reply-To: <1346750457-12385-7-git-send-email-walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Dave Jones <davej@redhat.com>

On 09/04/2012 11:20 AM, Michel Lespinasse wrote:
> Add a CONFIG_DEBUG_VM_RB build option for the previously existing
> DEBUG_MM_RB code. Now that Andi Kleen modified it to avoid using
> recursive algorithms, we can expose it a bit more.
> 
> Also extend this code to validate_mm() after stack expansion, and to
> check that the vma's start and last pgoffs have not changed since the
> nodes were inserted on the anon vma interval tree (as it is important
> that the nodes be reindexed after each such update).

This patch exposes the following warning:

[   24.977502] ------------[ cut here ]------------
[   24.979089] WARNING: at mm/interval_tree.c:110
anon_vma_interval_tree_verify+0x81/0xa0()
[   24.981765] Pid: 5928, comm: trinity-child37 Tainted: G        W
3.6.0-rc5-next-20120914-sasha-00003-g7deb7fa-dirty #333
[   24.985501] Call Trace:
[   24.986345]  [<ffffffff81224c91>] ? anon_vma_interval_tree_verify+0x81/0xa0
[   24.988535]  [<ffffffff81106766>] warn_slowpath_common+0x86/0xb0
[   24.990636]  [<ffffffff81106855>] warn_slowpath_null+0x15/0x20
[   24.992658]  [<ffffffff81224c91>] anon_vma_interval_tree_verify+0x81/0xa0
[   24.994980]  [<ffffffff8122e6e8>] validate_mm+0x58/0x1e0
[   24.996772]  [<ffffffff8122e934>] vma_link+0x94/0xe0
[   24.997719]  [<ffffffff812315e9>] copy_vma+0x279/0x2e0
[   24.998522]  [<ffffffff8117a7fd>] ? trace_hardirqs_off+0xd/0x10
[   25.000772]  [<ffffffff81232e89>] move_vma+0xa9/0x260
[   25.002499]  [<ffffffff812334b5>] sys_mremap+0x475/0x540
[   25.004364]  [<ffffffff8374b6e8>] tracesys+0xe1/0xe6
[   25.006108] ---[ end trace 7c901670963aa6e2 ]---

The code line is

        WARN_ON_ONCE(node->cached_vma_last != avc_last_pgoff(node));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
