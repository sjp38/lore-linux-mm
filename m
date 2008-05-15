Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id m4F7dln6008918
	for <linux-mm@kvack.org>; Thu, 15 May 2008 08:39:47 +0100
Received: from an-out-0708.google.com (ancc5.prod.google.com [10.100.29.5])
	by zps75.corp.google.com with ESMTP id m4F7djth006907
	for <linux-mm@kvack.org>; Thu, 15 May 2008 00:39:46 -0700
Received: by an-out-0708.google.com with SMTP id c5so77106anc.0
        for <linux-mm@kvack.org>; Thu, 15 May 2008 00:39:45 -0700 (PDT)
Message-ID: <6599ad830805150039u76c9002cg6c873fd71e687a69@mail.gmail.com>
Date: Thu, 15 May 2008 00:39:45 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and control (v4)
In-Reply-To: <20080515070342.GJ31115@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080514130904.24440.23486.sendpatchset@localhost.localdomain>
	 <20080514130951.24440.73671.sendpatchset@localhost.localdomain>
	 <20080514132529.GA25653@balbir.in.ibm.com>
	 <6599ad830805141925mf8a13daq7309148153a3c2df@mail.gmail.com>
	 <20080515061727.GC31115@balbir.in.ibm.com>
	 <6599ad830805142355ifeeb0e2w86ccfd96aa27aea6@mail.gmail.com>
	 <20080515070342.GJ31115@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 15, 2008 at 12:03 AM, Balbir Singh
<balbir@linux.vnet.ibm.com> wrote:
>
>  I want to focus on this conclusion/assertion, since it takes care of
>  most of the locking related discussion above, unless I missed
>  something.
>
>  My concern with using mmap_sem, is that
>
>  1. It's highly contended (every page fault, vma change, etc)

But the only *new* cases of taking the mmap_sem that this would
introduce would be:

- on a failed vm limit charge
- when a task exit/exec causes an mm ownership change
- when a task moves between two cgroups in the memrlimit hierarchy.

All of these should be rare events, so I don't think the additional
contention is a worry.

>  2. It's going to make the locking hierarchy deeper and complex

Yes, potentially. But if the upside of that is that we eliminate a
lock/unlock on a shared lock on every mmap/munmap call, it might well
be worth it.

>  3. It's not appropriate to call all the accounting callbacks with
>    the mmap_sem() held, since the undo operations _can get_ complicated
>    at the caller.
>

Can you give an example?

>  I would prefer introducing a new lock, so that other subsystems are
>  not affected.
>

For getting the first cut of the memrlimit controller working this may
well make sense. But it would be nice to avoid it longer-term.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
