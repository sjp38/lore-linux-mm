Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id DF3FD6B0038
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 20:45:08 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id p9so15061030pgc.6
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 17:45:08 -0700 (PDT)
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp. [114.179.232.161])
        by mx.google.com with ESMTPS id f81si191757pfj.30.2017.10.30.17.45.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Oct 2017 17:45:07 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: consult a question about action_result() in memory_failure()
Date: Tue, 31 Oct 2017 00:44:26 +0000
Message-ID: <20171031004423.GA18629@hori1.linux.bs1.fc.nec.co.jp>
References: <566fb926-6aba-844e-c777-8c81b4670e7b@huawei.com>
In-Reply-To: <566fb926-6aba-844e-c777-8c81b4670e7b@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <240CED5B007CDC4EB772BF6BE9C24408@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gengdongjiu <gengdongjiu@huawei.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi gengdongjiu,

On Tue, Oct 24, 2017 at 08:47:41PM +0800, gengdongjiu wrote:
> Hi Naoya,
>    very sorry to disturb you, I want to consult you about the handing to =
error page type in memory_failure().
> If the error page is the current task's page table, will the memory_failu=
re not handling that?
> From my test, I found the memory_failure() consider the error page table =
physical address as unknown page.
> why it does not handling the page table page error? Thanks a lot.

I think that that's because it's handled not in the context of
memory error handling, but in MCE's context.

When your hardware detects a memory error on a page table page
(f.e. memory scrubbing running in background), MCE SRAO is sent to
the kernel, and the kernel kicks memory error handler.
But memory error handler does nothing because there's currently
no way to isolate the page table page. I think that a main problem
is that no one easily knows "which processes owned the page table page."
So the error page is still open for access, then later some CPU
try to access the page table page, which triggers severer MCE SRAR.
Then in this time, MCE handler tries to kill the process of current
context (hoping that it's the right process to be killed.)
# For errors on "kernel" page table pages, there's no choice other
# than panic...

So the current situation not the worst, but still open for improvement.
Any suggestion to handle it in memory error handling would be wonderful.

Thanks,
Naoya Horiguchi


>=20
> commit 64d37a2baf5e5c0f1009c0ef290a9027de721d66
> Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date:   Wed Apr 15 16:13:05 2015 -0700
>=20
>     mm/memory-failure.c: define page types for action_result() in one pla=
ce
>=20
>     This cleanup patch moves all strings passed to action_result() into a
>     singl=3D e array action_page_type so that a reader can easily find wh=
ich
>     kind of actio=3D n results are possible.  And this patch also fixes t=
he
>     odd lines to be printed out, like "unknown page state page" or "free
>     buddy, 2nd try page".
>=20
>     [akpm@linux-foundation.org: rename messages, per David]
>     [akpm@linux-foundation.org: s/DIRTY_UNEVICTABLE_LRU/CLEAN_UNEVICTABLE=
_LRU', per Andi]
>     Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
>     Reviewed-by: Andi Kleen <ak@linux.intel.com>
>     Cc: Tony Luck <tony.luck@intel.com>
>     Cc: "Xie XiuQi" <xiexiuqi@huawei.com>
>     Cc: Steven Rostedt <rostedt@goodmis.org>
>     Cc: Chen Gong <gong.chen@linux.intel.com>
>     Cc: David Rientjes <rientjes@google.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
>=20
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index d487f8d..5fd8931 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -521,6 +521,52 @@ static const char *action_name[] =3D {
>         [RECOVERED] =3D "Recovered",
>  };
>=20
> +enum action_page_type {
> +       MSG_KERNEL,
> +       MSG_KERNEL_HIGH_ORDER,
> +       MSG_SLAB,
> +       MSG_DIFFERENT_COMPOUND,
> +       MSG_POISONED_HUGE,
> +       MSG_HUGE,
> +       MSG_FREE_HUGE,
> +       MSG_UNMAP_FAILED,
> +       MSG_DIRTY_SWAPCACHE,
> +       MSG_CLEAN_SWAPCACHE,
> +       MSG_DIRTY_MLOCKED_LRU,
> +       MSG_CLEAN_MLOCKED_LRU,
> +       MSG_DIRTY_UNEVICTABLE_LRU,
> +       MSG_CLEAN_UNEVICTABLE_LRU,
> +       MSG_DIRTY_LRU,
> +       MSG_CLEAN_LRU,
> +       MSG_TRUNCATED_LRU,
> +       MSG_BUDDY,
> +       MSG_BUDDY_2ND,
> +       MSG_UNKNOWN,
> +};
> +
> +static const char * const action_page_types[] =3D {
> +       [MSG_KERNEL]                    =3D "reserved kernel page",
> +       [MSG_KERNEL_HIGH_ORDER]         =3D "high-order kernel page",
> +       [MSG_SLAB]                      =3D "kernel slab page",
> +       [MSG_DIFFERENT_COMPOUND]        =3D "different compound page afte=
r locking",
> +       [MSG_POISONED_HUGE]             =3D "huge page already hardware p=
oisoned",
> +       [MSG_HUGE]                      =3D "huge page",
> +       [MSG_FREE_HUGE]                 =3D "free huge page",
> +       [MSG_UNMAP_FAILED]              =3D "unmapping failed page",
> +       [MSG_DIRTY_SWAPCACHE]           =3D "dirty swapcache page",
> +       [MSG_CLEAN_SWAPCACHE]           =3D "clean swapcache page",
> +       [MSG_DIRTY_MLOCKED_LRU]         =3D "dirty mlocked LRU page",
> +       [MSG_CLEAN_MLOCKED_LRU]         =3D "clean mlocked LRU page",
> +       [MSG_DIRTY_UNEVICTABLE_LRU]     =3D "dirty unevictable LRU page",
> +       [MSG_CLEAN_UNEVICTABLE_LRU]     =3D "clean unevictable LRU page",
> +       [MSG_DIRTY_LRU]                 =3D "dirty LRU page",
> +       [MSG_CLEAN_LRU]                 =3D "clean LRU page",
> +       [MSG_TRUNCATED_LRU]             =3D "already truncated LRU page",
> +       [MSG_BUDDY]                     =3D "free buddy page",
> +       [MSG_BUDDY_2ND]                 =3D "free buddy page (2nd try)",
> +       [MSG_UNKNOWN]                   =3D "unknown page",
> +};
>=20
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
