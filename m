Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4E2516B004F
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 20:46:06 -0500 (EST)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n0E1k1kD008558
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 01:46:01 GMT
Received: from qw-out-2122.google.com (qwe3.prod.google.com [10.241.194.3])
	by spaceape9.eur.corp.google.com with ESMTP id n0E1jtIU029640
	for <linux-mm@kvack.org>; Tue, 13 Jan 2009 17:45:56 -0800
Received: by qw-out-2122.google.com with SMTP id 3so67818qwe.43
        for <linux-mm@kvack.org>; Tue, 13 Jan 2009 17:45:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20090107184116.18062.8379.sendpatchset@localhost.localdomain>
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain>
	 <20090107184116.18062.8379.sendpatchset@localhost.localdomain>
Date: Tue, 13 Jan 2009 17:45:54 -0800
Message-ID: <6599ad830901131745t704428dav6fbf69aa315285b1@mail.gmail.com>
Subject: Re: [RFC][PATCH 1/4] Memory controller soft limit documentation
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 7, 2009 at 10:41 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> -7. TODO
> +7. Soft limits
> +
> +Soft limits allow for greater sharing of memory. The idea behind soft limits
> +is to allow control groups to use as much of the memory as needed, provided
> +
> +a. There is no memory contention
> +b. They do not exceed their hard limit
> +
> +When the system detects memory contention (through do_try_to_free_pages(),
> +while allocating), control groups are pushed back to their soft limits if
> +possible. If the soft limit of each control group is very high, they are
> +pushed back as much as possible to make sure that one control group does not
> +starve the others.

Can you give an example here of how to implement the following setup:

- we have a high-priority latency-sensitive server job A and a bunch
of low-priority batch jobs B, C and D

- each job *may* need up to 2GB of memory, but generally each tends to
use <1GB of memory

- we want to run all four jobs on a 4GB machine

- we don't want A to ever have to wait for memory to be reclaimed (as
it's serving latency-sensitive queries), so the kernel should be
squashing B/C/D down *before* memory actually runs out.

Is this possible with the proposed hard/soft limit setup? Or do we
need some additional support for keeping a pool of pre-reserved free
memory available?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
