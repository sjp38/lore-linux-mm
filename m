Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 486AC6B0044
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 08:32:01 -0500 (EST)
Received: by pzk34 with SMTP id 34so45633pzk.11
        for <linux-mm@kvack.org>; Tue, 24 Nov 2009 05:31:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091124145759.194cfc9f.nishimura@mxp.nes.nec.co.jp>
References: <20091124145759.194cfc9f.nishimura@mxp.nes.nec.co.jp>
Date: Tue, 24 Nov 2009 19:01:54 +0530
Message-ID: <661de9470911240531p5e587c42w96995fde37dbd401@mail.gmail.com>
Subject: Re: [BUGFIX][PATCH -mmotm] memcg: avoid oom-killing innocent task in
	case of use_hierarchy
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, stable <stable@kernel.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 11:27 AM, Daisuke Nishimura
<nishimura@mxp.nes.nec.co.jp> wrote:
> task_in_mem_cgroup(), which is called by select_bad_process() to check wh=
ether
> a task can be a candidate for being oom-killed from memcg's limit, checks
> "curr->use_hierarchy"("curr" is the mem_cgroup the task belongs to).
>
> But this check return true(it's false positive) when:
>
> =A0 =A0 =A0 =A0<some path>/00 =A0 =A0 =A0 =A0 =A0use_hierarchy =3D=3D 0 =
=A0 =A0 =A0<- hitting limit
> =A0 =A0 =A0 =A0 =A0<some path>/00/aa =A0 =A0 use_hierarchy =3D=3D 1 =A0 =
=A0 =A0<- "curr"
>
> This leads to killing an innocent task in 00/aa. This patch is a fix for =
this
> bug. And this patch also fixes the arg for mem_cgroup_print_oom_info(). W=
e
> should print information of mem_cgroup which the task being killed, not c=
urrent,
> belongs to.
>

Quick Question: What happens if <some path>/00 has no tasks in it
after your patches?

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
