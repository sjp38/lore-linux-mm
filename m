Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id BA62D828DF
	for <linux-mm@kvack.org>; Wed, 13 Jan 2016 22:49:57 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id e65so92548369pfe.0
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 19:49:57 -0800 (PST)
Received: from mail-pf0-x233.google.com (mail-pf0-x233.google.com. [2607:f8b0:400e:c00::233])
        by mx.google.com with ESMTPS id a76si6398417pfj.116.2016.01.13.19.49.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jan 2016 19:49:56 -0800 (PST)
Received: by mail-pf0-x233.google.com with SMTP id 65so92296140pff.2
        for <linux-mm@kvack.org>; Wed, 13 Jan 2016 19:49:56 -0800 (PST)
Subject: Re: [RFC][PATCH 0/7] Sanitization of slabs based on grsecurity/PaX
References: <1450755641-7856-1-git-send-email-laura@labbott.name>
 <alpine.DEB.2.20.1512220952350.2114@east.gentwo.org>
 <5679ACE9.70701@labbott.name>
 <CAGXu5jJQKaA1qgLEV9vXEVH4QBC__Vg141BX22ZsZzW6p9yk4Q@mail.gmail.com>
 <568C8741.4040709@labbott.name>
 <alpine.DEB.2.20.1601071020570.28979@east.gentwo.org>
 <568F0F75.4090101@labbott.name>
 <alpine.DEB.2.20.1601080806020.4128@east.gentwo.org>
From: Laura Abbott <laura@labbott.name>
Message-ID: <56971AE1.1020706@labbott.name>
Date: Wed, 13 Jan 2016 19:49:53 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1601080806020.4128@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>

On 1/8/16 6:07 AM, Christoph Lameter wrote:
> On Thu, 7 Jan 2016, Laura Abbott wrote:
>
>> The slub_debug=P not only poisons it enables other consistency checks on the
>> slab as well, assuming my understanding of what check_object does is correct.
>> My hope was to have the poison part only and none of the consistency checks in
>> an attempt to mitigate performance issues. I misunderstood when the checks
>> actually run and how SLUB_DEBUG was used.
>
> Ok I see that there pointer check is done without checking the
> corresponding debug flag. Patch attached thar fixes it.
>
>> Another option would be to have a flag like SLAB_NO_SANITY_CHECK.
>> sanitization enablement would just be that and SLAB_POISON
>> in the debug options. The disadvantage to this approach would be losing
>> the sanitization for ->ctor caches (the grsecurity version works around this
>> by re-initializing with ->ctor, I haven't heard any feedback if this actually
>> acceptable) and not having some of the fast paths enabled
>> (assuming I'm understanding the code path correctly.) which would also
>> be a performance penalty
>
> I think we simply need to fix the missing check there. There is already a
> flag SLAB_DEBUG_FREE for the pointer checks.
>
>

The patch improves performance but the overall performance of these full
sanitization patches is still significantly better than slub_debug=P. I'll
put some effort into seeing if I can figure out where the slow down is
coming from.

Thanks,
Laura

>
> Subject: slub: Only perform pointer checks in check_object when SLAB_DEBUG_FREE is set
>
> Seems that check_object() always checks for pointer issues currently.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
>
> Index: linux/mm/slub.c
> ===================================================================
> --- linux.orig/mm/slub.c
> +++ linux/mm/slub.c
> @@ -848,6 +848,9 @@ static int check_object(struct kmem_cach
>   		 */
>   		return 1;
>
> +	if (!(s->flags & SLAB_DEBUG_FREE))
> +		return 1;
> +
>   	/* Check free pointer validity */
>   	if (!check_valid_pointer(s, page, get_freepointer(s, p))) {
>   		object_err(s, page, p, "Freepointer corrupt");
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
