Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 60E886B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 22:23:53 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id f3-v6so12347740plf.1
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 19:23:53 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i3-v6si1931433pld.241.2018.04.03.19.23.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 03 Apr 2018 19:23:52 -0700 (PDT)
Date: Tue, 3 Apr 2018 19:23:47 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] kfree_rcu() should use kfree_bulk() interface
Message-ID: <20180404022347.GA17512@bombadil.infradead.org>
References: <1522776173-7190-1-git-send-email-rao.shoaib@oracle.com>
 <1522776173-7190-3-git-send-email-rao.shoaib@oracle.com>
 <20180403205822.GB30145@bombadil.infradead.org>
 <d434c58c-082b-9a17-8d15-9c66e0c1941a@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <d434c58c-082b-9a17-8d15-9c66e0c1941a@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rao Shoaib <rao.shoaib@oracle.com>
Cc: linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com, joe@perches.com, brouer@redhat.com, linux-mm@kvack.org

On Tue, Apr 03, 2018 at 05:55:55PM -0700, Rao Shoaib wrote:
> On 04/03/2018 01:58 PM, Matthew Wilcox wrote:
> > I think you might be better off with an IDR.  The IDR can always
> > contain one entry, so there's no need for this 'rbf_list_head' or
> > __rcu_bulk_schedule_list.  The IDR contains its first 64 entries in
> > an array (if that array can be allocated), so it's compatible with the
> > kfree_bulk() interface.
> > 
> I have just familiarized myself with what IDR is by reading your article. If
> I am incorrect please correct me.
> 
> The list and head you have pointed are only used  if the container can not
> be allocated. That could happen with IDR as well. Note that the containers
> are allocated at boot time and are re-used.

No, it can't happen with the IDR.  The IDR can always contain one entry
without allocating anything.  If you fail to allocate the second entry,
just free the first entry.

> IDR seems to have some overhead, such as I have to specifically add the
> pointer and free the ID, plus radix tree maintenance.

... what?  Adding a pointer is simply idr_alloc(), and you get back an
integer telling you which index it has.  Your data structure has its
own set of overhead.

IDR has a bulk-free option (idr_destroy()), but it doesn't have a get-bulk
function yet.  I think that's a relatively straightforward function to
add ...

/*
 * Return: number of elements pointed to by 'ptrs'.
 */
int idr_get_bulk(struct idr *idr, void __rcu ***ptrs, u32 *start)
{
	struct radix_tree_iter iter;
	void __rcu **slot;
	unsigned long base = idr->idr_base;
	unsigned long id = *start;

	id = (id < base) ? 0 : id - base;
	slot = radix_tree_iter_find(&idr->idr_rt, &iter, id);
	if (!slot)
		return 0;
	*start = iter.index + base;
	*ptrs = slot;
	return iter.next_index - iter.index;
}

(completely untested, but you get the idea.  For your case, it's just
going to return a pointer to the first slot).

> The change would also require retesting. So I would like to keep the current
> design.

That's not how review works.
