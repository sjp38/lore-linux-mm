Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DDD3E6B6FC5
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 12:07:05 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id r13so9325583pgb.7
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 09:07:05 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d11si9665730plo.184.2018.12.04.09.07.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 09:07:04 -0800 (PST)
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS) documentation
References: <20181203233509.20671-1-jglisse@redhat.com>
	<20181203233509.20671-3-jglisse@redhat.com>
Date: Tue, 04 Dec 2018 09:06:59 -0800
In-Reply-To: <20181203233509.20671-3-jglisse@redhat.com> (jglisse's message of
	"Mon, 3 Dec 2018 18:34:57 -0500")
Message-ID: <875zw98bm4.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <balbirs@au1.ibm.com>, "Aneesh Kumar K . V  <aneesh.kumar@linux.ibm.com>,  Benjamin Herrenschmidt" <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, Christian =?utf-8?Q?K=C3=B6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>

jglisse@redhat.com writes:

> +
> +To help with forward compatibility each object as a version value and
> +it is mandatory for user space to only use target or initiator with
> +version supported by the user space. For instance if user space only
> +knows about what version 1 means and sees a target with version 2 then
> +the user space must ignore that target as if it does not exist.

So once v2 is introduced all applications that only support v1 break.

That seems very un-Linux and will break Linus' "do not break existing
applications" rule.

The standard approach that if you add something incompatible is to
add new field, but keep the old ones.

> +2) hbind() bind range of virtual address to heterogeneous memory
> +================================================================
> +
> +So instead of using a bitmap, hbind() take an array of uid and each uid
> +is a unique memory target inside the new memory topology description.

You didn't define what an uid is?

user id?

Please use sensible terminology that doesn't conflict with existing
usages.

I assume it's some kind of number that identifies a node in your
graph. 

> +User space also provide an array of modifiers. Modifier can be seen as
> +the flags parameter of mbind() but here we use an array so that user
> +space can not only supply a modifier but also value with it. This should
> +allow the API to grow more features in the future. Kernel should return
> +-EINVAL if it is provided with an unkown modifier and just ignore the
> +call all together, forcing the user space to restrict itself to modifier
> +supported by the kernel it is running on (i know i am dreaming about well
> +behave user space).

It sounds like you're trying to define a system call with built in
ioctl? Is that really a good idea?

If you need ioctl you know where to find it.

Please don't over design APIs like this.

> +3) Tracking and applying heterogeneous memory policies
> +======================================================
> +
> +Current memory policy infrastructure is node oriented, instead of
> +changing that and risking breakage and regression HMS adds a new
> +heterogeneous policy tracking infra-structure. The expectation is
> +that existing application can keep using mbind() and all existing
> +infrastructure under-disturb and unaffected, while new application
> +will use the new API and should avoid mix and matching both (as they
> +can achieve the same thing with the new API).

I think we need a stronger motivation to define a completely
parallel and somewhat redundant infrastructure. What breakage
are you worried about?

The obvious alternative would of course be to add some extra
enumeration to the existing nodes.

It's a strange document. It goes from very high level to low level
with nothing inbetween. I think you need a lot more details
in the middle, in particularly how these new interfaces
should be used. For example how should an application
know how to look for a specific type of device?
How is an automated tool supposed to use the enumeration?
etc.

-Andi
