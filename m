Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0FFF66B025E
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 12:22:49 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id o64so109194906pfb.3
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 09:22:49 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id mj8si5665598pab.50.2015.12.22.09.22.48
        for <linux-mm@kvack.org>;
        Tue, 22 Dec 2015 09:22:48 -0800 (PST)
Subject: Re: [kernel-hardening] [RFC][PATCH 6/7] mm: Add Kconfig option for
 slab sanitization
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <1450755641-7856-7-git-send-email-laura@labbott.name>
 <567964F3.2020402@intel.com>
 <alpine.DEB.2.20.1512221023550.2748@east.gentwo.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <567986E7.50107@intel.com>
Date: Tue, 22 Dec 2015 09:22:47 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1512221023550.2748@east.gentwo.org>
Content-Type: multipart/mixed;
 boundary="------------020001080303010705010207"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: kernel-hardening@lists.openwall.com, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Laura Abbott <laura@labbott.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

This is a multi-part message in MIME format.
--------------020001080303010705010207
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

On 12/22/2015 08:25 AM, Christoph Lameter wrote:
> On Tue, 22 Dec 2015, Dave Hansen wrote:
>> On 12/21/2015 07:40 PM, Laura Abbott wrote:
>>> +	  The tradeoff is performance impact. The noticible impact can vary
>>> +	  and you are advised to test this feature on your expected workload
>>> +	  before deploying it
>>
>> What if instead of writing SLAB_MEMORY_SANITIZE_VALUE, we wrote 0's?
>> That still destroys the information, but it has the positive effect of
>> allowing a kzalloc() call to avoid zeroing the slab object.  It might
>> mitigate some of the performance impact.
> 
> We already write zeros in many cases or the object is initialized in a
> different. No one really wants an uninitialized object. The problem may be
> that a freed object is having its old content until reused. Which is
> something that poisoning deals with.

Or are you just saying that we should use the poisoning *code* that we
already have in slub?  Using the _code_ looks like a really good idea,
whether we're using it to write POISON_FREE, or 0's.  Something like the
attached patch?



--------------020001080303010705010207
Content-Type: text/x-patch;
 name="slub-poison-zeros.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="slub-poison-zeros.patch"



---

 b/mm/slub.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff -puN mm/slub.c~slub-poison-zeros mm/slub.c
--- a/mm/slub.c~slub-poison-zeros	2015-12-22 09:18:30.585371985 -0800
+++ b/mm/slub.c	2015-12-22 09:21:23.754174731 -0800
@@ -177,6 +177,7 @@ static inline bool kmem_cache_has_cpu_pa
 /* Internal SLUB flags */
 #define __OBJECT_POISON		0x80000000UL /* Poison object */
 #define __CMPXCHG_DOUBLE	0x40000000UL /* Use cmpxchg_double */
+#define __OBJECT_POISON_ZERO	0x20000000UL /* Poison with zeroes */
 
 #ifdef CONFIG_SMP
 static struct notifier_block slab_notifier;
@@ -678,7 +679,10 @@ static void init_object(struct kmem_cach
 	u8 *p = object;
 
 	if (s->flags & __OBJECT_POISON) {
-		memset(p, POISON_FREE, s->object_size - 1);
+		if (s->flags & __OBJECT_POISON_ZERO) {
+			memset(p, POISON_FREE, s->object_size - 1);
+		else
+			memset(p, 0, s->object_size - 1);
 		p[s->object_size - 1] = POISON_END;
 	}
 
@@ -2495,7 +2499,8 @@ redo:
 		stat(s, ALLOC_FASTPATH);
 	}
 
-	if (unlikely(gfpflags & __GFP_ZERO) && object)
+	if (unlikely(gfpflags & __GFP_ZERO) && object &&
+	    !(s->flags & __OBJECT_POISON_ZERO)) {
 		memset(object, 0, s->object_size);
 
 	slab_post_alloc_hook(s, gfpflags, object);
@@ -2839,7 +2844,8 @@ bool kmem_cache_alloc_bulk(struct kmem_c
 	local_irq_enable();
 
 	/* Clear memory outside IRQ disabled fastpath loop */
-	if (unlikely(flags & __GFP_ZERO)) {
+	if (unlikely(flags & __GFP_ZERO) &&
+	    !(s->flags & __OBJECT_POISON_ZERO)) {
 		int j;
 
 		for (j = 0; j < i; j++)
_

--------------020001080303010705010207--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
