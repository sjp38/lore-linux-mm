Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFA66B0055
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 03:37:33 -0400 (EDT)
Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id n9F7bQJY016758
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 08:37:27 +0100
Received: from pzk27 (pzk27.prod.google.com [10.243.19.155])
	by zps37.corp.google.com with ESMTP id n9F7bNTn005025
	for <linux-mm@kvack.org>; Thu, 15 Oct 2009 00:37:24 -0700
Received: by pzk27 with SMTP id 27so527634pzk.12
        for <linux-mm@kvack.org>; Thu, 15 Oct 2009 00:37:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20091013135027.c60285a8.nishimura@mxp.nes.nec.co.jp>
References: <20091013134903.66c9682a.nishimura@mxp.nes.nec.co.jp>
	 <20091013135027.c60285a8.nishimura@mxp.nes.nec.co.jp>
Date: Thu, 15 Oct 2009 00:37:23 -0700
Message-ID: <6599ad830910150037j7aca0020mfbe29d6c03befbf7@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/8] cgroup: introduce cancel_attach()
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 12, 2009 at 9:50 PM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> =A0int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
> =A0{
> =A0 =A0 =A0 =A0int retval =3D 0;
> - =A0 =A0 =A0 struct cgroup_subsys *ss;
> + =A0 =A0 =A0 struct cgroup_subsys *ss, *fail =3D NULL;

Maybe give this a more descriptive name, such as "failed_subsys" ?

> @@ -1553,8 +1553,10 @@ int cgroup_attach_task(struct cgroup *cgrp, struct=
 task_struct *tsk)
> =A0 =A0 =A0 =A0for_each_subsys(root, ss) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (ss->can_attach) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0retval =3D ss->can_attach(=
ss, cgrp, tsk, false);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return retv=
al;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (retval) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 fail =3D ss=
;

Comment here on why you set "fail" ?
> +out:
> + =A0 =A0 =A0 if (retval)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_subsys(root, ss) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ss =3D=3D fail)

Comment here?

The problem with this API is that the subsystem doesn't know how long
it needs to hold on to the potential rollback state for. The design
for transactional cgroup attachment that I sent out over a year ago
presented a more robust API, but I've not had time to work on it. So
maybe this patch could be a stop-gap.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
