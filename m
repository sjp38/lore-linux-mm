Subject: Re: [PATCH][RFC] pte notifiers -- support for external page	tables
References: <11890207643068-git-send-email-avi@qumranet.com>
From: Andi Kleen <andi@firstfloor.org>
In-Reply-To: <11890207643068-git-send-email-avi@qumranet.com>
Date: 06 Sep 2007 15:28:58 +0200
Message-ID: <p73k5r3apnp.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Avi Kivity <avi-atKUWr5tajBWk0Htik3J/w@public.gmane.org> writes:
> 
> pte notifiers are different from paravirt_ops: they extend the normal
> page tables rather than replace them; and they provide high-level information
> such as the vma and the virtual address for the driver to use.

Sounds like a locking horror to me.  To do anything with page tables
you need locks. Both for the kernel page tables and for your new tables.

What happens when people add all
things of complicated operations in these notifiers? That will likely
happen and then everytime you change something in VM code they 
will break. This has the potential to increase the cost of maintaining
VM code considerably, which would be a bad thing.

This is quite different from paravirt ops because low level pvops
can typically run lockless by just doing some kind of hypercall directly.
But that won't work for maintaining your custom page tables.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
