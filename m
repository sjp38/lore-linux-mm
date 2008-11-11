Date: Tue, 11 Nov 2008 16:30:22 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
In-Reply-To: <20081111221753.GK10818@random.random>
Message-ID: <Pine.LNX.4.64.0811111626520.29222@quilx.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
 <1226409701-14831-2-git-send-email-ieidus@redhat.com>
 <1226409701-14831-3-git-send-email-ieidus@redhat.com>
 <20081111114555.eb808843.akpm@linux-foundation.org> <20081111210655.GG10818@random.random>
 <Pine.LNX.4.64.0811111522150.27767@quilx.com> <20081111221753.GK10818@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Tue, 11 Nov 2008, Andrea Arcangeli wrote:

> this page_count check done with only the tree_lock won't prevent a
> task to start O_DIRECT after page_count has been read in the above line.
>
> If a thread starts O_DIRECT on the page, and the o_direct is still in
> flight by the time you copy the page to the new page, the read will
> not be represented fully in the newpage leading to userland data
> corruption.

O_DIRECT does not take a refcount on the page in order to prevent this?

> > Define a regular VM page? A page on the LRU?
>
> Yes, pages owned, allocated and worked on by the VM. So they can be
> swapped, collected, migrated etc... You can't possibly migrate a
> device driver page for example and infact those device driver pages
> can't be migrated either.

Oh they could be migrated if you had a callback to the devices method for
giving up references. Same as slab defrag.

> The KSM page initially is a driver page, later we'd like to teach the
> VM how to swap it by introducing rmap methods and adding it to the
> LRU. As long as it's only anonymous memory that we're sharing/cloning,
> we won't have to patch pagecache radix tree and other stuff. BTW, if
> we ever decice to clone pagecache we could generate immense metadata
> ram overhead in the radix tree with just a single page of data. All
> issues that don't exist for anon ram.

Seems that we are tinkering around with the concept of what an anonymous
page is? Doesnt shmem have some means of converting pages to file backed?
Swizzling?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
