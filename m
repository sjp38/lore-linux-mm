Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id B7BBE6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 13:42:26 -0500 (EST)
Message-ID: <4F468888.9090702@fb.com>
Date: Thu, 23 Feb 2012 10:42:16 -0800
From: Arun Sharma <asharma@fb.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Enable MAP_UNINITIALIZED for archs with mmu
References: <1326912662-18805-1-git-send-email-asharma@fb.com> <CAKTCnzn-reG4bLmyWNYPELYs-9M3ZShEYeOix_OcnPow-w8PNg@mail.gmail.com>
In-Reply-To: <CAKTCnzn-reG4bLmyWNYPELYs-9M3ZShEYeOix_OcnPow-w8PNg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org

Hi Balbir,

Thanks for reviewing. Would you change your position if I limit the 
scope of the patch to a cgroup with a single address space?

The moment the cgroup sees more than one address space (either due to 
tasks getting created or being added), this optimization would be turned 
off.

More details below:

On 2/22/12 11:45 PM, Balbir Singh wrote:
>
> So the assumption is that only apps that have access to each others
> VMA's will run in this cgroup?
>

In a distributed computing environment, a user submits a job to the 
cluster job scheduler. The job might involve multiple related 
executables and might involve multiple address spaces. But they're 
performing one logical task, have a single resource limit enforced by a 
cgroup.

They don't have access to each other's VMAs, but if "accidentally" one 
of them comes across an uninitialized page with data from another task, 
it's not a violation of the security model.

> Sorry, I am not convinced we need to do this
>
> 1. I know that zeroing out memory is expensive, but building a
> potential loop hole is not a good idea
> 2. How do we ensure that tasks in a cgroup should be allowed to reuse
> memory uninitialized, how does the cgroup admin know what she is
> getting into?

I was thinking of addressing this via documentation (as in: don't use 
this if you don't know what you're doing!). But limiting the scope to a 
single address space cgroup seems cleaner to me.

  -Arun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
