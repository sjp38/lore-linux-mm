Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 7EFE5900002
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 17:59:19 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so3551180wib.11
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 14:59:18 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id se11si9843929wic.40.2014.07.09.14.59.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 09 Jul 2014 14:59:18 -0700 (PDT)
Date: Wed, 9 Jul 2014 17:59:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mm: shm: hang in shmem_fallocate
Message-ID: <20140709215906.GA27323@cmpxchg.org>
References: <52AE7B10.2080201@oracle.com>
 <52F6898A.50101@oracle.com>
 <alpine.LSU.2.11.1402081841160.26825@eggly.anvils>
 <52F82E62.2010709@oracle.com>
 <539A0FC8.8090504@oracle.com>
 <alpine.LSU.2.11.1406151921070.2850@eggly.anvils>
 <53A9A7D8.2020703@suse.cz>
 <alpine.LSU.2.11.1406251152450.1580@eggly.anvils>
 <53ABE479.3080508@suse.cz>
 <alpine.LSU.2.11.1406262108390.27670@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1406262108390.27670@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

Hi Hugh,

On Thu, Jun 26, 2014 at 10:36:20PM -0700, Hugh Dickins wrote:
> Hannes, a question for you please, I just could not make up my mind.
> In mm/truncate.c truncate_inode_pages_range(), what should be done
> with a failed clear_exceptional_entry() in the case of hole-punch?
> Is that case currently depending on the rescan loop (that I'm about
> to revert) to remove a new page, so I would need to add a retry for
> that rather like the shmem_free_swap() one?  Or is it irrelevant,
> and can stay unchanged as below?  I've veered back and forth,
> thinking first one and then the other.

I realize you have given up on changing truncate.c in the meantime,
but I'm still asking myself about the swap retry case: why retry for
swap-to-page changes, yet not for page-to-page changes?

In case faults are disabled through i_size, concurrent swapin could
still turn swap entries into pages, so I can see the need to retry.
There is no equivalent for shadow entries, though, and they can only
be turned through page faults, so no retry necessary in that case.

However, you explicitely mentioned the hole-punch case above: if that
can't guarantee the hole will be reliably cleared under concurrent
faults, I'm not sure why it would put in more effort to free it of
swap (or shadow) entries than to free it of pages.

What am I missing?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
