Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4644A6B0044
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 20:39:48 -0500 (EST)
Received: from wpaz13.hot.corp.google.com (wpaz13.hot.corp.google.com [172.24.198.77])
	by smtp-out.google.com with ESMTP id n0K1dkZ0013968
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 17:39:46 -0800
Received: from rv-out-0506.google.com (rvfb25.prod.google.com [10.140.179.25])
	by wpaz13.hot.corp.google.com with ESMTP id n0K1deHI010195
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 17:39:41 -0800
Received: by rv-out-0506.google.com with SMTP id b25so3003512rvf.43
        for <linux-mm@kvack.org>; Mon, 19 Jan 2009 17:39:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 19 Jan 2009 17:39:40 -0800
Message-ID: <6599ad830901191739t45c793afk2ceda8fc430121ce@mail.gmail.com>
Subject: Re: [PATCH 2/4] cgroup:add css_is_populated
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 15, 2009 at 2:27 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> cgroup creation is done in several stages.
> After allocated and linked to cgroup's hierarchy tree, all necessary
> control files are created.
>
> When using CSS_ID, scanning cgroups without cgrouo_lock(), status
> of cgroup is important. At removal of cgroup/css, css_tryget() works fine
> and we can write a safe code.

What problems are you currently running into during creation? Won't
the fact that the css for the cgroup has been created, and its pointer
been stored in the cgroup, be sufficient?

Or is the problem that a cgroup that fails creation half-way could
result in the memory code alreadying having taken a reference on the
memcg, which can't then be cleanly destroyed?

Paul

> "This cgroup is not ready yet"
>
> This patch adds CSS_POPULATED flag.
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> ---
> Index: mmotm-2.6.29-Jan14/include/linux/cgroup.h
> ===================================================================
> --- mmotm-2.6.29-Jan14.orig/include/linux/cgroup.h
> +++ mmotm-2.6.29-Jan14/include/linux/cgroup.h
> @@ -69,6 +69,7 @@ struct cgroup_subsys_state {
>  enum {
>        CSS_ROOT, /* This CSS is the root of the subsystem */
>        CSS_REMOVED, /* This CSS is dead */
> +       CSS_POPULATED, /* This CSS finished all initialization */
>  };
>
>  /*
> @@ -90,6 +91,11 @@ static inline bool css_is_removed(struct
>        return test_bit(CSS_REMOVED, &css->flags);
>  }
>
> +static inline bool css_is_populated(struct cgroup_subsys_state *css)
> +{
> +       return test_bit(CSS_POPULATED, &css->flags);
> +}
> +
>  /*
>  * Call css_tryget() to take a reference on a css if your existing
>  * (known-valid) reference isn't already ref-counted. Returns false if
> Index: mmotm-2.6.29-Jan14/kernel/cgroup.c
> ===================================================================
> --- mmotm-2.6.29-Jan14.orig/kernel/cgroup.c
> +++ mmotm-2.6.29-Jan14/kernel/cgroup.c
> @@ -2326,8 +2326,10 @@ static int cgroup_populate_dir(struct cg
>        }
>
>        for_each_subsys(cgrp->root, ss) {
> +               struct cgroup_subsys_state *css = cgrp->subsys[ss->subsys_id];
>                if (ss->populate && (err = ss->populate(ss, cgrp)) < 0)
>                        return err;
> +               set_bit(CSS_POPULATED, &css->flags);
>        }
>
>        return 0;
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
