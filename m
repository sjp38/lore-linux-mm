Received: from zps18.corp.google.com (zps18.corp.google.com [172.25.146.18])
	by smtp-out.google.com with ESMTP id m4E3S1t5003597
	for <linux-mm@kvack.org>; Wed, 14 May 2008 04:28:01 +0100
Received: from yw-out-2324.google.com (ywj3.prod.google.com [10.192.10.3])
	by zps18.corp.google.com with ESMTP id m4E3RxTm003400
	for <linux-mm@kvack.org>; Tue, 13 May 2008 20:28:00 -0700
Received: by yw-out-2324.google.com with SMTP id 3so1457421ywj.23
        for <linux-mm@kvack.org>; Tue, 13 May 2008 20:27:59 -0700 (PDT)
Message-ID: <6599ad830805132027w7b258257u82f7ddcf6e8c852b@mail.gmail.com>
Date: Tue, 13 May 2008 20:27:59 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH] another swap controller for cgroup
In-Reply-To: <20080514032125.46F7D5A07@siro.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <48231FB6.7000206@linux.vnet.ibm.com>
	 <20080514032125.46F7D5A07@siro.lan>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, minoura@valinux.co.jp, nishimura@mxp.nes.nec.co.jp, linux-mm@kvack.org, containers@lists.osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2008 at 8:21 PM, YAMAMOTO Takashi
<yamamoto@valinux.co.jp> wrote:
>
>  note that a failure can affect other subsystems which belong to
>  the same hierarchy as well, and, even worse, a back-out attempt can also fail.
>  i'm afraid that we need to play some kind of transaction-commit game,
>  which can make subsystems too complex to implement properly.
>

I was considering something like that - every call to can_attach()
would be guaranteed to be followed by either a call to attach() or to
a new method called cancel_attach(). Then the subsystem would just
need to ensure that nothing could happen which would cause the attach
to become invalid between the two calls.

Or possibly, since for some subsystems that might involve holding a
spinlock, we should extend it to:

After a successful call to can_attach(), either abort_attach() or
commit_attach() will be called; these calls are not allowed to sleep,
and cgroup.c will not sleep between calls.. If commit_attach() is
called, it will be followed shortly by attach(), which is allowed to
sleep.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
