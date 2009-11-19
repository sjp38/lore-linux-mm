Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7DD766B004D
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 16:42:31 -0500 (EST)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id nAJLgNgH009230
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 21:42:24 GMT
Received: from pxi29 (pxi29.prod.google.com [10.243.27.29])
	by wpaz24.hot.corp.google.com with ESMTP id nAJLgK8w003831
	for <linux-mm@kvack.org>; Thu, 19 Nov 2009 13:42:21 -0800
Received: by pxi29 with SMTP id 29so948835pxi.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2009 13:42:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091119132828.29aba7b2.nishimura@mxp.nes.nec.co.jp>
References: <20091119132734.1757fc42.nishimura@mxp.nes.nec.co.jp>
	 <20091119132828.29aba7b2.nishimura@mxp.nes.nec.co.jp>
Date: Thu, 19 Nov 2009 13:42:19 -0800
Message-ID: <6599ad830911191342q3709338apc14950a6de80b128@mail.gmail.com>
Subject: Re: [PATCH -mmotm 1/5] cgroup: introduce cancel_attach()
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 18, 2009 at 8:28 PM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> This patch adds cancel_attach() operation to struct cgroup_subsys.
> cancel_attach() can be used when can_attach() operation prepares somethin=
g
> for the subsys, but we should rollback what can_attach() operation has pr=
epared
> if attach task fails after we've succeeded in can_attach().
>
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Acked-by: Li Zefan <lizf@cn.fujitsu.com>

Reviewed-by: Paul Menage <menage@google.com>

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Rememb=
er at which subsystem we've failed in
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* can_at=
tach() to call cancel_attach() only
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* agains=
t subsystems whose attach() have
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* succee=
ded(see below).

Maybe: Remember on which subsystem the can_attach() failed, so that we
only call cancel_attach() against the subsystems whose can_attach()
succeeded. (See below)

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* This m=
eans can_attach() of this subsystem
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* have f=
ailed, so we don't need to call
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* cancel=
_attach() against rests of subsystems.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/

Maybe: This subsystem was the one that failed the can_attach() check
earlier, so we don't need to call cancel_attach() against it or any
remaining subsystems.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
