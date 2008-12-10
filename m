Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id mBAMmdsb012468
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 14:48:39 -0800
Received: from rv-out-0708.google.com (rvfb17.prod.google.com [10.140.179.17])
	by zps77.corp.google.com with ESMTP id mBAMmbOi023248
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 14:48:38 -0800
Received: by rv-out-0708.google.com with SMTP id b17so671538rvf.46
        for <linux-mm@kvack.org>; Wed, 10 Dec 2008 14:48:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20081210133508.3ee454ae.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081210133508.3ee454ae.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 10 Dec 2008 14:48:37 -0800
Message-ID: <6599ad830812101448h46e1ea1cs80635611f9205962@mail.gmail.com>
Subject: Re: [PATCH mmotm 1/2] cgroup: fix to stop adding a new task while
	rmdir going on
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 9, 2008 at 8:35 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> still need reviews.
> ==
> Recently, pre_destroy() was moved to out of cgroup_lock() for avoiding
> dead lock. But, by this, serialization between task attach and rmdir()
> is lost.
>
> This adds CGRP_TRY_REMOVE flag to cgroup and check it at attaching.
> If attach_pid founds CGRP_TRY_REMOVE, it returns -EBUSY.

As I've mentioned in other threads, I think the fix is to restore the
locking for pre_destroy(), and solve the other potential deadlocks in
better ways.

This patch can result in an attach falsely getting an EBUSY when it
shouldn't really do so (since the cgroup wasn't really going away).

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
