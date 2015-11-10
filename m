Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id AAB6D6B0038
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 11:02:48 -0500 (EST)
Received: by wmww144 with SMTP id w144so6881799wmw.0
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:02:48 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id 193si6213966wmx.83.2015.11.10.08.02.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 08:02:46 -0800 (PST)
Received: by wmww144 with SMTP id w144so124064675wmw.1
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 08:02:46 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page reference manipulation
In-Reply-To: <1447053784-27811-2-git-send-email-iamjoonsoo.kim@lge.com>
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com> <1447053784-27811-2-git-send-email-iamjoonsoo.kim@lge.com>
Date: Tue, 10 Nov 2015 17:02:43 +0100
Message-ID: <xa1tegfxg7vg.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Mon, Nov 09 2015, Joonsoo Kim wrote:
> CMA allocation should be guaranteed to succeed by definition,=20

Uh?  That=E2=80=99s a peculiar statement.  Which is to say that it=E2=80=99=
s not true.

> but,
> unfortunately, it would be failed sometimes. It is hard to track down
> the problem, because it is related to page reference manipulation and
> we don't have any facility to analyze it.
>
> This patch adds tracepoints to track down page reference manipulation.
> With it, we can find exact reason of failure and can fix the problem.
> Following is an example of tracepoint output.
>
> <...>-9018  [004]    92.678375: page_ref_set:         pfn=3D0x17ac9 flags=
=3D0x0 count=3D1 mapcount=3D0 mapping=3D(nil) mt=3D4 val=3D1
> <...>-9018  [004]    92.678378: kernel_stack:
>  =3D> get_page_from_freelist (ffffffff81176659)
>  =3D> __alloc_pages_nodemask (ffffffff81176d22)
>  =3D> alloc_pages_vma (ffffffff811bf675)
>  =3D> handle_mm_fault (ffffffff8119e693)
>  =3D> __do_page_fault (ffffffff810631ea)
>  =3D> trace_do_page_fault (ffffffff81063543)
>  =3D> do_async_page_fault (ffffffff8105c40a)
>  =3D> async_page_fault (ffffffff817581d8)
> [snip]
> <...>-9018  [004]    92.678379: page_ref_mod:         pfn=3D0x17ac9 flags=
=3D0x40048 count=3D2 mapcount=3D1 mapping=3D0xffff880015a78dc1 mt=3D4 val=
=3D1
> [snip]
> ...
> ...
> <...>-9131  [001]    93.174468: test_pages_isolated:  start_pfn=3D0x17800=
 end_pfn=3D0x17c00 fin_pfn=3D0x17ac9 ret=3Dfail
> [snip]
> <...>-9018  [004]    93.174843: page_ref_mod_and_test: pfn=3D0x17ac9 flag=
s=3D0x40068 count=3D0 mapcount=3D0 mapping=3D0xffff880015a78dc1 mt=3D4 val=
=3D-1 ret=3D1
>  =3D> release_pages (ffffffff8117c9e4)
>  =3D> free_pages_and_swap_cache (ffffffff811b0697)
>  =3D> tlb_flush_mmu_free (ffffffff81199616)
>  =3D> tlb_finish_mmu (ffffffff8119a62c)
>  =3D> exit_mmap (ffffffff811a53f7)
>  =3D> mmput (ffffffff81073f47)
>  =3D> do_exit (ffffffff810794e9)
>  =3D> do_group_exit (ffffffff81079def)
>  =3D> SyS_exit_group (ffffffff81079e74)
>  =3D> entry_SYSCALL_64_fastpath (ffffffff817560b6)
>
> This output shows that problem comes from exit path. In exit path,
> to improve performance, pages are not freed immediately. They are gathered
> and processed by batch. During this process, migration cannot be possible
> and CMA allocation is failed. This problem is hard to find without this
> page reference tracepoint facility.
>
> Enabling this feature bloat kernel text 20 KB in my configuration.
>
>    text    data     bss     dec     hex filename
> 12041272        2223424 1507328 15772024         f0a978 vmlinux_disabled
> 12064844        2225920 1507328 15798092         f10f4c vmlinux_enabled
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

> ---
>  include/trace/events/page_ref.h | 128 ++++++++++++++++++++++++++++++++++=
++++++

I haven=E2=80=99t really looked at the above file though.

--=20
Best regards,                                            _     _
.o. | Liege of Serenely Enlightened Majesty of         o' \,=3D./ `o
..o | Computer Science,  =E3=83=9F=E3=83=8F=E3=82=A6 =E2=80=9Cmina86=E2=80=
=9D =E3=83=8A=E3=82=B6=E3=83=AC=E3=83=B4=E3=82=A4=E3=83=84  (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
