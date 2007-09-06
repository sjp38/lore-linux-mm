Message-ID: <46E019FC.5000001@qumranet.com>
Date: Thu, 06 Sep 2007 18:17:16 +0300
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RFC] pte notifiers -- support for external page	tables
References: <11890207643068-git-send-email-avi@qumranet.com> <p73myw09g5w.fsf@bingen.suse.de>
In-Reply-To: <p73myw09g5w.fsf@bingen.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm-devel <kvm-devel@lists.sourceforge.net>, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org> writes:
>   
>> pte notifiers are different from paravirt_ops: they extend the normal
>> page tables rather than replace them; and they provide high-level information
>> such as the vma and the virtual address for the driver to use.
>>     
>
> Sounds like a locking horror to me.  To do anything with page tables
> you need locks. Both for the kernel page tables and for your new tables.
>
> What happens when people add all
> things of complicated operations in these notifiers? That will likely
> happen and then everytime you change something in VM code they 
> will break. This has the potential to increase the cost of maintaining
> VM code considerably, which would be a bad thing.
>
> This is quite different from paravirt ops because low level pvops
> can typically run lockless by just doing some kind of hypercall directly.
> But that won't work for maintaining your custom page tables.
>   

Okay, here's a possible fix: add ->lock() and ->unlock() callbacks, to 
be called when mmap_sem is taken either for read or write.  Also add a 
->release() for when the mm goes away to avoid the need to care about 
the entire data structure going away.

The notifier list would need to be kept sorted to avoid deadlocks.

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
