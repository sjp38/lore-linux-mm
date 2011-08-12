Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A04256B0169
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 19:46:06 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p7CNk4FO018885
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 16:46:04 -0700
Received: from gxk1 (gxk1.prod.google.com [10.202.11.1])
	by wpaz24.hot.corp.google.com with ESMTP id p7CNjxFl015387
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 16:46:03 -0700
Received: by gxk1 with SMTP id 1so2080022gxk.10
        for <linux-mm@kvack.org>; Fri, 12 Aug 2011 16:45:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110812172758.GL2395@linux.vnet.ibm.com>
References: <1312492042-13184-1-git-send-email-walken@google.com>
	<CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
	<20110807142532.GC1823@barrios-desktop>
	<CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
	<20110812153616.GH7959@redhat.com>
	<20110812160813.GF2395@linux.vnet.ibm.com>
	<20110812164325.GK7959@redhat.com>
	<20110812172758.GL2395@linux.vnet.ibm.com>
Date: Fri, 12 Aug 2011 16:45:59 -0700
Message-ID: <CANN689GmsnRXwuy2GGWQopic_68LbEiDGNzbJCTDAN=FvDKXJg@mail.gmail.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 10:27 AM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> Or maybe I make rcu_cookie_gp_elapsed() take only one cookie and
> compare it to the current cookie. =A0This would save a bit of code in
> the TINY cases:
>
> =A0 =A0 =A0 =A0rcu_get_gp_cookie(&pagep->rcucookie);
> =A0 =A0 =A0 =A0. . .
>
> =A0 =A0 =A0 =A0if (!rcu_cookie_gp_elapsed(&pagep->rcucookie))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0synchronize_rcu();

Agree this looks nicer that having the second cookie on the stack. As
you said, this does not allow us to compare two past points in time,
but I really don't see a use case for that.

> How long would there normally be between recording the cookie and
> checking for the need for a grace period? =A0One disk access? =A0One HZ?
> Something else?

I would expect >>10 seconds in the normal case ? I'm not sure how much
lower this may get in adverse workloads. Andrea ?

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
