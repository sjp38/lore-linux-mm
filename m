Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0583E6B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 15:02:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k18-v6so8613798wrn.8
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 12:02:42 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id g61-v6si1399806ede.420.2018.06.04.12.02.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jun 2018 12:02:41 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w54Iwkjf065104
	for <linux-mm@kvack.org>; Mon, 4 Jun 2018 15:02:39 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2jd9c7cpmt-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 04 Jun 2018 15:02:39 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Mon, 4 Jun 2018 20:02:37 +0100
Date: Mon, 4 Jun 2018 12:02:29 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys on POWER: Access rights not reset on execve
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180519202747.GK5479@ram.oc3035372033.ibm.com>
 <CALCETrVz9otkOQAxVkz6HtuMwjAeY6mMuLgFK_o0M0kbkUznwg@mail.gmail.com>
 <20180520060425.GL5479@ram.oc3035372033.ibm.com>
 <CALCETrVvQkphypn10A_rkX35DNqi29MJcXYRpRiCFNm02VYz2g@mail.gmail.com>
 <20180520191115.GM5479@ram.oc3035372033.ibm.com>
 <aae1952c-886b-cfc8-e98b-fa3be5fab0fa@redhat.com>
 <20180603201832.GA10109@ram.oc3035372033.ibm.com>
 <4e53b91f-80a7-816a-3e9b-56d7be7cd092@redhat.com>
 <20180604140135.GA10088@ram.oc3035372033.ibm.com>
 <f2f61c24-8e8f-0d36-4e22-196a2a3f7ca7@redhat.com>
In-Reply-To: <f2f61c24-8e8f-0d36-4e22-196a2a3f7ca7@redhat.com>
Message-Id: <20180604190229.GB10088@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: Quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>, Linux-MM <linux-mm@kvack.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Dave Hansen <dave.hansen@intel.com>

On Mon, Jun 04, 2018 at 07:57:46PM +0200, Florian Weimer wrote:
> On 06/04/2018 04:01 PM, Ram Pai wrote:
> >On Mon, Jun 04, 2018 at 12:12:07PM +0200, Florian Weimer wrote:
> >>On 06/03/2018 10:18 PM, Ram Pai wrote:
> >>>On Mon, May 21, 2018 at 01:29:11PM +0200, Florian Weimer wrote:
> >>>>On 05/20/2018 09:11 PM, Ram Pai wrote:
> >>>>>Florian,
> >>>>>
> >>>>>	Does the following patch fix the problem for you?  Just like x86
> >>>>>	I am enabling all keys in the UAMOR register during
> >>>>>	initialization itself. Hence any key created by any thread at
> >>>>>	any time, will get activated on all threads. So any thread
> >>>>>	can change the permission on that key. Smoke tested it
> >>>>>	with your test program.
> >>>>
> >>>>I think this goes in the right direction, but the AMR value after
> >>>>fork is still strange:
> >>>>
> >>>>AMR (PID 34912): 0x0000000000000000
> >>>>AMR after fork (PID 34913): 0x0000000000000000
> >>>>AMR (PID 34913): 0x0000000000000000
> >>>>Allocated key in subprocess (PID 34913): 2
> >>>>Allocated key (PID 34912): 2
> >>>>Setting AMR: 0xffffffffffffffff
> >>>>New AMR value (PID 34912): 0x0fffffffffffffff
> >>>>About to call execl (PID 34912) ...
> >>>>AMR (PID 34912): 0x0fffffffffffffff
> >>>>AMR after fork (PID 34914): 0x0000000000000003
> >>>>AMR (PID 34914): 0x0000000000000003
> >>>>Allocated key in subprocess (PID 34914): 2
> >>>>Allocated key (PID 34912): 2
> >>>>Setting AMR: 0xffffffffffffffff
> >>>>New AMR value (PID 34912): 0x0fffffffffffffff
> >>>>
> >>>>I mean this line:
> >>>>
> >>>>AMR after fork (PID 34914): 0x0000000000000003
> >>>>
> >>>>Shouldn't it be the same as in the parent process?
> >>>
> >>>Fixed it. Please try this patch. If it all works to your satisfaction,=
 I
> >>>will clean it up further and send to Michael Ellermen(ppc maintainer).
> >>>
> >>>
> >>>commit 51f4208ed5baeab1edb9b0f8b68d7144449b3527
> >>>Author: Ram Pai <linuxram@us.ibm.com>
> >>>Date:   Sun Jun 3 14:44:32 2018 -0500
> >>>
> >>>     Fix for the fork bug.
> >>>     Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> >>
> >>Is this on top of the previous patch, or a separate fix?
> >
> >top of previous patch.
>=20
> Thanks.  With this patch, I get this on an LPAR:
>=20
> AMR (PID 1876): 0x0000000000000003
> AMR after fork (PID 1877): 0x0000000000000003
> AMR (PID 1877): 0x0000000000000003
> Allocated key in subprocess (PID 1877): 2
> Allocated key (PID 1876): 2
> Setting AMR: 0xffffffffffffffff
> New AMR value (PID 1876): 0x0fffffffffffffff
> About to call execl (PID 1876) ...
> AMR (PID 1876): 0x0000000000000003
> AMR after fork (PID 1878): 0x0000000000000003
> AMR (PID 1878): 0x0000000000000003
> Allocated key in subprocess (PID 1878): 2
> Allocated key (PID 1876): 2
> Setting AMR: 0xffffffffffffffff
> New AMR value (PID 1876): 0x0fffffffffffffff
>=20
> Test program is still this one:
>=20
> <https://lists.ozlabs.org/pipermail/linuxppc-dev/2018-May/173198.html>
>=20
> So the process starts out with a different AMR value for some
> reason. That could be a pre-existing bug that was just hidden by the
> reset-to-zero on fork, or it could be intentional.  But the kernel

yes it is a bug, a patch for which is lined up for submission..

The fix is


commit eaf5b2ac002ad2f5bca118d7ce075ce28311aa8e
Author: Ram Pai <linuxram@us.ibm.com>
Date:   Mon Jun 4 10:58:44 2018 -0500

    powerpc/pkeys: fix total pkeys calculation
=20=20=20=20
    Total number of pkeys calculation is off by 1. Fix it.
=20=20=20=20
    Signed-off-by: Ram Pai <linuxram@us.ibm.com>

diff --git a/arch/powerpc/mm/pkeys.c b/arch/powerpc/mm/pkeys.c
index 4530cdf..3384c4e 100644
--- a/arch/powerpc/mm/pkeys.c
+++ b/arch/powerpc/mm/pkeys.c
@@ -93,7 +93,7 @@ int pkey_initialize(void)
 	 * arch-neutral code.
 	 */
 	pkeys_total =3D min_t(int, pkeys_total,
-			(ARCH_VM_PKEY_FLAGS >> VM_PKEY_SHIFT));
+			((ARCH_VM_PKEY_FLAGS >> VM_PKEY_SHIFT)+1));
=20
 	if (!pkey_mmu_enabled() || radix_enabled() || !pkeys_total)
 		static_branch_enable(&pkey_disabled);
