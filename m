Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E9EA36B0071
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 00:04:11 -0400 (EDT)
Message-ID: <4CABF4F3.7050002@zytor.com>
Date: Tue, 05 Oct 2010 21:02:59 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] access_error API cleanup
References: <1286265215-9025-1-git-send-email-walken@google.com> <1286265215-9025-4-git-send-email-walken@google.com>
In-Reply-To: <1286265215-9025-4-git-send-email-walken@google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 10/05/2010 12:53 AM, Michel Lespinasse wrote:
> access_error() already takes error_code as an argument, so there is
> no need for an additional write flag.
> 
> Signed-off-by: Michel Lespinasse <walken@google.com>
> ---
>  arch/x86/mm/fault.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index b355b92..844d46f 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -915,9 +915,9 @@ spurious_fault(unsigned long error_code, unsigned long address)
>  int show_unhandled_signals = 1;
>  
>  static inline int
> -access_error(unsigned long error_code, int write, struct vm_area_struct *vma)
> +access_error(unsigned long error_code, struct vm_area_struct *vma)
>  {
> -	if (write) {
> +	if (error_code & PF_WRITE) {
>  		/* write, present and write, not present: */
>  		if (unlikely(!(vma->vm_flags & VM_WRITE)))
>  			return 1;
> @@ -1110,7 +1110,7 @@ retry:
>  	 * we can handle it..
>  	 */
>  good_area:
> -	if (unlikely(access_error(error_code, write, vma))) {
> +	if (unlikely(access_error(error_code, vma))) {
>  		bad_area_access_error(regs, error_code, address);
>  		return;
>  	}

Acked-by: H. Peter Anvin <hpa@zytor.com>

I was going to put it into the x86 tree, but being part of a larger
series it gets messy.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
