From: Christoph Rohland <cr@sap.com>
Subject: Re: [PATCH] Fix races in 2.4.2-ac22 SysV shared memory
References: <20010323011331.J7756@redhat.com>
Message-ID: <m3g0fz3qd0.fsf@linux.local>
Date: 28 Mar 2001 11:18:16 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ben LaHaise <bcrl@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi Stephen,

On Fri, 23 Mar 2001, Stephen C. Tweedie wrote:
> @@ -234,11 +243,11 @@
>  		return -ENOMEM;
>  	}
>  
> -	spin_lock(&info->lock);
> -	shmem_recalc_inode(page->mapping->host);
>  	entry = shmem_swp_entry(info, page->index); 
>	if (IS_ERR(entry)) /* this had been allocted on page allocation */
>  		BUG();
> +	spin_lock(&info->lock);
> +	shmem_recalc_inode(page->mapping->host);
>  	error = -EAGAIN;
>  	if (entry->val) {
>  		__swap_free(swap, 2);

I think this is wrong. The spinlock protects us against
shmem_truncate. shmem_swp_entry cannot sleep in this case since the
entry is allocated in nopage.

Greetings
		Christoph


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
