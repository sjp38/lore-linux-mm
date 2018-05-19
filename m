Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B83E6B06D7
	for <linux-mm@kvack.org>; Sat, 19 May 2018 16:28:01 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k27-v6so8017228wre.23
        for <linux-mm@kvack.org>; Sat, 19 May 2018 13:28:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a3-v6si9785598wrn.5.2018.05.19.13.27.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 May 2018 13:27:59 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w4JKOBvX090105
	for <linux-mm@kvack.org>; Sat, 19 May 2018 16:27:58 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2j2fx2cafe-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 19 May 2018 16:27:57 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Sat, 19 May 2018 21:27:56 +0100
Date: Sat, 19 May 2018 13:27:47 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: pkeys on POWER: Access rights not reset on execve
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <53828769-23c4-b2e3-cf59-239936819c3e@redhat.com>
 <20180519011947.GJ5479@ram.oc3035372033.ibm.com>
 <CALCETrWMP9kTmAFCR0WHR3YP93gLSzgxhfnb0ma_0q=PCuSdQA@mail.gmail.com>
MIME-Version: 1.0
In-Reply-To: <CALCETrWMP9kTmAFCR0WHR3YP93gLSzgxhfnb0ma_0q=PCuSdQA@mail.gmail.com>
Message-Id: <20180519202747.GK5479@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Florian Weimer <fweimer@redhat.com>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, Linux-MM <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>

On Fri, May 18, 2018 at 06:50:39PM -0700, Andy Lutomirski wrote:
> On Fri, May 18, 2018 at 6:19 PM Ram Pai <linuxram@us.ibm.com> wrote:
> 
> > However the fundamental issue is still the same, as mentioned in the
> > other thread.
> 
> > "Should the permissions on a key be allowed to be changed, if the key
> > is not allocated in the first place?".
> 
> > my answer is NO. Lets debate :)
> 
> As a preface, here's my two-minute attempt to understand POWER's behavior:
> there are two registers, AMR and UAMR.  AMR contains both kernel-relevant
> state and user-relevant state.  UAMR specifies which bits of AMR are
> available for user code to directly access.  AMR bits outside UAMR are read
> as zero and are unaffected by writes.  I'm assuming that the kernel
> reserves some subset of AMR bits in advance to correspond to allocatable
> pkeys.


You got it mostly right. Filling in some more details below for
completeness.

Yes there is a AMR register which has two bits each corresponding to
each key.  One bit corresponds to read permission, and the other bit
corresponds to write permission.  If set, the corresponding permission
is denied.  Both userspace and kernel can modify the register.

Yes there is a UAMOR register which has a bit corresponding to each key.
When a bit in UAMOR register is set, that key's permission can be
changed by userspace. Only kernel can modify UAMOR register.

for example, if bit 10 is set in UAMOR register, only then key-10's read-write
permissions can be modified by userspace.

NOTE: the UAMR register you mention above, is actually UAMOR register. 

And finally the kernel reserves some subset of keys, in advance, that
it wants for itself. It will never give away those keys to userspace
through sys_pkey_alloc(), and the bits corresponding to those keys will
be 0 in UAMOR register.

> 
> Here's my question: given that disallowed AMR bits are read-as-zero, there
> can always be a thread that is in the middle of a sequence like:
> 
> step1 : unsigned long old = amr;
> step2 : amr |= whatever;
> step3 : ...  <- thread is here
> step4 : amr = old;
> 
> Now another thread calls pkey_alloc(), so UAMR is asynchronously changed,
> and the thread will write zero to the relevant AMR bits. 

> If I understand
> correctly, this means that the decision to mask off unallocated keys via
> UAMR effectively forces the initial value of newly-allocated keys in other
> threads in the allocating process to be zero, whatever zero means.

The initial value of the newly allocated key will be whatever the
init_value is, that is specified in the sys_pkey_alloc().

Remember, the UAMOR and the AMR values are thread specific. If thread T2
allocates a new key, then that thread will enable the bit in its version
of the UAMOR register. It will not have any effect on the UAMOR value of
any other threads's version.

So in the above code snippet, assuming T1 is executing the code, and T2 is
running parallely, and assume that both threads have the same AMR and
UAMOR value till the end of step2.  At step 3, when T2 allocates a new
key,  thread T2's UAMOR will enable the bit corresponding to the
allocated key and set the corresponding bits in AMR to the init_val
specified in sys_pkey_alloc(). It has no effect on thread T1's UAMOR or
AMR register.

> (I
> didn't get far enough in the POWER docs to figure out what zero means.).

ok.

> So
> I don't think you're doing anyone any favors by making UAMR dynamic.

depending on the explaination above, do you continue to hold that opinion?

> 
> IOW both x86 and POWER screwed up the ISA.

-- 
Ram Pai
