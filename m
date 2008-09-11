Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out3.google.com with ESMTP id m8BJssNw019758
	for <linux-mm@kvack.org>; Thu, 11 Sep 2008 20:54:55 +0100
Received: from rv-out-0708.google.com (rvbf25.prod.google.com [10.140.82.25])
	by wpaz1.hot.corp.google.com with ESMTP id m8BJsgwv017908
	for <linux-mm@kvack.org>; Thu, 11 Sep 2008 12:54:53 -0700
Received: by rv-out-0708.google.com with SMTP id f25so469315rvb.50
        for <linux-mm@kvack.org>; Thu, 11 Sep 2008 12:54:53 -0700 (PDT)
Message-ID: <6599ad830809111254h62e1945egd72b30f2c8585104@mail.gmail.com>
Date: Thu, 11 Sep 2008 12:54:53 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH -mm] cgroup,cpuset: use alternative malloc to allocate large memory buf for tasks
In-Reply-To: <6599ad830809110945pb85ec68o16328b31cbb0dc52@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <48C8F32E.2020004@cn.fujitsu.com>
	 <6599ad830809110945pb85ec68o16328b31cbb0dc52@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Paul Jackson <pj@sgi.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Sep 11, 2008 at 9:45 AM, Paul Menage <menage@google.com> wrote:
> On Thu, Sep 11, 2008 at 3:30 AM, Lai Jiangshan <laijs@cn.fujitsu.com> wrote:
>> This new alternative allocation implementation can allocate memory
>> up to 64M in 32bits system or 512M in 64bits system.
>
> Isn't a lot of this patch just reimplementing vmalloc()?

To extend on this, I think there are two ways of fixing the large
allocation problem:

1) just use vmalloc() rather than kmalloc() when the pid array is over
a certain threshold (probably 1 page?)

2) allocate pages/chunks in a similar way to your CL, but don't bother
mapping them. Instead we'd use the fact that each record (pid) is the
same size, and hence we can very easily use the high bits of an index
to select the chunk and the low bits to select the pid within the
chunk - no need to suffer the overhead of setting up and tearing down
ptes in order for the MMU do the same operation for us in hardware.

Obviously option 1 is a lot simpler, but option 2 avoids a
vmap()/vunmap() on every open/close of a tasks file. I'm not familiar
enough with the performance of vmap/vunmap on typical
hardware/workloads to know how high this overhead is  - maybe a VM
guru can comment?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
