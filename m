Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B98996B009D
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 19:07:37 -0500 (EST)
Received: by iwn9 with SMTP id 9so5418543iwn.14
        for <linux-mm@kvack.org>; Sun, 07 Nov 2010 16:07:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101107220353.964566018@cmpxchg.org>
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
	<20101106010357.GD23393@cmpxchg.org>
	<AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
	<20101107215030.007259800@cmpxchg.org>
	<20101107220353.964566018@cmpxchg.org>
Date: Mon, 8 Nov 2010 09:07:35 +0900
Message-ID: <AANLkTinh+LEQYGe9dDOKBwNnVVXMiFYpDqkqvvpNe9H8@mail.gmail.com>
Subject: Re: [patch 4/4] memcg: use native word page statistics counters
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 8, 2010 at 7:14 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> The statistic counters are in units of pages, there is no reason to
> make them 64-bit wide on 32-bit machines.
>
> Make them native words. =A0Since they are signed, this leaves 31 bit on
> 32-bit machines, which can represent roughly 8TB assuming a page size
> of 4k.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> =A0include/linux/memcontrol.h | =A0 =A02 +-
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 43 +++++++++++++++++++++-=
---------------------
> =A0mm/page-writeback.c =A0 =A0 =A0 =A0| =A0 =A04 ++--
> =A03 files changed, 24 insertions(+), 25 deletions(-)
>

<snip>

>
> =A0static unsigned long dirty_writeback_pages(void)
> =A0{
> - =A0 =A0 =A0 s64 ret;
> + =A0 =A0 =A0 unsigned long ret;
>
> =A0 =A0 =A0 =A0ret =3D mem_cgroup_page_stat(MEMCG_NR_DIRTY_WRITEBACK_PAGE=
S);
> - =A0 =A0 =A0 if (ret < 0)
> + =A0 =A0 =A0 if ((long)ret < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ret =3D global_page_state(NR_UNSTABLE_NFS)=
 +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0global_page_state(NR_WRITE=
BACK);

BTW, let me ask a question.
dirty_writeback_pages seems to be depends on mem_cgroup_page_stat's
result(ie, negative) for separate global and memcg.
But mem_cgroup_page_stat could return negative value by per-cpu as
well as root cgroup.
If I understand right, Isn't it a problem?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
