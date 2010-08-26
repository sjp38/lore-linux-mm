Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 7DE066B01F1
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 06:54:34 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id o7QAsTU8011283
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 03:54:31 -0700
Received: from vws16 (vws16.prod.google.com [10.241.21.144])
	by hpaq12.eem.corp.google.com with ESMTP id o7QAreLX021201
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 03:54:28 -0700
Received: by vws16 with SMTP id 16so1648765vws.28
        for <linux-mm@kvack.org>; Thu, 26 Aug 2010 03:54:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100825.234149.189710316.davem@davemloft.net>
References: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
	<20100825.234149.189710316.davem@davemloft.net>
Date: Thu, 26 Aug 2010 03:54:28 -0700
Message-ID: <AANLkTik8cHD_qsey8NBw-YWsoibwMM5RNP9SeKom2VtC@mail.gmail.com>
Subject: Re: [PATCH] mm: fix hang on anon_vma->root->lock
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, riel@redhat.com, aarcange@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 25, 2010 at 11:41 PM, David Miller <davem@davemloft.net> wrote:
> From: Hugh Dickins <hughd@google.com>
> Date: Wed, 25 Aug 2010 23:12:54 -0700 (PDT)
>
>> After several hours, kbuild tests hang with anon_vma_prepare() spinning on
>> a newly allocated anon_vma's lock - on a box with CONFIG_TREE_PREEMPT_RCU=y
>> (which makes this very much more likely, but it could happen without).
>>
>> The ever-subtle page_lock_anon_vma() now needs a further twist: since
>> anon_vma_prepare() and anon_vma_fork() are liable to change the ->root
>> of a reused anon_vma structure at any moment, page_lock_anon_vma()
>> needs to check page_mapped() again before succeeding, otherwise
>> page_unlock_anon_vma() might address a different root->lock.
>>
>> Signed-off-by: Hugh Dickins <hughd@google.com>
>
> Interesting, is the condition which allows this to trigger specific
> to this merge window or was it always possible?

Just specific to this merge window, which started using
anon_vma->root->lock in place of anon_vma->lock (anon_vma->root is
often anon_vma itself, but not always).  I _think_ that change was
itself a simplification of the locking in 2.6.35, rather than plugging
a particular hole (it's not been backported to -stable), but I may be
wrong on that - Rik?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
