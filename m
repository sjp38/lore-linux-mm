From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14338.17669.163923.174022@dukat.scot.redhat.com>
Date: Mon, 11 Oct 1999 21:13:57 +0100 (BST)
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <Pine.GSO.4.10.9910111157310.18777-100000@weyl.math.psu.edu>
References: <14338.1859.507452.652164@dukat.scot.redhat.com>
	<Pine.GSO.4.10.9910111157310.18777-100000@weyl.math.psu.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Manfred Spraul <manfreds@colorfullife.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 11 Oct 1999 12:05:23 -0400 (EDT), Alexander Viro
<viro@math.psu.edu> said:

> On Mon, 11 Oct 1999, Stephen C. Tweedie wrote:
>> No, spinlocks would be ideal.  The vma swapout codes _have_ to be
>> prepared for the vma to be destroyed as soon as we sleep.  In fact, the
>> entire mm may disappear if the process happens to exit.  Once we know
>> which page to write where, the swapout operation becomes a per-page
>> operation, not per-vma.

> Aha, so you propose to drop it in ->swapout(), right? (after get_file() in
> filemap_write_page()... Ouch. Probably we'ld better lambda-expand the call
> in filemap_swapout() - the thing is called from other places too)...

Right now it is the big kernel lock which is used for this, and the
scheduler drops it anyway for us.  If anyone wants to replace that lock
with another spinlock, then yes, the swapout method would have to drop
it before doing anything which could block.  And that is ugly: having
spinlocks unbalanced over function calls is a maintenance nightmare.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
