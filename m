Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 96C8D6B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 14:41:22 -0500 (EST)
Received: by mail-ie0-f177.google.com with SMTP id 16so8369135iea.36
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 11:41:21 -0800 (PST)
Date: Tue, 5 Mar 2013 11:40:39 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] tmpfs: fix mempolicy object leaks
In-Reply-To: <5133E178.90405@gmail.com>
Message-ID: <alpine.LNX.2.00.1303051101350.27525@eggly.anvils>
References: <1361344302-26565-1-git-send-email-gthelen@google.com> <1361344302-26565-2-git-send-email-gthelen@google.com> <alpine.LNX.2.00.1302201221270.1152@eggly.anvils> <5133E178.90405@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Huck <will.huckk@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 4 Mar 2013, Will Huck wrote:
> 
> Could you explain me why shmem has more relationship with mempolicy? It seems
> that there are many codes in shmem handle mempolicy, but other components in
> mm subsystem just have little.

NUMA mempolicy is mostly handled in mm/mempolicy.c, which services the
mbind, migrate_pages, set_mempolicy, get_mempolicy system calls: which
govern how process memory is distributed across NUMA nodes.

mm/shmem.c is affected because it was also found useful to specify
mempolicy on the shared memory objects which may back process memory:
that includes SysV SHM and POSIX shared memory and tmpfs.  mm/hugetlb.c
contains some mempolicy handling for hugetlbfs; fs/ramfs is kept minimal,
so nothing in there.

Those are the memory-based filesystems, where NUMA mempolicy is most
natural.  The regular filesystems could support shared mempolicy too,
but that would raise more awkward design questions.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
