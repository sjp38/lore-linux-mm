Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id m4FFSmYW026487
	for <linux-mm@kvack.org>; Thu, 15 May 2008 16:28:48 +0100
Received: from yw-out-1718.google.com (ywm5.prod.google.com [10.192.13.5])
	by zps35.corp.google.com with ESMTP id m4FFSkVA023485
	for <linux-mm@kvack.org>; Thu, 15 May 2008 08:28:47 -0700
Received: by yw-out-1718.google.com with SMTP id 5so234312ywm.22
        for <linux-mm@kvack.org>; Thu, 15 May 2008 08:28:46 -0700 (PDT)
Message-ID: <6599ad830805150828i6b61755dk9ce5213607621af7@mail.gmail.com>
Date: Thu, 15 May 2008 08:28:46 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm][PATCH 4/4] Add memrlimit controller accounting and control (v4)
In-Reply-To: <20080515082553.GK31115@balbir.in.ibm.com>
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
	 <6599ad830805150039u76c9002cg6c873fd71e687a69@mail.gmail.com>
	 <20080515082553.GK31115@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 15, 2008 at 1:25 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  >
>  > But the only *new* cases of taking the mmap_sem that this would
>  > introduce would be:
>  >
>  > - on a failed vm limit charge
>
>  Why a failed charge? Aren't we talking of moving all charge/uncharge
>  under mmap_sem?
>

Sorry, I worded that wrongly - I meant "cleaning up a successful
charge after an expansion fails for other reasons"

I thought that all the charges and most of the uncharges were already
under mmap_sem, and it would just be a few of the cleanup paths that
needed to take it.

>
>  > - when a task moves between two cgroups in the memrlimit hierarchy.
>  >
>
>  Yes, this would nest cgroup_mutex and mmap_sem. Not sure if that would
>  be a bad side-effect.
>

I think it's already nested that way - e.g. the cpusets code can call
various migration functions (which take mmap_sem) while holding
cgroup_mutex.

>
>  Refactor the code to try and use mmap_sem and see what I come up
>  with. Basically use mmap_sem for all charge/uncharge operations as
>  well use mmap_sem in read_mode in the move_task() and
>  mm_owner_changed() callbacks. That should take care of the race
>  conditions discussed, unless I missed something.

Sounds good.

Thanks,

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
