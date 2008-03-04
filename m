Date: Tue, 4 Mar 2008 14:30:20 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [RFC] Notifier for Externally Mapped Memory (EMM)
Message-ID: <20080304133020.GC5301@v2.random>
References: <20080220103942.GU7128@v2.random> <20080221045430.GC15215@wotan.suse.de> <20080221144023.GC9427@v2.random> <20080221161028.GA14220@sgi.com> <20080227192610.GF28483@v2.random> <20080302155457.GK8091@v2.random> <20080303213707.GA8091@v2.random> <20080303220502.GA5301@v2.random> <47CC9B57.5050402@qumranet.com> <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803032327470.9642@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Mon, Mar 03, 2008 at 11:31:15PM -0800, Christoph Lameter wrote:
> @@ -446,6 +450,8 @@ static int page_mkclean_one(struct page 
>  	if (address == -EFAULT)
>  		goto out;
>  
> +	/* rmap lock held */
> +	emm_notify(mm, emm_invalidate_start, address, address + PAGE_SIZE);
>  	pte = page_check_address(page, mm, address, &ptl);
>  	if (!pte)
>  		goto out;
> @@ -462,6 +468,7 @@ static int page_mkclean_one(struct page 
>  	}
>  
>  	pte_unmap_unlock(pte, ptl);
> +	emm_notify(mm, emm_invalidate_end, address, address + PAGE_SIZE);
>  out:
>  	return ret;
>  }

I could have ripped invalidate_page from my patch too, except I didn't
want to slow down those paths for the known-common-users when not even
GRU would get any benefit from two hooks when only one is needed.

When working with single pages it's more efficient and preferable to
call invalidate_page and only later release the VM reference on the
page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
