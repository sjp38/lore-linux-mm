Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA26000
	for <linux-mm@kvack.org>; Tue, 1 Dec 1998 12:50:02 -0500
Date: Tue, 1 Dec 1998 18:48:44 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: Update shared mappings
In-Reply-To: <199812011503.PAA18144@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981201182728.16745C-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Zlatko.Calusic@CARNet.hr, Linux-MM List <linux-mm@kvack.org>, Andi Kleen <andi@zero.aec.at>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Dec 1998, Stephen C. Tweedie wrote:

>I think I have: I can reliably deadlock machines with this patch.

s/patch/proggy/ side effect of lots of kernel developing ;)

andrea@dragon:/tmp$ egcc -O2 shared_map.c 
andrea@dragon:/tmp$ ./a.out 
andrea@dragon:/tmp$ 

No deadlock at all. Are you sure you are using my _latest_ patch in
arca-39? Some weeks ago I fixed this:

static void update_shared_mappings(struct vm_area_struct *this,
				   unsigned long address,
				   pte_t orig_pte)
{
	if (this->vm_flags & VM_SHARED)
	{
		struct file * filp = this->vm_file;
		if (filp)
		{
			struct inode * inode = filp->f_dentry->d_inode;
			struct vm_area_struct * shared;

			for (shared = inode->i_mmap; shared;
			     shared = shared->vm_next_share)
			{
				if (shared->vm_mm == this->vm_mm)
					    ^^^^^          ^^^^^
					continue;
				update_one_shared_mapping(shared, address,
							  orig_pte);
			}
		}
	}
}


--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
