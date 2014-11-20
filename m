Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id AC6506B0070
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 09:42:04 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id hi2so5574495wib.17
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 06:42:04 -0800 (PST)
Received: from mail-wg0-x234.google.com (mail-wg0-x234.google.com. [2a00:1450:400c:c00::234])
        by mx.google.com with ESMTPS id db3si7641519wib.3.2014.11.20.06.42.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 06:42:03 -0800 (PST)
Received: by mail-wg0-f52.google.com with SMTP id a1so3895208wgh.25
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 06:42:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANN689G+y77m2_paF0vBpHG8EsJ2-pEnJvLJSGs-zHf+SqTEjQ@mail.gmail.com>
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
	<CANN689G+y77m2_paF0vBpHG8EsJ2-pEnJvLJSGs-zHf+SqTEjQ@mail.gmail.com>
Date: Thu, 20 Nov 2014 18:42:03 +0400
Message-ID: <CALYGNiOC4dEzzVzSQXGC4oxLbgp=8TC=A+duJs67jT97TWQ++g@mail.gmail.com>
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>, Michal Hocko <mhocko@suse.cz>

On Thu, Nov 20, 2014 at 2:14 AM, Michel Lespinasse <walken@google.com> wrote:
> On Wed, Nov 19, 2014 at 8:58 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>> On Wed, Nov 19, 2014 at 7:09 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>>> Also from reading http://lwn.net/Articles/383162/ I understand that correctness
>>> also depends on the hierarchy and I wonder if there's a danger of reintroducing
>>> a bug like the one described there.
>>
>> If I remember right that was fixed by linking non-exclusively mapped pages to
>> root anon_vma instead of anon_vma from vma where fault has happened.
>> After my patch this still works. Topology hierarchy actually isn't used.
>> Here just one selected "root' anon_vma which dies last. That's all.
>
> That's not how I remember it.

??? That at the end of lwn article:

[quote]
The fix is straightforward; when linking an existing page to an
anon_vma structure,
the kernel needs to pick the one which is highest in the process hierarchy;
that guarantees that the anon_vma will not go away prematurely.
[/quote]

nowdays this happens in __page_set_anon_rmap():

/*
* If the page isn't exclusively mapped into this vma,
* we must use the _oldest_ possible anon_vma for the
* page mapping!
*/
if (!exclusive)
    anon_vma = anon_vma->root;

The rest treeish of topology affects only performance.

>
> An anon_vma corresponds to a given vma V, and is used to track all
> vmas (V and descendant vmas) that may include a page that was
> originally mapped in V.
>
> Each anon page has a link to the anon_vma corresponding to the vma
> they were originally faulted in, and an offset indicating where the
> page was located relative to that original VMA.
>
> The anon_vma has an interval tree of struct anon_vma_chain, and each
> struct anon_vma_chain includes a link to a descendent-of-V vma. This
> allows rmap to quickly find all the vmas that may map a given page
> (based on the page's anon_vma and offset).
>
> When forking or splitting vmas, the new vma is a descendent of the
> same vmas as the old one so it must be added to all the anon_vma
> interval trees that were referencing the old one (that is, ancestors
> of the new vma). To that end, all the struct anon_vma_chain pointing
> to a given vma are kept on a linked list, and struct anon_vma_chain
> includes a link to the anon_vma holding the interval tree.
>
> Locking the entire structure is done with a single lock hosted in the
> root anon_vma (that is, a vma that was created by mmap() and not by
> cloning or forking existing vmas).
>
> Limit the length of the ancestors linked list is correct, though it
> has performance implications. In the extreme case, forcing all vmas to
> be added on the root vma's interval tree would be correct, though it
> may re-introduce the performance problems that lead to the
> introduction of anon_vma.
>
> The good thing about Konstantin's proposal is that it does not have
> any magic constant like mine did. However, I think he is mistaken in
> saying that hierarchy isn't used - an ancestor vma will always have
> more descendents than its children, and the reason for the hierarchy
> is to limit the number of vmas that rmap must explore.

I mean after breaking hierarchy whole structure stays correct and kernel
wouldn't explode, of course reusing anon_vma from ancestor makes
rmap walk less effective because newly allocated pages will get false
aliased vmas where they will never be mapped.


I'm thinking about limitation for reusing anon_vmas which might increase
performance without breaking asymptotic estimation of count anon_vma in
the worst case. For example this heuristic: allow to reuse only anon_vma
with single direct descendant. It seems there will be arount up to two times
more anon_vmas but false-aliasing must be much lower.



>
> --
> Michel "Walken" Lespinasse
> A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
