Subject: Re: [RFC/PATCH] powerpc: tlb flush batch use lazy MMU mode
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1176188977.8061.48.camel@localhost.localdomain>
References: <1176188977.8061.48.camel@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 12 Apr 2007 11:35:26 +1000
Message-Id: <1176341727.8061.112.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: linuxppc-dev list <linuxppc-dev@ozlabs.org>, Anton Blanchard <anton@samba.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-04-10 at 17:09 +1000, Benjamin Herrenschmidt wrote:
> The current tlb flush code on powerpc 64 bits has a subtle race since we
> lost the page table lock due to the possible faulting in of new PTEs
> after a previous one has been removed but before the corresponding hash
> entry has been evicted, which can leads to all sort of fatal problems.
> 
> This patch reworks the batch code completely. It doesn't use the mmu_gather
> stuff anymore. Instead, we use the lazy mmu hooks that were added by the
> paravirt code. They have the nice property that the enter/leave lazy mmu
> mode pair is always fully contained by the PTE lock for a given range
> of PTEs. Thus we can guarantee that all batches are flushed on a given
> CPU before it drops that lock.

 .../...

Ran for a little while on a P5 partition with a few sdet runs and it
seems to be fine. You can apply :-)

Despite the bug being present in 2.6.21 (and earlier), I still think
however that this is .22 material, at least for now.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
