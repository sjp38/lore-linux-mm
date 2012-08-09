Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id D1A0D6B007D
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 11:24:17 -0400 (EDT)
Message-ID: <5023D60F.7010009@zytor.com>
Date: Thu, 09 Aug 2012 08:23:59 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 4/6] x86: Add clear_page_nocache
References: <1344524583-1096-1-git-send-email-kirill.shutemov@linux.intel.com> <1344524583-1096-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1344524583-1096-5-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

On 08/09/2012 08:03 AM, Kirill A. Shutemov wrote:
> From: Andi Kleen <ak@linux.intel.com>
>
> Add a cache avoiding version of clear_page. Straight forward integer variant
> of the existing 64bit clear_page, for both 32bit and 64bit.
>
> Also add the necessary glue for highmem including a layer that non cache
> coherent architectures that use the virtual address for flushing can
> hook in. This is not needed on x86 of course.
>
> If an architecture wants to provide cache avoiding version of clear_page
> it should to define ARCH_HAS_USER_NOCACHE to 1 and implement
> clear_page_nocache() and clear_user_highpage_nocache().
>

Compile failure:

/home/hpa/kernel/tip.x86-mm/arch/x86/mm/fault.c: In function 
a??clear_user_highpage_nocachea??:
/home/hpa/kernel/tip.x86-mm/arch/x86/mm/fault.c:1215:30: error: 
a??KM_USER0a?? undeclared (first use in this function)
/home/hpa/kernel/tip.x86-mm/arch/x86/mm/fault.c:1215:30: note: each 
undeclared identifier is reported only once for each function it appears in
/home/hpa/kernel/tip.x86-mm/arch/x86/mm/fault.c:1215:2: error: too many 
arguments to function a??kmap_atomica??
In file included from 
/home/hpa/kernel/tip.x86-mm/include/linux/pagemap.h:10:0,
                  from 
/home/hpa/kernel/tip.x86-mm/include/linux/mempolicy.h:70,
                  from 
/home/hpa/kernel/tip.x86-mm/include/linux/hugetlb.h:15,
                  from /home/hpa/kernel/tip.x86-mm/arch/x86/mm/fault.c:14:
/home/hpa/kernel/tip.x86-mm/include/linux/highmem.h:66:21: note: 
declared here
make[4]: *** [arch/x86/mm/fault.o] Error 1
make[3]: *** [arch/x86/mm] Error 2
make[2]: *** [arch/x86] Error 2
make[1]: *** [sub-make] Error 2
make[1]: Leaving directory `/home/hpa/kernel/tip.x86-mm'

This happens on *all* my test configurations, including both x86-64 and 
i386 allyesconfig.  I suspect your patchset base is stale.

	-hpa

-- 
H. Peter Anvin, Intel Open Source Technology Center
I work for Intel.  I don't speak on their behalf.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
