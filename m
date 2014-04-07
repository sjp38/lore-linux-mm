From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [rfc 0/3] Cleaning up soft-dirty bit usage
Date: Mon, 7 Apr 2014 16:07:01 +0300
Message-ID: <20140407130701.GA16677@node.dhcp.inet.fi>
References: <20140403184844.260532690@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140403184844.260532690@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Cyrill Gorcunov <gorcunov@openvz.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Thu, Apr 03, 2014 at 10:48:44PM +0400, Cyrill Gorcunov wrote:
> Hi! I've been trying to clean up soft-dirty bit usage. I can't cleanup
> "ridiculous macros in pgtable-2level.h" completely because I need to
> define _PAGE_FILE,_PAGE_PROTNONE,_PAGE_NUMA bits in sequence manner
> like
> 
> #define _PAGE_BIT_FILE		(_PAGE_BIT_PRESENT + 1)	/* _PAGE_BIT_RW */
> #define _PAGE_BIT_NUMA		(_PAGE_BIT_PRESENT + 2)	/* _PAGE_BIT_USER */
> #define _PAGE_BIT_PROTNONE	(_PAGE_BIT_PRESENT + 3)	/* _PAGE_BIT_PWT */
> 
> which can't be done right now because numa code needs to save original
> pte bits for example in __split_huge_page_map, if I'm not missing something
> obvious.

Sorry, I didn't get this. How __split_huge_page_map() does depend on pte
bits order?

> 
> Also if we ever redefine the bits above we will need to update PAT code
> which uses _PAGE_GLOBAL + _PAGE_PRESENT to make pte_present return true
> or false.
> 
> Another weird thing I found is the following sequence:
> 
>    mprotect_fixup
>     change_protection (passes @prot_numa = 0 which finally ends up in)
>       ...
>       change_pte_range(..., prot_numa)
> 
> 			if (!prot_numa) {
> 				...
> 			} else {
> 				... this seems to be dead code branch ...
> 			}
> 
>     is it intentional, and @prot_numa argument is supposed to be passed
>     with prot_numa = 1 one day, or it's leftover from old times?

I see one more user of change_protection() -- change_prot_numa(), which
has .prot_numa == 1.

-- 
 Kirill A. Shutemov
