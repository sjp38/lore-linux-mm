Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AB5DD6B0044
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 21:23:09 -0500 (EST)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id n0K2N6tX010227
	for <linux-mm@kvack.org>; Tue, 20 Jan 2009 02:23:06 GMT
Received: from rv-out-0506.google.com (rvbk40.prod.google.com [10.140.87.40])
	by wpaz1.hot.corp.google.com with ESMTP id n0K2Mj4Y005680
	for <linux-mm@kvack.org>; Mon, 19 Jan 2009 18:23:03 -0800
Received: by rv-out-0506.google.com with SMTP id k40so3193167rvb.11
        for <linux-mm@kvack.org>; Mon, 19 Jan 2009 18:23:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090120110221.005e116c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090115192712.33b533c3.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830901191739t45c793afk2ceda8fc430121ce@mail.gmail.com>
	 <20090120110221.005e116c.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 19 Jan 2009 18:23:03 -0800
Message-ID: <6599ad830901191823q556faeeub28d02d39dda7396@mail.gmail.com>
Subject: Re: [PATCH 2/4] cgroup:add css_is_populated
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 19, 2009 at 6:02 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Ah, this is related to CSS ID scanning. No real problem to current codes.
>
> Now, in my patch, CSS ID is attached just after create().
>
> Then, "scan by CSS ID" can find a cgroup which is not populated yet.
> I just wanted to skip them for avoiding mess.
>
> For example, css_tryget() can succeed against css which belongs to not-populated
> cgroup. If creation of cgroup fails, it's destroyed and freed without RCU synchronize.
> This may breaks CSS ID scanning's assumption that "we're safe under rcu_read_lock".
> And allows destroy css while css->refcnt > 1.

So for the CSS ID case, we could solve this by not populating
css_id->css until creation is guaranteed to have succeeded? (We'd
still allocated the css_id along with the subsystem, just not complete
its initialization). cgroup.c already knows about and hides the
details of css_id, so this wouldn't be hard.

The question is whether other users of css_tryget() might run into
this problem, without using CSS IDs. But currently no-one's using
css_tryget() apart from you, so that's a problem we can solve as it
arises.

I think we're safe from css_get() being used in this case, since
css_get() can only be used on css references obtained from a locked
task, or from other pointers that are known to be ref-counted, which
would be impossible if css_tryget() can't succeed on a css in the
partially-completed state.


Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
