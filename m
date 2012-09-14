Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 43BC86B005D
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 18:46:38 -0400 (EDT)
Received: by iagk10 with SMTP id k10so4814054iag.14
        for <linux-mm@kvack.org>; Fri, 14 Sep 2012 15:46:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5053AC2F.3070203@gmail.com>
References: <1346750457-12385-1-git-send-email-walken@google.com>
	<1346750457-12385-7-git-send-email-walken@google.com>
	<5053AC2F.3070203@gmail.com>
Date: Fri, 14 Sep 2012 15:46:37 -0700
Message-ID: <CANN689Ff3W4z=+3J8aGO-2GrPHGJ=ote_f5q9jzRQRAP+b0T4Q@mail.gmail.com>
Subject: Re: [PATCH 6/7] mm: add CONFIG_DEBUG_VM_RB build option
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: linux-mm@kvack.org, riel@redhat.com, peterz@infradead.org, aarcange@redhat.com, hughd@google.com, daniel.santos@pobox.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Dave Jones <davej@redhat.com>

On Fri, Sep 14, 2012 at 3:14 PM, Sasha Levin <levinsasha928@gmail.com> wrote:
> On 09/04/2012 11:20 AM, Michel Lespinasse wrote:
>> Add a CONFIG_DEBUG_VM_RB build option for the previously existing
>> DEBUG_MM_RB code. Now that Andi Kleen modified it to avoid using
>> recursive algorithms, we can expose it a bit more.
>>
>> Also extend this code to validate_mm() after stack expansion, and to
>> check that the vma's start and last pgoffs have not changed since the
>> nodes were inserted on the anon vma interval tree (as it is important
>> that the nodes be reindexed after each such update).
>
> This patch exposes the following warning:
>
> [   24.977502] ------------[ cut here ]------------
> [   24.979089] WARNING: at mm/interval_tree.c:110
> anon_vma_interval_tree_verify+0x81/0xa0()
> [   24.981765] Pid: 5928, comm: trinity-child37 Tainted: G        W
> 3.6.0-rc5-next-20120914-sasha-00003-g7deb7fa-dirty #333
> [   24.985501] Call Trace:
> [   24.986345]  [<ffffffff81224c91>] ? anon_vma_interval_tree_verify+0x81/0xa0
> [   24.988535]  [<ffffffff81106766>] warn_slowpath_common+0x86/0xb0
> [   24.990636]  [<ffffffff81106855>] warn_slowpath_null+0x15/0x20
> [   24.992658]  [<ffffffff81224c91>] anon_vma_interval_tree_verify+0x81/0xa0
> [   24.994980]  [<ffffffff8122e6e8>] validate_mm+0x58/0x1e0
> [   24.996772]  [<ffffffff8122e934>] vma_link+0x94/0xe0
> [   24.997719]  [<ffffffff812315e9>] copy_vma+0x279/0x2e0
> [   24.998522]  [<ffffffff8117a7fd>] ? trace_hardirqs_off+0xd/0x10
> [   25.000772]  [<ffffffff81232e89>] move_vma+0xa9/0x260
> [   25.002499]  [<ffffffff812334b5>] sys_mremap+0x475/0x540
> [   25.004364]  [<ffffffff8374b6e8>] tracesys+0xe1/0xe6
> [   25.006108] ---[ end trace 7c901670963aa6e2 ]---
>
> The code line is
>
>         WARN_ON_ONCE(node->cached_vma_last != avc_last_pgoff(node));

That's very interesting (and potentially relevant to another bug
that's been reported too).

I'd like to know, what workload did you use that triggered this ?
(I find it hard to test mremap as I don't know of enough users of it)

Thanks,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
