Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id BB2C76B0047
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 14:42:10 -0500 (EST)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id o29Jg6ZA013420
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 11:42:07 -0800
Received: from gxk6 (gxk6.prod.google.com [10.202.11.6])
	by kpbe12.cbf.corp.google.com with ESMTP id o29Jg5K8003572
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 11:42:05 -0800
Received: by gxk6 with SMTP id 6so4407009gxk.14
        for <linux-mm@kvack.org>; Tue, 09 Mar 2010 11:42:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4B931068.70900@cn.fujitsu.com>
References: <4B8E3F77.6070201@cn.fujitsu.com>
	 <6599ad831003050403v2e988723k1b6bf38d48707ab1@mail.gmail.com>
	 <4B931068.70900@cn.fujitsu.com>
Date: Tue, 9 Mar 2010 11:42:02 -0800
Message-ID: <6599ad831003091142t38c9ffc9rea7d351742ecbd98@mail.gmail.com>
Subject: Re: [PATCH 4/4] cpuset,mm: use rwlock to protect task->mempolicy and
	mems_allowed
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: miaox@cn.fujitsu.com
Cc: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Mar 6, 2010 at 6:33 PM, Miao Xie <miaox@cn.fujitsu.com> wrote:
>
> Before applying this patch, cpuset updates task->mems_allowed just like
> what you said. But the allocator is still likely to see an empty nodemask=
.
> This problem have been pointed out by Nick Piggin.
>
> The problem is following:
> The size of nodemask_t is greater than the size of long integer, so loadi=
ng
> and storing of nodemask_t are not atomic operations. If task->mems_allowe=
d
> don't intersect with new_mask, such as the first word of the mask is empt=
y
> and only the first word of new_mask is not empty. When the allocator
> loads a word of the mask before
>
> =A0 =A0 =A0 =A0current->mems_allowed |=3D new_mask;
>
> and then loads another word of the mask after
>
> =A0 =A0 =A0 =A0current->mems_allowed =3D new_mask;
>
> the allocator gets an empty nodemask.

Couldn't that be solved by having the reader read the nodemask twice
and compare them? In the normal case there's no race, so the second
read is straight from L1 cache and is very cheap. In the unlikely case
of a race, the reader would keep trying until it got two consistent
values in a row.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
