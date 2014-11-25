Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id AF5C56B0069
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 10:00:08 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id r20so9443114wiv.0
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 07:00:08 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gp6si3532677wib.41.2014.11.25.07.00.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 07:00:07 -0800 (PST)
Date: Tue, 25 Nov 2014 16:00:06 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
Message-ID: <20141125150006.GB4415@dhcp22.suse.cz>
References: <CALYGNiOHXvyqr3+Jq5FsZ_xscsXwrQ_9YCtL2819i6iRkgms2w@mail.gmail.com>
 <546CC0CD.40906@suse.cz>
 <CALYGNiO9_bAVVZ2GdFq=PO2yV3LPs2utsbcb2pFby7MypptLCw@mail.gmail.com>
 <CANN689G+y77m2_paF0vBpHG8EsJ2-pEnJvLJSGs-zHf+SqTEjQ@mail.gmail.com>
 <CALYGNiOC4dEzzVzSQXGC4oxLbgp=8TC=A+duJs67jT97TWQ++g@mail.gmail.com>
 <546DFFA1.4030700@redhat.com>
 <CALYGNiP_zqAucmN=Gn75Mm2wK1iE6fPNxTsaTRgnUbFbFE7C-g@mail.gmail.com>
 <CALYGNiO9NSpCFcRezArgfqzLQcTx2DnFYWYgpyK2HFyCnuGLOA@mail.gmail.com>
 <20141125105953.GC4607@dhcp22.suse.cz>
 <CALYGNiPZmf4Y1_vX_FaiALKp-BPvct7fAiaPEjnDGnVx9paS9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiPZmf4Y1_vX_FaiALKp-BPvct7fAiaPEjnDGnVx9paS9w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>

On Tue 25-11-14 16:13:16, Konstantin Khlebnikov wrote:
> On Tue, Nov 25, 2014 at 1:59 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Mon 24-11-14 11:09:40, Konstantin Khlebnikov wrote:
> >> On Thu, Nov 20, 2014 at 6:03 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> >> > On Thu, Nov 20, 2014 at 5:50 PM, Rik van Riel <riel@redhat.com> wrote:
> >> >> -----BEGIN PGP SIGNED MESSAGE-----
> >> >> Hash: SHA1
> >> >>
> >> >> On 11/20/2014 09:42 AM, Konstantin Khlebnikov wrote:
> >> >>
> >> >>> I'm thinking about limitation for reusing anon_vmas which might
> >> >>> increase performance without breaking asymptotic estimation of
> >> >>> count anon_vma in the worst case. For example this heuristic: allow
> >> >>> to reuse only anon_vma with single direct descendant. It seems
> >> >>> there will be arount up to two times more anon_vmas but
> >> >>> false-aliasing must be much lower.
> >>
> >> Done. RFC patch in attachment.
> >
> > This is triggering BUG_ON(anon_vma->degree); in unlink_anon_vmas. I have
> > applied the patch on top of 3.18.0-rc6.
> 
> It seems I've screwed up with counter if anon_vma is merged in anon_vma_prepare.
> Increment must be in the next if block:
> 
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -182,8 +182,6 @@ int anon_vma_prepare(struct vm_area_struct *vma)
>                         if (unlikely(!anon_vma))
>                                 goto out_enomem_free_avc;
>                         allocated = anon_vma;
> -                       /* Bump degree, root anon_vma is its own parent. */
> -                       anon_vma->degree++;
>                 }
> 
>                 anon_vma_lock_write(anon_vma);
> @@ -192,6 +190,7 @@ int anon_vma_prepare(struct vm_area_struct *vma)
>                 if (likely(!vma->anon_vma)) {
>                         vma->anon_vma = anon_vma;
>                         anon_vma_chain_link(vma, avc, anon_vma);
> +                       anon_vma->degree++;
>                         allocated = NULL;
>                         avc = NULL;
>                 }
> 
> I've tested it with trinity but probably isn't long enough.

OK, this has passed few runs with the original reproducer:
$ date +%s; grep anon_vma /proc/slabinfo;
$ ./vma_chain_repro
$ sleep 1h
$ date +%s; grep anon_vma /proc/slabinfo
$ killall vma_chain_repro
$ date +%s; grep anon_vma /proc/slabinfo
1416923468
anon_vma           11523  11523    176   23    1 : tunables    0    0    0 : slabdata    501    501      0
1416927070
anon_vma           11477  11477    176   23    1 : tunables    0    0    0 : slabdata    499    499      0
1416927070
anon_vma           11127  11431    176   23    1 : tunables    0    0    0 : slabdata    497    497      0

anon_vmas do not seem to leak anymore. I have forwarded the patch to the
customer who was complaining about NSD but I guess it will take some
time to get the confirmation.

Anyway thanks a lot for your help and feel free to add
Tested-by: Michal Hocko <mhocko@suse.cz>

I have yet to look deeper into the code to give you my Reviewed-by.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
