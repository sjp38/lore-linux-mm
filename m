Message-ID: <43D75239.90907@cosmosbay.com>
Date: Wed, 25 Jan 2006 11:26:01 +0100
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: [RFC] non-refcounted pages, application to slab?
References: <20060125093909.GE32653@wotan.suse.de>
In-Reply-To: <20060125093909.GE32653@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Nick Piggin a ecrit :
> If an allocator knows exactly the lifetime of its page, then there is no
> need to do refcounting or the final put_page_zestzero (atomic op + mem
> barriers).
> 
> This is probably not worthwhile for most cases, but slab did strike me
> as a potential candidate (however the complication here is that some
> code I think uses the refcount of underlying pages of slab allocations
> eg nommu code). So it is not a complete patch, but I wonder if anyone
> thinks the savings might be worth the complexity?
> 
> Is there any particular code that is really heavy on slab allocations?
> That isn't mostly handled by the slab's internal freelists?

Hi Nick

After reading your patch, I have some crazy idea.

The atomic op + mem barrier you want to avoid could be avoided more generally 
just by changing atomic_dec_and_test(atomic_t *v).

If the current thread is the last referer (refcnt = 1), then it can safely set 
the value to 0 because no other CPU can be touching the value (or else there 
must be a bug somewhere, as the 'other cpu' could touch the value just after 
us and we could free an object still in use by 'other cpu'

Something like :


--- include/asm-i386/atomic.h.orig      2006-01-25 12:11:46.000000000 +0100
+++ include/asm-i386/atomic.h   2006-01-25 12:13:07.000000000 +0100
@@ -130,6 +130,13 @@
                 printk("BUG: atomic counter underflow at:\n");
                 dump_stack();
         }
+#ifdef CONFIG_SMP
+       /* avoid an atomic op if we are the last user of this atomic */
+       if (atomic_read(v) == 1) {
+               atomic_set(v, 0); /* not a real atomic op on most machines */
+               return 1;
+       }
+#endif
         __asm__ __volatile__(
                 LOCK_PREFIX "decl %0; sete %1"
                 :"=m" (v->counter), "=qm" (c)


Thank you

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
