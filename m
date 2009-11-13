Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9F50F6B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 13:33:17 -0500 (EST)
Received: by iwn34 with SMTP id 34so2699443iwn.12
        for <linux-mm@kvack.org>; Fri, 13 Nov 2009 10:33:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091113181557.GM29804@csn.ul.ie>
References: <20091113142608.33B9.A69D9226@jp.fujitsu.com>
	 <20091113135443.GF29804@csn.ul.ie>
	 <20091114023138.3DA5.A69D9226@jp.fujitsu.com>
	 <20091113181557.GM29804@csn.ul.ie>
Date: Sat, 14 Nov 2009 03:33:16 +0900
Message-ID: <2f11576a0911131033w4a9e6042k3349f0be290a167e@mail.gmail.com>
Subject: Re: [PATCH] vmscan: Stop kswapd waiting on congestion when the min
	watermark is not being met
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> @@ -2092,8 +2102,12 @@ loop_again:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * OK, kswapd is getting into trouble. =A0=
Take a nap, then take
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * another pass across the zones.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned && priority < DEF_PRIORIT=
Y - 2)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_wait(BLK_RW_ASYN=
C, HZ/10);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (total_scanned && (priority < DEF_PRIORI=
TY - 2)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!has_under_min_watermar=
k_zone)

if I am correct, we must to remove "!".


> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 count_vm_ev=
ent(KSWAPD_NO_CONGESTION_WAIT);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 congestion_=
wait(BLK_RW_ASYNC, HZ/10);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
