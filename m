Date: Thu, 2 Jun 2005 16:13:41 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch] scm: fix scm_fp_list allocation problem
Message-Id: <20050602161341.3d94f17b.akpm@osdl.org>
In-Reply-To: <200506012227.PAA05624@allur.sanmateo.akamai.com>
References: <200506012227.PAA05624@allur.sanmateo.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pmeda@akamai.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

pmeda@akamai.com wrote:
>
> 
> The change is to use kmalloc or vmalloc for scm_fp_list based on the
> structure size similar to fdset allocation in fs code.  This change allows
> local users to change the number of files macros(SCM_MAX_FD, OPEN_MAX, NR_OPEN etc.)
> to large values without changing other code. This change does not touch those macros,
> and hence compiler should generate the same code as before for normal users.
> 
> One of the problems faced by changing the number of fds is not being able to
> ssh for nonroot user. This is because of scm credentail passing an fd from 
> authentication process to actual shell process, and allocating big array wth kmalloc
> for that passing. The kmalloc works at 1024 fds, and fails now and then after.
> 
> More soph. fix would be to embed the size as part of structure, and allocate fd array,
> and passin one fd or small array(<32 fds) for passing just one fd, and expanding the
> array based on the passed fds dynamically. The structure change needs to be taught to
> all functions (like scm_fp_dup) that understand scm_fp_list. Since credentials will be
> freed shortly, and normal SCM_FD_MAX case is just 1024 fds, and it needs to use vmalloc
> for the worst case anyway, it can wait or is not worth. I stick to simple fix.
> 
> Thanks to Peter Swain for help in debugging ssh problem and Sudhin Mishra for reproducing the
> problem with ltp recvmsg testcase.
> 

I figure a 32k kmalloc will support an OPEN_MAX of 4095 on 64-bit 4k
pagesize machines.

Just how high do you want to go?

Given that you need to patch the kernel to support larger SCM_MAX_FD, why
not add this patch at the same time, keep it out of the main tree?

> 
> 
> --- a/include/net/scm.h	Wed Jun  1 20:02:43 2005
> +++ b/include/net/scm.h	Wed Jun  1 20:04:59 2005
> @@ -3,6 +3,8 @@
>  
>  #include <linux/limits.h>
>  #include <linux/net.h>
> +#include <linux/slab.h>
> +#include <linux/vmalloc.h>
>  
>  /* Well, we should have at least one descriptor open
>   * to accept passed FDs 8)
> @@ -27,6 +29,30 @@
>  extern int __scm_send(struct socket *sock, struct msghdr *msg, struct scm_cookie *scm);
>  extern void __scm_destroy(struct scm_cookie *scm);
>  extern struct scm_fp_list * scm_fp_dup(struct scm_fp_list *fpl);
> +
> +static __inline__ struct scm_fp_list *scm_fp_alloc(void)

Use `inline', not `__inline__'.

> +{
> +	struct scm_fp_list *fpl;
> +	int size  = sizeof(struct scm_fp_list);
> +	
> +	if (size <= PAGE_SIZE) {
> +		fpl = (struct scm_fp_list *) kmalloc (size, GFP_KERNEL);
> +	}
> +	else {
> +		fpl = (struct scm_fp_list *) vmalloc (size);
> +	}

- Unneeded braces

- Unneeded typecast

- Unneeded space

- Incorrect `else' indenting.

Should be:

	if (size <= PAGE_SIZE)
		fpl = kmalloc(size, GFP_KERNEL);
	else
		fpl = vmalloc(size);

> +static __inline__ void scm_fp_free(struct scm_fp_list *fpl)
> +{
> +	if (sizeof(struct scm_fp_list) <= PAGE_SIZE) {
> +		kfree(fpl);
> +	}
> +	else {
> +		vfree(fpl);
> +	}
> +}

Dittoes.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
