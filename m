Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f179.google.com (mail-qc0-f179.google.com [209.85.216.179])
	by kanga.kvack.org (Postfix) with ESMTP id 89C1B6B0080
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 18:14:17 -0500 (EST)
Received: by mail-qc0-f179.google.com with SMTP id c9so1273051qcz.38
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 15:14:17 -0800 (PST)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com. [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id 67si891678qgx.12.2014.11.19.15.14.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Nov 2014 15:14:16 -0800 (PST)
Received: by mail-qa0-f49.google.com with SMTP id s7so1152125qap.8
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 15:14:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALYGNiO9_bAVVZ2GdFq=PO2yV3LPs2utsbcb2pFby7MypptLCw@mail.gmail.com>
References: <502D42E5.7090403@redhat.com>
	<20120818000312.GA4262@evergreen.ssec.wisc.edu>
	<502F100A.1080401@redhat.com>
	<alpine.LSU.2.00.1208200032450.24855@eggly.anvils>
	<CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
	<20120822032057.GA30871@google.com>
	<50345232.4090002@redhat.com>
	<20130603195003.GA31275@evergreen.ssec.wisc.edu>
	<20141114163053.GA6547@cosmos.ssec.wisc.edu>
	<20141117160212.b86d031e1870601240b0131d@linux-foundation.org>
	<20141118014135.GA17252@cosmos.ssec.wisc.edu>
	<546AB1F5.6030306@redhat.com>
	<20141118121936.07b02545a0684b2cc839a10c@linux-foundation.org>
	<CALYGNiMxnxmy-LyJ4OT9OoFeKwTPPkZMF-bJ-eJDBFXgZQ6AEA@mail.gmail.com>
	<CALYGNiM_CsjjiK_36JGirZT8rTP+ROYcH0CSyZjghtSNDU8ptw@mail.gmail.com>
	<546BDB29.9050403@suse.cz>
	<CALYGNiOHXvyqr3+Jq5FsZ_xscsXwrQ_9YCtL2819i6iRkgms2w@mail.gmail.com>
	<546CC0CD.40906@suse.cz>
	<CALYGNiO9_bAVVZ2GdFq=PO2yV3LPs2utsbcb2pFby7MypptLCw@mail.gmail.com>
Date: Wed, 19 Nov 2014 15:14:15 -0800
Message-ID: <CANN689G+y77m2_paF0vBpHG8EsJ2-pEnJvLJSGs-zHf+SqTEjQ@mail.gmail.com>
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>, Michal Hocko <mhocko@suse.cz>

On Wed, Nov 19, 2014 at 8:58 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> On Wed, Nov 19, 2014 at 7:09 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> Also from reading http://lwn.net/Articles/383162/ I understand that correctness
>> also depends on the hierarchy and I wonder if there's a danger of reintroducing
>> a bug like the one described there.
>
> If I remember right that was fixed by linking non-exclusively mapped pages to
> root anon_vma instead of anon_vma from vma where fault has happened.
> After my patch this still works. Topology hierarchy actually isn't used.
> Here just one selected "root' anon_vma which dies last. That's all.

That's not how I remember it.

An anon_vma corresponds to a given vma V, and is used to track all
vmas (V and descendant vmas) that may include a page that was
originally mapped in V.

Each anon page has a link to the anon_vma corresponding to the vma
they were originally faulted in, and an offset indicating where the
page was located relative to that original VMA.

The anon_vma has an interval tree of struct anon_vma_chain, and each
struct anon_vma_chain includes a link to a descendent-of-V vma. This
allows rmap to quickly find all the vmas that may map a given page
(based on the page's anon_vma and offset).

When forking or splitting vmas, the new vma is a descendent of the
same vmas as the old one so it must be added to all the anon_vma
interval trees that were referencing the old one (that is, ancestors
of the new vma). To that end, all the struct anon_vma_chain pointing
to a given vma are kept on a linked list, and struct anon_vma_chain
includes a link to the anon_vma holding the interval tree.

Locking the entire structure is done with a single lock hosted in the
root anon_vma (that is, a vma that was created by mmap() and not by
cloning or forking existing vmas).

Limit the length of the ancestors linked list is correct, though it
has performance implications. In the extreme case, forcing all vmas to
be added on the root vma's interval tree would be correct, though it
may re-introduce the performance problems that lead to the
introduction of anon_vma.

The good thing about Konstantin's proposal is that it does not have
any magic constant like mine did. However, I think he is mistaken in
saying that hierarchy isn't used - an ancestor vma will always have
more descendents than its children, and the reason for the hierarchy
is to limit the number of vmas that rmap must explore.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
