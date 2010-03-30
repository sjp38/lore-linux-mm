Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9BF176B01FA
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 07:57:00 -0400 (EDT)
Received: by pwi2 with SMTP id 2so4047929pwi.14
        for <linux-mm@kvack.org>; Tue, 30 Mar 2010 04:56:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100330055304.GA2983@sli10-desk.sh.intel.com>
References: <20100330055304.GA2983@sli10-desk.sh.intel.com>
Date: Tue, 30 Mar 2010 17:26:56 +0530
Message-ID: <661de9471003300456r6527f17au6d70bd0d2ee0a941@mail.gmail.com>
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, fengguang.wu@intel.com, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, Mar 30, 2010 at 11:23 AM, Shaohua Li <shaohua.li@intel.com> wrote:
> Commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26 introduces a regression.
> With it, our tmpfs test always oom. The test has a lot of rotated anon
> pages and cause percent[0] zero. Actually the percent[0] is a very small
> value, but our calculation round it to zero. The commit makes vmscan
> completely skip anon pages and cause oops.
> An option is if percent[x] is zero in get_scan_ratio(), forces it
> to 1. See below patch.
> But the offending commit still changes behavior. Without the commit, we s=
can
> all pages if priority is zero, below patch doesn't fix this. Don't know i=
f
> It's required to fix this too.
>
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
>
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 79c8098..d5cc34e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1604,6 +1604,18 @@ static void get_scan_ratio(struct zone *zone, stru=
ct scan_control *sc,
> =A0 =A0 =A0 =A0/* Normalize to percentages */
> =A0 =A0 =A0 =A0percent[0] =3D 100 * ap / (ap + fp + 1);
> =A0 =A0 =A0 =A0percent[1] =3D 100 - percent[0];
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* if percent[x] is small and rounded to 0, this case doe=
sn't mean we
> + =A0 =A0 =A0 =A0* should skip scan. Give it at least 1% share.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (percent[0] =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 percent[0] =3D 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 percent[1] =3D 99;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (percent[1] =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 percent[0] =3D 99;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 percent[1] =3D 1;
> + =A0 =A0 =A0 }
> =A0}
>

Can you please post the meminfo before and after the changes (diff
maybe?). Can you also please share the ap and fp data from which the
percent figures are being calculated Is your swappiness set to 60? Can
you please share the OOM/panic message as well.

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
