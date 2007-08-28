Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id l7SK4e7r023441
	for <linux-mm@kvack.org>; Tue, 28 Aug 2007 13:04:40 -0700
Received: from an-out-0708.google.com (andd14.prod.google.com [10.100.30.14])
	by zps75.corp.google.com with ESMTP id l7SK4Fks014939
	for <linux-mm@kvack.org>; Tue, 28 Aug 2007 13:04:35 -0700
Received: by an-out-0708.google.com with SMTP id d14so249091and
        for <linux-mm@kvack.org>; Tue, 28 Aug 2007 13:04:35 -0700 (PDT)
Message-ID: <6599ad830708281304m18a34ab5m96692eafc55e3c57@mail.gmail.com>
Date: Tue, 28 Aug 2007 13:04:34 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm PATCH 5/10] Memory controller task migration (v7)
In-Reply-To: <20070828083252.C7D5C1BFA2F@siro.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <46D2A9D3.50703@linux.vnet.ibm.com>
	 <20070828083252.C7D5C1BFA2F@siro.lan>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@suse.de, a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On 8/28/07, YAMAMOTO Takashi <yamamoto@valinux.co.jp> wrote:
>
> although i have no good idea right now, something which allows
> to move a process with its thread group leader dead would be better.
>

One way I was thinking of approaching this problem was slightly different:

- every mm always has an "owning" task. Initially that will be the
thread that creates the mm

- if the owning thread exits or execs and *isn't* the last user of the
mm, then we may need to find a new owner for the mm:

1) My guess is that typically the thread that created the mm will also
be the last user of the mm - if this is the case, then in the normal
case we don't need to find a new owner.

2) If we do need a new owner, first look amongst the other threads in
the process (cheap, should find another user of the mm quickly)

3) next look in the child and parent threads (more expensive, but rarer)

4) if necessary, scan the entire thread list (expensive, but should
never be needed in general use)

The advantage of this is that we don't then need to have a memory
container pointer in the mm - we can just use the memory container of
the mm's owner.

With just a single container type needing to be tied to an mm, this
isn't a huge advantage since we're just replacing one pointer (memory
container) with another (owning task) and have similar levels of
complexity for both. But if we have multiple container subsystems that
need to be tied to a particular mm then they can both use the mm owner
pointer.

E.g. I want to add a swap container subsystem that restricts which
swap devices a group of processes can swap to, and how many pages they
can put into swap. And I want to be able to run this independently of
the in-memory page accounting subsystem. Having a task owner pointer
in the mm allows these to be indpendent subsystems, and (I believe)
isn't any more complex than the work involved to support moving an mm
whose thread group leader has exited or execd.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
