Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E04DC6B01F0
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 20:31:07 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o7P0YerF017303
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:34:40 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by kpbe16.cbf.corp.google.com with ESMTP id o7P0Yc2l004350
	for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:34:38 -0700
Received: by pzk4 with SMTP id 4so3244720pzk.21
        for <linux-mm@kvack.org>; Tue, 24 Aug 2010 17:34:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100825092010.cfe91b1a.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100820185552.426ff12e.kamezawa.hiroyu@jp.fujitsu.com>
	<20100820185816.1dbcd53a.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=imK6Px+JrdVupg2V3jtN9pgmEdWv=+aB1XKLY@mail.gmail.com>
	<20100825092010.cfe91b1a.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 24 Aug 2010 17:34:38 -0700
Message-ID: <AANLkTikD3CFRPo7WvWwCnLQ+jzEs6rUk1sivYM3aRbGJ@mail.gmail.com>
Subject: Re: [PATCH 1/5] cgroup: ID notification call back
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kamezawa.hiroyuki@gmail.com, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 24, 2010 at 5:20 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> Hmm, sure. I'll change the ->create() interface. =A0O.K. ?
>

Hmm. An alternative (possibly cleaner) would be:

1) add a css_size field in cgroup_subsys that contains the size of the
per-subsystem structure
2) change cgroups to allocate and populate the css *before* calling
create(), since it now knows the actual size
3) simplify all the subsystem create() methods since they no longer
have to worry about allocation or out-of-memory handling
4) also add a top_css field in cgroups that allows cpusets to use the
statically-allocated top_cpuset since it's initialized prior to memory
allocation being reliable

This avoids us having to pass in any new parameters to the create()
method in future since they can be populated in the CSS.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
