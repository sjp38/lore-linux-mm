Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CFE546B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 11:30:10 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: why my systems never cache more than ~900 MB?
Date: Wed, 25 Mar 2009 02:42:35 +1100
References: <49C89CE0.2090103@wpkg.org> <200903250220.45575.nickpiggin@yahoo.com.au> <49C8FDD4.7070900@wpkg.org>
In-Reply-To: <49C8FDD4.7070900@wpkg.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903250242.35787.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Tomasz Chmielewski <mangoo@wpkg.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 25 March 2009 02:35:48 Tomasz Chmielewski wrote:
> Nick Piggin schrieb:
> > On Tuesday 24 March 2009 19:42:08 Tomasz Chmielewski wrote:
> >> On my (32 bit) systems with more than 1 GB memory it is impossible to
> >> cache more than about 900 MB. Why?
> >>
> >> Caching never goes beyond ~900 MB (i.e. when I read a mounted drive with
> >> dd):
> >
> > Because blockdev mappings are limited to lowmem due to sharing their
> > cache with filesystem metadata cache, which needs kernel mapped memory.
> > It will >900MB of pagecache data OK (data from regular files)
>
> Does not help me, as what interests me here on these machines is mainly
> caching block device data; they are iSCSI targets and access block
> devices directly.

OK. Yeah, it's just due to crufty old code... I'm slowly working to
remove this limitation (can be done in 1 of 2 ways: either disconnect
filesystem metadata cache from blockdev data cache, or rework filesystems
to be able to handle highmem for metadata cache).

Actually the quickest way for you might be just to create a new type of
block device that can use highmem but not support filesystems.


> >> Same behaviour on 32 bit machines with 4 GB RAM.
> >>
> >> No problems on 64 bit machines.
> >> I have one 32 bit machine that caches beyond ~900 MB without problems.
> >
> > Does it have a different user/kernel split?
>
> Yes it does:
>
> CONFIG_VMSPLIT_2G_OPT=y
>
>
> What split should I choose to enable blockdev mapping on the whole
> memory on 32 bit system with 3 or 4 GB RAM? Is it possible with 4 GB RAM
> at all?

It's not possible to use 4GB RAM with VMSPLIT. You could use VMSPLIT_1G
to give the kernel the most amount of virtual memory. And even reduce
vmalloc space to get a few more MB with vmalloc= boot parameter.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
