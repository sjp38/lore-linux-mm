Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m2OHkjGW032402
	for <linux-mm@kvack.org>; Mon, 24 Mar 2008 17:46:45 GMT
Received: from wx-out-0506.google.com (wxct4.prod.google.com [10.70.121.4])
	by zps75.corp.google.com with ESMTP id m2OHkc8M002749
	for <linux-mm@kvack.org>; Mon, 24 Mar 2008 10:46:44 -0700
Received: by wx-out-0506.google.com with SMTP id t4so3060961wxc.18
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 10:46:44 -0700 (PDT)
Message-ID: <6599ad830803241046l61e2965t52fd28e165d5df7a@mail.gmail.com>
Date: Mon, 24 Mar 2008 10:46:43 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm] Memory controller add mm->owner
In-Reply-To: <47E7E5D0.9020904@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080324140142.28786.97267.sendpatchset@localhost.localdomain>
	 <6599ad830803240803s5160101bi2bf68b36085f777f@mail.gmail.com>
	 <47E7D51E.4050304@linux.vnet.ibm.com>
	 <6599ad830803240934g2a70d904m1ca5548f8644c906@mail.gmail.com>
	 <47E7E5D0.9020904@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Mar 24, 2008 at 10:33 AM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
>  > OK, so we don't need to handle this for NPTL apps - but for anything
>  > still using LinuxThreads or manually constructed clone() calls that
>  > use CLONE_VM without CLONE_PID, this could still be an issue.
>
>  CLONE_PID?? Do you mean CLONE_THREAD?

Yes, sorry - CLONE_THREAD.

>
>  For the case you mentioned, mm->owner is a moving target and we don't want to
>  spend time finding the successor, that can be expensive when threads start
>  exiting one-by-one quickly and when the number of threads are high. I wonder if
>  there is an efficient way to find mm->owner in that case.
>

But:

- running a high-threadcount LinuxThreads process is by definition
inefficient and expensive (hence the move to NPTL)

- any potential performance hit is only paid at exit time

- in the normal case, any of your children or one of your siblings
will be a suitable alternate owner

- in the worst case, it's not going to be worse than doing a
for_each_thread() loop

so I don't think this would be a major problem

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
