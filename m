Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EC70C6B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 21:48:59 -0500 (EST)
Received: from zps38.corp.google.com (zps38.corp.google.com [172.25.146.38])
	by smtp-out.google.com with ESMTP id n0E2mtlr002596
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:48:55 -0800
Received: from rv-out-0708.google.com (rvfb17.prod.google.com [10.140.179.17])
	by zps38.corp.google.com with ESMTP id n0E2migl000929
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:48:44 -0800
Received: by rv-out-0708.google.com with SMTP id b17so327047rvf.36
        for <linux-mm@kvack.org>; Tue, 13 Jan 2009 18:48:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090108183529.b4fd99f4.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090108183529.b4fd99f4.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 13 Jan 2009 18:48:43 -0800
Message-ID: <6599ad830901131848gf7f6996iead1276bc50753b8@mail.gmail.com>
Subject: Re: [RFC][PATCH 4/4] cgroup-memcg fix frequent EBUSY at rmdir
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 8, 2009 at 1:35 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> +       if (ret == -EAGAIN) { /* subsys asks us to retry later */
> +               mutex_unlock(&cgroup_mutex);
> +               cond_resched();
> +               goto retry;
> +       }

This spinning worries me a bit. It might be better to do an
interruptible sleep until the relevant CSS's refcount goes down to
zero. And is there no way that the memory controller can hang on to a
reference indefinitely, if the cgroup still has some pages charged to
it?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
