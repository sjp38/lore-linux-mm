Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 105946B007E
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 22:59:43 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b203so118795567pfb.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 19:59:43 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id h85si7473444pfj.72.2016.04.27.19.59.42
        for <linux-mm@kvack.org>;
        Wed, 27 Apr 2016 19:59:42 -0700 (PDT)
From: "Li, Liang Z" <liang.z.li@intel.com>
Subject: RE: post-copy is broken?
Date: Thu, 28 Apr 2016 02:59:38 +0000
Message-ID: <F2CBF3009FA73547804AE4C663CAB28E041877A3@shsmsx102.ccr.corp.intel.com>
References: <20160414162230.GC9976@redhat.com>
 <20160415125236.GA3376@node.shutemov.name> <20160415134233.GG2229@work-vm>
 <20160415152330.GB3376@node.shutemov.name> <20160415163448.GJ2229@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E04181101@shsmsx102.ccr.corp.intel.com>
 <20160418095528.GD2222@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E0418115C@shsmsx102.ccr.corp.intel.com>
 <20160418101555.GE2222@work-vm>
 <F2CBF3009FA73547804AE4C663CAB28E041813A6@shsmsx102.ccr.corp.intel.com>
 <20160427144739.GF10120@redhat.com>
In-Reply-To: <20160427144739.GF10120@redhat.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, Amit Shah <amit.shah@redhat.com>, "qemu-devel@nongnu.org" <qemu-devel@nongnu.org>, "quintela@redhat.com" <quintela@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> -----Original Message-----
> From: Andrea Arcangeli [mailto:aarcange@redhat.com]
> Sent: Wednesday, April 27, 2016 10:48 PM
> To: Li, Liang Z
> Cc: Dr. David Alan Gilbert; Kirill A. Shutemov; kirill.shutemov@linux.int=
el.com;
> Amit Shah; qemu-devel@nongnu.org; quintela@redhat.com; linux-
> mm@kvack.org
> Subject: Re: post-copy is broken?
>=20
> Hello Liang,
>=20
> On Mon, Apr 18, 2016 at 10:33:14AM +0000, Li, Liang Z wrote:
> > If the THP is disabled, no fails.
> > And your test was always passed, even when  real post-copy was failed.
> >
> > In my env, the output of
> > 'cat /sys/kernel/mm/transparent_hugepage/enabled'  is:
> >
> >  [always] ...
> >
>=20
> Can you test the fix?
> https://marc.info/?l=3Dlinux-mm&m=3D146175869123580&w=3D2
>=20
> This was not a breakage in userfaultfd nor in postcopy. userfaultfd had n=
o
> bugs and is fully rock solid and with zero chances of generating undetect=
ed
> memory corruption like it was happening in v4.5.
>=20
> As I suspected, the same problem would have happened with any THP
> pmd_trans_huge split (swapping/inflating-balloon etc..). Postcopy just
> makes it easier to reproduce the problem because it does a scattered
> MADV_DONTNEED on the destination qemu guest memory for the pages
> redirtied during the last precopy pass that run, or not transferred (to a=
llow
> THP faults in destination qemu during precopy), just before starting the
> guest in the destination node.
>=20
> Other reports of KVM memory corruption happening on v4.5 with THP
> enabled will also be taken care of by the above fix.
>=20
> I hope I managed to fix this in time for v4.6 final (current is v4.6-rc5-=
69), so
> the only kernel where KVM must not be used with THP enabled will be v4.5.
>=20
> On a side note, this MADV_DONTEED trigger reminded me as soon as the
> madvisev syscall is merged, loadvm_postcopy_ram_handle_discard should
> start using it to reduce the enter/exit kernel to just 1 (or a few madvis=
ev in
> case we want to give a limit to the temporary buffer to avoid the risk of
> allocating too much temporary RAM for very large
> guests) to do the MADV_DONTNEED scattered zapping. Same thing in
> virtio_balloon_handle_output.
>=20

I have test the patch, guest doesn't crash anymore, I think the issue is fi=
xed. Thanks!

Liang
> Thanks,
> Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
