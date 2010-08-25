Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4F96B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 20:06:01 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o7P09RKJ008313
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:09:27 -0700
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by kpbe16.cbf.corp.google.com with ESMTP id o7P09PKT014451
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:09:26 -0700
Received: by pzk3 with SMTP id 3so3301741pzk.36
        for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:09:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 24 Aug 2010 17:09:25 -0700
Message-ID: <AANLkTi=imK6Px+JrdVupg2V3jtN9pgmEdWv=+aB1XKLY@mail.gmail.com>
Subject: Re: [PATCH 1/5] cgroup: ID notification call back
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 2:58 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> CC'ed to Paul Menage and Li Zefan.
> =3D=3D
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> When cgroup subsystem use ID (ss->use_id=3D=3D1), each css's ID is assign=
ed
> after successful call of ->create(). css_ID is tightly coupled with
> css struct itself but it is allocated by ->create() call, IOW,
> per-subsystem special allocations.
>
> To know css_id before creation, this patch adds id_attached() callback.
> after css_ID allocation. This will be used by memory cgroup's quick looku=
p
> routine.
>
> Maybe you can think of other implementations as
> =A0 =A0 =A0 =A0- pass ID to ->create()
> =A0 =A0 =A0 =A0or
> =A0 =A0 =A0 =A0- add post_create()
> =A0 =A0 =A0 =A0etc...
> But when considering dirtiness of codes, this straightforward patch seems
> good to me. If someone wants post_create(), this patch can be replaced.

I think I'd prefer the approach where any necessary css_ids are
allocated prior to calling any create methods (which gives the
additional advantage of removing the need to roll back partial
creation of a cgroup in the event of alloc_css_id() failing) and then
passed in to the create() method. The main cgroups framework would
still be responsible for actually filling the css->id field with the
allocated id.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
