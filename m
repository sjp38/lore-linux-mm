Date: Mon, 6 Oct 2008 21:29:23 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH, RFC] shmat: introduce flag SHM_MAP_HINT
Message-ID: <20081006192923.GJ3180@one.firstfloor.org>
References: <20081006132651.GG3180@one.firstfloor.org> <1223303879-5555-1-git-send-email-kirill@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1223303879-5555-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@redhat.com>, Arjan van de Ven <arjan@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Oct 06, 2008 at 05:37:59PM +0300, Kirill A. Shutemov wrote:
> It allows interpret attach address as a hint, not as exact address.

First you should also do a patch for the manpage and send to 
the manpage maintainer.


>  #define SHM_LOCK 	11
> diff --git a/ipc/shm.c b/ipc/shm.c
> index e77ec69..19462bb 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -819,7 +819,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
>  	if (shmid < 0)
>  		goto out;
>  	else if ((addr = (ulong)shmaddr)) {
> -		if (addr & (SHMLBA-1)) {
> +		if (!(shmflg & SHM_MAP_HINT) && (addr & (SHMLBA-1))) {
>  			if (shmflg & SHM_RND)
>  				addr &= ~(SHMLBA-1);	   /* round down */
>  			else
> @@ -828,7 +828,7 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr)
>  #endif
>  					goto out;
>  		}
> -		flags = MAP_SHARED | MAP_FIXED;
> +		flags = (shmflg & SHM_MAP_HINT ? 0 : MAP_FIXED) | MAP_SHARED;


IMHO you need at least make the

   if (find_vma_intersection(current->mm, addr, addr + size))
                        goto invalid;

test above conditional too.

-Andi

-- 
ak@linux.intel.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
