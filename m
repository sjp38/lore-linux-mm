From: Paul Menage <menage@google.com>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
Date: Wed, 10 Dec 2008 10:35:34 -0800
Message-ID: <6599ad830812101035v33dbc6cfh57aa5510f6d65d54@mail.gmail.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830812100240g5e549a5cqe29cbea736788865@mail.gmail.com>
	 <29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756245AbYLJSgR@vger.kernel.org>
In-Reply-To: <29741.10.75.179.61.1228908581.squirrel@webmail-b.css.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Wed, Dec 10, 2008 at 3:29 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> (BTW, I don't like hierarchy-walk-by-small-locks approarch now because
>  I'd like to implement scan-and-stop-continue routine.
>  See how readdir() aginst /proc scans PID. It's very roboust against
>  very temporal PIDs.)

So you mean that you want to be able to sleep, and then contine
approximately where you left off, without keeping any kind of
reference count on the last cgroup that you touched? OK, so in that
case I agree that you would need some kind of hierarch

> I tried similar patch and made it to use only one shared refcnt.
> (my previous patch...)

A crucial difference is that your css_tryget() fails if the cgroups
framework is trying to remove the cgroup but might abort due to
another subsystem holding a reference, whereas mine spins and if the
rmdir is aborted it will return a refcount.

>
> We need rolling update of refcnts and rollback. Such code tends to make
> a hole (This was what my first patch did...).

Can you clarify what you mean by "rolling update of refcnts"?

>
> 1. pre_destroy() is called by rmdir(), in synchronized manner.
>   This means that all refs in memcg will be removed at rmdir().
>   If we drop refs at destroy(), it happens when dput()'s refcnt finally
>   goes down to 0. This asynchronous manner is not good for users.

OK, fair enough.

Paul
