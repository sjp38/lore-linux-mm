Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 465FC900146
	for <linux-mm@kvack.org>; Sun,  4 Sep 2011 03:21:21 -0400 (EDT)
Received: by iagv1 with SMTP id v1so6851255iag.14
        for <linux-mm@kvack.org>; Sun, 04 Sep 2011 00:21:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1315098933-29464-1-git-send-email-kirill@shutemov.name>
References: <1315098933-29464-1-git-send-email-kirill@shutemov.name>
From: Paul Menage <paul@paulmenage.org>
Date: Sun, 4 Sep 2011 00:20:59 -0700
Message-ID: <CALdu-PA09QKbL97dZHs1TZv-n=xDUyQvOXatSKOAHExKjfHS+Q@mail.gmail.com>
Subject: Re: [PATCH] memcg: drain all stocks for the cgroup before read usage
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Sep 3, 2011 at 6:15 PM, Kirill A. Shutemov <kirill@shutemov.name> w=
rote:
> From: "Kirill A. Shutemov" <kirill@shutemov.name>
>
> Currently, mem_cgroup_usage() for non-root cgroup returns usage
> including stocks.
>
> Let's drain all socks before read resource counter value. It makes
> memory{,.memcg}.usage_in_bytes and memory.stat consistent.

Isn't that quite an expensive operation, and bear in mind that
resource control trackers may be reading this file very frequently,
maybe every second or so.

How about having a trigger file that can be written to force the drain
for cases where the consistency is really desired? Or a separate
usage_in_bytes_consistent file that does the drain.

Paul

>
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> ---
> =A0mm/memcontrol.c | =A0 =A01 +
> =A01 files changed, 1 insertions(+), 0 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index ebd1e86..e091022 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3943,6 +3943,7 @@ static inline u64 mem_cgroup_usage(struct mem_cgrou=
p *mem, bool swap)
> =A0 =A0 =A0 =A0u64 val;
>
> =A0 =A0 =A0 =A0if (!mem_cgroup_is_root(mem)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 drain_all_stock_sync(mem);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!swap)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return res_counter_read_u6=
4(&mem->res, RES_USAGE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> --
> 1.7.5.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
