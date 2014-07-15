Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id A71B06B0035
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 05:46:11 -0400 (EDT)
Received: by mail-ig0-f170.google.com with SMTP id h3so2625995igd.5
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 02:46:11 -0700 (PDT)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id c3si14450337igv.49.2014.07.15.02.46.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 02:46:11 -0700 (PDT)
Received: by mail-ie0-f173.google.com with SMTP id tr6so4345937ieb.18
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 02:46:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53C4F5A9.6030202@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1404905415-9046-21-git-send-email-a.ryabinin@samsung.com>
 <20140715061219.GK11317@js1304-P5Q-DELUXE> <53C4F5A9.6030202@samsung.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 15 Jul 2014 13:45:50 +0400
Message-ID: <CACT4Y+YHEvCb35YN6OO_Vgs17UFfF0D3B45JBMqnG-k6Wf_sXg@mail.gmail.com>
Subject: Re: [RFC/PATCH RESEND -next 20/21] fs: dcache: manually unpoison
 dname after allocation to shut up kasan's reports
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org

On Tue, Jul 15, 2014 at 1:34 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> On 07/15/14 10:12, Joonsoo Kim wrote:
>> On Wed, Jul 09, 2014 at 03:30:14PM +0400, Andrey Ryabinin wrote:
>>> We need to manually unpoison rounded up allocation size for dname
>>> to avoid kasan's reports in __d_lookup_rcu.
>>> __d_lookup_rcu may validly read a little beyound allocated size.
>>
>> If it read a little beyond allocated size, IMHO, it is better to
>> allocate correct size.
>>
>> kmalloc(name->len + 1, GFP_KERNEL); -->
>> kmalloc(roundup(name->len + 1, sizeof(unsigned long ), GFP_KERNEL);
>>
>> Isn't it?
>>
>
> It's not needed here because kmalloc always roundup allocation size.
>
> This out of bound access happens in dentry_string_cmp() if CONFIG_DCACHE_WORD_ACCESS=y.
> dentry_string_cmp() relays on fact that kmalloc always round up allocation size,
> in other words it's by design.
>
> That was discussed some time ago here - https://lkml.org/lkml/2013/10/3/493.
> Since filesystem's maintainer don't want to add needless round up here, I'm not going to do it.
>
> I think this patch needs only more detailed description why we not simply allocate more.
> Also I think it would be better to rename unpoisoin_shadow to something like kasan_mark_allocated().


Note that this poison/unpoison functionality can be used in other
contexts. E.g. when you allocate a bunch of pages, then at some point
poison a part of it to ensure that nobody touches it, then unpoison it
back. Allocated/unallocated looks like a bad fit here, because it has
nothing to do with allocation state. Poison/unpoison is also what we
use in user-space.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
