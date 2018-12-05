Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4CA4B6B7636
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 15:36:30 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i14so10313583edf.17
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 12:36:30 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a1si5697137edj.47.2018.12.05.12.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 12:36:28 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB5KTVk1032216
	for <linux-mm@kvack.org>; Wed, 5 Dec 2018 15:36:27 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p6knfejvx-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Dec 2018 15:36:27 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Wed, 5 Dec 2018 20:36:25 -0000
Date: Wed, 5 Dec 2018 12:36:17 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys: Reserve PKEY_DISABLE_READ
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20181108201231.GE5481@ram.oc3035372033.ibm.com>
 <87bm6z71yw.fsf@oldenburg.str.redhat.com>
 <20181109180947.GF5481@ram.oc3035372033.ibm.com>
 <87efbqqze4.fsf@oldenburg.str.redhat.com>
 <20181127102350.GA5795@ram.oc3035372033.ibm.com>
 <87zhtuhgx0.fsf@oldenburg.str.redhat.com>
 <58e263a6-9a93-46d6-c5f9-59973064d55e@intel.com>
 <87va4g5d3o.fsf@oldenburg.str.redhat.com>
 <20181203040249.GA11930@ram.oc3035372033.ibm.com>
 <CALCETrXeSQ8T9nvK7WpgPpkraLfg70FoDWvPZeLS3KiDaqXwtw@mail.gmail.com>
MIME-Version: 1.0
In-Reply-To: <CALCETrXeSQ8T9nvK7WpgPpkraLfg70FoDWvPZeLS3KiDaqXwtw@mail.gmail.com>
Message-Id: <20181205203617.GF11930@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Florian Weimer <fweimer@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>

On Wed, Dec 05, 2018 at 08:21:02AM -0800, Andy Lutomirski wrote:
> > On Dec 2, 2018, at 8:02 PM, Ram Pai <linuxram@us.ibm.com> wrote:
> >
> >> On Thu, Nov 29, 2018 at 12:37:15PM +0100, Florian Weimer wrote:
> >> * Dave Hansen:
> >>
> >>>> On 11/27/18 3:57 AM, Florian Weimer wrote:
> >>>> I would have expected something that translates PKEY_DISABLE_WRITE |
> >>>> PKEY_DISABLE_READ into PKEY_DISABLE_ACCESS, and also accepts
> >>>> PKEY_DISABLE_ACCESS | PKEY_DISABLE_READ, for consistency with POWER.
> >>>>
> >>>> (My understanding is that PKEY_DISABLE_ACCESS does not disable all
> >>>> access, but produces execute-only memory.)
> >>>
> >>> Correct, it disables all data access, but not execution.
> >>
> >> So I would expect something like this (completely untested, I did not
> >> even compile this):
> >
> >
> > Ok. I re-read through the entire email thread to understand the problem and
> > the proposed solution. Let me summarize it below. Lets see if we are on the same
> > plate.
> >
> > So the problem is as follows:
> >
> > Currently the kernel supports  'disable-write'  and 'disable-access'.
> >
> > On x86, cpu supports 'disable-write' and 'disable-access'. This
> > matches with what the kernel supports. All good.
> >
> > However on power, cpu supports 'disable-read' too. Since userspace can
> > program the cpu directly, userspace has the ability to set
> > 'disable-read' too.  This can lead to inconsistency between the kernel
> > and the userspace.
> >
> > We want the kernel to match userspace on all architectures.
> >
> > Proposed Solution:
> >
> > Enhance the kernel to understand 'disable-read', and facilitate architectures
> > that understand 'disable-read' to allow it.
> >
> > Also explicitly define the semantics of disable-access  as
> > 'disable-read and disable-write'
> >
> > Did I get this right?  Assuming I did, the implementation has to do
> > the following --
> >
> >    On power, sys_pkey_alloc() should succeed if the init_val
> >    is PKEY_DISABLE_READ, PKEY_DISABLE_WRITE, PKEY_DISABLE_ACCESS
> >    or any combination of the three.
> >
> >    On x86, sys_pkey_alloc() should succeed if the init_val is
> >    PKEY_DISABLE_WRITE or PKEY_DISABLE_ACCESS or PKEY_DISABLE_READ
> >    or any combination of the three, except  PKEY_DISABLE_READ
> >          specified all by itself.
> >
> >    On all other arches, none of the flags are supported.
> 
> I don’t really love having a situation where you can use different
> flag combinations to refer to the same mode.

true. But it is a side-effect of x86 cpu implicitly defining
'disable-access' as a combination of 'disable-read' and 'disable_write'.
In other words, if you disable-access on a pte on x86, you are
automatically disabling read and disabling write on that page.
The software/kernel just happens to explicitly capture that implicit
behavior.

> 
> Also, we should document the effect these flags have on execute permission.

Actually none of the above flags, interact with execute permission. They
operate independently; both on x86 and on POWER.  But yes, this
statement needs to be documented somewhere.

RP
