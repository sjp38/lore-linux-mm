Date: Wed, 3 Oct 2001 14:30:38 -0700
From: Mike Fedyk <mfedyk@matchmail.com>
Subject: Re: weird memshared value
Message-ID: <20011003143038.B7266@mikef-linux.matchmail.com>
References: <3BBB7F5F.9040806@brsat.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3BBB7F5F.9040806@brsat.com.br>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Oct 03, 2001 at 06:13:03PM -0300, Roberto Orenstein wrote:
> Hi Cristoph,
> 
> Guess found a bug in the MemShared value that shows up in /proc/meminfo.
> At least it's pretty weird :)
> 
> After a cp kernel_tree new_tree, together with make bzImage, got the 
> following number:
> 
> MemShared:    4294966488 kB
> 
> My system has only 128MB. P-III, kernel 2.4.9-ac16.
> It doesn't harm, but it's way far from my system mem.
> 
> Any idea?
> 

Here you go:

Date: Mon, 1 Oct 2001 22:17:26 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
X-Sender: hugh@localhost.localdomain
To: Christoph Rohland <cr@sap.com>
cc: Mike Fedyk <mfedyk@matchmail.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
   linux-kernel@vger.kernel.org
Subject: [PATCH] Re: 4GB MemShared, Cached bigger (and growing) than MemTotal
 (64MB) on 2.4.9-ac18
In-Reply-To: <m34rpj3lsa.fsf@linux.local>
Message-ID: <Pine.LNX.4.21.0110012142400.1098-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Status: RO
Content-Length: 778
Lines: 25

On 1 Oct 2001, Christoph Rohland wrote:
> On Sun, 30 Sep 2001, Mike Fedyk wrote:
> > 
> > After this happened, I saw MemShared go up to about 4GB, and Cached
> > started growing, getting even bigger than ram!
> 
> Apparently the shmem accounting is screwed. (Hugh does something ring
> at your side?) 

I've now looked, and it's obviously my error in -ac shmem_writepage:
patch below against 2.4.10-ac2, would apply equally to 2.4.9-ac16 on.

Hugh

--- 2.4.10-ac2/mm/shmem.c	Mon Oct  1 21:36:28 2001
+++ linux/mm/shmem.c	Mon Oct  1 21:41:00 2001
@@ -462,6 +462,7 @@
 		swap_list_unlock();
 		/* Add it back to the page cache */
 		add_to_page_cache_locked(page, mapping, index);
+		atomic_inc(&shmem_nrpages);
 		activate_page(page);
 		SetPageDirty(page);
 		error = -ENOMEM;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
