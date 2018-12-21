Return-Path: <SRS0=s2+Z=O6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B52D5C43387
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 17:12:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66C4E21917
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 17:12:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="j0ZOzJzU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66C4E21917
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA8548E0005; Fri, 21 Dec 2018 12:12:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E58D68E0001; Fri, 21 Dec 2018 12:12:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D219C8E0005; Fri, 21 Dec 2018 12:12:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9318C8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 12:12:38 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id b17so5478259pfc.11
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:12:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=xQhRj9iYI7mYkuS4/q+tuuSBNRB+e2fXSmyuUTFvmE4=;
        b=OhKj4qcQGnywZOcH6YqFwqHekOJwsBCg211X+AwETxIzgA+tsgxFq7gP/j3W2+mxR7
         XZpIDTtp75Y+1kBehn9N8DC/FcRFSPBRtBGVKLRcRtnbXDyPuobT+hGXJrUHRGNkek6J
         P0J5ejTi3LC0HRLFxhNVXsj3DZ/JyFfRTscmxNf9I7zTPdeOaQsq0PDDs+5klle1p+vK
         /QgfRqVbIefg0qwagoRPe4C/wgt+pjYkJWBUaVgWL7eFFGqhcGrpkq5FwRHCPh5E6Vyb
         a4chbQiEBBHQbpQ+Lelk5cAo4e/pnsvw4k+VTaS+2CSh+paMvcHDlZt0q647cQaJ42DT
         R4dg==
X-Gm-Message-State: AJcUukczubW497cAhAlzeYJB12aQQORzPhqGFzZ3pkTY2euYJnMGl6Db
	jeI6kRwker+/x8rlJygKMh0vXO5o0Zyaf5h28SEMx4CWo+AaEMA1tLXyPbHAKsOp2ixntyaX+La
	w68oK4t9zELnpYM/IXjJpXfLmGrHseEnGrH0BV2JBGKbEP9jNuCi2n9AnH/t6b0SctQ==
X-Received: by 2002:a17:902:9045:: with SMTP id w5mr3229618plz.32.1545412358233;
        Fri, 21 Dec 2018 09:12:38 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5lD0znuMEpwgrQMhhNkwnN9ihsRFBVytrKu0fh/sWH//zTW7WXyAOj+/WaIHmyF+JGKJpT
X-Received: by 2002:a17:902:9045:: with SMTP id w5mr3229559plz.32.1545412357208;
        Fri, 21 Dec 2018 09:12:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545412357; cv=none;
        d=google.com; s=arc-20160816;
        b=YnZoaHyCCD5iN9iDhwAFaOzT2rQbQ18J2BranZqly0lm+rwMFWUtCwO111ZRWc0O/q
         uPN/b1/jTopduoloaBL/IIRfuEiC2xqQRccF5CdkN938yWLqRQPmWYFY80vULnF6SmPS
         ek8aEP7jwtXyJgJ3L/2Sfcxw1MHcM1E+i2Gf+BX6NRhkq/u40qbgQho0iWjIhQtjbxZN
         E0FraHJ0PKqiXeDQ2mhE+2J182nbSfXFmyPT/zCQMcJBKFobIr29SDnpQfKChmfQdn0B
         HlVWk/4pStwCpy8ZL6oFek6xiUGV9q3GGqji7qTtT+Np6GAP3mKlmykcWMA0qdZ+y+Vk
         H8jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=xQhRj9iYI7mYkuS4/q+tuuSBNRB+e2fXSmyuUTFvmE4=;
        b=qtK/H6ZjqU+EN27a/BynmiHzGMp7uGrNb8dbNDvi6pyoNvZ938/mGUP2+wRTEBFFru
         6JBL+1bAWPD5Bz2KSF2Ndb3PpaLxhrnx4tULqXCiUXtSClkNa1FLmB65hipjo6RCFjDd
         ui2j/QPTWFUJFOvE/CdcXHzVcHLaZ8cuRzhDvfXRXEtTR3y+pF+124HHW+pXDf6BciEF
         i1pgzy4hsU74AJadueQi4fSLwM2IJimSv9i2dD6HZRhfN/4/D/ij9zBpmhIdyS8M+TNH
         9PvL8PlQtGBb9tykcdW1GIhr4zqsmIzZi/lc/pN/h/rGM9OWWrUdR1wfGsEp/rlyznVp
         D9Gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=j0ZOzJzU;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z123si9862265pfc.97.2018.12.21.09.12.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Dec 2018 09:12:37 -0800 (PST)
Received-SPF: pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=j0ZOzJzU;
       spf=pass (google.com: domain of luto@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=luto@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-wm1-f42.google.com (mail-wm1-f42.google.com [209.85.128.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 90E3E2192C
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 17:12:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1545412356;
	bh=AC3N5cPmiWWCoi55jyxZG7SDG+N0rDbDxh2J62m/Kd4=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc:From;
	b=j0ZOzJzUwQGJViXlXiGXzuLtogRDNIDIMf3u7tuc7oxXVJOLWwDevwoJzWOjy/xdM
	 +TI7ZZr3ZIkIpEDRUI6ycSepBJdHrvB/I277GFpcIkaRLZQCOZvL34SPcfBGgXorCq
	 wZTy/0xtBYw2wROx9hSzaQbzXbXR3cZHvJ9Wsi+w=
Received: by mail-wm1-f42.google.com with SMTP id b11so5980351wmj.1
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:12:36 -0800 (PST)
X-Received: by 2002:a7b:c7c7:: with SMTP id z7mr3851149wmk.74.1545412354958;
 Fri, 21 Dec 2018 09:12:34 -0800 (PST)
MIME-Version: 1.0
References: <20181212000354.31955-1-rick.p.edgecombe@intel.com>
 <20181212000354.31955-2-rick.p.edgecombe@intel.com> <CALCETrVP577NvdeYj8bzpEfTXj3GZD3nFcJxnUq5n1daDBxU=g@mail.gmail.com>
 <CAKv+Gu_kunBqhUAQt6==SN-ei4Xc+z6=Z=pKXHHJYjk4Gdw73g@mail.gmail.com>
In-Reply-To: <CAKv+Gu_kunBqhUAQt6==SN-ei4Xc+z6=Z=pKXHHJYjk4Gdw73g@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 21 Dec 2018 09:12:23 -0800
X-Gmail-Original-Message-ID: <CALCETrWScgJpdnzNswJSKioQ93Oyw+Y_dJLoRxPX2Z=REVV1Ug@mail.gmail.com>
Message-ID:
 <CALCETrWScgJpdnzNswJSKioQ93Oyw+Y_dJLoRxPX2Z=REVV1Ug@mail.gmail.com>
Subject: Re: [PATCH v2 1/4] vmalloc: New flags for safe vfree on special perms
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Andy Lutomirski <luto@kernel.org>, Rick Edgecombe <rick.p.edgecombe@intel.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, 
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>, 
	"Naveen N . Rao" <naveen.n.rao@linux.vnet.ibm.com>, 
	Anil S Keshavamurthy <anil.s.keshavamurthy@intel.com>, "David S. Miller" <davem@davemloft.net>, 
	Masami Hiramatsu <mhiramat@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, 
	Ingo Molnar <mingo@redhat.com>, Alexei Starovoitov <ast@kernel.org>, 
	Daniel Borkmann <daniel@iogearbox.net>, Jessica Yu <jeyu@kernel.org>, Nadav Amit <namit@vmware.com>, 
	Network Development <netdev@vger.kernel.org>, Jann Horn <jannh@google.com>, 
	Kristen Carlson Accardi <kristen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, 
	"Dock, Deneen T" <deneen.t.dock@intel.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181221171223.vMeac6_fjkE28rUT5jS15ywSeLLo_rjJgL4NvH_vbpU@z>

> On Dec 21, 2018, at 9:39 AM, Ard Biesheuvel <ard.biesheuvel@linaro.org> w=
rote:
>
>> On Wed, 12 Dec 2018 at 03:20, Andy Lutomirski <luto@kernel.org> wrote:
>>
>> On Tue, Dec 11, 2018 at 4:12 PM Rick Edgecombe
>> <rick.p.edgecombe@intel.com> wrote:
>>>
>>> This adds two new flags VM_IMMEDIATE_UNMAP and VM_HAS_SPECIAL_PERMS, fo=
r
>>> enabling vfree operations to immediately clear executable TLB entries t=
o freed
>>> pages, and handle freeing memory with special permissions.
>>>
>>> In order to support vfree being called on memory that might be RO, the =
vfree
>>> deferred list node is moved to a kmalloc allocated struct, from where i=
t is
>>> today, reusing the allocation being freed.
>>>
>>> arch_vunmap is a new __weak function that implements the actual unmappi=
ng and
>>> resetting of the direct map permissions. It can be overridden by more e=
fficient
>>> architecture specific implementations.
>>>
>>> For the default implementation, it uses architecture agnostic methods w=
hich are
>>> equivalent to what most usages do before calling vfree. So now it is ju=
st
>>> centralized here.
>>>
>>> This implementation derives from two sketches from Dave Hansen and Andy
>>> Lutomirski.
>>>
>>> Suggested-by: Dave Hansen <dave.hansen@intel.com>
>>> Suggested-by: Andy Lutomirski <luto@kernel.org>
>>> Suggested-by: Will Deacon <will.deacon@arm.com>
>>> Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
>>> ---
>>> include/linux/vmalloc.h |  2 ++
>>> mm/vmalloc.c            | 73 +++++++++++++++++++++++++++++++++++++----
>>> 2 files changed, 69 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
>>> index 398e9c95cd61..872bcde17aca 100644
>>> --- a/include/linux/vmalloc.h
>>> +++ b/include/linux/vmalloc.h
>>> @@ -21,6 +21,8 @@ struct notifier_block;                /* in notifier.=
h */
>>> #define VM_UNINITIALIZED       0x00000020      /* vm_struct is not full=
y initialized */
>>> #define VM_NO_GUARD            0x00000040      /* don't add guard page =
*/
>>> #define VM_KASAN               0x00000080      /* has allocated kasan s=
hadow memory */
>>> +#define VM_IMMEDIATE_UNMAP     0x00000200      /* flush before releasi=
ng pages */
>>> +#define VM_HAS_SPECIAL_PERMS   0x00000400      /* may be freed with sp=
ecial perms */
>>> /* bits [20..32] reserved for arch specific ioremap internals */
>>>
>>> /*
>>> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>>> index 97d4b25d0373..02b284d2245a 100644
>>> --- a/mm/vmalloc.c
>>> +++ b/mm/vmalloc.c
>>> @@ -18,6 +18,7 @@
>>> #include <linux/interrupt.h>
>>> #include <linux/proc_fs.h>
>>> #include <linux/seq_file.h>
>>> +#include <linux/set_memory.h>
>>> #include <linux/debugobjects.h>
>>> #include <linux/kallsyms.h>
>>> #include <linux/list.h>
>>> @@ -38,6 +39,11 @@
>>>
>>> #include "internal.h"
>>>
>>> +struct vfree_work {
>>> +       struct llist_node node;
>>> +       void *addr;
>>> +};
>>> +
>>> struct vfree_deferred {
>>>        struct llist_head list;
>>>        struct work_struct wq;
>>> @@ -50,9 +56,13 @@ static void free_work(struct work_struct *w)
>>> {
>>>        struct vfree_deferred *p =3D container_of(w, struct vfree_deferr=
ed, wq);
>>>        struct llist_node *t, *llnode;
>>> +       struct vfree_work *cur;
>>>
>>> -       llist_for_each_safe(llnode, t, llist_del_all(&p->list))
>>> -               __vunmap((void *)llnode, 1);
>>> +       llist_for_each_safe(llnode, t, llist_del_all(&p->list)) {
>>> +               cur =3D container_of(llnode, struct vfree_work, node);
>>> +               __vunmap(cur->addr, 1);
>>> +               kfree(cur);
>>> +       }
>>> }
>>>
>>> /*** Page table manipulation functions ***/
>>> @@ -1494,6 +1504,48 @@ struct vm_struct *remove_vm_area(const void *add=
r)
>>>        return NULL;
>>> }
>>>
>>> +/*
>>> + * This function handles unmapping and resetting the direct map as eff=
iciently
>>> + * as it can with cross arch functions. The three categories of archit=
ectures
>>> + * are:
>>> + *   1. Architectures with no set_memory implementations and no direct=
 map
>>> + *      permissions.
>>> + *   2. Architectures with set_memory implementations but no direct ma=
p
>>> + *      permissions
>>> + *   3. Architectures with set_memory implementations and direct map p=
ermissions
>>> + */
>>> +void __weak arch_vunmap(struct vm_struct *area, int deallocate_pages)
>>
>> My general preference is to avoid __weak functions -- they don't
>> optimize well.  Instead, I prefer either:
>>
>> #ifndef arch_vunmap
>> void arch_vunmap(...);
>> #endif
>>
>> or
>>
>> #ifdef CONFIG_HAVE_ARCH_VUNMAP
>> ...
>> #endif
>>
>>
>>> +{
>>> +       unsigned long addr =3D (unsigned long)area->addr;
>>> +       int immediate =3D area->flags & VM_IMMEDIATE_UNMAP;
>>> +       int special =3D area->flags & VM_HAS_SPECIAL_PERMS;
>>> +
>>> +       /*
>>> +        * In case of 2 and 3, use this general way of resetting the pe=
rmissions
>>> +        * on the directmap. Do NX before RW, in case of X, so there is=
 no W^X
>>> +        * violation window.
>>> +        *
>>> +        * For case 1 these will be noops.
>>> +        */
>>> +       if (immediate)
>>> +               set_memory_nx(addr, area->nr_pages);
>>> +       if (deallocate_pages && special)
>>> +               set_memory_rw(addr, area->nr_pages);
>>
>> Can you elaborate on the intent here?  VM_IMMEDIATE_UNMAP means "I
>> want that alias gone before any deallocation happens".
>> VM_HAS_SPECIAL_PERMS means "I mucked with the direct map -- fix it for
>> me, please".  deallocate means "this was vfree -- please free the
>> pages".  I'm not convinced that all the various combinations make
>> sense.  Do we really need both flags?
>>
>> (VM_IMMEDIATE_UNMAP is a bit of a lie, since, if in_interrupt(), it's
>> not immediate.)
>>
>> If we do keep both flags, maybe some restructuring would make sense,
>> like this, perhaps.  Sorry about horrible whitespace damage.
>>
>> if (special) {
>>  /* VM_HAS_SPECIAL_PERMS makes little sense without deallocate_pages. */
>>  WARN_ON_ONCE(!deallocate_pages);
>>
>>  if (immediate) {
>>    /* It's possible that the vmap alias is X and we're about to make
>> the direct map RW.  To avoid a window where executable memory is
>> writable, first mark the vmap alias NX.  This is silly, since we're
>> about to *unmap* it, but this is the best we can do if all we have to
>> work with is the set_memory_abc() APIs.  Architectures should override
>> this whole function to get better behavior. */
>
> So can't we fix this first? Assuming that architectures that bother to
> implement them will not have executable mappings in the linear region,
> all we'd need is set_linear_range_ro/rw() routines that default to
> doing nothing, and encapsulate the existing code for x86 and arm64.
> That way, we can handle do things in the proper order, i.e., release
> the vmalloc mapping (without caring about the permissions), restore
> the linear alias attributes, and finally release the pages.

Seems reasonable, except that I think it should be
set_linear_range_not_present() and set_linear_range_rw(), for three
reasons:

1. It=E2=80=99s not at all clear to me that we need to keep the linear mapp=
ing
around for modules.

2. At least on x86, the obvious algorithm to do the free operation
with a single flush requires it.  Someone should probably confirm that
arm=E2=80=99s TLB works the same way, i.e. that no flush is needed when
changing from not-present (or whatever ARM calls it) to RW.

3. Anyone playing with XPFO wants this facility anyway.  In fact, with
this change, Rick=E2=80=99s series will more or less implement XPFO for
vmalloc memory :)

Does that seem reasonable to you?

