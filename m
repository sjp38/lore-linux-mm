Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6B72B6B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 22:05:42 -0500 (EST)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id n0E35de6013259
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 03:05:39 GMT
Received: from rv-out-0708.google.com (rvbf25.prod.google.com [10.140.82.25])
	by wpaz33.hot.corp.google.com with ESMTP id n0E35KZg028792
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 19:05:36 -0800
Received: by rv-out-0708.google.com with SMTP id f25so353051rvb.18
        for <linux-mm@kvack.org>; Tue, 13 Jan 2009 19:05:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090114120044.2ecf13db.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090108182556.621e3ee6.kamezawa.hiroyu@jp.fujitsu.com>
	 <20090108183529.b4fd99f4.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830901131848gf7f6996iead1276bc50753b8@mail.gmail.com>
	 <20090114120044.2ecf13db.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 13 Jan 2009 19:05:35 -0800
Message-ID: <6599ad830901131905ie10e4bl5168ab7f337b27e1@mail.gmail.com>
Subject: Re: [RFC][PATCH 4/4] cgroup-memcg fix frequent EBUSY at rmdir
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 13, 2009 at 7:00 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> Hmm, add wait_queue to css and wake it up at css_put() ?
>
> like this ?
> ==
> __css_put()
> {
>        if (atomi_dec_return(&css->refcnt) == 1) {
>                if (notify_on_release(cgrp) {
>                        .....
>                }
>                if (someone_waiting_rmdir(css)) {
>                        wake_up_him().
>                }
>        }
> }

Yes, something like that. A system-wide wake queue is probably fine though.

> pre_destroy() is for that.  Now, If there are still references from "page"
> after pre_destroy(), it's bug.

OK.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
