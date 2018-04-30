Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 319326B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 03:51:21 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b192so3067814wmb.1
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 00:51:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d18-v6si1197854edj.187.2018.04.30.00.51.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 00:51:19 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3U7iEtA072699
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 03:51:18 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hnxw10kh7-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 03:51:18 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Mon, 30 Apr 2018 08:51:16 +0100
Date: Mon, 30 Apr 2018 00:51:06 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH 4/9] x86, pkeys: override pkey when moving away from
 PROT_EXEC
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180326172721.D5B2CBB4@viggo.jf.intel.com>
 <20180326172727.025EBF16@viggo.jf.intel.com>
 <20180407000943.GA15890@ram.oc3035372033.ibm.com>
 <6e3f8e1c-afed-64de-9815-8478e18532aa@intel.com>
 <20180407010919.GB15890@ram.oc3035372033.ibm.com>
 <aedcb0b6-73f5-f72f-742e-b417131895d3@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aedcb0b6-73f5-f72f-742e-b417131895d3@intel.com>
Message-Id: <20180430075106.GA5666@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, shakeelb@google.com, stable@kernel.org, tglx@linutronix.de, mpe@ellerman.id.au, mingo@kernel.org, akpm@linux-foundation.org, shuah@kernel.org

On Thu, Apr 26, 2018 at 10:57:31AM -0700, Dave Hansen wrote:
> On 04/06/2018 06:09 PM, Ram Pai wrote:
> > Well :). my point is add this code and delete the other
> > code that you add later in that function.
> 
> I don't think I'm understanding what your suggestion was.  I looked at
> the code and I honestly do not think I can remove any of it.
> 
> For the plain (non-explicit pkey_mprotect()) case, there are exactly
> four paths through __arch_override_mprotect_pkey(), resulting in three
> different results.
> 
> 1. New prot==PROT_EXEC, no pkey-exec support -> do not override
> 2. New prot!=PROT_EXEC, old VMA not PROT_EXEC-> do not override
> 3. New prot==PROT_EXEC, w/ pkey-exec support -> override to exec pkey
> 4. New prot!=PROT_EXEC, old VMA is PROT_EXEC -> override to default
> 
> I don't see any redundancy there, or any code that we can eliminate or
> simplify.  It was simpler before, but that's what where bug was.

Your code is fine.  But than the following code accomplishes the same
outcome; arguably with a one line change. Its not a big deal. Just
trying to clarify my comment.

int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot, int pkey)
{
	/*
	 * Is this an mprotect_pkey() call?  If so, never
	 * override the value that came from the user.
	 */
	if (pkey != -1)
		return pkey;
	/*
	 * Look for a protection-key-drive execute-only mapping
	 * which is now being given permissions that are not
	 * execute-only.  Move it back to the default pkey.
	 */
	if (vma_is_pkey_exec_only(vma) && (prot != PROT_EXEC)) <--------
		return ARCH_DEFAULT_PKEY;

	/*
	 * The mapping is execute-only.  Go try to get the
	 * execute-only protection key.  If we fail to do that,
	 * fall through as if we do not have execute-only
	 * support.
	 */
	if (prot == PROT_EXEC) {
		pkey = execute_only_pkey(vma->vm_mm);
		if (pkey > 0)
			return pkey;
	}
	/*
	 * This is a vanilla, non-pkey mprotect (or we failed to
	 * setup execute-only), inherit the pkey from the VMA we
	 * are working on.
	 */
	return vma_pkey(vma);
}

-- 
Ram Pai
