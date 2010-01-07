Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DDFAA6B0085
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 20:01:32 -0500 (EST)
Received: from spaceape24.eur.corp.google.com (spaceape24.eur.corp.google.com [172.28.16.76])
	by smtp-out.google.com with ESMTP id o0711SE4014525
	for <linux-mm@kvack.org>; Thu, 7 Jan 2010 01:01:28 GMT
Received: from pwj10 (pwj10.prod.google.com [10.241.219.74])
	by spaceape24.eur.corp.google.com with ESMTP id o0710ArS026016
	for <linux-mm@kvack.org>; Wed, 6 Jan 2010 17:01:27 -0800
Received: by pwj10 with SMTP id 10so5173163pwj.26
        for <linux-mm@kvack.org>; Wed, 06 Jan 2010 17:01:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill@shutemov.name>
References: <cover.1262186097.git.kirill@shutemov.name>
	 <9411cbdd545e1232c916bfef03a60cf95510016d.1262186098.git.kirill@shutemov.name>
Date: Wed, 6 Jan 2010 17:01:21 -0800
Message-ID: <6599ad831001061701x72098dacn7a5d916418396e33@mail.gmail.com>
Subject: Re: [PATCH v5 1/4] cgroup: implement eventfd-based generic API for
	notifications
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: containers@lists.linux-foundation.org, linux-mm@kvack.org, Li Zefan <lizf@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, Dan Malek <dan@embeddedalley.com>, Vladislav Buzov <vbuzov@embeddedalley.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Alexander Shishkin <virtuoso@slind.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 30, 2009 at 7:57 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> This patch introduces write-only file "cgroup.event_control" in every
> cgroup.

This looks like a nice generic API for doing event notifications - thanks!

Sorry I hadn't had a chance to review it before now, due to travelling
and day-job pressures.


> +}
> +
> +static int cgroup_event_wake(wait_queue_t *wait, unsigned mode,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int sync, void *key)

Maybe some comments here indicating how/when it gets called? (And more
comments for each function generally?)

> + =A0 =A0 =A0 if (flags & POLLHUP) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&cgrp->event_list_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&event->list);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&cgrp->event_list_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_work(&event->remove);

Comment saying why we can't do the remove immediately in this context?

> +
> +fail:
> + =A0 =A0 =A0 if (!IS_ERR(cfile))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(cfile);

cfile is either valid or NULL - it never contains an error value.

> +
> + =A0 =A0 =A0 if (!IS_ERR(efile))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 fput(efile);

While this is OK currently, it's a bit fragile. efile starts as NULL,
and IS_ERR(NULL) is false. So if we jump to fail: before trying to do
the eventfd_fget() then we'll try to fput(NULL), which will oops. This
works because we don't currently jump to fail: until after
eventfd_fget(), but someone could add an extra setup step between the
kzalloc() and the eventfd_fget() which could fail.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
