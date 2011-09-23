Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3D2689000BD
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 06:18:23 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p8NAIJeu011437
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 03:18:19 -0700
Received: from qyg14 (qyg14.prod.google.com [10.241.82.142])
	by wpaz33.hot.corp.google.com with ESMTP id p8NAHTeM012101
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 23 Sep 2011 03:18:18 -0700
Received: by qyg14 with SMTP id 14so3791060qyg.9
        for <linux-mm@kvack.org>; Fri, 23 Sep 2011 03:18:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110922161523.f5b2193f.akpm@google.com>
References: <1316230753-8693-1-git-send-email-walken@google.com>
	<1316230753-8693-7-git-send-email-walken@google.com>
	<20110922161523.f5b2193f.akpm@google.com>
Date: Fri, 23 Sep 2011 03:18:13 -0700
Message-ID: <CANN689GtH_vf-iOJyNjhet8-DXd=ermbmUykNJfKvg0yw=FiWQ@mail.gmail.com>
Subject: Re: [PATCH 6/8] kstaled: rate limit pages scanned per second.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Sep 22, 2011 at 4:15 PM, Andrew Morton <akpm@google.com> wrote:
> On Fri, 16 Sep 2011 20:39:11 -0700
> Michel Lespinasse <walken@google.com> wrote:
>
>> Scan some number of pages from each node every second, instead of trying=
 to
>> scan the entime memory at once and being idle for the rest of the config=
ured
>> interval.
>
> Well... =A0why? =A0The amount of work done per scan interval is the same
> (actually, it will be slightly increased due to cache evictions).
>
> I think we should see a good explanation of what observed problem this
> hackery^Wtweak is trying to solve. =A0Once that is revealed, we can
> compare the proposed solution with one based on thread policy/priority
> (for example).

There are two aspects to this:

- some people might find it nicer to have a small amount of load
during the entire scan interval, rather than some spike when we
trigger the scanning and some idle time afterwards. That part is
highly debatable and there are probably better ways to achieve this.

- jitter reduction - if we were to scan the entire memory at once
without sleeping, the pages that are scanned first would have a fairly
constant interval between times they are looked at; however if the
time to scan pages is not constant (it could vary depending on CPU
load and pages getting allocated and freed) the pages that are scanned
towards the end of each scan would have a bit more jitter. This effect
is reduced by trying to scan a fixed number of pages per second.

> This is all rather unpleasing.

Yeah, this is not my favourite patch in the series :/

Would it help if I reordered it last in the series, as it seems more
controversial & the later ones don't functionally depend on it ?

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
